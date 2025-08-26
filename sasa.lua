-- Aimbot propre avec exclusion alliés & ragdolls pour Hypershot-like games

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuration
local ADMIN_USERNAMES = {
    ["kitlebot11"] = true, -- Remplace par ton pseudo Roblox
}

local ALLIES = {  -- Pseudos à ignorer dans l’aimbot (tes alliés)
    ["modylem"] = true
}

local AIM_RADIUS = 1000
local AIM_SMOOTHNESS = 0.4 -- de 0 (direct) à 1 (lent)

local isAimbotEnabled = false

-- Détection mobile
local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Vérifie si le joueur est vivant et pas ragdoll
local function isPlayerValid(player)
    if not player.Character then return false end

    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end

    -- Ignore si a un "Core" (ragdoll ou mort)
    if player.Character:FindFirstChild("Core") then return false end

    return true
end

-- Trouve la cible la plus proche valide
local function getClosestTarget()
    local closestHead = nil
    local shortestDistance = AIM_RADIUS
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer
           and not ALLIES[player.Name] -- Ignore alliés
           and isPlayerValid(player) then

            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestHead = head
                    end
                end
            end
        end
    end

    return closestHead
end

-- Aimer en douceur vers la cible
local function aimAt(targetHead)
    if not targetHead then return end

    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local direction = (targetHead.Position - rootPart.Position).Unit
    local desiredCFrame = CFrame.new(rootPart.Position, rootPart.Position + direction)

    -- Lerping pour aimbot smooth
    rootPart.CFrame = rootPart.CFrame:Lerp(desiredCFrame, AIM_SMOOTHNESS)
end

-- GUI toggle simple
local function createAimbotGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AimbotGUI"
    gui.ResetOnSpawn = false
    gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 0, 50)
    button.Position = UDim2.new(0.5, -60, 1, -70)
    button.AnchorPoint = Vector2.new(0.5, 1)
    button.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 20
    button.Text = "Aimbot OFF"
    button.Parent = gui

    button.MouseButton1Click:Connect(function()
        isAimbotEnabled = not isAimbotEnabled
        button.Text = isAimbotEnabled and "Aimbot ON" or "Aimbot OFF"
        button.BackgroundColor3 = isAimbotEnabled and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(30, 30, 30)
    end)
end

-- Boucle principale
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local targetHead = getClosestTarget()
        aimAt(targetHead)
    end
end)

-- Lancer uniquement si admin + mobile
if ADMIN_USERNAMES[LocalPlayer.Name] and isMobile() then
    createAimbotGUI()
    print("✅ Aimbot prêt et fonctionnel.")
else
    warn("❌ Script réservé aux admins mobiles.")
end
