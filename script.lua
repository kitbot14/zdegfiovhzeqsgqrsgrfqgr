local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- === VARIABLES ET OPTIONS ===
-- Aimbot
local aimbotEnabled, aimSpeed, aimRadius = false, 0.4, 800
local fovColor = Color3.new(1, 1, 1)
local aimbotKey = Enum.KeyCode.Q

-- FOV dessin avec Drawing API
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = fovColor
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.Radius = aimRadius

-- Wallhack
local wallhackEnabled = false
local wallColor = Color3.new(1, 0, 0)

-- Fly
local flyEnabled = false
local flyKey = Enum.KeyCode.Space
local bodyVel = nil

-- === FONCTIONS ===

-- Vérifie si un joueur est dans la même équipe
local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

-- Trouver cible ennemie la plus proche dans le FOV
local function getClosestEnemy()
    local closest, shortest = nil, aimRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and not isAlly(p) then
            local head = p.Character.Head
            local screen, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screen.X, screen.Y) - center).Magnitude
                if dist < shortest then
                    shortest = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

-- Vise la tête du joueur cible de façon smooth
local function aimAt(p)
    if not (p and p.Character and p.Character:FindFirstChild("Head")) then return end
    local targetPos = p.Character.Head.Position
    Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), aimSpeed)
end

-- Wallhack (Highlight sur la tête ennemie)
local function applyWallhack(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not isAlly(p) then
            local hl = p.Character:FindFirstChild("Wallhl")
            if state then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "Wallhl"
                    hl.FillColor = wallColor
                    hl.OutlineColor = wallColor
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Adornee = p.Character.Head
                    hl.Parent = p.Character
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

-- Gestion fly simple
UserInput.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == flyKey then
        if not flyEnabled then return end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.Velocity = Vector3.new(0, 50, 0)
            bodyVel.MaxForce = Vector3.new(0, 1e5, 0)
        end
    end
end)
UserInput.InputEnded:Connect(function(input, gp)
    if input.KeyCode == flyKey and bodyVel then
        bodyVel:Destroy()
        bodyVel = nil
    end
end)

-- === INTERFACE Rayfield ===

local Window = Rayfield:CreateWindow({
    Name = "Admin Panel V2",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Options avancées",
    Theme = "Midnight",
    ConfigurationSaving = { Enabled = true, FileName = "AdminV2" },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Onglet Aimbot
local AimTab = Window:CreateTab("Aimbot", nil)
AimTab:CreateSection("Configuration du Aimbot")
AimTab:CreateToggle({ Name = "Activer Aimbot", CurrentValue = false, Callback = function(v) aimbotEnabled = v; FOVCircle.Visible = v end })
AimTab:CreateKeybind({ Name = "Touche Aimbot", CurrentKeybind = aimbotKey.Name, Callback = function(k) aimbotKey = Enum.KeyCode[k] end })
AimTab:CreateSlider({ Name = "Aim Speed", Range = { 0.1, 1 }, Increment = 0.1, CurrentValue = aimSpeed, Callback = function(v) aimSpeed = v end })
AimTab:CreateSlider({ Name = "Rayon FOV", Range = { 100, 2000 }, Increment = 50, CurrentValue = aimRadius, Suffix = " studs", Callback = function(v) aimRadius = v; FOVCircle.Radius = v end })
AimTab:CreateColorPicker({ Name = "Couleur FOV", Color = fovColor, Callback = function(c) fovColor = c; FOVCircle.Color = c end })

-- Onglet Wallhack
local WallTab = Window:CreateTab("Wallhack", nil)
WallTab:CreateToggle({ Name = "Activer Wallhack", CurrentValue = false, Callback = function(v) wallhackEnabled = v; applyWallhack(v) end })
WallTab:CreateColorPicker({ Name = "Couleur Wallhack", Color = wallColor, Callback = function(c) wallColor = c; if wallhackEnabled then applyWallhack(true) end end })

-- Onglet Fly
local FlyTab = Window:CreateTab("Fly", nil)
FlyTab:CreateToggle({ Name = "Activer Fly", CurrentValue = false, Callback = function(v) flyEnabled = v end })
FlyTab:CreateKeybind({ Name = "Touche Fly", CurrentKeybind = flyKey.Name, Callback = function(k) flyKey = Enum.KeyCode[k] end })

-- Onglet Téléport
local TpTab = Window:CreateTab("Téléport", nil)
TpTab:CreateSection("Liste des joueurs")
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        TpTab:CreateButton({
            Name = p.Name,
            Callback = function()
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and me then me.CFrame = hrp.CFrame + Vector3.new(0, 5, 0) end
            end
        })
    end
end

Rayfield:Notify({
    Title = "Admin Panel V2",
    Content = "Activé",
    Duration = 3
})

-- === BOUCLE PRINCIPALE ===
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target then aimAt(target) end
    end

    if wallhackEnabled then
        applyWallhack(true)
    end
end)
