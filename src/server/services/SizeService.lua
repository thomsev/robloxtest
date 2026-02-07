--!strict

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local SizeService = {}

local scaleThrottle: { [Player]: number } = {}

local function getRebirthMultiplier(player: Player): number
	local rebirths = (player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number
	return 1 + (rebirths * Config.RebirthGrowthBonus)
end

function SizeService.GetSize(player: Player): number
	return ((player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number)
end

function SizeService.GetRebirthMultiplier(player: Player): number
	return getRebirthMultiplier(player)
end

function SizeService.ApplyScaling(player: Player)
	local now = os.clock()
	if scaleThrottle[player] and now - scaleThrottle[player] < Config.ScaleApplyIntervalSeconds then
		return
	end
	scaleThrottle[player] = now

	local character = Util.getCharacter(player)
	local humanoid = Util.getHumanoid(character)
	if not humanoid then
		return
	end

	local size = SizeService.GetSize(player)
	local bodyScale = Util.clamp(0.85 + (size / 50), 0.85, 2.8)

	local scales = {
		"BodyDepthScale",
		"BodyHeightScale",
		"BodyWidthScale",
		"HeadScale",
	}

	for _, scaleName in ipairs(scales) do
		local scaleValue = humanoid:FindFirstChild(scaleName)
		if scaleValue and scaleValue:IsA("NumberValue") then
			scaleValue.Value = bodyScale
		end
	end

	humanoid.WalkSpeed = Util.clamp(
		Config.BaseWalkSpeed + size * Config.WalkSpeedBonusPerSize,
		Config.BaseWalkSpeed,
		Config.MaxWalkSpeed
	)
end

function SizeService.SetSize(player: Player, value: number)
	local nextValue = Util.clamp(value, 1, Config.MaxSize)
	player:SetAttribute(Constants.ATTR_SIZE, nextValue)
	SizeService.ApplyScaling(player)

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local sizeValue = leaderstats:FindFirstChild(Constants.ATTR_SIZE)
		if sizeValue and sizeValue:IsA("NumberValue") then
			sizeValue.Value = nextValue
		end
	end
end

function SizeService.AddSize(player: Player, delta: number)
	local safeDelta = Util.clamp(delta, 0, Config.AntiExploit.MaxGrowthPerTick)
	if safeDelta <= 0 then
		return
	end

	local current = SizeService.GetSize(player)
	SizeService.SetSize(player, current + safeDelta)
end

function SizeService.Rebirth(player: Player): boolean
	local size = SizeService.GetSize(player)
	if size < Config.RebirthRequiredSize then
		return false
	end

	local rebirths = ((player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number) + 1
	player:SetAttribute(Constants.ATTR_REBIRTHS, rebirths)
	SizeService.SetSize(player, 1)

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirthValue = leaderstats:FindFirstChild(Constants.ATTR_REBIRTHS)
		if rebirthValue and rebirthValue:IsA("IntValue") then
			rebirthValue.Value = rebirths
		end
	end

	return true
end

function SizeService.Init()
	Players.PlayerAdded:Connect(function(player)
		if player:GetAttribute(Constants.ATTR_SIZE) == nil then
			player:SetAttribute(Constants.ATTR_SIZE, 1)
		end
		if player:GetAttribute(Constants.ATTR_REBIRTHS) == nil then
			player:SetAttribute(Constants.ATTR_REBIRTHS, 0)
		end

		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		local sizeValue = Instance.new("NumberValue")
		sizeValue.Name = Constants.ATTR_SIZE
		sizeValue.Value = SizeService.GetSize(player)
		sizeValue.Parent = leaderstats

		local rebirthValue = Instance.new("IntValue")
		rebirthValue.Name = Constants.ATTR_REBIRTHS
		rebirthValue.Value = (player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number
		rebirthValue.Parent = leaderstats

		player.CharacterAdded:Connect(function()
			task.defer(function()
				SizeService.ApplyScaling(player)
			end)
		end)
	end)

	Players.PlayerRemoving:Connect(function(player)
		scaleThrottle[player] = nil
	end)
end

return SizeService
