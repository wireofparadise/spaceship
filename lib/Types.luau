export type CollectionMigrations = { (old: any) -> any }

export type CollectionValidator<T> = (data: T) -> boolean

export type CollectionOptions<T> = {
	Name: string,
	Default: T,
	Validate: CollectionValidator<T>,
	Scope: string?,
	Migrations: CollectionMigrations?,
	MaxRetries: number?,
	RetryDelaySeconds: number?,
}

export type CollectionClass<T> = {
	__index: CollectionClass<T>,
	new: (options: CollectionOptions<T>) -> Collection<T>,

	__default: T,
	__dataStore: DataStore,
	__validate: CollectionValidator<T>,
	__migrations: CollectionMigrations,
	__scope: string,
	__maxRetries: number,
	__retryDelaySeconds: number,

	Select: (self: Collection<T>, key: string) -> T?,
	Update: (self: Collection<T>, key: string, data: T, userIds: { number }?) -> boolean,

	Log: (self: Collection<T>, message: string) -> (),
	Warn: (self: Collection<T>, message: string) -> (),
}

export type Collection<T> = typeof(setmetatable({} :: CollectionClass<T>, {} :: any))

return nil
