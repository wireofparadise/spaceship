local Collection = require(script.Collection)
local Errors = require(script.Errors)
local Interfaces = require(script.Interfaces)

local Spaceship = {}

export type Collection<T> = Interfaces.ICollection<T>
export type CollectionOptions<T> = Collection.Options<T>
export type SchemaValidator<T> = Collection.SchemaValidator<T>
export type SchemaMigrations = Collection.SchemaMigrations
export type Error = Errors.Error

Spaceship.ErrorKind = Errors.ErrorKind

function Spaceship.CreateCollection<T>(options: CollectionOptions<T>): Collection<T>
	return Collection.new(options)
end

return Spaceship
