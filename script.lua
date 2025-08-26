local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local isAimbotEnabled = false
local aimSpeed = 0.2
local aimRadius = 1000

local isWallhackEnabled = false

-- Ciblage : trouver le joueur le plus proche du centre de l'écran
local function getClosestTarget()
    local closest, shortest = nil, aimRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if dist < shortest then
                    shortest, closest = dist, p
                end
            end
        end
    end
    return closest
end

-- Viser en douceur la tête de la cible
local function aimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local camC0 = Camera.CFrame
        local newC0 = CFrame.new(camC0.Position, head.Position)
        Camera.CFrame = camC0:Lerp(newC0, aimSpeed)
    end
end

-- Wallhack visuel amélioré : rouge néon + cercle tête
local function applyWallhack(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    if state then
                        part.Color = Color3.new(1, 0, 0)
                        part.Material = Enum.Material.Neon
                    else
                        part.Color = part:FindFirstChild("OriginalColor") and part.OriginalColor.Value or Color3.new(1, 1, 1)
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
            -- Cercle autour de la tête
            local head = p.Character:FindFirstChild("Head")
            if head then
                local circle = head:FindFirstChild("WallCircle")
                if state and not circle then
                    circle = Instance.new("SelectionSphere")
                    circle.Name = "WallCircle"
                    circle.Adornee = head
                    circle.Color3 = Color3.new(1, 0, 0)
                    circle.LineThickness = 0.05
                    circle.Parent = head
                elseif not state and circle then
                    circle:Destroy()
                end
            end
        end
    end
end

--  Rayfield GUI
local Window = Rayfield:CreateWindow({
    Name = "Admin Panel",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Admin Tools",
    Theme = "Midnight",
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = true, FileName = "AdminConfig" },
    Discord = { Enabled = false },
    KeySystem = false,
})

local Main = Window:CreateTab("Main", nil)
Main:CreateSection("Aimbot Settings")

-- Toggle Aimbot
Main:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Flag = "AimToggle",
    Callback = function(state)
        isAimbotEnabled = state
    end,
})

-- Slider pour la vitesse d'aimbot
Main:CreateSlider({
    Name = "Aim Speed",
    Range = {0.05, 1},
    Increment = 0.05,
    Suffix = "",
    CurrentValue = aimSpeed,
    Flag = "AimSpeed",
    Callback = function(val)
        aimSpeed = val
    end,
})

-- Slider pour le rayon d'aimbot
Main:CreateSlider({
    Name = "Aim Radius",
    Range = {100, 2000},
    Increment = 100,
    Suffix = "studs",
    CurrentValue = aimRadius,
    Flag = "AimRadius",
    Callback = function(val)
        aimRadius = val
    end,
})

Main:CreateSection("Wallhack")
Main:CreateToggle({
    Name = "Enable Wallhack",
    CurrentValue = false,
    Flag = "WallhackToggle",
    Callback = function(state)
        isWallhackEnabled = state
        applyWallhack(state)
    end,
})

Main:CreateSection("Teleport")
Main:CreateButton({
    Name = "Open Teleport Menu",
    Callback = function()
        local TeleTab = Window:CreateTab("Teleport", nil)
        TeleTab:CreateSection("Players")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                TeleTab:CreateButton({
                    Name = p.Name,
                    Callback = function()
                        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and myHrp then
                            myHrp.CFrame = hrp.CFrame
                        end
                    end,
                })
            end
        end
    end,
})

Rayfield:Notify({
    Title = "Admin Panel Loaded",
    Content = "Utilise le menu pour configurer",
    Duration = 3,
})

-- Rendu continu
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestTarget()
        aimAt(target)
    end
end)
