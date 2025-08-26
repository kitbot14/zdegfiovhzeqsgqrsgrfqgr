local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local enemyColor = Color3.new(1, 0, 0) -- rouge
local allyColor = Color3.new(0, 1, 0)  -- vert

-- Retourne true si joueur est un allié (vérification avec team sinon false)
local function isAlly(player)
    if not player or player == LocalPlayer then return false end
    if player.Team and LocalPlayer.Team then
        return player.Team == LocalPlayer.Team
    end
    return false -- si teams non définis, on considère ennemi
end

local function updateWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local char = p.Character
            local hl = char:FindFirstChild("Wallhl")

            local is_ally = isAlly(p)
            local color = is_ally and allyColor or enemyColor

            if enabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "Wallhl"
                    hl.FillTransparency = 0.3
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
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
    if not enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then
                local hl = p.Character:FindFirstChild("Wallhl")
                if hl then hl:Destroy() end
            end
        end
    end
end

-- Permet de changer la couleur des ennemis (par défaut rouge)
function module.SetColor(color)
    enemyColor = color
end

-- Permet de changer la couleur des alliés (optionnel)
function module.SetAllyColor(color)
    allyColor = color
end

function module.Update()
    if enabled then
        updateWallhack()
    end
end

return module
