local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- === Variables de configuration ===
local aimbotEnabled = false
local aimbotFOV = 100
local aimbotMaxDistance = 100
local aimbotHeadshotChance = 100  -- % de chance de viser la tête

local espEnabled = false
local jumpBoostEnabled = false
local jumpBoostPower = 100

-- === UI ===
local Window = Rayfield:CreateWindow({
    Name = "Hacker Core UI",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "By You",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-- 🔫 Aimbot Tab
local Combat = Window:CreateTab("Aimbot", 4483362458)
Combat:CreateToggle({ Name = "Activer Aimbot", CurrentValue = false, Callback = function(v) aimbotEnabled = v end })
Combat:CreateSlider({ Name = "FOV (px)", Range = {10, 300}, Increment = 10, CurrentValue = 100, Callback = function(v) aimbotFOV = v end })
Combat:CreateSlider({ Name = "Distance max (studs)", Range = {10, 300}, Increment = 10, CurrentValue = 100, Callback = function(v) aimbotMaxDistance = v end })
Combat:CreateSlider({ Name = "Chance de Headshot (%)", Range = {0,100}, Increment = 5, CurrentValue = 100, Callback = function(v) aimbotHeadshotChance = v end })

--  ESP Tab
local Visuals = Window:CreateTab("ESP", 4483362733)
Visuals:CreateToggle({
    Name = "Wallhack (ESP)",
    CurrentValue = false,
    Callback = function(v)
        espEnabled = v
        for _, p in ipairs(Players:GetPlayers()) do addOrRemoveHighlight(p) end
    end
})

--  Jump Boost Tab
local Movement = Window:CreateTab("Jump Boost", 4483363013)
Movement:CreateToggle({ Name = "Activer Jump Boost", CurrentValue = false, Callback = function(v) jumpBoostEnabled = v end })
Movement:CreateSlider({ Name = "Jump Power", Range = {50, 300}, Increment = 10, CurrentValue = 100, Callback = function(v) jumpBoostPower = v end })

-- Helper : (Re)crée l'Highlight pour un joueur donné
function addHighlight(player)
    if player == LocalPlayer or not player.Character then return end
    if not player.Character:FindFirstChild("PLAYER_HL") then
        local hl = Instance.new("Highlight")
        hl.Name = "PLAYER_HL"
        hl.FillColor = Color3.new(1,0,0)
        hl.FillTransparency = 0.3
        hl.OutlineColor = Color3.new(1,1,1)
        hl.OutlineTransparency = 0
        hl.Adornee = player.Character
        hl.Parent = player.Character
    end
end

function removeHighlight(player)
    if player.Character then
        local h = player.Character:FindFirstChild("PLAYER_HL")
        if h then h:Destroy() end
    end
end

function addOrRemoveHighlight(player)
    if espEnabled then addHighlight(player) else removeHighlight(player) end
end

-- === Connexions utiles ===
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        addOrRemoveHighlight(p)
    end)
end)
Players.PlayerRemoving:Connect(function(p)
    removeHighlight(p)
end)

-- === Boucle principale ===
RunService.RenderStepped:Connect(function()
    -- Aimbot logique
    if aimbotEnabled then
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (p.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Magnitude
                if dist <= aimbotMaxDistance then
                    local targetPart = math.random(1,100) <= aimbotHeadshotChance and p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("Torso")
                    if targetPart then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(targetPart.Position)
                        if onScreen then
                            local d = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                            if d < bestDist and d < aimbotFOV then
                                bestDist, best = d, targetPart
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

    -- Force recreate highlights si supprimés
    if espEnabled then
        for _, p in ipairs(Players:GetPlayers()) do addHighlight(p) end
    end
end)
