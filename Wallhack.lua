local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local enemyColor = Color3.new(1, 0, 0)
local allyColor = Color3.new(0, 1, 0)

local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

local function update()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hl = char:FindFirstChild("Wallhl") or Instance.new("Highlight", char)
            hl.Name = "Wallhl"
            hl.Adornee = char
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0

            if isAlly(p) then
                hl.FillColor = allyColor
                hl.OutlineColor = allyColor
            else
                hl.FillColor = enemyColor
                hl.OutlineColor = enemyColor
            end

            hl.Enabled = enabled
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
        update()
    end
end

return module
