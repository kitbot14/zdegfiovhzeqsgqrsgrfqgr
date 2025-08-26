local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ADMIN_USERNAMES = {
    ["kitlebot10"] = true,
}

local isAimbotEnabled = false
local isFlyEnabled = false
local isWallhackEnabled = false
local isInvincible = false
local isInvisible = false
local oneShotEnabled = false

local aimRadius = 1000
local flySpeed = 50
local flyVelocity = nil
local moveVector = Vector3.new(0, 0, 0)

local guiPosition = UDim2.new(1, -170, 0, 20) -- position initiale

-- Check mobile
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Draggable GUI function
local function makeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    guiPosition = frame.Position -- sauvegarde de la position
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Aimbot : cible la plus proche dans le rayon
local function getClosestTarget()
    local closest = nil
    local shortestDistance = aimRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
            local head = player.Character.Head
            local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closest = player
                end
            end
        end
    end

    return closest
end

-- Aimer la cible
local function aimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local dir = (head.Position - Camera.CFrame.Position).Unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
    end
end

-- One shot : kill instantané de la cible
local function oneShot(target)
    if target and target.Character and target.Character:FindFirstChild("Humanoid") then
        target.Character.Humanoid.Health = 0
    end
end

-- Fly toggle avec BodyVelocity
local function toggleFly(state)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local humanoid = LocalPlayer.Character.Humanoid

    if state then
        humanoid.PlatformStand = true
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyVelocity.Parent = hrp
    else
        humanoid.PlatformStand = false
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
end

-- Mouvement fly
local function updateFlyMovement()
    if not flyVelocity then return end

    local camCFrame = workspace.CurrentCamera.CFrame
    local forward = camCFrame.LookVector
    local right = camCFrame.RightVector

    local direction = (right * moveVector.X) + (Vector3.new(0, moveVector.Y, 0)) + (forward * moveVector.Z)
    flyVelocity.Velocity = direction * flySpeed
end

-- Gestion des inputs clavier/tactile pour fly
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not isFlyEnabled then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W then
            moveVector = Vector3.new(moveVector.X, moveVector.Y, 1)
        elseif input.KeyCode == Enum.KeyCode.S then
            moveVector = Vector3.new(moveVector.X, moveVector.Y, -1)
        elseif input.KeyCode == Enum.KeyCode.A then
            moveVector = Vector3.new(-1, moveVector.Y, moveVector.Z)
        elseif input.KeyCode == Enum.KeyCode.D then
            moveVector = Vector3.new(1, moveVector.Y, moveVector.Z)
        elseif input.KeyCode == Enum.KeyCode.E then
            moveVector = Vector3.new(moveVector.X, 1, moveVector.Z)
        elseif input.KeyCode == Enum.KeyCode.Q then
            moveVector = Vector3.new(moveVector.X, -1, moveVector.Z)
        end
    elseif input.UserInputType == Enum.UserInputType.Touch then
        -- Pour mobile, on peut gérer un joystick tactile plus tard si besoin
    end
end)

UserInputService.InputEnded:Connect(function(input, gameProcessed)
    if gameProcessed or not isFlyEnabled then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S then
            moveVector = Vector3.new(moveVector.X, moveVector.Y, 0)
        elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D then
            moveVector = Vector3.new(0, moveVector.Y, moveVector.Z)
        elseif input.KeyCode == Enum.KeyCode.E or input.KeyCode == Enum.KeyCode.Q then
            moveVector = Vector3.new(moveVector.X, 0, moveVector.Z)
        end
    end
end)

-- Invincible : empêche de perdre de la vie
local function toggleInvincible(state)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid

    if state then
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge

        humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if humanoid.Health < humanoid.MaxHealth then
                humanoid.Health = humanoid.MaxHealth
            end
        end)
    else
        humanoid.MaxHealth = 100
        if humanoid.Health > 100 then
            humanoid.Health = 100
        end
    end
end

-- Invisible : rendre perso transparent & no collisions
local function toggleInvisible(state)
    if not LocalPlayer.Character then return end

    for _, part in ipairs(LocalPlayer.Character:GetChildren()) do
        if part:IsA("BasePart") then
            if state then
                part.Transparency = 1
                part.CanCollide = false
            else
                part.Transparency = 0
                part.CanCollide = true
            end
        elseif part:IsA("Decal") or part:IsA("Texture") then
            part.Transparency = state and 1 or 0
        end
    end
end

-- GUI
local function createMainGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdminToolsGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 260)
    frame.Position = guiPosition
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundTransparency = 1
    title.Text = "Admin Tools"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Parent = frame

    makeDraggable(frame)

    local function createToggleButton(text, yPos, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -20, 0, 40)
        btn.Position = UDim2.new(0, 10, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 18
        btn.Text = text .. " OFF"
        btn.Parent = frame

        btn.MouseButton1Click:Connect(function()
            local isOn = btn.Text:find("ON") == nil
            if isOn then
                btn.Text = text .. " ON"
                btn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
            else
                btn.Text = text .. " OFF"
                btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            end
            callback(isOn)
        end)

        return btn
    end

    createToggleButton("Aimbot", 40, function(state)
        isAimbotEnabled = state
    end)

    createToggleButton("Fly", 90, function(state)
        isFlyEnabled = state
        toggleFly(state)
    end)

    createToggleButton("Wallhack", 140, function(state)
        isWallhackEnabled = state
        -- updateWallhack() -- à remettre si tu veux wallhack ici
    end)

    createToggleButton("One Shot", 190, function(state)
        oneShotEnabled = state
    end)

    createToggleButton("Invincible", 240, function(state)
        isInvincible = state
        toggleInvincible(state)
    end)

    createToggleButton("Invisible", 290, function(state)
        isInvisible = state
        toggleInvisible(state)
    end)
end

-- Boucle principale
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestTarget()
        aimAt(target)
        if oneShotEnabled and target then
            oneShot(target)
        end
    end

    if isFlyEnabled then
        updateFlyMovement()
    end
end)

-- Activation si admin & mobile (tu peux enlever isMobile() si tu veux desktop aussi)
if ADMIN_USERNAMES[LocalPlayer.Name] and isMobile() then
    createMainGUI()
    print("✅ Admin Tools prêtes.")
else
    warn("❌ Ce script est réservé aux admins sur mobile.")
end
