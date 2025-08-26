local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local enemyColor = Color3.new(1, 0, 0) -- rouge
local allyColor = Color3.new(0, 1, 0)  -- vert

local function isAlly(player)
    if player == LocalPlayer then return false end
    -- Compare les couleurs d'équipes
    return player.TeamColor == LocalPlayer.TeamColor
end

local function updateWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hl = char:FindFirstChild("Wallhl")

            local color = isAlly(p) and allyColor or enemyColor

            if enabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "Wallhl"
                    hl.Adornee = char
                    hl.FillTransparency = 0.3
                    hl.OutlineTransparency = 0
                    hl.Parent = char
                end
                hl.FillColor = color
                hl.OutlineColor = color
            elseif hl then
                hl:Destroy()
            end
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

function module.SetEnemyColor(c) enemyColor = c end
function module.SetAllyColor(c)  allyColor = c  end
function module.Update() if enabled then updateWallhack() end end

return module
