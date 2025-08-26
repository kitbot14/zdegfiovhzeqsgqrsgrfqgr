local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local enabled = false
local speed = 0.4
local radius = 800

-- Récupérer la team d’un joueur (priorité à player.Team, sinon StringValue "team" dans Character)
local function getPlayerTeam(player)
    if player.Team then
        return player.Team.Name -- Roblox Team object, on récupère le nom de la team
    elseif player.Character then
        local teamVal = player.Character:FindFirstChild("team") or player.Character:FindFirstChild("Team")
        if teamVal and teamVal:IsA("StringValue") then
            return teamVal.Value
        end
    end
    return nil
end

-- Vérifier si un joueur est allié
local function isAlly(player)
    local localTeam = getPlayerTeam(LocalPlayer)
    local otherTeam = getPlayerTeam(player)
    if localTeam and otherTeam then
        return localTeam == otherTeam
    end
    return false
end

-- Trouver l’ennemi le plus proche dans la FOV
local function getClosestEnemy()
    local closest = nil
    local shortest = radius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Humanoid") then
            if not isAlly(player) then
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
    end
    return closest
end

-- Aimer en douceur vers la cible
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

-- DEBUG : affichage des teams dans la console pour vérifier
task.spawn(function()
    while true do
        print("LocalPlayer team:", getPlayerTeam(LocalPlayer))
        for _, p in ipairs(Players:GetPlayers()) do
            print(p.Name, "team:", getPlayerTeam(p))
        end
        wait(5)
    end
end)

return module
