local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Config
local ADMIN_USERNAMES = {
    ["kitlebot11"] = true, -- Remplace par ton pseudo Roblox
}

local ALLIES = {
    ["modylem"] = true, -- Ajoute tes alliés ici pour ne pas les viser
}

local AIM_RADIUS = 1000
local AIM_SMOOTHNESS = 0.4

local isAimbotEnabled = false

-- Fonction pour savoir si joueur valide (pas mort, pas ragdoll)
local function isPlayerValid(player)
    if not player.Character then return false end
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return false end
    if player.Character:FindFirstChild("Core") then return false end -- Ignore ragdoll / morts
    return true
end

-- Trouver cible la plus proche valide
local function getClosestTarget()
    local closestHead = nil
    local shortestDistance = AIM_RADIUS
    local screenCenter = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and not ALLIES[player.Name] and isPlayerValid(player) then
            local head = player.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and screenPos.Z > 0 then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist < shortestDistance then
                        shortestDistance = dist
                        closestHead = head
                    end
                end
            end
        end
    end

    return closestHead
end

-- Aimer en douceur vers la cible
local function aimAt(targetHead)
    if not targetHead then return end
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end
    local direction = (targetHead.Position - rootPart.Position).Unit
    local desiredCFrame = CFrame.new(rootPart.Position, rootPart.Position + direction)
    rootPart.CFrame = rootPart.CFrame:Lerp(desiredCFrame, AIM_SMOOTHNESS)
end

-- Toggle aimbot avec la touche P
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.P then
        if ADMIN_USERNAMES[LocalPlayer.Name] then
            isAimbotEnabled = not isAimbotEnabled
            print("Aimbot " .. (isAimbotEnabled and "activé" or "désactivé"))
        else
            warn("❌ Script réservé aux admins.")
        end
    end
end)

-- Boucle principale aimbot
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestTarget()
        aimAt(target)
    end
end)
