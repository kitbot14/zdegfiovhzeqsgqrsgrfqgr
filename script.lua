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

-- 📱 Aimbot Admin Mobile avec GUI - LocalScript (à placer dans StarterPlayerScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UIS = UserInputService

-- ✅ Configuration
local ADMIN_USERNAMES = {
    ["kitlebot10"] = true, -- ⚠️ Remplace "TonPseudo" par ton nom Roblox
}

local isAimbotEnabled = false
local isFlyEnabled = false
local aimRadius = 1000

-- 🧠 Détection mobile
local function isMobile()
    return UIS.TouchEnabled and not UIS.KeyboardEnabled
end

-- 🎯 Fonction pour trouver la cible la plus proche
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

-- 🧭 Viser automatiquement
local function aimAt(target)
    if target then
        local dir = (target.Position - Camera.CFrame.Position).Unit
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, Camera.CFrame.Position + dir)
    end
end

-- 🧱 Wallhack : rendre tous les joueurs semi-transparents et en surbrillance
local function enableWallhack()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            for _, part in ipairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.LocalTransparencyModifier = 0.5 -- semi-transparent
                    -- Optionnel : ajouter un highlight
                    if not part:FindFirstChild("WallhackHighlight") then
                        local highlight = Instance.new("SelectionBox")
                        highlight.Name = "WallhackHighlight"
                        highlight.Adornee = part
                        highlight.LineThickness = 0.05
                        highlight.Color3 = Color3.fromRGB(0, 255, 255)
                        highlight.Parent = part
                    end
                end
            end
        end
    end
end

-- Mise à jour wallhack à chaque joueur ajouté ou respawn
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        wait(1)
        enableWallhack()
    end)
end)

if LocalPlayer.Character then
    enableWallhack()
end

-- ✈️ Fly basique local (client-side) indétectable côté serveur
local flySpeed = 50
local flyVelocity = nil

local function toggleFly(state)
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") or not LocalPlayer.Character:FindFirstChild("Humanoid") then return end
    local hrp = LocalPlayer.Character.HumanoidRootPart
    local humanoid = LocalPlayer.Character.Humanoid

    if state then
        humanoid.PlatformStand = true -- désactive la physique classique
        flyVelocity = Instance.new("BodyVelocity")
        flyVelocity.Velocity = Vector3.new(0,0,0)
        flyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyVelocity.Parent = hrp
    else
        humanoid.PlatformStand = false
        if flyVelocity then
            flyVelocity:Destroy()
            flyVelocity = nil
        end
    end
end

-- Contrôles du fly (touches WASD + E/Q pour monter/descendre, ou commandes tactiles)
local moveVector = Vector3.new(0,0,0)

local function updateFlyMovement()
    if not flyVelocity then return end

    local cameraLook = workspace.CurrentCamera.CFrame.LookVector
    local rightVec = workspace.CurrentCamera.CFrame.RightVector

    local direction = (cameraLook * moveVector.Z) + (rightVec * moveVector.X) + Vector3.new(0, moveVector.Y, 0)
    flyVelocity.Velocity = direction * flySpeed
end

-- Gestion des touches pour le fly
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
    elseif input.UserInputType == Enum.UserInputType.Touch then
        -- Pour mobile, on pourrait gérer un joystick virtuel ou rien ici (complexe)
        -- Pour simplifier, on ignore ou on peut étendre plus tard
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

-- Mise à jour continue du fly
RunService.RenderStepped:Connect(function()
    if isFlyEnabled then
        updateFlyMovement()
    end
end)

UIS.InputBegan:Connect(onInputBegan)
UIS.InputEnded:Connect(onInputEnded)

-- 🖼️ Création du GUI avec boutons en haut à droite (Aimbot + Fly)
local function createAimbotGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AimbotGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    -- Bouton Aimbot
    local toggleAimbotBtn = Instance.new("TextButton")
    toggleAimbotBtn.Size = UDim2.new(0, 120, 0, 50)
    toggleAimbotBtn.Position = UDim2.new(1, -130, 0, 20)
    toggleAimbotBtn.AnchorPoint = Vector2.new(1, 0)
    toggleAimbotBtn.Text = "Aimbot OFF"
    toggleAimbotBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleAimbotBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleAimbotBtn.Font = Enum.Font.GothamBold
    toggleAimbotBtn.TextSize = 20
    toggleAimbotBtn.Parent = gui

    toggleAimbotBtn.MouseButton1Click:Connect(function()
        isAimbotEnabled = not isAimbotEnabled
        toggleAimbotBtn.Text = isAimbotEnabled and "Aimbot ON" or "Aimbot OFF"
        toggleAimbotBtn.BackgroundColor3 = isAimbotEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
    end)

    -- Bouton Fly
    local toggleFlyBtn = Instance.new("TextButton")
    toggleFlyBtn.Size = UDim2.new(0, 120, 0, 50)
    toggleFlyBtn.Position = UDim2.new(1, -130, 0, 80) -- juste en dessous du bouton Aimbot
    toggleFlyBtn.AnchorPoint = Vector2.new(1, 0)
    toggleFlyBtn.Text = "Fly OFF"
    toggleFlyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleFlyBtn.TextColor3 = Color3.new(1, 1, 1)
    toggleFlyBtn.Font = Enum.Font.GothamBold
    toggleFlyBtn.TextSize = 20
    toggleFlyBtn.Parent = gui

    toggleFlyBtn.MouseButton1Click:Connect(function()
        isFlyEnabled = not isFlyEnabled
        toggleFlyBtn.Text = isFlyEnabled and "Fly ON" or "Fly OFF"
        toggleFlyBtn.BackgroundColor3 = isFlyEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
        toggleFly(isFlyEnabled)
    end)
end

-- 🚀 Lancer l’aimbot
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestTarget()
        aimAt(target)
    end
end)

-- ✅ Lancer si admin et mobile
if ADMIN_USERNAMES[LocalPlayer.Name] and isMobile() then
    createAimbotGUI()
    print("✅ Aimbot & Fly admin mobile prêt.")
else
    warn("❌ Ce script est réservé aux admins sur mobile.")
end
