local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local isAimbot = false
local aimSpeed = 0.2
local aimRadius = 1000
local aimbotKey = "E"

local isWallhack = false
local wallColor = Color3.fromRGB(255, 0, 0)

-- Trouver cible proche
local function getClosestTarget()
    local closest, shortest = nil, aimRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local screen, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screen.X, screen.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then shortest, closest = dist, p end
            end
        end
    end
    return closest
end

-- Aimer smoothely
local function aimAt(p)
    if p and p.Character and p.Character:FindFirstChild("Head") then
        local head = p.Character.Head
        local from = Camera.CFrame
        local to = CFrame.new(from.Position, head.Position)
        Camera.CFrame = from:Lerp(to, aimSpeed)
    end
end

-- Wallhack color personnalisé
local function applyWallhack(state)
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            for _, part in ipairs(p.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Color = state and wallColor or Color3.new(1,1,1)
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
                    circ.Color3 = wallColor
                    circ.LineThickness = 0.05
                    circ.Parent = head
                elseif not state and circ then
                    circ:Destroy()
                end
            end
        end
    end
end

-- Créer l’interface Rayfield
local Window = Rayfield:CreateWindow({
    Name = "Admin Panel",
    LoadingTitle = "Chargement…",
    LoadingSubtitle = "Admin Tools",
    Theme = "Midnight",
    ToggleUIKeybind = aimbotKey,
    ConfigurationSaving = { Enabled = true, FileName = "AdminConfig" },
    Discord = { Enabled = false },
    KeySystem = false,
})

local Main = Window:CreateTab("Main", nil)

-- Aimbot
Main:CreateSection("Aimbot Settings")
Main:CreateToggle({
    Name = "Enable Aimbot",
    CurrentValue = isAimbot,
    Flag = "AimbotToggle",
    Callback = function(v) isAimbot = v end,
})

Main:CreateSlider({
    Name = "Aim Speed",
    Range = {0.05, 1},
    Increment = 0.05,
    CurrentValue = aimSpeed,
    Flag = "AimSpeed",
    Callback = function(v) aimSpeed = v end,
})

Main:CreateSlider({
    Name = "Aim Radius",
    Range = {100, 2000},
    Increment = 100,
    CurrentValue = aimRadius,
    Flag = "AimRadius",
    Callback = function(v) aimRadius = v end,
})

Main:CreateKeybind({
    Name = "Aimbot Key",
    CurrentKeybind = aimbotKey,
    HoldToInteract = false,
    Flag = "AimbotKey",
    Callback = function(key)
        aimbotKey = key
    end,
})

-- Wallhack
Main:CreateSection("Wallhack")
Main:CreateToggle({
    Name = "Enable Wallhack",
    CurrentValue = isWallhack,
    Flag = "WallhackToggle",
    Callback = function(v)
        isWallhack = v
        applyWallhack(v)
    end,
})
Main:CreateColorPicker({
    Name = "Wallhack Color",
    Color = wallColor,
    Flag = "WallColor",
    Callback = function(c)
        wallColor = c
        if isWallhack then applyWallhack(true) end
    end,
})

-- Teleportation
Main:CreateSection("Teleport")
Main:CreateButton({
    Name = "Open Teleport Menu",
    Flag = "TeleportBtn",
    Callback = function()
        local Tele = Window:CreateTab("Teleport", nil)
        Tele:CreateSection("Players")
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                Tele:CreateButton({
                    Name = p.Name,
                    Callback = function()
                        local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                        local myhrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp and myhrp then myhrp.CFrame = hrp.CFrame end
                    end,
                })
            end
        end
    end,
})

Rayfield:Notify({
    Title = "Admin Panel Chargé",
    Content = "Appuie sur "..aimbotKey.." pour l'Onglet",
    Duration = 3,
})

RunService.RenderStepped:Connect(function()
    if isAimbot and (not aimbotKey or aimbotKey == "") then
        local t = getClosestTarget()
        aimAt(t)
    end
end)
