# `Collection<T>`

A **collection** is a class that contains the DataStore, and exposes methods to interact with it.

## `Collection:Select()`

=== "Luau"
    ```luau
    Collection:Select(
        key: string
    ): (T, Error?)
    ```

=== "TypeScript"
    ```ts
    public function Select(
        key: string
    ): [T, Error | undefined];
    ```

**Parameters:**

- `key` [`string`](https://www.lua.org/pil/2.4.html) — Unique key for the requested data.

**Returns:**

- [`T`](https://luau.org/types/generics/) — Found value in the DataStore, or [`CollectionOptions.Default`](./collection-options.md#default) if an error occurs.
- [`Error?`](./error.md#error) — An error value or [`nil`](https://www.lua.org/pil/2.1.html) if succeeded.

**Description:**

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
    ): Error?
    ```

=== "TypeScript"
    ```ts
    public function Update(
        key: string,
        data: T,
        userIds: number[]
    ): Error | undefined;
    ```

**Parameters:**

- `key` [`string`](https://www.lua.org/pil/2.4.html) — Unique key for the requested data.

**Returns:**

- [`Error?`](./error.md#error) — An error value or [`nil`](https://www.lua.org/pil/2.1.html) if succeeded.

**Description:**

- Uses [`CollectionOptions.Validate`](collection-options.md#validate) function to validate the given data. Rejects the update if the given data has failed validation.
- Uses [`DataStore:UpdateAsync()`](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore#GetAsync) to fetch the data from the DataStore, reject the new update if [`DataStore`](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore) contains a newer version, and set the new value if it has verified that it's newer.
    - Retries [`CollectionOptions.MaxRetries`](collection-options.md#maxretries) times with a [`CollectionOptions.RetryDelaySeconds`](collection-options.md#retrydelayseconds) delay if the [`pcall()`](https://www.lua.org/pil/8.4.html) has resulted in a failure.
