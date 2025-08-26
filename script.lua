local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer      = Players.LocalPlayer
local Camera           = workspace.CurrentCamera

-- Aimbot settings
local isAimbot        = false
local aimSpeed        = 0.3
local aimRadius       = 800
local predictionTime  = 0.1
local aimbotKey       = Enum.KeyCode.E

-- Visual FOV
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Transparency = 0.7
FOVCircle.Filled = false
FOVCircle.NumSides = 64

-- Predict player movement velocity
local lastPos = {}
local velocities = {}

RunService.Heartbeat:Connect(function(dt)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local part = pl.Character.HumanoidRootPart
            if not lastPos[pl] then
                lastPos[pl] = part.Position
                velocities[pl] = Vector3.new()
            else
                local vel = (part.Position - lastPos[pl]) / dt
                velocities[pl] = velocities[pl]:Lerp(vel, 0.5)
                lastPos[pl] = part.Position
            end
        end
    end
end)

-- Find closest target within FOV radius
local function getClosestTarget()
    local closest, shortest = nil, aimRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    for _, pl in ipairs(Players:GetPlayers()) do
        if pl ~= LocalPlayer and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = pl.Character.HumanoidRootPart
            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortest then
                    shortest, closest = dist, pl
                end
            end
        end
    end
    return closest
end

-- Smooth aim with prediction
local function aimAt(pl, dt)
    if not (pl and pl.Character and pl.Character:FindFirstChild("HumanoidRootPart")) then return end
    local part = pl.Character.HumanoidRootPart
    local predicted = part.Position + velocities[pl] * predictionTime
    local from = Camera.CFrame
    local to = CFrame.new(from.Position, predicted)
    Camera.CFrame = from:Lerp(to, aimSpeed * dt * 60)
end

-- Toggle aiming with key
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == aimbotKey then
        isAimbot = not isAimbot
        FOVCircle.Visible = isAimbot
    end
end)

-- Rayfield UI
local Window = Rayfield:CreateWindow({
    Name = "Advanced Aimbot Panel",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Paramétrage Aimbot",
    Theme = "Midnight",
    ConfigurationSaving = { Enabled = true, FileName = "AimConfig" },
    Discord = { Enabled = false },
    KeySystem = false
})

local Main = Window:CreateTab("Aimbot", nil)
Main:CreateSection("Aimbot Settings")

Main:CreateToggle({
    Name = "Activer Aimbot",
    CurrentValue = isAimbot,
    Callback = function(v)
        isAimbot = v
        FOVCircle.Visible = v
    end
})

Main:CreateSlider({
    Name = "Vitesse (smooth)",
    Range = {0.1, 1},
    Increment = 0.1,
    CurrentValue = aimSpeed,
    Callback = function(v) aimSpeed = v end
})

Main:CreateSlider({
    Name = "Rayon FOV",
    Range = {100, 1500},
    Increment = 100,
    CurrentValue = aimRadius,
    Suffix = " studs",
    Callback = function(v) aimRadius = v; FOVCircle.Radius = v end
})

Main:CreateSlider({
    Name = "Prediction (sec)",
    Range = {0, 0.5},
    Increment = 0.05,
    CurrentValue = predictionTime,
    Callback = function(v) predictionTime = v end
})

-- Notification for UI
Rayfield:Notify({
    Title = "Aimbot actif",
    Content = "Appuie sur E pour activer/désactiver",
    Duration = 3
})

-- Main loop
RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    if isAimbot then
        local target = getClosestTarget()
        if target then aimAt(target, dt) end
    end
end)
