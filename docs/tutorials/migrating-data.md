# Migrating data

## What is migration?

Migration is a process of updating your data structure to a newer version.

For example, you have published your game, and stored 1,000 different keys in your DataStore but suddenly, you want to update your game. A problem arises: the data that is saved in your DataStore is already following a certain structure, and if you change how you access data in your code, some old values are going to be lost forever. Your solution is writing a migration. In Spaceship, a migration is simply a function that receives old data as an argument and returns new data.

## How to write a migration?

Assuming that you have followed the [quickstart tutorial](./quickstart.md), you should have a collection somewhat similar to this:

=== "Luau"
    ```luau
    type PlayerSave = {
        Coins: number,
    }

    local collection: Spaceship.Collection<PlayerSave> = Spaceship.CreateCollection({
        Name = "PlayerSaves",
        Default = {
            Coins = 0,
        },
        Validate = t.strictInterface({
            Coins = t.number,
        }),
    })
    ```

=== "TypeScript"
    ```ts
    interface PlayerSave {
        Coins: number;
    }

    const collection = Spaceship.CreateCollection<PlayerSave>({
        Name: "PlayerSaves",
        Default: {
            Coins: 0,
        },
        Validate: t.strictInterface({
            Coins: t.number,
        }),
    })
    ```

Migrating data is really simple in Spaceship. You have to update your type, default schema, valdiation logic and add a transformation function to the [`Migrations`](../api-reference/collection-options.md#migrations) array.

!!! danger "Migrations"
    Migrations should never change once you've published them. Any changes to existing migration functions may result in data loss.

=== "Luau"
    ```luau
    type PlayerSave = {
        Coins: number,
        XP: number,
    }

    local collection: Spaceship.Collection<PlayerSave> = Spaceship.CreateCollection({
        Name = "PlayerSaves",
        Default = {
            Coins = 0,
            XP = 0,
        },
        Validate = t.strictInterface({
            Coins = t.number,
            XP = t.number,
        }),
        Migrations = {
            function(old)
                return {
                    Coins = old.Coins,
                    XP = 0,
                }
            end
        }
    })
    ```

=== "TypeScript"
    ```ts
    interface PlayerSave {
        Coins: number;
        XP: number;
    }

    const collection = Spaceship.CreateCollection<PlayerSave>({
        Name: "PlayerSaves",
        Default: {
            Coins: 0,
            XP: 0,
        },
        Validate: t.strictInterface({
            Coins: t.number,
            XP: t.number,
        }),
        Migrations: [
            (old) => ({
                Coins: old.Coins,
                XP: 0,
            })
        ]
    })
    ```

That's it! Spaceship assigns a certain version to every piece of saved data, and tracks new versions internally, based on the length of your migrations array.
