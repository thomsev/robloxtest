--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Remotes = require(Shared.Remotes)

local UpgradeService = {}

local requestEvent = Remotes.getUpgradeRequestEvent()

local function attrForUpgrade(upgradeName: string): string?
	if upgradeName == "RunSpeed" then
		return Constants.ATTR_SPEED_LEVEL
	elseif upgradeName == "GrowthRate" then
		return Constants.ATTR_GROWTH_LEVEL
	elseif upgradeName == "SmashMultiplier" then
		return Constants.ATTR_SMASH_LEVEL
	end
	return nil
end

function UpgradeService.GetLevel(player: Player, upgradeName: string): number
	local attr = attrForUpgrade(upgradeName)
	if not attr then
		return 0
	end
	return ((player:GetAttribute(attr) or 0) :: number)
end

function UpgradeService.GetCost(player: Player, upgradeName: string): number
	local cfg = Config.Upgrades[upgradeName]
	if not cfg then
		return math.huge
	end
	local level = UpgradeService.GetLevel(player, upgradeName)
	if level >= cfg.MaxLevel then
		return math.huge
	end
	return math.floor(cfg.BaseCost * (cfg.CostGrowth ^ level))
end

function UpgradeService.GrowthMultiplier(player: Player): number
	local level = UpgradeService.GetLevel(player, "GrowthRate")
	return 1 + level * Config.Upgrades.GrowthRate.PerLevel
end

function UpgradeService.SpeedBonus(player: Player): number
	local level = UpgradeService.GetLevel(player, "RunSpeed")
	return level * Config.Upgrades.RunSpeed.PerLevel
end

function UpgradeService.SmashMultiplier(player: Player): number
	local level = UpgradeService.GetLevel(player, "SmashMultiplier")
	return 1 + level * Config.Upgrades.SmashMultiplier.PerLevel
end

function UpgradeService.TryPurchase(player: Player, upgradeName: string, currencyService, effectsService): boolean
	local cfg = Config.Upgrades[upgradeName]
	local attr = attrForUpgrade(upgradeName)
	if not cfg or not attr then
		return false
	end

	local level = UpgradeService.GetLevel(player, upgradeName)
	if level >= cfg.MaxLevel then
		effectsService.Feedback(player, "MAX LEVEL!")
		return false
	end

	local cost = UpgradeService.GetCost(player, upgradeName)
	if not currencyService.TrySpend(player, cost) then
		effectsService.Feedback(player, "Not enough coins!")
		return false
	end

	player:SetAttribute(attr, level + 1)
	effectsService.Feedback(player, string.format("%s UP! Lv.%d", upgradeName, level + 1))
	effectsService.Emit(player, "Upgrade", { Upgrade = upgradeName, Level = level + 1 })
	return true
end

function UpgradeService.Init(currencyService, effectsService)
	requestEvent.OnServerEvent:Connect(function(player, upgradeName)
		if type(upgradeName) ~= "string" then
			return
		end
		UpgradeService.TryPurchase(player, upgradeName, currencyService, effectsService)
	end)
end

return UpgradeService
