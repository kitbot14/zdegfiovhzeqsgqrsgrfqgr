local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera

-- Settings
local aimbotEnabled = false
local aimbotFOV = 150
local aimbotMaxDistance = 100
local wallhackEnabled = false
local flyEnabled = false
local flySpeed = 50
local jumpPower = 50

-- Fly movement state
local flying = false
local moveDir = Vector3.zero

-- UI Setup
local Window = Rayfield:CreateWindow({
    Name = "Hacker Menu",
    LoadingTitle = "Hacking Interface",
    LoadingSubtitle = "By You",
    ConfigurationSaving = { Enabled = false },
    Discord = { Enabled = false },
    KeySystem = false
})

-----------------------------------
-- Combat (Aimbot sur joueurs)
-----------------------------------
local Combat = Window:CreateTab("Combat", 4483362458)

Combat:CreateToggle({
    Name = "Aimbot (Joueurs)",
    CurrentValue = false,
    Callback = function(Value)
        aimbotEnabled = Value
    end,
})

Combat:CreateSlider({
    Name = "Max Distance Aimbot",
    Range = {10, 500},
    Increment = 10,
    CurrentValue = 100,
    Callback = function(Value)
        aimbotMaxDistance = Value
    end,
})

-- Aimbot logic
RunService.RenderStepped:Connect(function()
    if not aimbotEnabled then return end
    local closest = nil
    local shortest = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local dist3D = (head.Position - Camera.CFrame.Position).Magnitude
            if dist3D <= aimbotMaxDistance then
                local screenPos, onScreen = Camera:WorldToScreenPoint(head.Position)
                if onScreen then
                    local dist2D = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                    if dist2D < shortest and dist2D < aimbotFOV then
                        shortest = dist2D
                        closest = head
                    end
                end
            end
        end
    end

    if closest then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, closest.Position)
    end
end)

-----------------------------------
-- Visuals (Wallhack ESP)
-----------------------------------
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
                    local old = player.Character:FindFirstChild("PLAYER_HIGHLIGHT")
                    if old then old:Destroy() end
                end
            end
        end

        -- For new players
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

-----------------------------------
-- Movement (Fly + JumpBoost)
-----------------------------------
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
    Name = "Fly",
    CurrentValue = false,
    Callback = function(Value)
        flyEnabled = Value
        flying = Value
        if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.Anchored = false
        end
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

-- Input handling for fly
local moveVector = Vector3.zero
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then moveVector = moveVector + Vector3.new(0, 0, -1) end
    if input.KeyCode == Enum.KeyCode.S then moveVector = moveVector + Vector3.new(0, 0, 1) end
    if input.KeyCode == Enum.KeyCode.A then moveVector = moveVector + Vector3.new(-1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.D then moveVector = moveVector + Vector3.new(1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.Space then moveVector = moveVector + Vector3.new(0, 1, 0) end
    if input.KeyCode == Enum.KeyCode.LeftShift then moveVector = moveVector + Vector3.new(0, -1, 0) end
end)

UserInputService.InputEnded:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.W then moveVector = moveVector - Vector3.new(0, 0, -1) end
    if input.KeyCode == Enum.KeyCode.S then moveVector = moveVector - Vector3.new(0, 0, 1) end
    if input.KeyCode == Enum.KeyCode.A then moveVector = moveVector - Vector3.new(-1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.D then moveVector = moveVector - Vector3.new(1, 0, 0) end
    if input.KeyCode == Enum.KeyCode.Space then moveVector = moveVector - Vector3.new(0, 1, 0) end
    if input.KeyCode == Enum.KeyCode.LeftShift then moveVector = moveVector - Vector3.new(0, -1, 0) end
end)

-- Fly movement update
RunService.RenderStepped:Connect(function()
    if flying and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local root = LocalPlayer.Character.HumanoidRootPart
        root.Anchored = false
        local camCF = Camera.CFrame
        local moveDir = camCF:VectorToWorldSpace(moveVector)
        root.Velocity = moveDir.Unit * flySpeed
    end
end)

-----------------------------------
-- Hacking Tools (Fake)
-----------------------------------
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
