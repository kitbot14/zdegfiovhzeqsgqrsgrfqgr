local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local enabled = false
local speed = 0.4
local radius = 800
local fovColor = Color3.new(1,1,1)

-- Vérifie si allié
local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

-- Trouver ennemi le plus proche dans la FOV Circle
local function getClosestEnemy()
    local closest = nil
    local shortest = radius
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not isAlly(player) then
            local part = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if part then
                local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen and screenPos.Z > 0 then
                    local pos2D = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (pos2D - center).Magnitude
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

-- Aimer de manière fluide (Lerp) vers la cible
local function aimAt(target)
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        if head and char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local direction = (head.Position - root.Position).Unit
                local desired = CFrame.new(root.Position, root.Position + direction)
                root.CFrame = root.CFrame:Lerp(desired, speed)
            end
        end
    end
end

-- API publique pour ton loader
local module = {}

function module.SetEnabled(v)
    enabled = v
end

function module.SetSpeed(v)
    speed = v
end

function module.SetRadius(v)
    radius = v
end

function module.SetColor(c)
    fovColor = c  -- dans ce module ce n'est qu'un paramètre, utilisée par le cercle dans le loader
end

function module.Update()
    if not enabled then return end
    local target = getClosestEnemy()
    if target then
        aimAt(target)
    end
end

return module
