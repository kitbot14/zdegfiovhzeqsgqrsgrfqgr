local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- États
local isAimbotEnabled = false
local isWallhackEnabled = false

local aimRadius = 1000

-- Fonction ciblage/aimer
local function getClosestTarget()
    local closest, shortest = nil, aimRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then
                    shortest, closest = dist, p
                end
            end
        end
    end
    return closest
end

local function aimAt(target)
    if target and target.Character and target.Character:FindFirstChild("Head") then
        local head = target.Character.Head
        local camPos = Camera.CFrame.Position
        Camera.CFrame = CFrame.new(camPos, head.Position)
    end
end

-- Wallhack visuel
local function applyWallhack(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    if state then
                        part.Color = Color3.new(1, 0, 0)
                        part.Material = Enum.Material.Neon
                    else
                        part.Color = Color3.new(1, 1, 1)
                        part.Material = Enum.Material.Plastic
                    end
                end
            end
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

-- SECTION: Rayfield GUI Setup
local Window = Rayfield:CreateWindow({
    Name = "Admin Control Panel",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Admin Tools",
    Theme = "Midnight",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FileName = "AdminControlConfig"
    },
    Discord = { Enabled = false },
    KeySystem = false
})

local MainTab = Window:CreateTab("Main", "rbxassetid://7020476796")

-- Aimbot Toggle
MainTab:CreateToggle({
    Name = "Aimbot",
    CurrentValue = false,
    Callback = function(state)
        isAimbotEnabled = state
    end,
})

-- Wallhack Toggle
MainTab:CreateToggle({
    Name = "Wallhack",
    CurrentValue = false,
    Callback = function(state)
        isWallhackEnabled = state
        applyWallhack(state)
    end,
})

-- Teleportation submenu
MainTab:CreateButton({
    Name = "Teleport Menu",
    Callback = function()
        local TeleTab = Window:CreateTab("Teleport", "rbxassetid://6023426926")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                TeleTab:CreateButton({
                    Name = p.Name,
                    Callback = function()
                        local targetHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if targetHRP and myHRP then
                            myHRP.CFrame = targetHRP.CFrame
                        end
                    end
                })
            end
        end
    end
})

Rayfield:Notify({
    Title = "Admin Panel Actif",
    Content = "Utilise les onglets pour configurer",
    Duration = 3,
})

-- Render loop
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local target = getClosestTarget()
        aimAt(target)
    end
end)
