-- Runewake v0.1. Server-authoritative enemy spawning, chase, telegraphs and combat.
local Players = game:GetService("Players")
local Enemies = {}
Enemies.__index = Enemies

local function block(parent, name, size, localPosition, color, material, rootCFrame)
    local p = Instance.new("Part")
    p.Name = name
    p.Size = size
    p.Color = color
    p.Material = material or Enum.Material.SmoothPlastic
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.CFrame = rootCFrame * CFrame.new(localPosition)
    p.Parent = parent
    return p
end

local function makeModel(id, config, spawn, parent)
    local model = Instance.new("Model")
    model.Name = config.displayName
    model:SetAttribute("EnemyId", id)
    model.Parent = parent
    local origin = CFrame.new(spawn)
    local root = block(model, "EnemyRoot", Vector3.new(1, 1, 1), Vector3.zero, Color3.new(1, 1, 1), Enum.Material.SmoothPlastic, origin)
    root.Transparency = 1
    model.PrimaryPart = root

    if id == "shardback" then
        block(model, "Shovel jaw", Vector3.new(4, 1.5, 3), Vector3.new(0, -0.6, -3), Color3.fromRGB(80, 107, 135), Enum.Material.Slate, origin)
        block(model, "Burrower shell", Vector3.new(6, 2.5, 7), Vector3.new(0, 0.2, 0), Color3.fromRGB(36, 69, 84), Enum.Material.Rock, origin)
        for i = 1, 3 do
            local z = (i - 2) * 2.2
            local gem = block(model, "Crystal fin", Vector3.new(1.5, 3.8, 1.5), Vector3.new(0, 2.5, z), Color3.fromRGB(63, 230, 228), Enum.Material.Neon, origin)
            gem.CFrame *= CFrame.Angles(math.rad(12 * (i - 2)), 0, math.rad(22))
            for _, side in ipairs({-1, 1}) do
                block(model, "Six-leg gait foot", Vector3.new(2.4, 1.4, 1.3), Vector3.new(side * 3.6, -1.4, z), Color3.fromRGB(57, 72, 96), Enum.Material.Slate, origin)
            end
        end
    elseif id == "bellwisp" then
        local bell = block(model, "Cracked floating bell", Vector3.new(5.5, 5.5, 5.5), Vector3.new(0, 0, 0), Color3.fromRGB(114, 119, 144), Enum.Material.Slate, origin)
        bell.Shape = Enum.PartType.Ball
        local core = block(model, "Luminous crack", Vector3.new(3, 3, 1.8), Vector3.new(0, 0, -2.5), Color3.fromRGB(252, 198, 99), Enum.Material.Neon, origin)
        core.Shape = Enum.PartType.Ball
        for i = 1, 3 do
            local ribbon = block(model, "Rune streamer", Vector3.new(0.65, 6, 0.7), Vector3.new((i-2)*2, -4, 2), Color3.fromRGB(131, 226, 230), Enum.Material.Neon, origin)
            ribbon.CFrame *= CFrame.Angles(0, 0, math.rad(17 * (i-2)))
        end
    else
        block(model, "Standing root trunk", Vector3.new(4, 10, 4), Vector3.new(0, -1, 0), Color3.fromRGB(86, 64, 54), Enum.Material.Wood, origin)
        block(model, "Stone gate torso", Vector3.new(11, 13, 6), Vector3.new(0, 4, 0), Color3.fromRGB(102, 105, 116), Enum.Material.Slate, origin)
        local rune = block(model, "Core rune", Vector3.new(4, 6, 1), Vector3.new(0, 5, -3.6), Color3.fromRGB(159, 88, 232), Enum.Material.Neon, origin)
        rune.Transparency = 0.15
        block(model, "Gate hammer arm", Vector3.new(4, 15, 7), Vector3.new(8, 3, -1), Color3.fromRGB(83, 87, 97), Enum.Material.Slate, origin)
        block(model, "Root arm", Vector3.new(3, 12, 3), Vector3.new(-7, 2, 0), Color3.fromRGB(83, 65, 48), Enum.Material.Wood, origin)
        block(model, "Root left leg", Vector3.new(4, 7, 4), Vector3.new(-3, -9, 0), Color3.fromRGB(75, 57, 44), Enum.Material.Wood, origin)
        block(model, "Root right leg", Vector3.new(4, 7, 4), Vector3.new(3, -9, 0), Color3.fromRGB(75, 57, 44), Enum.Material.Wood, origin)
    end

    local info = Instance.new("BillboardGui")
    info.Name = "EnemyHealth"
    info.Size = UDim2.fromOffset(id == "rootbound_warden" and 240 or 170, 45)
    info.StudsOffsetWorldSpace = Vector3.new(0, id == "rootbound_warden" and 15 or 6, 0)
    info.AlwaysOnTop = true
    info.MaxDistance = 100
    info.Adornee = root
    info.Parent = root
    local text = Instance.new("TextLabel")
    text.Name = "HealthText"
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundColor3 = Color3.fromRGB(31, 22, 37)
    text.BackgroundTransparency = 0.1
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.fromRGB(255, 220, 225)
    text.TextScaled = true
    text.Parent = info
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 8)
    uiCorner.Parent = text
    return model, root, text
end

local function targetNear(position, range)
    local chosenRoot, chosenHumanoid, chosenDistance
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and hum and hum.Health > 0 and hrp.Position.X > 345 and hrp.Position.X < 455 then
            local d = (hrp.Position - position).Magnitude
            if d < range and (not chosenDistance or d < chosenDistance) then
                chosenRoot, chosenHumanoid, chosenDistance = hrp, hum, d
            end
        end
    end
    return chosenRoot, chosenHumanoid, chosenDistance
end

