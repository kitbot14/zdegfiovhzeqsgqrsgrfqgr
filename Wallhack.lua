local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local enemyColor = Color3.new(1, 0, 0) -- Rouge
local allyColor = Color3.new(0, 1, 0)  -- Vert

local function getTeamId(player)
    local teamIdValue = player:FindFirstChild("TeamId")
    if teamIdValue and teamIdValue:IsA("NumberValue") then
        return teamIdValue.Value
    end
    return nil
end

local LocalTeamId = nil

local function isAlly(player)
    local teamId = getTeamId(player)
    return teamId ~= nil and teamId == LocalTeamId
end

local function applyHighlight(player)
    if not player.Character then return end
    local char = player.Character

    local hl = char:FindFirstChild("Wallhl")
    if not hl then
        hl = Instance.new("Highlight")
        hl.Name = "Wallhl"
        hl.FillTransparency = 0.5
        hl.OutlineTransparency = 0
        hl.Adornee = char
        hl.Parent = char
    end

    if isAlly(player) then
        hl.FillColor = allyColor
        hl.OutlineColor = allyColor
    else
        hl.FillColor = enemyColor
        hl.OutlineColor = enemyColor
    end

    hl.Enabled = enabled
end

local function updateWallhack()
    LocalTeamId = getTeamId(LocalPlayer)  -- mettre à jour à chaque frame
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            applyHighlight(p)
        end
    end
end

local function clearHighlights()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character then
            local hl = p.Character:FindFirstChild("Wallhl")
            if hl then hl:Destroy() end
        end
    end
end

local module = {}

function module.SetEnabled(v)
    enabled = v
    if v then
        updateWallhack()
    else
        clearHighlights()
    end
end

function module.SetEnemyColor(c)
    enemyColor = c
end

function module.SetAllyColor(c)
    allyColor = c
end

function module.Update()
    if enabled then
        updateWallhack()
    end
end

return module
