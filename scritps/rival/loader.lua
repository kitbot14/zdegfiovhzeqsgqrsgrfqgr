local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- === Config
local aimbotEnabled = false
local aimbotFOV = 100
local aimbotMaxDistance = 150
local aimbotTarget = "Head"
local headChance = 80
local torsoChance = 80
local fovColor = Color3.fromRGB(0, 255, 0)

local espEnabled = false
local espFillColor = Color3.fromRGB(255, 0, 0)
local espOutlineColor = Color3.fromRGB(255, 255, 255)

local jumpBoostEnabled = false
local jumpBoostPower = 100

local noRecoil = false
local instantReload = false

-- === UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Hacker Pro UI",
    LoadingTitle = "Initialisation...",
    LoadingSubtitle = "By You",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Aimbot Tab
local Combat = Window:CreateTab("Aimbot", 4483362458)
Combat:CreateToggle({ Name = "Activer Aimbot", CurrentValue = false, Callback = function(v) aimbotEnabled = v end })
Combat:CreateSlider({ Name = "FOV (px)", Range = {10, 500}, Increment = 10, CurrentValue = 100, Callback = function(v) aimbotFOV = v end })
Combat:CreateSlider({ Name = "Distance max (studs)", Range = {10, 500}, Increment = 10, CurrentValue = 150, Callback = function(v) aimbotMaxDistance = v end })
Combat:CreateDropdown({ Name = "Zone ciblée", Options = {"Head", "Torso", "Random"}, CurrentOption = "Head", Callback = function(v) aimbotTarget = v end })
Combat:CreateSlider({ Name = "Chance Tête (%)", Range = {0, 100}, Increment = 5, CurrentValue = 80, Callback = function(v) headChance = v end })
Combat:CreateSlider({ Name = "Chance Torse (%)", Range = {0, 100}, Increment = 5, CurrentValue = 80, Callback = function(v) torsoChance = v end })
Combat:CreateColorPicker({ Name = "Couleur FOV", Default = fovColor, Callback = function(c) fovColor = c end })

-- ESP Tab
local Visuals = Window:CreateTab("ESP", 4483362733)
Visuals:CreateToggle({ Name = "Wallhack (ESP)", CurrentValue = false, Callback = function(v) espEnabled = v; for _, p in pairs(Players:GetPlayers()) do updateHighlight(p) end end })
Visuals:CreateColorPicker({ Name = "Couleur Remplissage", Default = espFillColor, Callback = function(c) espFillColor = c; refreshHighlights() end })
Visuals:CreateColorPicker({ Name = "Couleur Contour", Default = espOutlineColor, Callback = function(c) espOutlineColor = c; refreshHighlights() end })

-- Jump Boost
local Movement = Window:CreateTab("Jump Boost", 4483363013)
Movement:CreateToggle({ Name = "Activer Jump Boost", CurrentValue = false, Callback = function(v) jumpBoostEnabled = v end })
Movement:CreateSlider({ Name = "Jump Power", Range = {50, 300}, Increment = 10, CurrentValue = 100, Callback = function(v) jumpBoostPower = v end })

-- Extra
local Extra = Window:CreateTab("Extras", 4483362920)
Extra:CreateToggle({ Name = "Pas de Recul", CurrentValue = false, Callback = function(v) noRecoil = v end })
Extra:CreateToggle({ Name = "Recharge Instantanée", CurrentValue = false, Callback = function(v) instantReload = v end })

-- === ESP Highlight
function updateHighlight(player)
    if player == LocalPlayer or not player.Character then return end
    local hl = player.Character:FindFirstChild("PLAYER_HL")
    if not hl and espEnabled then
        hl = Instance.new("Highlight")
        hl.Name = "PLAYER_HL"
        hl.FillTransparency = 0.3
        hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = player.Character
        hl.Parent = player.Character
    end
    if hl then
        hl.FillColor = espFillColor
        hl.OutlineColor = espOutlineColor
        if not espEnabled then hl:Destroy() end
    end
end

function refreshHighlights()
    for _, p in pairs(Players:GetPlayers()) do updateHighlight(p) end
end

Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() updateHighlight(p) end) end)
Players.PlayerRemoving:Connect(function(p) local h = p.Character and p.Character:FindFirstChild("PLAYER_HL"); if h then h:Destroy() end end)

-- === FOV Drawing
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Radius = aimbotFOV
fovCircle.Color = fovColor
fovCircle.Visible = false

-- === Main Loop
RunService.RenderStepped:Connect(function()
    -- FOV Circle
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = aimbotFOV
    fovCircle.Color = fovColor
    fovCircle.Visible = aimbotEnabled

    -- Aimbot Logic
    if aimbotEnabled then
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if dist <= aimbotMaxDistance then
                    local part = nil
                    if aimbotTarget == "Random" then
                        part = math.random(100) <= headChance and p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("Torso")
                    else
                        part = p.Character:FindFirstChild(aimbotTarget)
                    end
                    if part then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                        if onScreen then
                            local diff = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if diff < bestDist and diff <= aimbotFOV then
                                bestDist = diff
                                best = part
                            end
                        end
                    end
                end
            end
        end
        if best then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, best.Position)
        end
    end

    -- Jump Boost
    if jumpBoostEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.JumpPower = jumpBoostPower
    end

    -- ESP persistence
    if espEnabled then refreshHighlights() end
end)
