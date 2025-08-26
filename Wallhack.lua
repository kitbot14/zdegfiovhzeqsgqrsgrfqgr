local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local enemyColor = Color3.new(1, 0, 0) -- rouge par défaut
local allyColor = Color3.new(0, 1, 0)  -- vert par défaut

local function isAlly(player)
    if player == LocalPlayer then return true end
    -- Compare les couleurs de l'équipe
    return player.TeamColor == LocalPlayer.TeamColor
end

local function applyHighlight(p)
    if not p.Character then return end
    local char = p.Character
    local hl = char:FindFirstChild("Wallhl") or Instance.new("Highlight", char)
    hl.Name = "Wallhl"
    hl.Adornee = char
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    return hl
end

local function updateWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Character and p ~= LocalPlayer then
            local hl = applyHighlight(p)
            hl.Visible = enabled
            local c = isAlly(p) and allyColor or enemyColor
            hl.FillColor = c
            hl.OutlineColor = c
        end
    end
end

local module = {}

function module.SetEnabled(v)
    enabled = v
    if not v then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("Wallhl")
                if hl then hl:Destroy() end
            end
        end
    else
        updateWallhack()
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
