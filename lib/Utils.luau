local Utils = {}

function Utils.deepCopy(t: any)
	if type(t) ~= "table" then
		return t
	end

	local copy = {}

	for k, v in pairs(t) do
		copy[k] = Utils.deepCopy(v)
	end

	return setmetatable(copy, getmetatable(t))
end

return Utils
