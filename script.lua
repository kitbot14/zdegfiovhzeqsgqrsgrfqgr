local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local ADMIN_USERNAMES = { ["kitlebot10"] = true }
local isAimbotEnabled = false
local isWallhackEnabled = false

local aimRadius = 1000
local guiPosition = UDim2.new(1, -170, 0, 20)

local function isMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Menu Draggable et Réductible
local function makeDraggable(frame)
    local dragging, dragInput, mousePos, framePos = false, nil, nil, nil

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                    guiPosition = frame.Position
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)
end

-- Aimbot simple : vise la tête du joueur le plus proche au centre de l’écran
local function getClosestTarget()
    local closest, shortest = nil, aimRadius
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local head = p.Character.Head
            local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                if dist < shortest then shortest, closest = dist, p end
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

-- Wallhack corrigé : rouge + cercle visible
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

-- Téléportation via menu : ouverture d'un sous-menu listant les joueurs
local function createMainGUI()
    local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    gui.Name = "AdminTools"
    gui.ResetOnSpawn = false

    local frame = Instance.new("Frame", gui)
    frame.AnchorPoint = Vector2.new(1, 0)
    frame.Position = guiPosition
    frame.Size = UDim2.new(0, 160, 0, 180)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    makeDraggable(frame)

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, -40, 0, 30)
    title.Position = UDim2.new(0, 10, 0, 5)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.Text = "Admin Tools"

    local toggleBtn = Instance.new("TextButton", frame)
    toggleBtn.Size = UDim2.new(0, 30, 0, 30)
    toggleBtn.Position = UDim2.new(1, -35, 0, 5)
    toggleBtn.Text = "-"
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 24
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBtn.TextColor3 = Color3.new(1,1,1)

    local isExpanded = true
    local function updateUI()
        frame.Size = isExpanded and UDim2.new(0, 160, 0, 180) or UDim2.new(0, 160, 0, 40)
        toggleBtn.Text = isExpanded and "-" or "+"
        for _, obj in ipairs(frame:GetChildren()) do
            if obj:IsA("TextButton") and obj ~= toggleBtn then
                obj.Visible = isExpanded
            end
        end
    end

    toggleBtn.MouseButton1Click:Connect(function() isExpanded = not isExpanded; updateUI() end)

    local function addToggle(text, y, cb)
        local b = Instance.new("TextButton", frame)
        b.Size = UDim2.new(1, -20, 0, 30)
        b.Position = UDim2.new(0, 10, 0, y)
        b.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        b.Font = Enum.Font.GothamBold
        b.TextSize = 18
        b.TextColor3 = Color3.new(1,1,1)
        b.Text = text.." OFF"
        b.MouseButton1Click:Connect(function()
            local on = not b.Text:find("ON")
            b.Text = text.." "..(on and "ON" or "OFF")
            b.BackgroundColor3 = on and Color3.new(0,170/255,0) or Color3.new(40/255,40/255,40/255)
            cb(on)
        end)
        return b
    end

    addToggle("Aimbot", 40, function(s) isAimbotEnabled = s end)
    addToggle("Wallhack", 80, function(s) isWallhackEnabled = s; applyWallhack(s) end)

    local tpMainBtn = Instance.new("TextButton", frame)
    tpMainBtn.Size, tpMainBtn.Position = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 120)
    tpMainBtn.BackgroundColor3, tpMainBtn.Font = Color3.fromRGB(40,40,40), Enum.Font.GothamBold
    tpMainBtn.TextSize, tpMainBtn.TextColor3 = 18, Color3.new(1,1,1)
    tpMainBtn.Text = "Teleport Menu"
    tpMainBtn.MouseButton1Click:Connect(function()
        -- Display secondary menu overlay
        local sec = Instance.new("Frame", gui)
        sec.Size, sec.Position = UDim2.new(0, 200, 0, 300), UDim2.new(0.5, -100, 0.5, -150)
        sec.BackgroundColor3 = Color3.fromRGB(15,15,15)
        sec.BorderSizePixel = 0

        local y = 10
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local pb = Instance.new("TextButton", sec)
                pb.Size, pb.Position = UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, y)
                pb.BackgroundColor3, pb.Font = Color3.fromRGB(50,50,50), Enum.Font.Gotham
                pb.TextSize, pb.TextColor3 = 18, Color3.new(1,1,1)
                pb.Text = p.Name
                pb.MouseButton1Click:Connect(function()
                    local c = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    local me = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if c and me then me.CFrame = c.CFrame end
                    sec:Destroy()
                end)
                y = y + 35
            end
        end
    end)

    updateUI()
end

-- Main loop
RunService.RenderStepped:Connect(function()
    if isAimbotEnabled then
        local t = getClosestTarget()
        aimAt(t)
    end
end)

-- Init
if ADMIN_USERNAMES[LocalPlayer.Name] then
    createMainGUI()
    print("Admin Tools prêtes.")
else
    warn("Script réservé aux admins.")
end