local function warningDisc(parent, center, radius, rectangle)
    local p = Instance.new("Part")
    p.Name = "DANGER: move out of the red area"
    p.Anchored = true
    p.CanCollide = false
    p.CanTouch = false
    p.Material = Enum.Material.Neon
    p.Color = Color3.fromRGB(255, 75, 83)
    p.Transparency = 0.55
    if rectangle then
        p.Size = Vector3.new(radius * 1.2, 0.15, radius * 2.1)
        p.Position = Vector3.new(center.X, 0.3, center.Z)
    else
        p.Shape = Enum.PartType.Cylinder
        p.Size = Vector3.new(0.15, radius * 2, radius * 2)
        p.CFrame = CFrame.new(center.X, 0.3, center.Z) * CFrame.Angles(0, 0, math.rad(90))
    end
    p.Parent = parent
    return p
end

function Enemies.new(catalog, world, onDefeat)
    local self = setmetatable({}, Enemies)
    self.catalog = catalog
    self.world = world
    self.onDefeat = onDefeat
    self.live = {}
    self.lastSwing = {}
    for _, info in ipairs(world.EnemySpawns) do
        self:_spawn(info.id, info.position)
    end
    return self
end

function Enemies:_move(record, dest, dt)
    local current = record.root.Position
    local delta = Vector3.new(dest.X - current.X, 0, dest.Z - current.Z)
    if delta.Magnitude < 0.2 then return end
    local advance = math.min(delta.Magnitude, record.config.moveSpeed * dt)
    local point = current + delta.Unit * advance
    record.model:PivotTo(CFrame.lookAt(point, point + delta.Unit))
end

function Enemies:_attack(record, victimRoot, victimHum)
    if not record.alive then return end
    local cfg = record.config
    local attack
    local style = "pulse"
    if cfg.isBoss then
        record.attackIndex = record.attackIndex == 1 and 2 or 1
        attack = cfg.attacks[record.attackIndex]
        style = attack.id
    else
        attack = cfg.attack
        if record.id == "shardback" then style = "charge" end
    end
    local focus = victimRoot.Position
    local origin = record.root.Position
    local radius = style == "gate_slam" and 10 or (style == "root_sweep" and 12 or (style == "charge" and 7 or attack.pulseRadius or 6))
    local danger = warningDisc(self.world.Dungeon, focus, radius, style == "gate_slam")
    task.wait(attack.windupSeconds)
    if danger.Parent then danger:Destroy() end
    if not record.alive then return end
    if style == "charge" then
        local vector = Vector3.new(focus.X - origin.X, 0, focus.Z - origin.Z)
        if vector.Magnitude > 0.2 then
            local point = origin + vector.Unit * math.min(13, vector.Magnitude)
            record.model:PivotTo(CFrame.lookAt(point, point + vector.Unit))
        end
    end
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local humanoid = char and char:FindFirstChildOfClass("Humanoid")
        if hrp and humanoid and humanoid.Health > 0 and math.abs(hrp.Position.Y - focus.Y) < 17 then
            local flatDist = (Vector3.new(hrp.Position.X, 0, hrp.Position.Z) - Vector3.new(focus.X, 0, focus.Z)).Magnitude
            if flatDist <= radius then
                humanoid:TakeDamage(attack.damage)
            end
        end
    end
    task.wait(attack.recoverySeconds)
end

function Enemies:_spawn(id, location)
    local config = self.catalog.enemies[id]
    if not config then return end
    local model, root, text = makeModel(id, config, location, self.world.Dungeon)
    local rec = {
        id = id, config = config, model = model, root = root,
        hp = config.health, alive = true, home = location,
        lastAttack = 0, attackIndex = 2,
        healthLabel = text,
    }
    self.live[model] = rec
    local function update()
        rec.healthLabel.Text = string.format("%s  %d / %d", config.displayName, math.ceil(rec.hp), config.health)
    end
    update()
    task.spawn(function()
        local previous = os.clock()
        while rec.alive and model.Parent do
            local now = os.clock()
            local dt = math.min(0.25, now - previous)
            previous = now
            local target, humanoid, distance = targetNear(root.Position, config.detectionRange)
            if target and humanoid then
                local attackRange = config.attack and config.attack.triggerRange or 13
                if distance > attackRange then
                    self:_move(rec, target.Position, dt)
                elseif now - rec.lastAttack > (config.isBoss and 3.5 or config.attack.cooldownSeconds) then
                    rec.lastAttack = now
                    self:_attack(rec, target, humanoid)
                end
            elseif (root.Position - location).Magnitude > 3 then
                self:_move(rec, location, dt)
            end
            task.wait(0.12)
        end
    end)
end

function Enemies:AttackNearest(player, damage)
    local character = player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    local hrp = character and character:FindFirstChild("HumanoidRootPart")
    if not hrp or not humanoid or humanoid.Health <= 0 then return nil end
    local closest, distance = nil, 15
    for _, rec in pairs(self.live) do
        if rec.alive and rec.model.Parent then
            local d = (rec.root.Position - hrp.Position).Magnitude
            if d < distance then closest, distance = rec, d end
        end
    end
    if not closest then return nil end
    closest.hp = math.max(0, closest.hp - damage)
    closest.healthLabel.Text = string.format("%s  %d / %d", closest.config.displayName, math.ceil(closest.hp), closest.config.health)
    if closest.hp <= 0 and closest.alive then
        closest.alive = false
        self.live[closest.model] = nil
        local old = closest.model
        old:Destroy()
        if self.onDefeat then self.onDefeat(player, closest.id, closest.config) end
        local delaySeconds = closest.config.isBoss and 75 or 22
        task.delay(delaySeconds, function()
            if self.world.Dungeon.Parent then self:_spawn(closest.id, closest.home) end
        end)
    end
    return closest.id
end

return Enemies
