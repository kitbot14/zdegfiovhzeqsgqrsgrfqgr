local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local enabled = false
local speed = 0.4
local radius = 800

-- Récupère la team "team" (StringValue) du joueur
local function getPlayerTeam(player)
    if player.Character then
        local teamVal = player.Character:FindFirstChild("team") or player.Character:FindFirstChild("Team")
        if teamVal and teamVal:IsA("StringValue") then
            return teamVal.Value
        end
    end
    return nil
end

-- Vérifie si un joueur est allié (même team)
local function isAlly(player)
    local localTeam = getPlayerTeam(LocalPlayer)
    local otherTeam = getPlayerTeam(player)
    if localTeam and otherTeam then
        return localTeam == otherTeam
    end
    return false
end

-- Trouve l'ennemi le plus proche dans le FOV
local function getClosestEnemy()
    local closest = nil
    local shortest = radius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") and not isAlly(player) then
            local targetPart = player.Character:FindFirstChild("Head") or player.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
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

-- Vise vers la cible en douceur
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

function module.Update()
    if not enabled then return end
    local target = getClosestEnemy()
    if target then
        aimAt(target)
    end
end

return module
