export type Error = {
	Kind: number,
	Message: string,
}

local Errors = {}

Errors.ErrorKind = {
	Roblox = 0,
	Validation = 1,
	Migration = 2,
	RaceCondition = 3,
}

function Errors.new(kind: number, message: string): Error
	return {
		Kind = kind,
		Message = message,
	}
end

return Errors
