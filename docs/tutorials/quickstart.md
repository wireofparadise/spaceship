# Quickstart

1. Follow the [installation tutorial](./installation.md) to install Spaceship.

2. Create a [`Collection`](../api-reference/collection.md):

    === "Luau"
        ```luau
        local Players = game:GetService("Players")
        local RunService = game:GetService("RunService")
        local Spaceship = require(game.ReplicatedStorage.Packages.Spaceship)
        local t = require(game.ReplicatedStorage.Packages.t)
        
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
        import { Players, RunService } from "@rbxts/services";
        import { Spaceship } from "@rbxts/spaceship";
        import { t } from "@rbxts/t";

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

3. Load data when player joins:
   
    === "Luau"
        ```luau
        local loadedData: { [Player]: PlayerSave } = {}

        Players.PlayerAdded:Connect(function(player)
            local save, err := collection:Select(tostring(player.UserId))

            if not Players:GetPlayerByUserId(player.UserId) then
                warn("early-exit: " .. player.Name)
                return
            end

            if err then
                warn(err.Message)
                player:Kick("Failed to load your data")
                return
            end

            loadedData[player] = save
        end)
        ```

    === "TypeScript"
        ```ts
        const loadedData = new Map<Player, PlayerSave>();

        Players.PlayerAdded.Connect((player) => {
            const [save, err] := collection.Select(tostring(player.UserId));

            if (!Players.GetPlayerByUserId(player.UserId)) {
                warn("early-exit: " + player.Name);
                return;
            }

            if (err) {
                warn(err.Message);
                player.Kick("Failed to load your data");
                return;
            }

            loadedData.set(player, save);
        });
        ```

4. Save data when player leaves:
   
    === "Luau"
        ```luau
        local function savePlayer(player: Player)
            local save = loadedData[player]
            if not save then
                warn(string.format("data is not loaded, player=%s", player.Name))
                return
            end

            local err = collection:Update(tostring(player.UserId), save, { player.UserId })
            if err then
                warn(err.Message)
            end
        end

        Players.PlayerRemoving:Connect(savePlayer)
        ```

    === "TypeScript"
        ```ts
        function savePlayer(player: Player) {
            const save = loadedData.get(player);
            if (!save) {
                warn(`data is not loaded, player=${player.Name}`);
                return;
            }

            const err = collection.Update(tostring(player.UserId), save, [player.UserId]);
            if (err) {
                warn(err.Message);
            }
        }

        Players.PlayerRemoving.Connect(savePlayer)
        ```

5. Save data when server shuts down:

    === "Luau"
        ```luau
        game:BindToClose(function()
            for _, player in pairs(Players:GetPlayers()) do
                savePlayer(player)
            end
        end)
        ```

    === "TypeScript"
        ```ts
        game.BindToClose(() => {
            for (const player of Players.GetPlayers()) {
                savePlayer(player);
            }
        });
        ```
