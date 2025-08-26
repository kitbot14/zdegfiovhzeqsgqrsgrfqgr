local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local flying = false
local enabled = false

local function enableFly()
    if flying or not enabled then return end
    flying = true
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bv = Instance.new("BodyVelocity")
    bv.Name = "MobileFly"
    bv.Velocity = Vector3.new(0, 50, 0)
    bv.MaxForce = Vector3.new(0, 100000, 0)
    bv.P = 10000
    bv.Parent = hrp
end

local function disableFly()
    flying = false
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local bv = hrp:FindFirstChild("MobileFly")
        if bv then bv:Destroy() end
    end
end

local function setupJumpFly()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")

    hum.Jumping:Connect(function(isJumping)
        if enabled then
            if isJumping then
                enableFly()
            else
                disableFly()
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(setupJumpFly)
if LocalPlayer.Character then
    setupJumpFly()
end

local module = {}

function module.SetEnabled(v)
    enabled = v
    if not v then
        disableFly()
    end
end

return module
