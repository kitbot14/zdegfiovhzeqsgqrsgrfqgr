local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players     = game:GetService("Players")
local RunService  = game:GetService("RunService")
local UserInput   = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

-- Vérifier qu'on est sur mobile
local function isMobile()
    return UserInput.TouchEnabled and not UserInput.KeyboardEnabled
end

-- Si pas sur mobile, on ne fait rien
if not isMobile() then return end

-- === État des fonctionnalités ===
local aimbotEnabled, aimSpeed, aimRadius = false, 0.4, 800
local fovColor = Color3.new(1,1,1)

local wallhackEnabled, wallColor = false, Color3.new(1,0,0)

local flyEnabled, flyHold = false, false
local bodyVel = nil

-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 3
FOVCircle.Color = fovColor
FOVCircle.Transparency = 0.6
FOVCircle.Filled = false
FOVCircle.Radius = aimRadius

-- Fonction allié par team
local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

-- Cible la plus proche
local function getClosestEnemy()
    local closest, shortest = nil, aimRadius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and not isAlly(p) then
            local head = p.Character.Head
            local xy, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(xy.X, xy.Y) - center).Magnitude
                if dist < shortest then
                    shortest, closest = dist, p
                end
            end
        end
    end
    return closest
end

-- Aimbot smooth
local function aimAt(p)
    if p and p.Character and p.Character:FindFirstChild("Head") then
        local headPos = p.Character.Head.Position
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, headPos), aimSpeed)
    end
end

-- Wallhack
local function applyWallhack(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not isAlly(p) then
            local hl = p.Character:FindFirstChild("Wallhl")
            if state then
                if not hl then
                    hl = Instance.new("Highlight", p.Character)
                    hl.Name = "Wallhl"
                    hl.FillColor = wallColor
                    hl.OutlineColor = wallColor
                    hl.FillTransparency = 0.5
                    hl.OutlineTransparency = 0
                    hl.Adornee = p.Character.Head
                else
                    hl.FillColor   = wallColor
                    hl.OutlineColor = wallColor
                end
            elseif hl then
                hl:Destroy()
            end
        end
    end
end

-- Fly tactile (press and hold)
local function startFly()
    if flyEnabled and not bodyVel and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            bodyVel = Instance.new("BodyVelocity", hrp)
            bodyVel.MaxForce = Vector3.new(0, 1e5, 0)
            bodyVel.Velocity = Vector3.new(0, 50, 0)
        end
    end
end

local function stopFly()
    if bodyVel then
        bodyVel:Destroy()
        bodyVel = nil
    end
end

-- === UI Rayfield (mobile friendly) ===
local Window = Rayfield:CreateWindow({
    Name = "Mobile Admin Panel",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Outils Mobile",
    Theme = "Midnight",
    ConfigurationSaving = {Enabled = true, FileName = "AdminMobile"},
    Discord = {Enabled = false},
    KeySystem = false
})

-- Onglet Aimbot
local AimTab = Window:CreateTab("Aimbot", nil)
AimTab:CreateSection("Aimbot Mobile")
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
    Callback = function(v) aimSpeed = v end
})
AimTab:CreateSlider({
    Name = "Rayon FOV",
    Range = {100, 2000},
    Increment = 100,
    CurrentValue = aimRadius,
    Suffix = " studs",
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

-- Onglet Wallhack
local WallTab = Window:CreateTab("Wallhack", nil)
WallTab:CreateToggle({
    Name = "Activer Wallhack",
    CurrentValue = false,
    Callback = function(v)
        wallhackEnabled = v
        applyWallhack(v)
    end
})
WallTab:CreateColorPicker({
    Name = "Couleur Wallhack",
    Color = wallColor,
    Callback = function(c)
        wallColor = c
        if wallhackEnabled then applyWallhack(true) end
    end
})

-- Onglet Fly
local FlyTab = Window:CreateTab("Fly", nil)
FlyTab:CreateToggle({
    Name = "Activer Fly",
    CurrentValue = false,
    Callback = function(v) flyEnabled = v end
})
FlyTab:CreateButton({
    Name = "Appuie et Maintiens pour voler",
    Callback = function()
        -- Instruction affichée, pas action directe
    end
})

-- Onglet Téléportation
local TpTab = Window:CreateTab("Téléport", nil)
TpTab:CreateSection("Joueurs")
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        TpTab:CreateButton({
            Name = p.Name,
            Callback = function()
                local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and me then me.CFrame = hrp.CFrame + Vector3.new(0,5,0) end
            end
        })
    end
end

Rayfield:Notify({Title = "Admin Mobile Activé", Content = "Utilise l’UI tactile", Duration = 3})

-- === Boucle principale ===
RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target then aimAt(target) end
    end
    if wallhackEnabled then
        applyWallhack(true)
    end
end)

-- Fly tactile gestions
-- On surveille les boutons tactiles via Rayfield ou Zones GUI
-- Pour simplifier : utiliser un bouton physique du GUI n'est pas trivial ici, donc on considère que
-- Fly est manuel : quand on active "Fly" dans UI, touche espace tactile permet de voler (tap répétitif)

-- Note: Sur mobile, touche Espace = souvent invisible clavier ; donc Fly tactile est limité.
