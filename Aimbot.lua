local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Paramètres
local enabled = false
local speed = 0.4
local radius = 800

-- Dessiner le cercle de FOV avec Drawing (compatible avec la plupart des exploits)
local fovCircle
local function createFOV()
    fovCircle = Drawing.new("Circle")
    fovCircle.Transparency = 1
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.new(1, 1, 1)
    fovCircle.Filled = false
    fovCircle.Radius = radius
    fovCircle.Visible = false
end
createFOV()

-- Trouver le joueur le plus proche au centre
local function getClosestPlayer()
    local closest, shortest = nil, radius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local part = player.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen and screenPos.Z > 0 then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortest then
                    shortest, closest = dist, player
                end
            end
        end
    end

    return closest
end

-- Viser vers la cible
local function aimAt(player)
    if not (player and player.Character) then return end
    local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if head and root then
        local dir = (head.Position - root.Position).Unit
        local newCF = CFrame.new(root.Position, root.Position + dir)
        root.CFrame = root.CFrame:Lerp(newCF, speed)
    end
end

-- Module API
local module = {}

function module.SetEnabled(v)
    enabled = v
    fovCircle.Visible = v
end

function module.SetSpeed(v)
    speed = v
end

function module.SetRadius(v)
    radius = v
    if fovCircle then fovCircle.Radius = v end
end

function module.Update()
    if not enabled then return end

    -- Met à jour le cercle
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    fovCircle.Position = center

    local target = getClosestPlayer()
    if target then aimAt(target) end
end

-- Connexion au RenderStepped pour fonctionnement fluide
RunService.RenderStepped:Connect(module.Update)

return module
