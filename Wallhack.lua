local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local wallColor = Color3.new(1,0,0)

local function isAlly(player)
    return player.Team == LocalPlayer.Team
end

local function updateWallhack()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and not isAlly(p) then
            local char = p.Character
            local hl = char:FindFirstChild("Wallhl")
            if enabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "Wallhl"
                    hl.FillColor = wallColor
                    hl.OutlineColor = wallColor
                    hl.FillTransparency = 0.3
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
                    hl.Parent = char
                else
                    hl.FillColor = wallColor
                    hl.OutlineColor = wallColor
                end
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
        -- Clean les highlights quand off
        for _, p in ipairs(Players:GetPlayers()) do
            local char = p.Character
            if char then
                local hl = char:FindFirstChild("Wallhl")
                if hl then hl:Destroy() end
            end
        end
    end
end

function module.SetColor(c)
    wallColor = c
    if enabled then
        updateWallhack()
    end
end

function module.Update()
    if enabled then
        updateWallhack()
    end
end

return module
