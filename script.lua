local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local isAimbot = false
local aimSpeed = 0.2
local aimRadius = 1000

local isWallhack = false
local wallColor = Color3.fromRGB(255, 0, 0)

-- Fonction pour le wallhack
local function applyWallhack(state)
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local highlight = player.Character:FindFirstChild("WallHighlight")
            if state then
                if not highlight then
                    local newHighlight = Instance.new("Highlight")
                    newHighlight.Name = "WallHighlight"
                    newHighlight.FillColor = wallColor
                    newHighlight.OutlineColor = wallColor
                    newHighlight.FillTransparency = 0.5
                    newHighlight.OutlineTransparency = 0
                    newHighlight.Adornee = player.Character
                    newHighlight.Parent = player.Character
                else
                    highlight.FillColor = wallColor
                    highlight.OutlineColor = wallColor
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

-- Trouver la cible la plus proche
local function getClosestTarget()
    local closest = nil
    local shortest = aimRadius

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screen, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screen.X, screen.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = player
                end
            end
        end
    end

    return closest
end

-- Aimbot avec interpolation
local function aimAt(player)
    if player and player.Character and player.Character:FindFirstChild("Head") then
        local head = player.Character.Head
        local current = Camera.CFrame
        local goal = CFrame.new(current.Position, head.Position)
        Camera.CFrame = current:Lerp(goal, aimSpeed)
    end
end

-- Création de l'interface
local Window = Rayfield:CreateWindow({
    Name = "Admin Panel",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Aimbot + Wallhack + TP",
    Theme = "Midnight",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "AdminConfig"
    },
    Discord = { Enabled = false },
    KeySystem = false,
})

local Main = Window:CreateTab("Main", nil)

-- Aimbot
Main:CreateSection("🎯 Aimbot")
Main:CreateToggle({
    Name = "Activer Aimbot",
    CurrentValue = false,
    Callback = function(v)
        isAimbot = v
    end
})

Main:CreateSlider({
    Name = "Vitesse du Aimbot",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = aimSpeed,
    Callback = function(v)
        aimSpeed = v
    end
})

Main:CreateSlider({
    Name = "Rayon de détection",
    Range = {100, 2000},
    Increment = 100,
    CurrentValue = aimRadius,
    Callback = function(v)
        aimRadius = v
    end
})

-- Wallhack
Main:CreateSection("🟥 Wallhack")
Main:CreateToggle({
    Name = "Activer Wallhack",
    CurrentValue = false,
    Callback = function(v)
        isWallhack = v
        applyWallhack(v)
    end
})

Main:CreateColorPicker({
    Name = "Couleur du Wallhack",
    Color = wallColor,
    Callback = function(c)
        wallColor = c
        if isWallhack then applyWallhack(true) end
    end
})

-- Téléportation
Main:CreateSection("📍 Téléportation")
Main:CreateButton({
    Name = "Ouvrir Menu Téléportation",
    Callback = function()
        local tpTab = Window:CreateTab("Joueurs", nil)
        tpTab:CreateSection("Clique sur un joueur pour te téléporter")
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                tpTab:CreateButton({
                    Name = player.Name,
                    Callback = function()
                        local targetHRP = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP and myHRP then
                            myHRP.CFrame = targetHRP.CFrame + Vector3.new(0, 5, 0)
                        end
                    end
                })
            end
        end
    end
})

-- Exécution du aimbot
RunService.RenderStepped:Connect(function()
    if isAimbot then
        local target = getClosestTarget()
        aimAt(target)
    end
end)

Rayfield:Notify({
    Title = "✅ Panel chargé",
    Content = "Aimbot & Téléportation disponibles",
    Duration = 4
})
