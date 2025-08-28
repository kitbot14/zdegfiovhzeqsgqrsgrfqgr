local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- CONFIG VARIABLES
local aimbotEnabled = false
local aimbotFOV = 100
local aimbotMaxDistance = 150
local targetMode = "Head" -- "Head", "Torso", "Random"
local headChance = 80 -- % hit rate
local torsoChance = 80
local fovColor = Color3.fromRGB(0, 255, 0)

local espEnabled = false
local espFillColor = Color3.fromRGB(255, 0, 0)
local espOutlineColor = Color3.fromRGB(255, 255, 255)

local jumpBoostEnabled = false
local jumpBoostPower = 100

local noRecoil = false
local instantReload = false

-- Create FOV circle
local fovCircle = Drawing.new("Circle")
fovCircle.Thickness = 2
fovCircle.Transparency = 1
fovCircle.Filled = false

-- Rayfield UI setup
local Window = Rayfield:CreateWindow({
    Name = "Hacker Pro UI",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "By You",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- Aimbot Tab
local T_aim = Window:CreateTab("Aimbot", 4483362458)
T_aim:CreateToggle({ Name = "Activer Aimbot", CurrentValue = false, Callback = function(v) aimbotEnabled = v end })
T_aim:CreateSlider({ Name = "FOV (px)", Range = {10, 500}, Increment = 10, CurrentValue = 100, Callback = function(v) aimbotFOV = v end })
T_aim:CreateSlider({ Name = "Distance max (studs)", Range = {10, 500}, Increment = 10, CurrentValue = 150, Callback = function(v) aimbotMaxDistance = v end })
T_aim:CreateDropdown({ Name = "Cible", Options = {"Head", "Torso", "Random"}, CurrentOption = "Head", Callback = function(opt) targetMode = opt end })
T_aim:CreateSlider({ Name = "Chance Tête (%)", Range = {0,100}, Increment = 5, CurrentValue = 80, Callback = function(v) headChance = v end })
T_aim:CreateSlider({ Name = "Chance Torse (%)", Range = {0,100}, Increment = 5, CurrentValue = 80, Callback = function(v) torsoChance = v end })
T_aim:CreateColorPicker({ Name = "Couleur du FOV", Default = fovColor, Callback = function(c) fovColor = c end })

-- ESP Tab
local T_esp = Window:CreateTab("ESP", 4483362733)
T_esp:CreateToggle({ Name = "Wallhack (ESP)", CurrentValue = false, Callback = function(v) espEnabled = v; for _, p in pairs(Players:GetPlayers()) do addOrRemoveHL(p) end end })
T_esp:CreateColorPicker({ Name = "Fill Color", Default = espFillColor, Callback = function(c) espFillColor = c; updateHLColors() end })
T_esp:CreateColorPicker({ Name = "Outline Color", Default = espOutlineColor, Callback = function(c) espOutlineColor = c; updateHLColors() end })

-- Jump Boost Tab
local T_jump = Window:CreateTab("Jump Boost", 4483363013)
T_jump:CreateToggle({ Name = "Activer Jump Boost", CurrentValue = false, Callback = function(v) jumpBoostEnabled = v end })
T_jump:CreateSlider({ Name = "Jump Power", Range = {50, 300}, Increment = 10, CurrentValue = 100, Callback = function(v) jumpBoostPower = v end })

-- Extra Tab
local T_extra = Window:CreateTab("Extra", 4483362920)
T_extra:CreateToggle({ Name = "Pas de Recul", CurrentValue = false, Callback = function(v) noRecoil = v end })
T_extra:CreateToggle({ Name = "Recharge Instantanée", CurrentValue = false, Callback = function(v) instantReload = v end })

-- Highlight Functions
local function addHighlight(player)
    if player == LocalPlayer or not player.Character then return end
    if player.Character:FindFirstChild("PLAYER_HL") then return end
    local hl = Instance.new("Highlight")
    hl.Name = "PLAYER_HL"
    hl.FillColor = espFillColor
    hl.OutlineColor = espOutlineColor
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = player.Character
    hl.Parent = player.Character
end

local function removeHighlight(player)
    if player.Character then
        local h = player.Character:FindFirstChild("PLAYER_HL")
        if h then h:Destroy() end
    end
end

local function addOrRemoveHL(player)
    if espEnabled then addHighlight(player) else removeHighlight(player) end
end

local function updateHLColors()
    for _, p in pairs(Players:GetPlayers()) do
        local h = p.Character and p.Character:FindFirstChild("PLAYER_HL")
        if h then
            h.FillColor = espFillColor
            h.OutlineColor = espOutlineColor
        end
    end
end

-- Events for ESP players
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(function() addOrRemoveHL(p) end) end)
Players.PlayerRemoving:Connect(removeHighlight)

-- Main loop
RunService.RenderStepped:Connect(function()
    -- Draw FOV circle
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    fovCircle.Radius = aimbotFOV
    fovCircle.Color = fovColor
    fovCircle.Visible = aimbotEnabled

    -- Aimbot logic
    if aimbotEnabled then
        local best, bestDist = nil, math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist3D = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if dist3D <= aimbotMaxDistance then
                    local pick = targetMode == "Random" and (math.random(100) <= headChance and "Head" or "Torso") or targetMode
                    local part = p.Character:FindFirstChild(pick)
                    if part then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                        local d = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if onScreen and d < bestDist and d < aimbotFOV then
                            bestDist, best = d, part
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

    -- ESP persistent
    if espEnabled then
        for _, p in pairs(Players:GetPlayers()) do addHighlight(p) end
    end
end)
