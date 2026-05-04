# `Error`

## `Kind`

**Type:** [`ErrorKind`](#errorkind)

**Descrption:** Error kind, used to separate different errors to determine how to handle them easier.

**Required:** ✅ yes

## `Message`

**Type:** [`string`](https://www.lua.org/pil/2.4.html)

**Descrption:** Additional message.

**Required:** ✅ yes

# `ErrorKind`

## `Roblox`

This value is used for all errors returned by the [`DataStoreService`](https://create.roblox.com/docs/reference/engine/classes/DataStoreService).

## `Validation`

This value is used for validation failures (invalid data).

## `Migration`

This value is used for migration failures.

## `RaceCondition`

This value is used when the [`DataStore`](https://create.roblox.com/docs/reference/engine/classes/DataStore) has a newer version of the given [`key`](./collection.md#collectionupdate) stored.
