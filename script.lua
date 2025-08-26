Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Vérifie si on est bien sur mobile
local function isMobile()
    return UserInput.TouchEnabled and not UserInput.KeyboardEnabled
end

if not isMobile() then return end

-- Variables
local aimbotEnabled, aimSpeed, aimRadius = false, 0.4, 800
local fovColor = Color3.new(1,1,1)
local wallhackEnabled, wallColor = false, Color3.new(1,0,0)

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = fovColor
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Radius = aimRadius

-- Détection d'allié
local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

-- Trouver l'ennemi le plus proche
local function getClosestEnemy()
    local closest = nil
    local shortest = aimRadius
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and not isAlly(player) then
            local headPos = player.Character.Head.Position
            local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)
            
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end
    
    return closest
end

-- Aimbot ciblage lisse
local function aimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local headPos = target.Character.Head.Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), aimSpeed)
    end
end

-- Wallhack Client uniquement
local function updateWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not isAlly(p) then
            local char = p.Character
            local hl = char:FindFirstChild("Wallhl")
            
            if wallhackEnabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "Wallhl"
                    hl.FillColor = wallColor
                    hl.OutlineColor = wallColor
                    hl.FillTransparency = 0.3
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
                    hl.Parent = char
                else
                    hl.FillColor = wallColor
                    hl.OutlineColor = wallColor
                end
            elseif hl then
                hl:Destroy()
            end
        end
    end
end

-- Interface Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Mobile ESP + Aimbot",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Optimisé Mobile",
    Theme = "Midnight",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

-- Aimbot UI
local AimTab = Window:CreateTab("Aimbot", nil)
AimTab:CreateToggle({
    Name = "Activer Aimbot",
    CurrentValue = false,
    Callback = function(v)
        aimbotEnabled = v
        FOVCircle.Visible = v
    end
})
AimTab:CreateSlider({
    Name = "Vitesse Aimbot",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = aimSpeed,
    Callback = function(v)
        aimSpeed = v
    end
})
AimTab:CreateSlider({
    Name = "Rayon FOV",
    Range = {100, 2000},
    Increment = 100,
    CurrentValue = aimRadius,
    Callback = function(v)
        aimRadius = v
        FOVCircle.Radius = v
    end
})
AimTab:CreateColorPicker({
    Name = "Couleur FOV",
    Color = fovColor,
    Callback = function(c)
        fovColor = c
        FOVCircle.Color = c
    end
})

-- Wallhack UI
local WallTab = Window:CreateTab("Wallhack", nil)
WallTab:CreateToggle({
    Name = "Activer Wallhack",
    CurrentValue = false,
    Callback = function(v)
        wallhackEnabled = v
        updateWallhack()
    end
})
WallTab:CreateColorPicker({
    Name = "Couleur Wallhack",
    Color = wallColor,
    Callback = function(c)
        wallColor = c
        if wallhackEnabled then updateWallhack() end
    end
})

-- Notification
Rayfield:Notify({
    Title = "Script Mobile Chargé",
    Content = "Aimbot & Wallhack prêts",
    Duration = 3
})

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Update FOV position
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    -- Aimbot
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target then aimAt(target) end
    end

    -- Wallhack mise à jour
    if wallhackEnabled then
        updateWallhack()
    end
end)
