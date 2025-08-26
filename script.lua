local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local isAimbot = false
local aimSpeed = 0.3
local aimRadius = 800

local isWallhack = false

-- Fonction de visée lissée
local function getClosestTarget()
    local closest, shortest = nil, aimRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local screen, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screen.X, screen.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then
                    shortest, closest = dist, p
                end
            end
        end
    end
    return closest
end

local function aimAt(p)
    if p and p.Character and p.Character:FindFirstChild("Head") then
        local head = p.Character.Head
        local from = Camera.CFrame
        local to = CFrame.new(from.Position, head.Position)
        Camera.CFrame = from:Lerp(to, aimSpeed)
    end
end

-- Wallhack stylé
local function applyWallhack(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Color = state and Color3.new(1,0,0) or Color3.new(1,1,1)
                    part.Material = state and Enum.Material.Neon or Enum.Material.Plastic
                end
            end
            local head = p.Character:FindFirstChild("Head")
            if head then
                local circ = head:FindFirstChild("WallCircle")
                if state and not circ then
                    circ = Instance.new("SelectionSphere")
                    circ.Name = "WallCircle"
                    circ.Adornee = head
                    circ.Color3 = Color3.new(1, 0, 0)
                    circ.LineThickness = 0.05
                    circ.Parent = head
                elseif not state and circ then
                    circ:Destroy()
                end
            end
        end
    end
end

-- Création du GUI Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Admin Panel",
    LoadingTitle = "Chargement...",
    LoadingSubtitle = "Admin Tools",
    Theme = "Midnight",
    ToggleUIKeybind = "K",
    ConfigurationSaving = { Enabled = true, FileName = "AdminConfig" },
    Discord = { Enabled = false },
    KeySystem = false
})

local Main = Window:CreateTab("Main", nil)
Main:CreateSection("Aimbot")
Main:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = false,
    Callback = function(v) isAimbot = v end
})
Main:CreateSlider({
    Name = "Aim Speed",
    Range = {0.05, 1}, Increment = 0.05,
    CurrentValue = aimSpeed,
    Callback = function(v) aimSpeed = v end
})
Main:CreateSlider({
    Name = "Aim Radius",
    Range = {100, 2000}, Increment = 100,
    CurrentValue = aimRadius,
    Suffix = "studs",
    Callback = function(v) aimRadius = v end
})

Main:CreateSection("Wallhack")
Main:CreateToggle({
    Name = "Enable Wallhack",
    CurrentValue = false,
    Callback = function(v)
        isWallhack = v
        applyWallhack(v)
    end
})

Main:CreateSection("Teleport")
Main:CreateButton({
    Name = "Open Teleport Menu",
    Callback = function()
        local Tele = Window:CreateTab("Teleport", nil)
        Tele:CreateSection("Players")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                Tele:CreateButton({
                    Name = p.Name,
                    Callback = function()
                        local target = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        local mine = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if target and mine then
                            mine.CFrame = target.CFrame
                        end
                    end
                })
            end
        end
    end
})

Rayfield:Notify({
    Title = "Admin Panel ready",
    Content = "Appuie sur K pour ouvrir le menu",
    Duration = 3
})

RunService.RenderStepped:Connect(function()
    if isAimbot then
        local t = getClosestTarget()
        aimAt(t)
    end
end)
