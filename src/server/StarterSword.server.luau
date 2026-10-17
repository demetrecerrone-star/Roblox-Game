-- A clearly visible starter sword so combat never looks like invisible damage.
-- Procedural parts are intentionally temporary until user-provided 3D weapon
-- assets have been optimized and uploaded to Roblox.
local Players = game:GetService("Players")

local function addPiece(tool, handle, name, className, size, localOffset, color, material)
    local piece = Instance.new(className or "Part")
    piece.Name = name
    piece.Size = size
    piece.Material = material or Enum.Material.Metal
    piece.Color = color
    piece.Anchored = false
    piece.CanCollide = false
    piece.CanTouch = false
    piece.Massless = true
    piece.CFrame = handle.CFrame * localOffset
    piece.Parent = tool
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = handle
    weld.Part1 = piece
    weld.Parent = handle
    return piece
end

local function buildSword()
    local tool = Instance.new("Tool")
    tool.Name = "Runewake Starter Sword"
    tool.ToolTip = "Basic rune-steel sword | tap ATTACK to swing"
    tool.RequiresHandle = true
    tool.CanBeDropped = false

    local handle = Instance.new("Part")
    handle.Name = "Handle"
    handle.Size = Vector3.new(0.32, 1.18, 0.3)
    handle.Material = Enum.Material.Wood
    handle.Color = Color3.fromRGB(89, 52, 33)
    handle.Anchored = false
    handle.CanCollide = false
    handle.CanTouch = false
    handle.Massless = true
    handle.Parent = tool

    addPiece(tool, handle, "Rune steel blade", "Part",
        Vector3.new(0.48, 2.7, 0.16), CFrame.new(0, 1.88, 0),
        Color3.fromRGB(185, 211, 220), Enum.Material.Metal)
    addPiece(tool, handle, "Blade tip", "WedgePart",
        Vector3.new(0.48, 0.6, 0.16), CFrame.new(0, 3.52, 0)
            * CFrame.Angles(0, 0, math.rad(180)),
        Color3.fromRGB(205, 222, 233), Enum.Material.Metal)
    addPiece(tool, handle, "Brass crossguard", "Part",
        Vector3.new(1.55, 0.3, 0.36), CFrame.new(0, 0.67, 0),
        Color3.fromRGB(180, 143, 75), Enum.Material.Metal)
    local crystal = addPiece(tool, handle, "Glowing rune inset", "Part",
        Vector3.new(0.13, 1.6, 0.03), CFrame.new(0, 2.05, -0.102),
        Color3.fromRGB(70, 255, 232), Enum.Material.Neon)
    crystal.Transparency = 0.2
    addPiece(tool, handle, "Pommel", "Part",
        Vector3.new(0.55, 0.3, 0.55), CFrame.new(0, -0.73, 0),
        Color3.fromRGB(162, 124, 68), Enum.Material.Metal)
    return tool
end

local function onCharacter(player, character)
    local hum = character:WaitForChild("Humanoid", 10)
    local backpack = player:WaitForChild("Backpack", 10)
    if not hum or not backpack then return end
    local existing = backpack:FindFirstChild("Runewake Starter Sword")
    if existing then existing:Destroy() end
    local sword = buildSword()
    sword.Parent = backpack
    task.defer(function()
        if hum.Parent == character and hum.Health > 0 and sword.Parent == backpack then
            hum:EquipTool(sword)
        end
    end)
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        onCharacter(player, character)
    end)
end)
