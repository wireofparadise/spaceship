local Utils = {}

function Utils.DeepCopy(t: any)
	if type(t) ~= "table" then
		return t
	end

	local copy = {}

	for k, v in pairs(t) do
		copy[k] = Utils.DeepCopy(v)
	end

	return setmetatable(copy, getmetatable(t))
end

return Utils
