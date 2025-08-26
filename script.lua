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
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ✅ Configuration
local ADMIN_USERNAMES = {
    ["kitlebot10"] = true, -- ⚠️ Remplace "TonPseudo" par ton nom Roblox
}

local isAimbotEnabled = false
local aimRadius = 1000

-- 🧠 Détection mobile
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
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
                local touchPos = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local dist = (Vector2.new(screenPoint.X, screenPoint.Y) - touchPos).Magnitude

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

-- 🖼️ Création du GUI avec bouton en haut à droite
local function createAimbotGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AimbotGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 120, 0, 50)
    toggleButton.Position = UDim2.new(1, -130, 0, 20) -- En haut à droite
    toggleButton.AnchorPoint = Vector2.new(1, 0)
    toggleButton.Text = "Aimbot OFF"
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleButton.TextColor3 = Color3.new(1, 1, 1)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 20
    toggleButton.Parent = gui

    toggleButton.MouseButton1Click:Connect(function()
        isAimbotEnabled = not isAimbotEnabled
        toggleButton.Text = isAimbotEnabled and "Aimbot ON" or "Aimbot OFF"
        toggleButton.BackgroundColor3 = isAimbotEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
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
    print("✅ Aimbot admin mobile prêt.")
else
    warn("❌ Ce script est réservé aux admins sur mobile.")
end
