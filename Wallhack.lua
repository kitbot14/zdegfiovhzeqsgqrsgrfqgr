local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local enemyColor = Color3.new(1, 0, 0) -- Rouge
local allyColor = Color3.new(0, 1, 0)  -- Vert

-- Essaie de récupérer la team de plusieurs façons
local function getPlayerTeam(player)
    -- Priorité 1 : StringValue "team" ou "Team" dans le Character
    if player.Character then
        local teamVal = player.Character:FindFirstChild("team") or player.Character:FindFirstChild("Team")
        if teamVal and teamVal:IsA("StringValue") then
            return teamVal.Value
        end
    end
    -- Priorité 2 : Player.Team (si défini)
    if player.Team then
        return player.Team.Name or tostring(player.Team)
    end
    return nil
end

local function isAlly(player)
    local localTeam = getPlayerTeam(LocalPlayer)
    local otherTeam = getPlayerTeam(player)
    if localTeam and otherTeam then
        return localTeam == otherTeam
    end
    return false
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
