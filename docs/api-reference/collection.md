# `Collection<T>`

A **collection** is a class that contains the DataStore, and exposes methods to interact with it.

## `Collection:Select()`

=== "Luau"
    ```luau
    Collection:Select(
        key: string
    ): T?
    ```

=== "TypeScript"
    ```ts
    public function Select(
        key: string
    ): T | undefined;
    ```

**Parameters:**

- `key` [`string`](https://www.lua.org/pil/2.4.html) — Unique key for the requested data.

**Returns:**

- [`T?`](https://luau.org/types/generics/) — The generic type of the class or [`nil`](https://www.lua.org/pil/2.1.html).

- Uses [`DataStore:GetAsync()`](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore#GetAsync) to fetch the data from the DataStore.
    - Retries [`CollectionOptions.MaxRetries`](collection-options.md#maxretries) times with a [`CollectionOptions.RetryDelaySeconds`](collection-options.md#retrydelayseconds) delay if the [`pcall()`](https://www.lua.org/pil/8.4.html) has resulted in a failure.
- Uses [`CollectionOptions.Default`](collection-options.md#default) to set the default value if the key does not exist yet.
- Uses [`CollectionOptions.Migrations`](collection-options.md#migrations) to migrate data of previous versions.
- Uses [`CollectionOptions.Validate`](collection-options.md#validate) function to validate the data. Forcefully returns [`nil`](https://www.lua.org/pil/2.1.html) if the validation fails.

## `Collection:Update()`

=== "Luau"
    ```luau
    Collection:Update(
        key: string,
        data: T,
        userIds: { number }
    ): boolean
    ```

=== "TypeScript"
    ```ts
    public function Update(
        key: string,
        data: T,
        userIds: number[]
    ): boolean;
    ```

**Parameters:**

- `key` [`string`](https://www.lua.org/pil/2.4.html) — Unique key for the requested data.

**Returns:**

- [`boolean`](https://www.lua.org/pil/2.2.html) — `false` if the update failed, `true` if it has succeeded.

- Uses [`CollectionOptions.Validate`](collection-options.md#validate) function to validate the given data. Rejects the update if the given data has failed validation.
- Uses [`DataStore:UpdateAsync()`](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore#GetAsync) to fetch the data from the DataStore, reject the new update if [`DataStore`](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore) contains a newer version, and set the new value if it has verified that it's newer.
    - Retries [`CollectionOptions.MaxRetries`](collection-options.md#maxretries) times with a [`CollectionOptions.RetryDelaySeconds`](collection-options.md#retrydelayseconds) delay if the [`pcall()`](https://www.lua.org/pil/8.4.html) has resulted in a failure.
