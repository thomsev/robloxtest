--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local SizeService = {}

local scaleThrottle: { [Player]: number } = {}

local function getTierForSize(size: number): string
	local selected = Config.SizeTiers[1].Name
	for _, tier in ipairs(Config.SizeTiers) do
		if size >= tier.Min then
			selected = tier.Name
		end
	end
	return selected
end

function SizeService.GetSize(player: Player): number
	return ((player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number)
end

function SizeService.GetTier(player: Player): string
	return ((player:GetAttribute(Constants.ATTR_SIZE_TIER) or "Tiny") :: string)
end

function SizeService.GetRebirthMultiplier(player: Player): number
	local rebirths = (player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number
	return 1 + (rebirths * Config.RebirthGrowthBonus)
end

function SizeService.ApplyScaling(player: Player, upgradeService)
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
	local bodyScale = Util.clamp(0.8 + (size / 52), 0.8, 3.7)
	for _, scaleName in ipairs({ "BodyDepthScale", "BodyHeightScale", "BodyWidthScale", "HeadScale" }) do
		local scaleValue = humanoid:FindFirstChild(scaleName)
		if scaleValue and scaleValue:IsA("NumberValue") then
			scaleValue.Value = bodyScale
		end
	end

	local speedBonus = 0
	if upgradeService then
		speedBonus = upgradeService.SpeedBonus(player)
	end
	humanoid.WalkSpeed = Util.clamp(Config.BaseWalkSpeed + (size * 0.05) + speedBonus, Config.BaseWalkSpeed, Config.MaxWalkSpeed)
end

function SizeService.SetSize(player: Player, value: number, effectsService, upgradeService)
	local prev = SizeService.GetSize(player)
	local nextValue = Util.clamp(value, 1, Config.MaxSize)
	player:SetAttribute(Constants.ATTR_SIZE, nextValue)

	if nextValue > ((player:GetAttribute(Constants.ATTR_BEST_SIZE) or 1) :: number) then
		player:SetAttribute(Constants.ATTR_BEST_SIZE, nextValue)
	end

	local oldTier = getTierForSize(prev)
	local newTier = getTierForSize(nextValue)
	if oldTier ~= newTier then
		player:SetAttribute(Constants.ATTR_SIZE_TIER, newTier)
		if effectsService then
			effectsService.Feedback(player, "TIER UP: " .. newTier)
			effectsService.Emit(player, "TierChange", { Tier = newTier, Size = nextValue })
		end
	end

	SizeService.ApplyScaling(player, upgradeService)

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local sizeValue = leaderstats:FindFirstChild(Constants.ATTR_SIZE)
		if sizeValue and sizeValue:IsA("NumberValue") then
			sizeValue.Value = nextValue
		end
	end
end

function SizeService.AddSize(player: Player, delta: number, effectsService, upgradeService)
	local safeDelta = Util.clamp(delta, 0, Config.AntiExploit.MaxGrowthPerTick)
	if safeDelta <= 0 then
		return
	end
	SizeService.SetSize(player, SizeService.GetSize(player) + safeDelta, effectsService, upgradeService)
end

function SizeService.Rebirth(player: Player, effectsService, currencyService): boolean
	if SizeService.GetSize(player) < Config.RebirthRequiredSize then
		return false
	end

	local rebirths = ((player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number) + 1
	player:SetAttribute(Constants.ATTR_REBIRTHS, rebirths)
	SizeService.SetSize(player, Config.RebirthSizeReset, effectsService)
	player:SetAttribute(Constants.ATTR_GOD_MODE_UNTIL, os.clock() + Config.RebirthGodModeSeconds)
	currencyService.AddCoins(player, 200 + rebirths * 30)

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local rebirthValue = leaderstats:FindFirstChild(Constants.ATTR_REBIRTHS)
		if rebirthValue and rebirthValue:IsA("IntValue") then
			rebirthValue.Value = rebirths
		end
	end

	effectsService.Feedback(player, "REBIRTH READY?! BOOM!")
	effectsService.Emit(player, "Rebirth", { Rebirths = rebirths, GodModeSeconds = Config.RebirthGodModeSeconds })
	return true
end

function SizeService.Init()
	Players.PlayerAdded:Connect(function(player)
		for _, pair in ipairs({
			{ Constants.ATTR_SIZE, 1 },
			{ Constants.ATTR_REBIRTHS, 0 },
			{ Constants.ATTR_SIZE_TIER, "Tiny" },
			{ Constants.ATTR_BEST_SIZE, 1 },
		}) do
			if player:GetAttribute(pair[1]) == nil then
				player:SetAttribute(pair[1], pair[2])
			end
		end

		local leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player

		for _, info in ipairs({
			{ Constants.ATTR_SIZE, "NumberValue" },
			{ Constants.ATTR_REBIRTHS, "IntValue" },
			{ Constants.ATTR_COINS, "IntValue" },
		}) do
			local value = Instance.new(info[2])
			value.Name = info[1]
			value.Value = (player:GetAttribute(info[1]) or 0) :: number
			value.Parent = leaderstats
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		scaleThrottle[player] = nil
	end)
end

return SizeService
