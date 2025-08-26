-- 📎 Discord Copy (facultatif)
pcall(function()
    setclipboard("https://discord.gg/HdynH7fV5Q")
    print("Discord copied: https://discord.gg/HdynH7fV5Q")
end)

-- 📦 UI Loader
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Window = Rayfield:CreateWindow({
    Name = "CodeNest Hub",
    LoadingTitle = "CodeNest Hub",
    LoadingSubtitle = "Made by Supremo",
    ConfigurationSaving = { Enabled = false },
    KeySystem = false,
    Theme = "Default"
})

-- DIRECT LOAD TO MAIN FEATURES (no key required)
local MainTab = Window:CreateTab("MAIN", 4483362458)
local VisualsTab = Window:CreateTab("VISUALS", 4483362458)
local OthersTab = Window:CreateTab("OTHERS", 4483362458)
local GunModsTab = Window:CreateTab("GUN MODS", 4483362458)

-- MAIN: Safe Loader
MainTab:CreateButton({
    Name = "Aimbot (Click to Load)",
    Callback = function()
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/DanielHubll/DanielHubll/refs/heads/main/Aimbot%20Mobile"))()
            end)
            Rayfield:Notify({
                Title = ok and "Aimbot Loaded" or "Error",
                Content = ok and "Aimbot activated." or tostring(err),
                Duration = 4
            })
        end)
    end
})

-- VISUALS (Safe ESP)
local Players, RunService = game:GetService("Players"), game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local espEnabled = false
local guiTags = {}

local function createESP(player)
    if player == LocalPlayer or not player.Character then return end
    local head = player.Character:FindFirstChild("Head")
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not head or not humanoid then return end
    if guiTags[player] then guiTags[player].Adornee = head return end

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESPGui"
    bb.Size = UDim2.new(0, 100, 0, 20)
    bb.Adornee = head
    bb.AlwaysOnTop = true
    bb.Parent = head

    local label = Instance.new("TextLabel", bb)
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 0, 0)
    label.TextScaled = true
    label.Text = ""

    guiTags[player] = { gui = bb, label = label, hum = humanoid }
end

local function removeESP(player)
    if guiTags[player] then
        guiTags[player].gui:Destroy()
        guiTags[player] = nil
    end
end

VisualsTab:CreateToggle({
    Name = "ESP Names + HP",
    CurrentValue = false,
    Callback = function(val)
        espEnabled = val
        for _, p in pairs(Players:GetPlayers()) do
            if val then createESP(p) else removeESP(p) end
        end
    end
})

RunService.RenderStepped:Connect(function()
    for _, data in pairs(guiTags) do
        if data.label and data.hum then
            data.label.Text = "HP: " .. math.floor(data.hum.Health)
        end
    end
end)

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if espEnabled then createESP(p) end
    end)
end)

-- OTHERS
OthersTab:CreateButton({
    Name = "Enable Infinite Jump",
    Callback = function()
        game:GetService("UserInputService").JumpRequest:Connect(function()
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
            end
        end)
    end
})

OthersTab:CreateSlider({
    Name = "WalkSpeed Changer",
    Range = {16, 100},
    CurrentValue = 16,
    Callback = function(val)
        if LocalPlayer.Character then
            local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if h then h.WalkSpeed = val end
        end
    end
})

-- GUN MODS
GunModsTab:CreateButton({
    Name = "Enable Gun Mods",
    Callback = function()
        local success, err = pcall(function()
            for _, v in pairs(debug.getregistry()) do
                if type(v) == "table" then
                    if rawget(v, "ShootCooldown") then v.ShootCooldown = 0 end
                    if rawget(v, "ShootSpread") then v.ShootSpread = 0 end
                    if rawget(v, "ShootRecoil") then v.ShootRecoil = 0 end
                end
            end
        end)
        Rayfield:Notify({
            Title = "CodeNest Hub",
            Content = success and "✅ Gun Mods Activated" or tostring(err),
            Duration = 4
        })
    end
})

-- INFO
Window:CreateTab("INFO", 4483362458):CreateParagraph({
    Title = "CodeNest Hub",
    Content = "By Sike • Key system removed"
})
