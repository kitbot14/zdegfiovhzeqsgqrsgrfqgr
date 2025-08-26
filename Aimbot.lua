-- 📱 Aimbot Admin Mobile avec GUI & Lerp - LocalScript (StarterPlayerScripts)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ✅ Config
local ADMIN_USERNAMES = {
    ["kitlebot10"] = true, -- 🔁 Remplace avec ton pseudo si besoin
}

local isAimbotEnabled = false
local aimRadius = 800
local aimSpeed = 0.4

-- 🧠 Vérifier mobile
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- 🧠 Vérifie si un joueur est un allié
local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

-- 🎯 Obtenir l'ennemi le plus proche dans le FOV
local function getClosestEnemy()
    local closest = nil
    local shortest = aimRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not isAlly(player) then
            local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and screenPos.Z > 0 then
                    local pos2D = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (pos2D - screenCenter).Magnitude
                    if dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
            end
        end
    end

    return closest
end

-- 🚀 Viser la cible en interpolant
local function aimAt(target)
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        if head and char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local direction = (head.Position - root.Position).Unit
                local desiredCFrame = CFrame.new(root.Position, root.Position + direction)
                root.CFrame = root.CFrame:Lerp(desiredCFrame, aimSpeed)
            end
        end
    end
end

-- 🖼️ GUI mobile
local function createAimbotGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AimbotGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 140, 0, 50)
    toggleButton.Position = UDim2.new(0.5, -70, 1, -80)
    toggleButton.AnchorPoint = Vector2.new(0.5, 1)
    toggleButton.Text = "Aimbot OFF"
    toggleButton.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    toggleButton.TextColor3 = Color3.new(1,1,1)
    toggleButton.Font = Enum.Font.GothamBold
    toggleButton.TextSize = 20
    toggleButton.Parent = gui

    toggleButton.MouseButton1Click:Connect(function()
        isAimbotEnabled = not isAimbotEnabled
        toggleButton.Text = isAimbotEnabled and "Aimbot ON" or "Aimbot OFF"
        toggleButton.BackgroundColor3 = isAimbotEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30,30,30)
    end)
end

-- 🌀 Loop principal
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestEnemy()
        aimAt(target)
    end
end)

-- 🎬 Démarrage conditionnel
if ADMIN_USERNAMES[LocalPlayer.Name] and isMobile() then
    createAimbotGUI()
    print("✅ Aimbot admin mobile actif.")
else
    warn("❌ Ce script est réservé aux admins sur mobile.")
end
