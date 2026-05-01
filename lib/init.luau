local Collection = require(script.Collection)
local Types = require(script.Types)

local Spaceship = {}

export type Collection<T> = Types.Collection<T>

function Spaceship.CreateCollection<T>(options: Types.CollectionOptions<T>)
	return Collection.new(options)
end

return Spaceship
