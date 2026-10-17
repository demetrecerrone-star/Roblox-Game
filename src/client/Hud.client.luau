-- Runewake v0.1 - phone-first adventure HUD and combat controls.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local signal = ReplicatedStorage:WaitForChild("RunewakeSignal")

local gui = Instance.new("ScreenGui")
gui.Name = "RunewakeHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.DisplayOrder = 15
gui.Parent = player:WaitForChild("PlayerGui")

local function corner(parent, n)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, n or 12)
    c.Parent = parent
end

local function label(parent, name, text, size, position, fontSize, align)
    local t = Instance.new("TextLabel")
    t.Name = name
    t.Size = size
    t.Position = position
    t.BackgroundTransparency = 1
    t.TextColor3 = Color3.fromRGB(239, 246, 246)
    t.TextStrokeTransparency = 0.75
    t.Font = Enum.Font.GothamBold
    t.TextSize = fontSize or 16
    t.TextWrapped = true
    t.TextXAlignment = align or Enum.TextXAlignment.Left
    t.Text = text
    t.Parent = parent
    return t
end

local titleFrame = Instance.new("Frame")
titleFrame.Name = "StatusPanel"
titleFrame.Position = UDim2.fromOffset(12, 9)
titleFrame.Size = UDim2.new(0.74, 0, 0, 126)
titleFrame.BackgroundColor3 = Color3.fromRGB(21, 33, 47)
titleFrame.BackgroundTransparency = 0.12
titleFrame.Parent = gui
corner(titleFrame)
local panelMax = Instance.new("UISizeConstraint")
panelMax.MaxSize = Vector2.new(358, 126)
panelMax.MinSize = Vector2.new(235, 126)
panelMax.Parent = titleFrame
local title = label(titleFrame, "Title", "RUNEWAKE", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(12, 7), 21)
title.TextColor3 = Color3.fromRGB(104, 241, 222)
local vitals = label(titleFrame, "Vitals", "Level 1  •  100/100 HP", UDim2.new(1, -20, 0, 25), UDim2.fromOffset(12, 38), 15)
local wallet = label(titleFrame, "Wallet", "Gold 30  •  Blade +0", UDim2.new(1, -20, 0, 22), UDim2.fromOffset(12, 67), 15)
local xp = label(titleFrame, "Experience", "XP: 0/120  •  Shards: 0", UDim2.new(1, -20, 0, 22), UDim2.fromOffset(12, 96), 13)
xp.TextColor3 = Color3.fromRGB(217, 219, 189)

local questBox = Instance.new("Frame")
questBox.Name = "QuestPanel"
questBox.Position = UDim2.fromOffset(12, 145)
questBox.Size = UDim2.new(0.78, 0, 0, 52)
questBox.BackgroundColor3 = Color3.fromRGB(29, 36, 49)
questBox.BackgroundTransparency = 0.2
questBox.Parent = gui
corner(questBox, 9)
local questConstraint = Instance.new("UISizeConstraint")
questConstraint.MaxSize = Vector2.new(380, 52)
questConstraint.MinSize = Vector2.new(225, 52)
questConstraint.Parent = questBox
local questLabel = label(questBox, "CurrentQuest", "QUEST: Talk to Mira Threadlight.", UDim2.new(1, -18, 1, -8), UDim2.fromOffset(9, 4), 13)

local attack = Instance.new("TextButton")
attack.Name = "Attack"
attack.AnchorPoint = Vector2.new(1, 1)
attack.Position = UDim2.new(1, -19, 1, -20)
attack.Size = UDim2.fromOffset(120, 120)
attack.BackgroundColor3 = Color3.fromRGB(63, 128, 143)
attack.TextColor3 = Color3.fromRGB(248, 255, 254)
attack.TextStrokeTransparency = 0.6
attack.Text = "ATTACK\n⚔"
attack.TextScaled = true
attack.Font = Enum.Font.GothamBlack
attack.AutoButtonColor = true
attack.Parent = gui
corner(attack, 50)
local textConstraint = Instance.new("UITextSizeConstraint")
textConstraint.MaxTextSize = 25
textConstraint.Parent = attack
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(131, 255, 233)
stroke.Thickness = 3
stroke.Parent = attack

