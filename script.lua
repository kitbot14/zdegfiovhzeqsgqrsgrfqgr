Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Vérifie si mobile
local function isMobile()
    return UserInput.TouchEnabled and not UserInput.KeyboardEnabled
end
if not isMobile() then return end

-- Variables globales (seront contrôlées par le menu)
local aimbotEnabled = false
local aimSpeed = 0.4
local aimRadius = 800
local fovColor = Color3.new(1,1,1)

local wallhackEnabled = false
local wallColor = Color3.new(1,0,0)

local flyEnabled = false

-- Cercle FOV (drawing)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = fovColor
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Radius = aimRadius

-- Chargement modules (à adapter avec tes liens http, ici j’ai mis des exemples)
local AimbotModule = loadstring(game:HttpGet("https://tonserver.com/aimbot.lua"))()
local WallhackModule = loadstring(game:HttpGet("https://tonserver.com/wallhack.lua"))()
local FlyModule = loadstring(game:HttpGet("https://github.com/kitbot14/zdegfiovhzeqsgqrsgrfqgr/raw/refs/heads/main/Fly.lua"))()

-- Setup menu Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Aimbot + Fly Mobile",
    LoadingTitle = "Mobile Script",
    LoadingSubtitle = "Aimbot & Fly OK",
    Theme = "Midnight",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

local AimTab = Window:CreateTab("Aimbot", nil)
AimTab:CreateToggle({
    Name = "Activer Aimbot",
    CurrentValue = false,
    Callback = function(v)
        aimbotEnabled = v
        FOVCircle.Visible = v
        AimbotModule.SetEnabled(v)
    end
})
AimTab:CreateSlider({
    Name = "Vitesse Aimbot",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = aimSpeed,
    Callback = function(v)
        aimSpeed = v
        AimbotModule.SetSpeed(v)
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
        AimbotModule.SetRadius(v)
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

local WallTab = Window:CreateTab("Wallhack", nil)
WallTab:CreateToggle({
    Name = "Activer Wallhack",
    CurrentValue = false,
    Callback = function(v)
        wallhackEnabled = v
        WallhackModule.SetEnabled(v)
    end
})
WallTab:CreateColorPicker({
    Name = "Couleur Wallhack",
    Color = wallColor,
    Callback = function(c)
        wallColor = c
        WallhackModule.SetColor(c)
    end
})

local FlyTab = Window:CreateTab("Fly", nil)
FlyTab:CreateToggle({
    Name = "Fly avec bouton Saut",
    CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        FlyModule.SetEnabled(v)
    end
})

Rayfield:Notify({
    Title = "✅ Chargé",
    Content = "Aimbot + Fly + ESP OK sur mobile",
    Duration = 4
})

-- Boucle principale (mise à jour FOV + appel modules)
RunService.RenderStepped:Connect(function()
    if FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FOVCircle.Radius = aimRadius
        FOVCircle.Color = fovColor
    end

    if aimbotEnabled then
        AimbotModule.Update()
    end

    if wallhackEnabled then
        WallhackModule.Update()
    end
end)
