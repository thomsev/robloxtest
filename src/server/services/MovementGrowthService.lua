--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local MovementGrowthService = {}
local lastPositions: { [Player]: Vector3 } = {}
local lastPulse: { [Player]: number } = {}

function MovementGrowthService.Init(sizeService, treadmillService, currencyService, upgradeService, effectsService)
	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				local root = Util.getRootPart(Util.getCharacter(player))
				if not root then
					continue
				end
				local currentPos = root.Position
				local lastPos = lastPositions[player]
				lastPositions[player] = currentPos
				if not lastPos then
					continue
				end

				local distance = (currentPos - lastPos).Magnitude
				if distance <= 0 or distance > Config.AntiExploit.MaxDistancePerTick then
					continue
				end

				local boostMultiplier = treadmillService.GetMultiplier(player)
				local dailyMultiplier = if ((player:GetAttribute(Constants.ATTR_DAILY_BOOST_UNTIL) or 0) :: number) > os.time() then Config.DailyReward.GrowthMultiplier else 1
				local growthDelta = distance * Config.GrowthPerMeter * boostMultiplier * sizeService.GetRebirthMultiplier(player) * upgradeService.GrowthMultiplier(player) * dailyMultiplier
				sizeService.AddSize(player, growthDelta, effectsService, upgradeService)
				currencyService.AddCoins(player, math.floor(distance * Config.DistanceCoinsPerMeter))

				local now = os.clock()
				if not lastPulse[player] or now - lastPulse[player] >= Config.PassiveCoinPulseSeconds then
					lastPulse[player] = now
					currencyService.AddCoins(player, Config.PassiveCoinPulseAmount)
					effectsService.Feedback(player, "+5 coin streak")
				end
			end
			Util.safeWait(Config.AntiExploit.TickRateSeconds)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastPositions[player] = nil
		lastPulse[player] = nil
	end)
end

return MovementGrowthService
