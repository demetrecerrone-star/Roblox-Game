-- Runewake v0.1 - creates the playable town and first dungeon from Roblox primitives.
-- All content is generated on the server; no external models or asset IDs are required.
local World = {}
local Lighting = game:GetService("Lighting")

local STONE = Color3.fromRGB(94, 99, 112)
local DARK = Color3.fromRGB(45, 50, 69)
local MOSS = Color3.fromRGB(80, 121, 84)
local WOOD = Color3.fromRGB(117, 75, 48)
local CYAN = Color3.fromRGB(82, 240, 228)
local GOLD = Color3.fromRGB(255, 195, 89)

local function part(parent, name, size, pos, color, material, collide)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Position = pos
    p.Color = color or STONE
    p.Material = material or Enum.Material.Slate
    p.Anchored = true
    p.CanCollide = collide ~= false
    p.TopSurface = Enum.SurfaceType.Smooth
    p.BottomSurface = Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function label(adornee, words, width, height, offset)
    local gui = Instance.new("BillboardGui")
    gui.Name = "FloatingLabel"
    gui.Adornee = adornee
    gui.Size = UDim2.fromOffset(width or 210, height or 46)
    gui.StudsOffsetWorldSpace = offset or Vector3.new(0, 4, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 95
    gui.Parent = adornee
    local text = Instance.new("TextLabel")
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 0.25
    text.BackgroundColor3 = Color3.fromRGB(15, 24, 37)
    text.TextColor3 = Color3.fromRGB(239, 248, 247)
    text.Font = Enum.Font.GothamBold
    text.TextScaled = true
    text.Text = words
    text.Parent = gui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = text
end

local function prompt(adornee, action, object, distance)
    local pr = Instance.new("ProximityPrompt")
    pr.ActionText = action
    pr.ObjectText = object
    pr.MaxActivationDistance = distance or 11
    pr.HoldDuration = 0.2
    pr.RequiresLineOfSight = false
    pr.Parent = adornee
    return pr
end

local function lamp(parent, point, color)
    local post = part(parent, "Rune lantern post", Vector3.new(0.8, 5, 0.8), point + Vector3.new(0, 2.5, 0), DARK, Enum.Material.Metal)
    local bulb = part(parent, "Rune glow", Vector3.new(2, 2, 2), point + Vector3.new(0, 5.4, 0), color or CYAN, Enum.Material.Neon, false)
    bulb.Shape = Enum.PartType.Ball
    local light = Instance.new("PointLight")
    light.Range = 22
    light.Brightness = 1.8
    light.Color = color or CYAN
    light.Parent = bulb
    return post
end

local function house(parent, name, at, wall, roof)
    local folder = Instance.new("Model")
    folder.Name = name
    folder.Parent = parent
    part(folder, "Foundation", Vector3.new(24, 1, 19), at + Vector3.new(0, 0.7, 0), STONE)
    part(folder, "Rear wall", Vector3.new(24, 12, 2), at + Vector3.new(0, 6, -8), wall, Enum.Material.WoodPlanks)
    part(folder, "Left wall", Vector3.new(2, 12, 18), at + Vector3.new(-11, 6, 0), wall, Enum.Material.WoodPlanks)
    part(folder, "Right wall", Vector3.new(2, 12, 18), at + Vector3.new(11, 6, 0), wall, Enum.Material.WoodPlanks)
    part(folder, "Front left", Vector3.new(7, 12, 2), at + Vector3.new(-8.5, 6, 8), wall, Enum.Material.WoodPlanks)
    part(folder, "Front right", Vector3.new(7, 12, 2), at + Vector3.new(8.5, 6, 8), wall, Enum.Material.WoodPlanks)
    part(folder, "Lintel", Vector3.new(10, 3, 2), at + Vector3.new(0, 10.5, 8), wall, Enum.Material.WoodPlanks)
    part(folder, "Roof", Vector3.new(28, 2.1, 23), at + Vector3.new(0, 13.2, 0), roof, Enum.Material.Slate)
    part(folder, "Door glow", Vector3.new(6, 7.8, 0.3), at + Vector3.new(0, 4.7, 8.7), CYAN, Enum.Material.Glass, false)
    local plaque = part(folder, "Sign", Vector3.new(11, 2.5, 0.6), at + Vector3.new(0, 10.7, 9.4), DARK, Enum.Material.Wood)
    label(plaque, name, 190, 30, Vector3.new(0, 2, 0))
end

local function tree(parent, at, scale)
    local trunk = part(parent, "Twilight tree trunk", Vector3.new(2 * scale, 7 * scale, 2 * scale), at + Vector3.new(0, 3.5 * scale, 0), WOOD, Enum.Material.Wood)
    local crown = part(parent, "Twilight tree canopy", Vector3.new(10 * scale, 10 * scale, 10 * scale), at + Vector3.new(0, 10 * scale, 0), MOSS, Enum.Material.Grass, false)
    crown.Shape = Enum.PartType.Ball
    return trunk
end

local function npc(parent, name, at, tunic, accent, accessory)
    local model = Instance.new("Model")
    model.Name = name
    model.Parent = parent
    local body = part(model, "Body", Vector3.new(3.2, 4.3, 2), at + Vector3.new(0, 4.5, 0), tunic, Enum.Material.Fabric, false)
    local face = part(model, "Head", Vector3.new(2.2, 2.2, 2), at + Vector3.new(0, 7.7, 0), Color3.fromRGB(223, 183, 147), Enum.Material.SmoothPlastic, false)
    face.Shape = Enum.PartType.Ball
    part(model, "Left boot", Vector3.new(1, 2.4, 1), at + Vector3.new(-0.8, 1.2, 0), DARK, Enum.Material.Leather, false)
    part(model, "Right boot", Vector3.new(1, 2.4, 1), at + Vector3.new(0.8, 1.2, 0), DARK, Enum.Material.Leather, false)
    part(model, "Cowl", Vector3.new(2.7, 0.8, 2.7), at + Vector3.new(0, 8.6, 0), accent, Enum.Material.Fabric, false)
    if accessory == "compass" then
        local orb = part(model, "Floating rune compass", Vector3.new(2, 2, 2), at + Vector3.new(2.5, 7.7, 0), CYAN, Enum.Material.Neon, false)
        orb.Shape = Enum.PartType.Ball
    elseif accessory == "smith" then
        part(model, "Glass forge arm", Vector3.new(1.2, 4, 1.2), at + Vector3.new(2.2, 4.3, 0), CYAN, Enum.Material.Glass, false)
        part(model, "Hammer", Vector3.new(3, 1.1, 1), at + Vector3.new(3.4, 3.6, 0), STONE, Enum.Material.Metal, false)
    else
        local pack = part(model, "Oversized lantern pack", Vector3.new(3.8, 4.2, 2), at + Vector3.new(0, 5.1, 1.9), GOLD, Enum.Material.Metal, false)
        local sparkle = Instance.new("PointLight")
        sparkle.Range = 10
        sparkle.Brightness = 0.9
        sparkle.Parent = pack
    end
    label(face, name, 200, 42, Vector3.new(0, 3.5, 0))
    return prompt(body, "Talk", name, 13)
end

local function pillar(parent, at)
    part(parent, "Carved stone pillar", Vector3.new(3, 13, 3), at + Vector3.new(0, 6.5, 0), STONE)
    part(parent, "Rune pillar cap", Vector3.new(4, 1.5, 4), at + Vector3.new(0, 13.5, 0), CYAN, Enum.Material.Neon, false)
end

function World.Create()
    local existing = workspace:FindFirstChild("RunewakeWorld")
    if existing then existing:Destroy() end

    local map = Instance.new("Folder")
    map.Name = "RunewakeWorld"
    map.Parent = workspace
    local town = Instance.new("Folder")
    town.Name = "Threadlight Village"
    town.Parent = map
    local dungeon = Instance.new("Folder")
    dungeon.Name = "Hollow Rune Depths"
    dungeon.Parent = map

    Lighting.ClockTime = 16.25
    Lighting.Brightness = 2.3
    Lighting.Ambient = Color3.fromRGB(120, 145, 160)
    Lighting.OutdoorAmbient = Color3.fromRGB(135, 165, 155)
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
    atmosphere.Density = 0.25
    atmosphere.Haze = 1.3
    atmosphere.Color = Color3.fromRGB(190, 225, 223)
    atmosphere.Parent = Lighting

    part(town, "Village grass", Vector3.new(160, 2, 160), Vector3.new(0, -1, 0), Color3.fromRGB(70, 121, 85), Enum.Material.Grass)
    part(town, "Cobblestone main lane", Vector3.new(16, 0.2, 140), Vector3.new(0, 0.15, 0), STONE, Enum.Material.Cobblestone)
    part(town, "Market lane", Vector3.new(132, 0.2, 14), Vector3.new(0, 0.2, 0), STONE, Enum.Material.Cobblestone)
    part(town, "Village plaza", Vector3.new(30, 0.4, 30), Vector3.new(0, 0.4, 0), Color3.fromRGB(123, 129, 132), Enum.Material.Cobblestone)
    for i = -1, 1, 2 do
        part(town, "Boundary fence", Vector3.new(160, 8, 3), Vector3.new(0, 4, 80*i), WOOD, Enum.Material.Wood)
        part(town, "Boundary fence", Vector3.new(3, 8, 160), Vector3.new(80*i, 4, 0), WOOD, Enum.Material.Wood)
    end
    for _, p in ipairs({
        {-67, -60}, {-64, 62}, {58, -63}, {65, 65},
        {-70, 28}, {67, 28}, {-69, -27}, {64, -30},
    }) do
        tree(town, Vector3.new(p[1], 0.5, p[2]), 1 + (math.abs(p[1]) % 3) * 0.1)
    end
    house(town, "Threadlight Cartography", Vector3.new(-35, 0, -29), Color3.fromRGB(96, 118, 138), DARK)
    house(town, "Kilnhand Forge", Vector3.new(36, 0, -29), Color3.fromRGB(133, 95, 68), Color3.fromRGB(55, 60, 70))
    house(town, "Wicks Salvage", Vector3.new(36, 0, 29), Color3.fromRGB(119, 112, 77), Color3.fromRGB(75, 62, 55))
    house(town, "Village Inn", Vector3.new(-34, 0, 31), Color3.fromRGB(124, 103, 112), Color3.fromRGB(80, 66, 87))
    for _, z in ipairs({-50, 0, 51}) do
        lamp(town, Vector3.new(-12, 0.5, z), CYAN)
        lamp(town, Vector3.new(12, 0.5, z), GOLD)
    end

    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "Runewake Town Spawn"
    spawn.Size = Vector3.new(10, 1, 10)
    spawn.Position = Vector3.new(0, 1.2, 50)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Material = Enum.Material.Neon
    spawn.Color = CYAN
    spawn.Transparency = 0.35
    spawn.Parent = town

    local villageSign = part(town, "Welcome stone", Vector3.new(13, 7, 3), Vector3.new(0, 4, 24), DARK)
    label(villageSign, "RUNEWAKE\nTHREADLIGHT VILLAGE", 260, 72, Vector3.new(0, 6, 0))

    local townGate = part(town, "Town dungeon rune portal", Vector3.new(9, 14, 2), Vector3.new(-58, 7, 0), CYAN, Enum.Material.Neon, false)
    townGate.Transparency = 0.3
    part(town, "Portal arch left", Vector3.new(3, 17, 4), Vector3.new(-65, 8.5, 0), DARK)
    part(town, "Portal arch right", Vector3.new(3, 17, 4), Vector3.new(-51, 8.5, 0), DARK)
    part(town, "Portal arch top", Vector3.new(17, 3, 4), Vector3.new(-58, 17, 0), DARK)
    label(townGate, "HOLLOW RUNE DEPTHS", 245, 45, Vector3.new(0, 10, 0))

    local X = 400
    part(dungeon, "Long carved dungeon floor", Vector3.new(86, 2, 290), Vector3.new(X, -1, 0), DARK, Enum.Material.Slate)
    part(dungeon, "Left dungeon wall", Vector3.new(4, 24, 290), Vector3.new(X - 43, 12, 0), STONE)
    part(dungeon, "Right dungeon wall", Vector3.new(4, 24, 290), Vector3.new(X + 43, 12, 0), STONE)
    part(dungeon, "Far end wall", Vector3.new(86, 24, 4), Vector3.new(X, 12, 144), STONE)
    part(dungeon, "Entrance wall", Vector3.new(86, 24, 4), Vector3.new(X, 12, -144), STONE)
    for _, z in ipairs({-110, -45, 20, 82, 125}) do
        pillar(dungeon, Vector3.new(X - 32, 0, z))
        pillar(dungeon, Vector3.new(X + 32, 0, z))
        lamp(dungeon, Vector3.new(X - 37, 0, z + 12), CYAN)
        lamp(dungeon, Vector3.new(X + 37, 0, z + 12), GOLD)
    end
    for _, z in ipairs({-85, -8, 56}) do
        part(dungeon, "Ancient arch lintel", Vector3.new(78, 5, 4), Vector3.new(X, 18, z), STONE)
        part(dungeon, "Arch rune center", Vector3.new(7, 2, 2), Vector3.new(X, 16, z), CYAN, Enum.Material.Neon, false)
    end
    local bossFloor = part(dungeon, "Warden arena", Vector3.new(70, 0.4, 70), Vector3.new(X, 0.3, 100), Color3.fromRGB(78, 69, 88), Enum.Material.Cobblestone)
    local rune = part(dungeon, "Warden rune seal", Vector3.new(34, 0.25, 34), Vector3.new(X, 0.6, 104), Color3.fromRGB(150, 94, 210), Enum.Material.Neon, false)
    rune.Transparency = 0.5
    local entrancePortal = part(dungeon, "Return rune portal", Vector3.new(10, 12, 2), Vector3.new(X, 6.3, -125), GOLD, Enum.Material.Neon, false)
    entrancePortal.Transparency = 0.25
    label(entrancePortal, "RETURN TO VILLAGE", 235, 42, Vector3.new(0, 8, 0))
    local warning = part(dungeon, "Boss chamber obelisk", Vector3.new(8, 16, 5), Vector3.new(X, 8, 135), DARK, Enum.Material.Slate)
    label(warning, "ROOTBOUND WARDEN\nBOSS CHAMBER", 260, 70, Vector3.new(0, 13, 0))

    return {
        Map = map,
        Dungeon = dungeon,
        TownSpawn = Vector3.new(0, 5, 48),
        DungeonSpawn = Vector3.new(X, 5, -111),
        Prompts = {
            Mira = npc(town, "Mira Threadlight", Vector3.new(-16, 0.5, -7), Color3.fromRGB(57, 125, 145), Color3.fromRGB(41, 56, 89), "compass"),
            Orren = npc(town, "Orren Kilnhand", Vector3.new(24, 0.5, -7), Color3.fromRGB(123, 75, 53), DARK, "smith"),
            Pip = npc(town, "Pip Wicks", Vector3.new(25, 0.5, 17), Color3.fromRGB(143, 112, 60), GOLD, "pack"),
            Enter = prompt(townGate, "Enter Dungeon", "Hollow Rune Depths", 15),
            Return = prompt(entrancePortal, "Return to Village", "Runewake", 15),
        },
        EnemySpawns = {
            { id = "shardback", position = Vector3.new(X - 12, 4, -63) },
            { id = "bellwisp", position = Vector3.new(X + 13, 8, -21) },
            { id = "shardback", position = Vector3.new(X + 9, 4, 34) },
            { id = "bellwisp", position = Vector3.new(X - 14, 8, 52) },
            { id = "rootbound_warden", position = Vector3.new(X, 9, 102) },
        },
    }
end

return World
