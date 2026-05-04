local Errors = require(script.Parent.Errors)

export type ICollection<T> = {
	Select: (self: ICollection<T>, key: string) -> (T, Errors.Error?),
	Update: (self: ICollection<T>, key: string, data: T, userIds: { number }?) -> Errors.Error?,
}

return nil
