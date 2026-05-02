# Getting started

To get started with Spaceship, we are going to write a simple [`Colletion`](../api-reference/collection.md) that loads and saves player data.

## Loading player data

First, we have to create our collection.

I name it `PlayerSaves`, and determine the [`CollectionOptions.Scope`](../api-reference/collection-options.md#scope) based on the current environment. I use `studio` for testing sessions inside Roblox Studio, and `global` for the live roblox game.

!!! tip "Luau types"
    You may notice that I also declare my own type, and use it to define the `playerSaves` variable. I recommend this to everyone that uses Spaceship to get static linter hints, and autocomplete.

I also define the [`CollectionOptions.Default`](../api-reference/collection-options.md#default) schema and [`CollectionOptions.Validate`](../api-reference/collection-options.md#validate) function for validating our data.

=== "Luau"

    ```luau
    local RunService = game:GetService("RunService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Spaceship = require(ReplicatedStorage.Packages.Spaceship)
    local t = require(ReplicatedStorage.Packages.t)

    export type PlayerSaveData = {
        Level: number,
    }

    local playerSaves: Spaceship.Collection<PlayerSaveData> = Spaceship.CreateCollection({
        Name = "PlayerSaves",
        Scope = RunService:IsStudio() and "studio" or "global",
        Default = {
            Level = 1
        },
        Validate = t.strictInterface({
            Level = t.number
        })
    })
    ```

=== "TypeScript"

    ```ts
    import { RunService } from "@rbxts/services";
    import { Spaceship } from "@rbxts/spaceship";
    import { t } from "@rbxts/t";

    export interface PlayerSaveData {
        level: number;
    }

    const playerSaves = Spaceship.CreateCollection<PlayerSaveData>({
        Name: "PlayerSaves",
        Scope: RunService.IsStudio() ? "studio" : "global",
        Default: {
            level: 1,
        },
        Validate: t.strictInterface({
            level: t.number,
        }),
    });
    ```

After that, we want to store a map indexed by the [`Player`](https://create.roblox.com/docs/reference/engine/classes/Player), that points to cached `PlayerSaveData` records.

=== "Luau"

    ```luau
    -- ...

    local loadedPlayerSaves: { [Player]: PlayerSaveData } = {}

    -- ...
    ```

=== "TypeScript"

    ```ts
    // ...

    const loadedPlayerSaves = new Map<Player, PlayerSaveData>();

    // ...
    ```

Now, let's populate this map when the player connects to the server:

=== "Luau"

    ```luau
    -- ...
    local Players = game:GetService("Players")

    -- ...

    local function getUniquePlayerKey(player: Player): string
        return tostring(player.UserId)
    end

    Players.PlayerAdded:Connect(function(player)
        local saveData = playerSaves:Select(getUniquePlayerKey(player))
        if not saveData then
            -- Failed to select/migrate/validate
            return
        end

        loadedPlayerSaves[player] = saveData
    end)
    ```

=== "TypeScript"

    ```ts
    // ...
    import { Players } from "@rbxts/services";

    // ...

    function getUniquePlayerKey(player: Player): string {
        return tostring(player.UserId);
    }

    Players.PlayerAdded.Connect((player) => {
        const saveData = playerSaves.Select(getUniquePlayerKey(player));
        if (!saveData) {
            // Failed to select/migrate/validate
            return;
        }

        loadedPlayerSaves.set(player, saveData);
    });
    ```

We also need to handle failures. Spaceship is going to retry fetching the data 3 times by default, you may configure this using [`CollectionOptions.MaxRetries`](../api-reference/collection-options.md#maxretries).

I recommend kicking players if the data fails to load, this prevents data loss, and if everything is set-up correctly, this should never happen.

=== "Luau"

    ```luau
    -- ...

    if not saveData then
        player:Kick("Failed to load your data, please contact support.")
        return
    end

    -- ...
    ```

=== "TypeScript"

    ```ts
    // ...

    if (!saveData) {
        player.Kick("Failed to load your data, please contact support.")
        return;
    }

    // ...
    ```

And now, let's run our game, and check out the output

??? danger "You must publish this place error"
    If you forgot to publish your place, publish it and enable *Studio access to API services* in roblox.

```
21:46:37.414  Collection(PlayerSaves/studio): loaded key 187318421  -  Server - Collection:145
```

Your timestamp and key is going to differ, but if you see the successful *loaded key* log, it worked, and the data is now loaded into the server memory!

## Saving player data

Now, let's say that the player has played the game for a while, it would be a bummer to lose all the progress, so we have to save his data when he leaves, or when the server closes.

Just like with the [`Collection:Select()`](../api-reference/collection.md#collectionselect) method, [`Collection:Update()`](../api-reference/collection.md#collectionupdate) is going to attempt to save the data 3 times by default, and it uses the same [`CollectionOptions.MaxRetries`](../api-reference/collection-options.md#maxretries) value.

Let's implement the saving event.

=== "Luau"

    ```luau
    --- ...

    Players.PlayerRemoving:Connect(function(player)
        local saveData = loadedPlayerSaves[player]
        if not saveData then
            -- Player's save data was never loaded into the server memory
            player:Kick("Your save data is not loaded, please contact support")
            return
        end

        if not playerSaves:Update(getUniquePlayerKey(player), saveData, { player.UserId }) then
            -- Something went wrong here, a more detailed output can be found in the
            -- developer console, this may happen because DataStore is not available,
            -- or save data was corrupted and has failed validation.
        end
    end)
    ```

=== "TypeScript"

    ```ts
    // ...

    Players.PlayerRemoving.Connect((player) => {
        const saveData = loadedPlayerSaves.get(player);
        if (!saveData) {
            // Player's save data was never loaded into the server memory
            player.Kick("Your save data is not loaded, please contact support");
            return;
        }

        if (!playerSaves.Update(getUniquePlayerKey(player), saveData, [player.UserId])) {
            /**
             * Something went wrong here, a more detailed output can be found in the
             * developer console, this may happen because DataStore is not available,
             * or save data was corrupted and has failed validation.
             */
        }
    });
    ```

??? note "Why do I have to pass a table with a [`UserId`](https://create.roblox.com/docs/reference/engine/classes/Player#UserId)?"
    [`DataStore:UpdateAsync()`](https://create.roblox.com/docs/reference/engine/classes/GlobalDataStore#UpdateAsync) accepts a [`table`](https://www.lua.org/pil/2.5.html) with all [`UserId's`](https://create.roblox.com/docs/reference/engine/classes/Player#UserId) to track which user owns which data for GDPR compliance.

Now let's hop in studio, and check our output.

```
21:46:47.300  Collection(PlayerSaves/studio): updated key 187318421  -  Server - Collection:145
```

## Using schema migrations

Now, let's say that your game has recieved a massive update, where the players now also have coins, alongside their levels.

That's sounds cool, until you realize that all your player data is stored on roblox without coins, so you have to manually detect the version and reconcile the table?

The answer is **no**. Spaceship allows you to migrate your schema by simply defining a transform function:

=== "Luau"

    ```luau
    --- ...

    export type PlayerSaveData = {
        Level: number,
        Coins: number -- Added in our new update!
    }

    local playerSaves: Spaceship.Collection<PlayerSaveData> = Spaceship.CreateCollection({
        Name = "PlayerSaves",
        Scope = RunService:IsStudio() and "studio" or "global",
        Default = {
            Level = 1,
            Coins = 0 -- We add a default value for coins, for player's who don't have a key in our datastore yet
        },
        Validate = t.strictInterface({
            Level = t.number,
            Coins = t.number -- We also update the validator to check for coins
        }),
        -- And now we add a transform function that takes old data, and defines the new schema, preserving the old values!
        Migrations = {
            function(old)
                return {
                    Level = old.Level,
                    Coins = 0,
                }
            end
        }
    })
    
    --- ...
    ```

=== "TypeScript"

    ```ts
    // ...
    
    export interface PlayerSaveData {
        level: number;
        coins: number; // Added in our new update!
    }

    const playerSaves = Spaceship.CreateCollection<PlayerSaveData>({
        Name: "PlayerSaves",
        Scope: RunService.IsStudio() ? "studio" : "global",
        Default: {
            level: 1,
            coins: 0, // We add a default value for coins, for player's who don't have a key in our datastore yet
        },
        Validate: t.strictInterface({
            level: t.number,
            coins: t.number, // We also update the validator to check for coins
        }),
        // And now we add a transform function that takes old data, and defines the new schema, preserving the old values!
        Migrations: [
            (old) => ({
                level: old.level,
                coins: 0
            })
        ]
    });

    // ...
    ```

And finally, let's join our game, to see the migration in action:

```
22:07:15.898  Collection(PlayerSaves/studio): migrated key 187318421 from version 0 to 1  -  Server - Collection:145
22:07:15.898  Collection(PlayerSaves/studio): loaded key 187318421  -  Server - Collection:145
```

As you can see, Spaceship has migrated our data successfully!

## Unloading player

When a player disconnects from the server, it's important that we free up the space in our map, to avoid memory being written, and never cleaned up.


=== "Luau"

    ```luau
    --- ...

    Players.PlayerRemoving:Connect(function(player)
        -- ...

        loadedPlayerSaves[player] = nil
    end)
    ```

=== "TypeScript"

    ```ts
    // -...

    Players.PlayerRemoving.Connect((player) => {
        // ...
        
        loadedPlayerSaves.delete(player);
    })
    ```