local help = label(gui, "Hint", "Tap NPCs to talk • Enter the glowing portal\nAttack nearby monsters • Dodge red warnings", UDim2.new(0.55, 0, 0, 54), UDim2.new(0, 14, 1, -70), 13)
help.TextColor3 = Color3.fromRGB(240, 245, 227)

local toast = Instance.new("Frame")
toast.Name = "Message"
toast.AnchorPoint = Vector2.new(0.5, 0)
toast.Position = UDim2.new(0.5, 0, 0.33, 0)
toast.Size = UDim2.new(0.88, 0, 0, 78)
toast.BackgroundColor3 = Color3.fromRGB(17, 30, 39)
toast.BackgroundTransparency = 0.08
toast.Visible = false
toast.Parent = gui
corner(toast)
local toastMax = Instance.new("UISizeConstraint")
toastMax.MaxSize = Vector2.new(580, 100)
toastMax.Parent = toast
local toastLabel = label(toast, "MessageText", "", UDim2.new(1, -20, 1, -12), UDim2.fromOffset(10, 6), 17, Enum.TextXAlignment.Center)
local toastGeneration = 0

local function message(text)
    toastGeneration += 1
    local generation = toastGeneration
    toastLabel.Text = text
    toast.Visible = true
    task.delay(5.5, function()
        if generation == toastGeneration then toast.Visible = false end
    end)
end

local function attr(name)
    return player:GetAttribute(name) or 0
end

local humanoid = nil
local healthConn
local function refresh()
    local level = attr("Level")
    local hp = humanoid and math.max(0, math.ceil(humanoid.Health)) or 0
    local maxHP = humanoid and math.ceil(humanoid.MaxHealth) or 100
    vitals.Text = string.format("Level %d  •  %d/%d HP", level, hp, maxHP)
    wallet.Text = string.format("Gold %d  •  Blade +%d", attr("Gold"), attr("WeaponLevel"))
    xp.Text = string.format("XP: %d/%d  •  Shards: %d", attr("XP"), attr("NextXP"), attr("Shards"))
    local quest = player:GetAttribute("Quest")
    if quest == "active" then
        questLabel.Text = "QUEST: Defeat the Rootbound Warden in the dungeon."
    elseif quest == "complete" then
        questLabel.Text = "QUEST: Return to Mira for your reward!"
    elseif quest == "claimed" then
        questLabel.Text = "QUEST COMPLETE: Explore and gather salvage."
    else
        questLabel.Text = "QUEST: Talk to Mira Threadlight in town."
    end
end

local function onCharacter(character)
    if healthConn then healthConn:Disconnect() end
    humanoid = character:WaitForChild("Humanoid", 10)
    if humanoid then healthConn = humanoid.HealthChanged:Connect(refresh) end
    refresh()
end
player.CharacterAdded:Connect(onCharacter)
if player.Character then task.spawn(onCharacter, player.Character) end
for _, key in ipairs({"Level", "Gold", "XP", "NextXP", "WeaponLevel", "Shards", "Quest"}) do
    player:GetAttributeChangedSignal(key):Connect(refresh)
end
refresh()

local nextAttack = 0
local function swing()
    if os.clock() < nextAttack then return end
    nextAttack = os.clock() + 0.57
    signal:FireServer("Attack")
    attack.BackgroundColor3 = Color3.fromRGB(102, 175, 170)
    TweenService:Create(attack, TweenInfo.new(0.38), {BackgroundColor3 = Color3.fromRGB(63, 128, 143)}):Play()
end
attack.Activated:Connect(swing)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.F or input.KeyCode == Enum.KeyCode.ButtonR2 then
        swing()
    end
end)

signal.OnClientEvent:Connect(function(kind, value)
    if kind == "Notice" and type(value) == "string" then
        message(value)
    elseif kind == "Hit" then
        attack.Text = "HIT!\n" .. tostring(value)
        task.delay(0.42, function()
            if attack.Parent then attack.Text = "ATTACK\n⚔" end
        end)
    end
end)
