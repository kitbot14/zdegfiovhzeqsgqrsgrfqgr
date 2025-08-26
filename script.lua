local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ADMIN_USERNAMES = {
    ["kitlebot10"] = true,
}

-- États des fonctionnalités
local isAimbotEnabled = false
local isWallhackEnabled = false
local isInvincible = false

local aimRadius = 1000

local guiPosition = UDim2.new(1, -170, 0, 20)

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- MENU DRAGGABLE ET RÉDUCTIBLE
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
                    guiPosition = frame.Position
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

-- AIMBOT : cible le joueur le plus proche au centre de l'écran dans le rayon
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

local function aimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local cameraPos = Camera.CFrame.Position
        local direction = (head.Position - cameraPos).Unit
        Camera.CFrame = CFrame.new(cameraPos, cameraPos + direction)
    end
end

-- INVINCIBLE corrigé (regénère santé en boucle)
local function toggleInvincible(state)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local humanoid = LocalPlayer.Character.Humanoid

    if state then
        humanoid.MaxHealth = math.huge
        humanoid.Health = humanoid.MaxHealth
        -- Connexion unique à HealthChanged pour éviter plusieurs connexions
        if not humanoid:FindFirstChild("InvincibleConnection") then
            local conn = humanoid.HealthChanged:Connect(function()
                if humanoid.Health < humanoid.MaxHealth then
                    humanoid.Health = humanoid.MaxHealth
                end
            end)
            conn.Name = "InvincibleConnection"
            conn.Parent = humanoid
        end
    else
        humanoid.MaxHealth = 100
        if humanoid.Health > 100 then
            humanoid.Health = 100
        end
        -- Déconnecter le listener invincible si il existe
        local conn = humanoid:FindFirstChild("InvincibleConnection")
        if conn then
            conn:Disconnect()
            conn:Destroy()
        end
    end
end

-- WALLHACK : met tout le monde en rouge et ajoute un rond rouge sur la tête
local function applyWallhack(state)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    if state then
                        part.Color = Color3.new(1, 0, 0) -- rouge vif
                        part.Material = Enum.Material.Neon
                    else
                        part.Color = Color3.new(1, 1, 1)
                        part.Material = Enum.Material.Plastic
                    end
                end
            end

            -- Rond rouge sur la tête
            local head = player.Character:FindFirstChild("Head")
            if head then
                local existingCircle = head:FindFirstChild("WallhackCircle")
                if state and not existingCircle then
                    local circle = Instance.new("SelectionSphere")
                    circle.Name = "WallhackCircle"
                    circle.Adornee = head
                    circle.Color3 = Color3.new(1, 0, 0)
                    circle.LineThickness = 0.05
                    circle.Parent = head
                elseif not state and existingCircle then
                    existingCircle:Destroy()
                end
            end
        end
    end
end

-- GUI création
local function createMainGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdminToolsGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = guiPosition
    frame.Size = UDim2.new(0, 160, 0, 280)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Parent = gui

    makeDraggable(frame)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Text = "Admin Tools"
    title.Parent = frame

    local toggleSizeBtn = Instance.new("TextButton")
    toggleSizeBtn.Size = UDim2.new(0, 30, 0, 30)
    toggleSizeBtn.Position = UDim2.new(1, -35, 0, 5)
    toggleSizeBtn.Text = "-"
    toggleSizeBtn.Font = Enum.Font.GothamBold
    toggleSizeBtn.TextSize = 24
    toggleSizeBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleSizeBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleSizeBtn.Parent = frame

    local isExpanded = true

    local function updateUI()
        if isExpanded then
            frame.Size = UDim2.new(0, 160, 0, 280)
            toggleSizeBtn.Text = "-"
            for _, child in ipairs(frame:GetChildren()) do
                if child:IsA("TextButton") and child ~= toggleSizeBtn then
                    child.Visible = true
                end
            end
            title.Text = "Admin Tools"
        else
            frame.Size = UDim2.new(0, 160, 0, 40)
            toggleSizeBtn.Text = "+"
            for _, child in ipairs(frame:GetChildren()) do
                if child:IsA("TextButton") and child ~= toggleSizeBtn then
                    child.Visible = false
                end
            end
            title.Text = "Menu"
        end
    end

    toggleSizeBtn.MouseButton1Click:Connect(function()
        isExpanded = not isExpanded
        updateUI()
    end)

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

    createToggleButton("Wallhack", 90, function(state)
        isWallhackEnabled = state
        applyWallhack(state)
    end)

    createToggleButton("Invincible", 140, function(state)
        isInvincible = state
        toggleInvincible(state)
    end)

    updateUI()
end

-- Boucle d’update principale
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestTarget()
        aimAt(target)
    end
end)

if ADMIN_USERNAMES[LocalPlayer.Name] then
    createMainGUI()
    print("✅ Admin Tools prêtes.")
else
    warn("❌ Ce script est réservé aux admins.")
end
