local DataStoreService = game:GetService("DataStoreService")
local Table = require(script.Parent.Table)
local Types = require(script.Parent.Types)

local Collection = {} :: Types.CollectionClass<any>
Collection.__index = Collection

function Collection.new<T>(options: Types.CollectionOptions<T>): Types.Collection<T>
	local self = setmetatable({}, Collection)

	options = table.freeze(Table.DeepCopy(options))
	self.__default = options.Default
	self.__dataStore = DataStoreService:GetDataStore(options.Name, options.Scope)
	self.__migrations = options.Migrations or table.freeze({})
	self.__validate = options.Validate
	self.__scope = options.Scope or "global"
	self.__maxRetries = options.MaxRetries or 3
	self.__retryDelaySeconds = options.RetryDelaySeconds or 2

	return self :: any
end

function Collection:Select(key: string)
	local data = nil
	local keyInfo: DataStoreKeyInfo? = nil
	local latestVersion = #self.__migrations

	local success: boolean
	local err: string
	for retry = 1, self.__maxRetries do
		success, err = pcall(function()
			data, keyInfo = self.__dataStore:GetAsync(key)
		end)

		if success then
			break
		end

		self:Warn(string.format("failed to select key %s (%d/%d tries): %s", key, retry, self.__maxRetries, err))

		if retry < self.__maxRetries then
			task.wait(self.__retryDelaySeconds)
		end
	end

	if not success then
		self:Warn(string.format("failed to select key %s: %s", key, err))
		return
	end

	if not data or not keyInfo then
		data = self.__default
		self:Log(string.format("key %s does not exist yet, using default schema", key))
	end

	if keyInfo then
		local savedVersion = keyInfo:GetMetadata().version or 0

		if savedVersion ~= latestVersion then
			for i = savedVersion + 1, latestVersion do
				local migrate = self.__migrations[i]

				if not migrate then
					self:Warn(string.format("missing migration %d for key %s", i, key))
					return
				end

				data = migrate(Table.DeepCopy(data))
			end

			self:Log(string.format("migrated key %s from version %d to %d", key, savedVersion, latestVersion))
		end
	end

	if not self.__validate(data) then
		self:Warn(string.format("validation for key %s has failed", key))
		return
	end

	self:Log(string.format("loaded key %s", key))

	return data
end

function Collection:Update(key: string, data: any, userIds: { number }?)
	if not self.__validate(data) then
		self:Warn(string.format("validation for key %s has failed", key))
		return false
	end

	local now = os.time()

	local aborted = false
	local success: boolean
	local err: string
	for retry = 1, self.__maxRetries do
		success, err = pcall(function()
			self.__dataStore:UpdateAsync(key, function(_, keyInfo: DataStoreKeyInfo?)
				if keyInfo and keyInfo.UpdatedTime > now * 1000 then
					self:Warn(
						string.format("aborted saving key %s: a newer version is already stored in the data store", key)
					)
					aborted = true
					return
				end

				local newUserIds = Table.DeepCopy(userIds)

				if not newUserIds and keyInfo then
					newUserIds = keyInfo:GetUserIds()
				end

				return data, newUserIds, {
					version = #self.__migrations,
				}
			end)
		end)

		if success or aborted then
			break
		end

		self:Warn(string.format("failed to update key %s (%d/%d tries): %s", key, retry, self.__maxRetries, err))

		if retry < self.__maxRetries then
			task.wait(self.__retryDelaySeconds)
		end
	end

	if aborted then
		return false
	end

	if not success then
		self:Warn(string.format("failed to update key %s: %s", key, err))
		return false
	end

	self:Log(string.format("updated key %s", key))

	return true
end

function Collection:Log(message: string)
	print(string.format("Collection(%s/%s): %s", self.__dataStore.Name, self.__scope, message))
end

function Collection:Warn(message: string)
	warn(string.format("Collection(%s/%s): %s", self.__dataStore.Name, self.__scope, message))
end

return Collection
