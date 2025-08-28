local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

-- SETTINGS
local aimbotEnabled = false
local aimbotFOV = 150
local wallhackEnabled = false
local jumpPower = 50
local flyEnabled = false
local flySpeed = 50

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Hacker Menu",
    LoadingTitle = "Hacking Interface",
    LoadingSubtitle = "By You",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-----------------------------
-- Combat Hacks (AIMBOT)
-----------------------------
local Combat = Window:CreateTab("Combat", 4483362458)

Combat:CreateToggle({
    Name = "Aimbot (Joueurs)",
    CurrentValue = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end,
})

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local closest = nil
    local shortest = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < shortest and dist < aimbotFOV then
                    shortest = dist
                    closest = head
                end
            end
        end
    end

    if closest then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
    end
end)

-----------------------------
-- Visuals (WALLHACK)
-----------------------------
local Visuals = Window:CreateTab("Visuals", 4483362733)

Visuals:CreateToggle({
    Name = "Wallhack Joueurs (ESP)",
    CurrentValue = false,
    Callback = function(Value)
        wallhackEnabled = Value

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if Value then
                    local hl = Instance.new("Highlight")
                    hl.Name = "PLAYER_HIGHLIGHT"
                    hl.FillColor = Color3.new(1, 0, 0)
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.OutlineTransparency = 0
                    hl.Adornee = player.Character
                    hl.Parent = player.Character
                else
                    if player.Character:FindFirstChild("PLAYER_HIGHLIGHT") then
                        player.Character:FindFirstChild("PLAYER_HIGHLIGHT"):Destroy()
                    end
                end
            end
        end

        -- Auto-update for new players
        Players.PlayerAdded:Connect(function(player)
            player.CharacterAdded:Connect(function(char)
                if wallhackEnabled then
                    local hl = Instance.new("Highlight")
                    hl.Name = "PLAYER_HIGHLIGHT"
                    hl.FillColor = Color3.new(1, 0, 0)
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.OutlineTransparency = 0
                    hl.Adornee = char
                    hl.Parent = char
                end
            end)
        end)
    end,
})

-----------------------------
-- Movement
-----------------------------
local Movement = Window:CreateTab("Movement", 4483363013)

Movement:CreateSlider({
    Name = "Jump Power",
    Range = {50, 200},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(Value)
        jumpPower = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.JumpPower = jumpPower
        end
    end,
})

Movement:CreateToggle({
    Name = "Fly Boost",
    CurrentValue = false,
    Callback = function(Value)
        flyEnabled = Value
    end,
})

Movement:CreateSlider({
    Name = "Fly Speed",
    Range = {10, 150},
    Increment = 10,
    CurrentValue = 50,
    Callback = function(Value)
        flySpeed = Value
    end,
})

-- Fly Logic
RunService.RenderStepped:Connect(function()
    if flyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, flySpeed, 0)
    end
end)

-----------------------------
-- Hacking Tools (Fake)
-----------------------------
local HackTab = Window:CreateTab("Hack Tools", 4483362910)

HackTab:CreateButton({
    Name = "🔓 Hacker une porte",
    Callback = function()
        Rayfield:Notify({
            Title = "Hack en cours...",
            Content = "Porte débloquée avec succès.",
            Duration = 4
        })
    end,
})

HackTab:CreateButton({
    Name = "🛑 Désactiver tourelle",
    Callback = function()
        Rayfield:Notify({
            Title = "Hack réussi",
            Content = "Tourelle désactivée.",
            Duration = 4
        })
    end,
})
