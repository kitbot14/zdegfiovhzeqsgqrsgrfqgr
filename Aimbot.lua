local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local aimbotEnabled = false
local aimSpeed = 0.4
local aimRadius = 800

local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

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

RunService.RenderStepped:Connect(function()
    if aimbotEnabled then
        local target = getClosestEnemy()
        if target then
            aimAt(target)
        end
    end
end)

-- API simple pour activer/désactiver aimbot
return {
    setEnabled = function(v) aimbotEnabled = v end,
    setAimSpeed = function(v) aimSpeed = v end,
    setAimRadius = function(v) aimRadius = v end,
}
