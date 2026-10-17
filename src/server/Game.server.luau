-- Runewake v0.1 - server-owned RPG progression, quests, portals and attacks.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local CharacterCatalog = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CharacterCatalog"))
local World = require(script.Parent:WaitForChild("World"))
local Enemies = require(script.Parent:WaitForChild("Enemies"))

local remote = ReplicatedStorage:FindFirstChild("RunewakeSignal") or Instance.new("RemoteEvent")
remote.Name = "RunewakeSignal"
remote.Parent = ReplicatedStorage

local world = World.Create()
local store = DataStoreService:GetDataStore("RunewakePlayerV1")
local lastAttack = {}

local function tell(player, message)
    if player and player.Parent == Players then
        remote:FireClient(player, "Notice", message)
    end
end

local function stat(player, name)
    return player:GetAttribute(name) or 0
end

local function addGold(player, amount)
    player:SetAttribute("Gold", math.max(0, stat(player, "Gold") + amount))
end

local function levelThreshold(level)
    return 80 + level * 40
end

local function addExperience(player, amount)
    local xp = stat(player, "XP") + amount
    local level = math.max(1, stat(player, "Level"))
    while xp >= levelThreshold(level) do
        xp -= levelThreshold(level)
        level += 1
        tell(player, string.format("LEVEL UP! You reached level %d. Your health and damage increase!", level))
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.MaxHealth = 100 + 12 * (level - 1)
            hum.Health = hum.MaxHealth
        end
    end
    player:SetAttribute("XP", xp)
    player:SetAttribute("Level", level)
    player:SetAttribute("NextXP", levelThreshold(level))
end

local function save(player)
    local payload = {
        Gold = stat(player, "Gold"),
        Level = stat(player, "Level"),
        XP = stat(player, "XP"),
        WeaponLevel = stat(player, "WeaponLevel"),
        Shards = stat(player, "Shards"),
        WardenCores = stat(player, "WardenCores"),
        Quest = player:GetAttribute("Quest") or "not_started",
    }
    local ok, err = pcall(function()
        store:SetAsync("player_" .. tostring(player.UserId), payload)
    end)
    if not ok then warn("[Runewake] Save issue: " .. tostring(err)) end
end

local function load(player)
    local initial = {
        Gold = 30, Level = 1, XP = 0, WeaponLevel = 0,
        Shards = 0, WardenCores = 0, Quest = "not_started",
    }
    local ok, result = pcall(function()
        return store:GetAsync("player_" .. tostring(player.UserId))
    end)
    if ok and type(result) == "table" then
        for key, default in pairs(initial) do
            if type(result[key]) == type(default) then initial[key] = result[key] end
        end
    elseif not ok then
        warn("[Runewake] Profile load not available; using starter values for " .. player.Name)
    end
    initial.Gold = math.clamp(initial.Gold, 0, 100000000)
    initial.Level = math.clamp(initial.Level, 1, 250)
    initial.WeaponLevel = math.clamp(initial.WeaponLevel, 0, 100)
    initial.XP = math.max(0, initial.XP)
    for key, value in pairs(initial) do player:SetAttribute(key, value) end
    player:SetAttribute("NextXP", levelThreshold(initial.Level))
end

local function giveLoot(player, id, config)
    local reward = config.reward
    if reward then
        addGold(player, reward.gold)
        if id == "rootbound_warden" then
            player:SetAttribute("WardenCores", stat(player, "WardenCores") + 1)
        else
            player:SetAttribute("Shards", stat(player, "Shards") + 1)
        end
    end
    addExperience(player, config.isBoss and 120 or (id == "bellwisp" and 25 or 20))
    if id == "rootbound_warden" then
        if player:GetAttribute("Quest") == "active" then
            player:SetAttribute("Quest", "complete")
            tell(player, "THE WARDEN FALLS! Return to Mira in the village to claim your reward.")
        else
            tell(player, "Warden defeated! Warden Core collected.")
        end
    else
        tell(player, config.displayName .. " defeated! You recovered a shard and earned gold.")
    end
end

local enemies = Enemies.new(CharacterCatalog, world, giveLoot)

