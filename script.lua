-- Fonction pour modifier un attribut dans toutes les tables du GC
local function toggleTableAttribute(attribute, value)
    for _, gcVal in pairs(getgc(true)) do
        if type(gcVal) == "table" and rawget(gcVal, attribute) then
            gcVal[attribute] = value
        end
    end
end

toggleTableAttribute("ShootCooldown", 0)
toggleTableAttribute("ShootSpread", 0)
toggleTableAttribute("ShootRecoil", 0)

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
local aimRadius = 1000
local flySpeed = 50
local flyVelocity = nil
local moveVector = Vector3.new(0, 0, 0)

local UIS = UserInputService

local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

-- Aimbot : trouve la cible la plus proche
local function getClosestTarget()
    local closest = nil
    local shortestDistance = aimRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPoint, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - center).Magnitude
                if dist < shortestDistance then
                    shortestDistance = dist
                    closest = head
                end
            end
        end
    end

    return closest
end

local function aimAt(target)
    if target then
        local dir = (target.Position - Camera.CFrame.Position).Unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
    end
end

-- Wallhack amélioré : rend le joueur visible à travers murs en modifiant Transparency et ajout Highlight
local function applyWallhackToPlayer(player)
    if player == LocalPlayer or not player.Character then return end
    for _, part in ipairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 0.5
            part.CanCollide = false -- peut traverser murs, mais on peut enlever si tu veux pas ça
            if not part:FindFirstChild("WallhackHighlight") then
                local highlight = Instance.new("Highlight")
                highlight.Name = "WallhackHighlight"
                highlight.Adornee = part
                highlight.FillColor = Color3.fromRGB(0, 255, 255)
                highlight.OutlineColor = Color3.fromRGB(0, 150, 255)
                highlight.Parent = part
            end
        end
    end
end

local function removeWallhackFromPlayer(player)
    if not player.Character then return end
    for _, part in ipairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") then
            part.Transparency = 0
            part.CanCollide = true
            local highlight = part:FindFirstChild("WallhackHighlight")
            if highlight then highlight:Destroy() end
        end
    end
end

local function updateWallhack()
    for _, player in ipairs(Players:GetPlayers()) do
        if isWallhackEnabled then
            applyWallhackToPlayer(player)
        else
            removeWallhackFromPlayer(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        wait(1)
        updateWallhack()
    end)
end)

if LocalPlayer.Character then
    updateWallhack()
end

-- Fly indétectable client-side
local function toggleFly(state)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local humanoid = LocalPlayer.Character.Humanoid

    if state then
        humanoid.PlatformStand = true
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Velocity = Vector3.new(0,0,0)
        flyVelocity.MaxForce = Vector3.new(1e5,1e5,1e5)
        flyVelocity.Parent = hrp
    else
        humanoid.PlatformStand = false
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
end

local function updateFlyMovement()
    if not flyVelocity then return end

    local cameraLook = workspace.CurrentCamera.CFrame.LookVector
    local rightVec = workspace.CurrentCamera.CFrame.RightVector

    local direction = (cameraLook * moveVector.Z) + (rightVec * moveVector.X) + Vector3.new(0, moveVector.Y, 0)
    flyVelocity.Velocity = direction * flySpeed
end

local function onInputBegan(input, gameProcessed)
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
    end
end

local function onInputEnded(input, gameProcessed)
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
end

RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestTarget()
        aimAt(target)
    end

    if isFlyEnabled then
        updateFlyMovement()
    end
end)

UIS.InputBegan:Connect(onInputBegan)
UIS.InputEnded:Connect(onInputEnded)

-- Création du GUI complet
local function createMainGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AdminToolsGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 160, 0, 180)
    frame.Position = UDim2.new(1, -170, 0, 20)
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

    -- Fonction utilitaire pour créer un bouton toggle
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
        updateWallhack()
    end)
end

-- Activation si admin & mobile
if ADMIN_USERNAMES[LocalPlayer.Name] and isMobile() then
    createMainGUI()
    print("✅ Admin Tools prêtes (Aimbot, Fly, Wallhack)")
else
    warn("❌ Ce script est réservé aux admins sur mobile.")
end
