# `CollectionOptions<T>`

## `Name`

**Type:** [`string`](https://www.lua.org/pil/2.4.html)

**Descrption:** The name in the [`DataStore:GetDataStore()`](https://create.roblox.com/docs/reference/engine/classes/DataStoreService#GetDataStore).

**Required:** ✅ yes

## `Scope`

**Type:** [`string`](https://www.lua.org/pil/2.4.html)

**Descrption:** The scope in the [`DataStore:GetDataStore()`](https://create.roblox.com/docs/reference/engine/classes/DataStoreService#GetDataStore).

**Required:** ❌ no

## `Default`

**Type:** [`T`](https://luau.org/types/generics/)

**Descrption:** The default value of a [`DataStore`](https://create.roblox.com/docs/reference/engine/classes/DataStoreService) entry.

**Required:** ✅ yes

## `Validate`

**Type:**

```luau
type CollectionValidator<T> = (data: T) -> boolean
```

**Descrption:** The function that validates given data, should return `true` if validation has succeeded, `false` if failed.

**Required:** ✅ yes

## `Migrations`

**Type:**

```luau
type CollectionMigrations = { (old: any) -> any} 
```

**Descrption:** An array of functions, that should be ordered in the order of data versions, that take in the old data, and return the new structure of the data. Useful for releasing game updates without data loss.

**Required:** ❌ no

!!! danger "Important"
    After a migration has been published, it **should never be changed**. Changes to existing migrations may break older saves.

    To prevent data loss, avoid any changes to the migrations.

## `MaxRetries`

**Type:** [`number`](https://www.lua.org/pil/2.3.html)

**Descrption:** The maximum number of retry attempts that a [`Collection`](collection.md) will perform if an operation fails.

**Required:** ❌ no

**Default:** `3`

## `RetryDelaySeconds`

**Type:** [`number`](https://www.lua.org/pil/2.3.html)

**Descrption:** The delay (in seconds) between each retry attempt when an operation fails.

**Required:** ❌ no

**Default:** `2`
