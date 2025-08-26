-- 🌌 Rayfield UI Loader
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- 📱 Vérifie si mobile
local function isMobile()
    return UserInput.TouchEnabled and not UserInput.KeyboardEnabled
end
if not isMobile() then return end

-- 🔗 Chargement modules
local AimbotModule = loadstring(game:HttpGet("https://github.com/kitbot14/zdegfiovhzeqsgqrsgrfqgr/raw/refs/heads/main/Aimbot.lua"))()
local WallhackModule = loadstring(game:HttpGet("https://github.com/kitbot14/zdegfiovhzeqsgqrsgrfqgr/raw/refs/heads/main/Wallhack.lua"))()
local FlyModule = loadstring(game:HttpGet("https://github.com/kitbot14/zdegfiovhzeqsgqrsgrfqgr/raw/refs/heads/main/Fly.lua"))()

-- 🔧 Variables globales
local aimbotEnabled = false
local aimSpeed = 0.4
local aimRadius = 800
local fovColor = Color3.fromRGB(255, 255, 255)

local wallEnabled = false
local enemyColor = Color3.fromRGB(255, 0, 0)
local allyColor = Color3.fromRGB(0, 255, 0)

local flyEnabled = false

-- 🔵 FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Radius = aimRadius
FOVCircle.Thickness = 2
FOVCircle.Filled = false
FOVCircle.Transparency = 0.5
FOVCircle.Color = fovColor

-- 🧱 Menu Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Mobile Hub ⚙️",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "Aimbot, Wallhack, Fly",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

-- Aimbot Tab
local AimTab = Window:CreateTab("🎯 Aimbot", nil)

AimTab:CreateToggle({
    Name = "Activer Aimbot",
    CurrentValue = false,
    Callback = function(v)
        aimbotEnabled = v
        AimbotModule.SetEnabled(v)
        FOVCircle.Visible = v
    end
})

AimTab:CreateSlider({
    Name = "Vitesse de visée",
    Range = {0.1, 1},
    Increment = 0.05,
    CurrentValue = aimSpeed,
    Callback = function(v)
        aimSpeed = v
        AimbotModule.SetSpeed(v)
    end
})

AimTab:CreateSlider({
    Name = "Rayon de FOV",
    Range = {100, 2000},
    Increment = 50,
    CurrentValue = aimRadius,
    Callback = function(v)
        aimRadius = v
        AimbotModule.SetRadius(v)
        FOVCircle.Radius = v
    end
})

AimTab:CreateColorPicker({
    Name = "Couleur FOV",
    Color = fovColor,
    Callback = function(c)
        fovColor = c
        FOVCircle.Color = c
        AimbotModule.SetColor(c)
    end
})

-- Wallhack Tab
local WallTab = Window:CreateTab("🔍 Wallhack", nil)

WallTab:CreateToggle({
    Name = "Activer Wallhack",
    CurrentValue = false,
    Callback = function(v)
        wallEnabled = v
        WallhackModule.SetEnabled(v)
    end
})

WallTab:CreateColorPicker({
    Name = "Couleur Ennemi",
    Color = enemyColor,
    Callback = function(c)
        enemyColor = c
        WallhackModule.SetEnemyColor(c)
    end
})

WallTab:CreateColorPicker({
    Name = "Couleur Allié",
    Color = allyColor,
    Callback = function(c)
        allyColor = c
        WallhackModule.SetAllyColor(c)
    end
})

-- Fly Tab
local FlyTab = Window:CreateTab("🚀 Fly", nil)

FlyTab:CreateToggle({
    Name = "Activer le Fly (saut)",
    CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        FlyModule.SetEnabled(v)
    end
})

-- ✅ Notification
Rayfield:Notify({
    Title = "✅ Chargé avec succès",
    Content = "Aimbot, Wallhack et Fly activés !",
    Duration = 4
})

-- ⏱ Boucle principale
RunService.RenderStepped:Connect(function()
    if FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    end

    if aimbotEnabled then
        AimbotModule.Update()
    end

    if wallEnabled then
        WallhackModule.Update()
    end
end)
