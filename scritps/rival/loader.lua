local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")

-- Aimbot Settings
local aimbotEnabled = false
local aimbotFOV = 100
local aimbotMaxDistance = 100
local aimbotTargetPart = "Head" -- or "Torso", "Random"
local aimbotHeadshotChance = 100

-- ESP
local espEnabled = false

-- Fly
local flyEnabled = false
local flySpeed = 50
local verticalFlyDir = 0

-- Jump
local jumpPower = 50

-- UI Window
local Window = Rayfield:CreateWindow({
    Name = "HACKER CORE UI",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "By You",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

--------------------------
-- AIMBOT TAB
--------------------------
local Combat = Window:CreateTab("Aimbot", 4483362458)

Combat:CreateToggle({
    Name = "Activer Aimbot",
    CurrentValue = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end,
})

Combat:CreateDropdown({
    Name = "Zone à viser",
    Options = {"Head", "Torso", "Random"},
    CurrentOption = "Head",
    Callback = function(Option)
        aimbotTargetPart = Option
    end,
})

Combat:CreateSlider({
    Name = "Chance de viser la tête (%)",
    Range = {0, 100},
    Increment = 5,
    CurrentValue = 100,
    Callback = function(Value)
        aimbotHeadshotChance = Value
    end,
})

Combat:CreateSlider({
    Name = "FOV (distance à l'écran)",
    Range = {10, 300},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(Value)
        aimbotFOV = Value
    end,
})

Combat:CreateSlider({
    Name = "Distance max (studs)",
    Range = {10, 300},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(Value)
        aimbotMaxDistance = Value
    end,
})

-- Aimbot Logic
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end

    local closest = nil
    local shortest = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local targetPartName = aimbotTargetPart
            if targetPartName == "Random" then
                targetPartName = math.random(1, 100) <= aimbotHeadshotChance and "Head" or "Torso"
            end

            local part = player.Character:FindFirstChild(targetPartName)
            if part then
                local dist3D = (part.Position - Camera.CFrame.Position).Magnitude
                if dist3D <= aimbotMaxDistance then
                    local screenPos, onScreen = Camera:WorldToScreenPoint(part.Position)
                    if onScreen then
                        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                        if dist2D < shortest and dist2D < aimbotFOV then
                            shortest = dist2D
                            closest = part
                        end
                    end
                end
            end
        end
    end

    if closest then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
    end
end)

--------------------------
-- ESP TAB
--------------------------
local Visuals = Window:CreateTab("ESP", 4483362733)

Visuals:CreateToggle({
    Name = "Wallhack (ESP)",
    CurrentValue = false,
    Callback = function(Value)
        espEnabled = Value

        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                if Value then
                    local hl = Instance.new("Highlight")
                    hl.Name = "PLAYER_HL"
                    hl.FillColor = Color3.new(1, 0, 0)
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.Adornee = player.Character
                    hl.Parent = player.Character
                else
                    local h = player.Character:FindFirstChild("PLAYER_HL")
                    if h then h:Destroy() end
                end
            end
        end

        -- New players
        Players.PlayerAdded:Connect(function(p)
            p.CharacterAdded:Connect(function(c)
                if espEnabled then
                    local hl = Instance.new("Highlight")
                    hl.Name = "PLAYER_HL"
                    hl.FillColor = Color3.new(1, 0, 0)
                    hl.FillTransparency = 0.3
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.Adornee = c
                    hl.Parent = c
                end
            end)
        end)
    end,
})

--------------------------
-- MOUVEMENT TAB (Fly + Jump)
--------------------------
local Movement = Window:CreateTab("Mouvement", 4483363013)

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
    Name = "Fly Mode",
    CurrentValue = false,
    Callback = function(Value)
        flyEnabled = Value
        verticalFlyDir = 0
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

-- Buttons for vertical fly (for mobile)
Movement:CreateButton({
    Name = "⬆️ Monter (Fly)",
    Callback = function()
        verticalFlyDir = 1
        task.delay(0.2, function() verticalFlyDir = 0 end)
    end,
})

Movement:CreateButton({
    Name = "⬇️ Descendre (Fly)",
    Callback = function()
        verticalFlyDir = -1
        task.delay(0.2, function() verticalFlyDir = 0 end)
    end,
})

-- Fly logic
RunService.RenderStepped:Connect(function()
    if flyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        local cam = workspace.CurrentCamera.CFrame
        local moveDirection = Vector3.new(cam.LookVector.X, 0, cam.LookVector.Z).Unit
        root.Velocity = (moveDirection * flySpeed) + Vector3.new(0, verticalFlyDir * flySpeed, 0)
    end
end)
