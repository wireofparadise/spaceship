local DataStoreService = game:GetService("DataStoreService")
local Errors = require(script.Parent.Errors)
local Interfaces = require(script.Parent.Interfaces)
local Utils = require(script.Parent.Utils)

export type SchemaMigrations = { (old: any) -> any }

export type SchemaValidator<T> = (data: T | unknown) -> boolean

export type Options<T> = {
	Name: string,
	Scope: string?,
	Default: T,
	Validate: SchemaValidator<T>,
	Migrations: SchemaMigrations?,
	MaxRetries: number?,
	RetryDelaySeconds: number?,
}

export type Collection<T> = {
	new: (options: Options<T>) -> Collection<T>,

	Name: string,
	Scope: string,
	DefaultSchema: T,
	ValidateSchema: SchemaValidator<T>,
	Migrations: SchemaMigrations,
	MaxRetries: number,
	RetryDelaySeconds: number,
	DataStore: DataStore,
	LatestSchemaVersion: number,

	Select: (self: Collection<T>, key: string) -> (T, Errors.Error?),
	Update: (self: Collection<T>, key: string, data: T, userIds: { number }?) -> Errors.Error?,
}

local Collection = {}

function Collection.new<T>(options: Options<T>): Interfaces.ICollection<T>
	local self: Collection<T> = setmetatable({}, { __index = Collection }) :: any

	self.Name = options.Name
	self.Scope = options.Scope or "global"
	self.DefaultSchema = Utils.DeepCopy(options.Default)
	self.ValidateSchema = options.Validate
	self.Migrations = Utils.DeepCopy(options.Migrations)
	self.MaxRetries = if options.MaxRetries ~= nil then options.MaxRetries else 3
	self.RetryDelaySeconds = if options.RetryDelaySeconds ~= nil then options.RetryDelaySeconds else 2
	self.DataStore = DataStoreService:GetDataStore(self.Name, self.Scope)
	self.LatestSchemaVersion = if self.Migrations then #self.Migrations else 0

	return self
end

function Collection.Select<T>(self: Collection<T>, key: string): (T, Errors.Error?)
	local data = nil
	local keyInfo: DataStoreKeyInfo? = nil

	local success: boolean
	local err: string
	for retry = 1, self.MaxRetries do
		success, err = pcall(function()
			data, keyInfo = self.DataStore:GetAsync(key)
		end)

		if success then
			break
		end

		--self:Warn(string.format("failed to select key %s (%d/%d tries): %s", key, retry, self.__maxRetries, err))

		if retry < self.MaxRetries then
			task.wait(self.RetryDelaySeconds)
		end
	end

	if not success then
		--self:Warn(string.format("failed to select key %s: %s", key, err))
		return self.DefaultSchema, Errors.new(Errors.ErrorKind.Roblox, err)
	end

	if not data or not keyInfo then
		data = self.DefaultSchema
		--self:Log(string.format("key %s does not exist yet, using default schema", key))
	end

	if keyInfo then
		local savedVersion = keyInfo:GetMetadata().version or 0

		if savedVersion ~= self.LatestSchemaVersion then
			for i = savedVersion + 1, self.LatestSchemaVersion do
				local migrate = self.Migrations[i]

				if not migrate then
					return self.DefaultSchema,
						Errors.new(Errors.ErrorKind.Migration, string.format("migration %d does not exist", i))
				end

				data = migrate(Utils.DeepCopy(data))
			end

			--self:Log(string.format("migrated key %s from version %d to %d", key, savedVersion, latestVersion))
		end
	end

	if not self.ValidateSchema(data) then
		return self.DefaultSchema, Errors.new(Errors.ErrorKind.Validation, "invalid schema")
	end

	--self:Log(string.format("loaded key %s", key))

	return data, nil
end

function Collection.Update<T>(self: Collection<T>, key: string, data: any, userIds: { number }?): Errors.Error?
	if not self.ValidateSchema(data) then
		return Errors.new(Errors.ErrorKind.Validation, "invalid schema")
	end

	local now = os.time()

	local success: boolean = false
	local err: string = nil

	for retry = 1, self.MaxRetries do
		local newerVersionTime: number? = nil

		success, err = pcall(function()
			self.DataStore:UpdateAsync(key, function(_, keyInfo: DataStoreKeyInfo?)
				if keyInfo then
					local updatedTime = keyInfo.UpdatedTime / 1000
					if updatedTime > now then
						newerVersionTime = updatedTime
						return
					end
				end

				local newUserIds = if not userIds
					then (if keyInfo then keyInfo:GetUserIds() else nil)
					else Utils.DeepCopy(userIds)

				return data, newUserIds, {
					version = self.LatestSchemaVersion,
				}
			end)
		end)

		if newerVersionTime ~= nil then
			return Errors.new(
				Errors.ErrorKind.RaceCondition,
				string.format("a version that is %d seconds newer was found in the datastore", newerVersionTime - now)
			)
		end

		if success then
			break
		end

		--self:Warn(string.format("failed to update key %s (%d/%d tries): %s", key, retry, self.__maxRetries, err))

		if retry < self.MaxRetries then
			task.wait(self.RetryDelaySeconds)
		end
	end

	if not success then
		return Errors.new(Errors.ErrorKind.Roblox, err)
	end

	--self:Log(string.format("updated key %s", key))

	return
end

return Collection
