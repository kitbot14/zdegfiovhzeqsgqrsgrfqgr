local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local enemyColor = Color3.new(1, 0, 0) -- Rouge
local allyColor = Color3.new(0, 1, 0)  -- Vert

-- 🔁 Obtenir l’ID d’équipe depuis le Character du joueur
local function getTeamId(player)
	if not player or not player.Character then return nil end
	local teamIdVal = player.Character:FindFirstChild("TeamId")
	if teamIdVal and teamIdVal:IsA("NumberValue") then
		return teamIdVal.Value
	end
	return nil
end

-- ✅ Déterminer si le joueur est un allié
local function isAlly(player)
	local myId = getTeamId(LocalPlayer)
	local otherId = getTeamId(player)
	if myId == nil or otherId == nil then return false end
	return myId == otherId
end

-- ✅ Appliquer les couleurs du Highlight
local function applyHighlight(player)
	if not player.Character then return end
	local char = player.Character

	local hl = char:FindFirstChild("Wallhl")
	if not hl then
		hl = Instance.new("Highlight")
		hl.Name = "Wallhl"
		hl.FillTransparency = 0.5
		hl.OutlineTransparency = 0
		hl.Adornee = char
		hl.Parent = char
	end

	-- Mettre la bonne couleur
	if isAlly(player) then
		hl.FillColor = allyColor
		hl.OutlineColor = allyColor
	else
		hl.FillColor = enemyColor
		hl.OutlineColor = enemyColor
	end

	hl.Enabled = enabled
end

-- 🔁 Mettre à jour tous les joueurs visibles
local function updateWallhack()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			applyHighlight(player)
		end
	end
end

-- ❌ Nettoyage des highlights
local function clearHighlights()
	for _, player in ipairs(Players:GetPlayers()) do
		if player.Character then
			local hl = player.Character:FindFirstChild("Wallhl")
			if hl then hl:Destroy() end
		end
	end
end

-- 📦 Export module
local module = {}

function module.SetEnabled(v)
	enabled = v
	if v then
		updateWallhack()
	else
		clearHighlights()
	end
end

function module.SetEnemyColor(c)
	enemyColor = c
end

function module.SetAllyColor(c)
	allyColor = c
end

function module.Update()
	if enabled then
		updateWallhack()
	end
end

return module