local function teleport(player, destination)
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum or hum.Health <= 0 then return end
    char:PivotTo(CFrame.new(destination))
    root.AssemblyLinearVelocity = Vector3.zero
    hum.Health = hum.MaxHealth
end

world.Prompts.Enter.Triggered:Connect(function(player)
    teleport(player, world.DungeonSpawn)
    tell(player, "Hollow Rune Depths - red shapes warn of incoming attacks. Tap ATTACK near monsters.")
end)

world.Prompts.Return.Triggered:Connect(function(player)
    teleport(player, world.TownSpawn)
    tell(player, "Back in Threadlight Village. Visit the NPCs to upgrade, trade and complete quests.")
end)

world.Prompts.Mira.Triggered:Connect(function(player)
    local state = player:GetAttribute("Quest")
    if state == "not_started" then
        player:SetAttribute("Quest", "active")
        tell(player, "MIRA: Find the Rootbound Warden deep in the dungeon. Defeat it, then return to me!")
    elseif state == "active" then
        tell(player, "MIRA: The Warden waits beyond the third archway. Follow the rune-lit path.")
    elseif state == "complete" then
        player:SetAttribute("Quest", "claimed")
        addGold(player, 100)
        addExperience(player, 150)
        tell(player, "QUEST COMPLETED! Mira paid you 100 gold and 150 experience.")
    else
        tell(player, "MIRA: The path is open, adventurer. Return whenever you are ready.")
    end
end)

world.Prompts.Orren.Triggered:Connect(function(player)
    local tier = stat(player, "WeaponLevel")
    local cost = 30 + 20 * tier
    if stat(player, "Gold") >= cost then
        addGold(player, -cost)
        player:SetAttribute("WeaponLevel", tier + 1)
        tell(player, string.format("ORREN: Blade forged to +%d! Damage improved. Cost: %d gold.", tier + 1, cost))
    else
        tell(player, string.format("ORREN: The next weapon upgrade costs %d gold. You have %d.", cost, stat(player, "Gold")))
    end
end)

world.Prompts.Pip.Triggered:Connect(function(player)
    local qty = stat(player, "Shards")
    if qty > 0 then
        player:SetAttribute("Shards", 0)
        addGold(player, qty * 12)
        tell(player, string.format("PIP: Bought %d salvage pieces for %d gold. Nice haul!", qty, qty * 12))
    else
        tell(player, "PIP: Bring me fragments or fractured plates from the dungeon. I'll pay 12 gold apiece.")
    end
end)

remote.OnServerEvent:Connect(function(player, action)
    if action ~= "Attack" then return end
    local now = os.clock()
    local last = lastAttack[player] or 0
    if now - last < 0.55 then return end
    lastAttack[player] = now
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not hum or not root or hum.Health <= 0 then return end
    if math.abs(root.Position.X - 400) > 49 then return end
    local damage = 22 + 5 * stat(player, "WeaponLevel") + 3 * (math.max(1, stat(player, "Level")) - 1)
    local targetId = enemies:AttackNearest(player, damage)
    if targetId then
        remote:FireClient(player, "Hit", damage)
    end
end)

Players.PlayerAdded:Connect(function(player)
    load(player)
    player.CharacterAdded:Connect(function(char)
        local humanoid = char:WaitForChild("Humanoid", 10)
        if not humanoid then return end
        humanoid.MaxHealth = 100 + 12 * (math.max(1, stat(player, "Level")) - 1)
        humanoid.Health = humanoid.MaxHealth
        humanoid.WalkSpeed = 18
        task.delay(3, function()
            if player.Parent == Players then
                tell(player, "WELCOME TO RUNEWAKE! Talk to Mira, enter the rune portal, and defeat the Warden.")
            end
        end)
    end)
end)
Players.PlayerRemoving:Connect(function(player)
    save(player)
    lastAttack[player] = nil
end)
game:BindToClose(function()
    local all = Players:GetPlayers()
    for _, player in ipairs(all) do
        task.spawn(save, player)
    end
    if #all > 0 then task.wait(2) end
end)
