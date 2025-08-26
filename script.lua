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

-- Vars
local aimbotEnabled = false
local aimSpeed = 0.4
local aimRadius = 800
local fovColor = Color3.new(1,1,1)
local wallhackEnabled = false
local wallColor = Color3.new(1,0,0)
local flyEnabled = false
local flying = false

-- FOV circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = fovColor
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Radius = aimRadius

-- Est-ce un allié ?
local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

-- Trouver l'ennemi le plus proche dans le FOV
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
                    -- DEBUG : décommenter pour voir les distances
                    -- print(player.Name, "distance to center:", dist)
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

-- Aimbot mobile → faire tourner le personnage vers la cible en douceur
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

-- Wallhack
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

-- Fly mobile avec saut
local function enableFly()
    if flying or not flyEnabled then return end
    flying = true
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "MobileFly"
    bv.Velocity = Vector3.new(0, 50, 0)
    bv.MaxForce = Vector3.new(0, 100000, 0)
    bv.P = 10000
    bv.Parent = hrp
end

local function disableFly()
    flying = false
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("MobileFly")
        if bv then bv:Destroy() end
    end
end

-- Détection du saut
local function setupJumpFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    hum.Jumping:Connect(function(isJumping)
        if flyEnabled then
            if isJumping then
                enableFly()
            else
                disableFly()
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(setupJumpFly)
if LocalPlayer.Character then
    setupJumpFly()
end

-- UI Rayfield
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

local FlyTab = Window:CreateTab("Fly", nil)
FlyTab:CreateToggle({
    Name = "Fly avec bouton Saut",
    CurrentValue = false,
    Callback = function(v)
        flyEnabled = v
        if not v then disableFly() end
    end
})

Rayfield:Notify({
    Title = "✅ Chargé",
    Content = "Aimbot + Fly + ESP OK sur mobile",
    Duration = 4
})

-- Boucle principale
RunService.RenderStepped:Connect(function()
    -- Mise à jour position cercle FOV au centre écran
    if FOVCircle.Visible then
        FOVCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
        FOVCircle.Radius = aimRadius
        FOVCircle.Color = fovColor
    end

    if aimbotEnabled then
        local target = getClosestEnemy()
        if target then
            aimAt(target)
        end
    end

    if wallhackEnabled then
        updateWallhack()
    end
end)
