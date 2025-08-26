local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInput = game:GetService("UserInputService")

local enabled = false
local speed = 0.4
local radius = 800
local fovColor = Color3.new(1,1,1)

-- Vérifie si allié
local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

-- Trouver ennemi le plus proche dans le FOV
local function getClosestEnemy()
    local closest = nil
    local shortest = radius
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and not isAlly(player) then
            local head = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and screenPos.Z > 0 then
                    local pos2D = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = (pos2D - screenCenter).Magnitude
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

-- Aimer vers la cible
local function aimAt(target)
    if target and target.Character then
        local head = target.Character:FindFirstChild("Head") or target.Character:FindFirstChild("HumanoidRootPart")
        local char = LocalPlayer.Character
        if head and char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local direction = (head.Position - root.Position).Unit
                local desiredCFrame = CFrame.new(root.Position, root.Position + direction)
                root.CFrame = root.CFrame:Lerp(desiredCFrame, speed)
            end
        end
    end
end

-- Public API
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
    fovColor = c
end

function module.Update()
    if not enabled then return end
    local target = getClosestEnemy()
    if target then
        aimAt(target)
    end
end

return module
