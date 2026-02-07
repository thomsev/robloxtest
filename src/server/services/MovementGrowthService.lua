--!strict

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Util = require(Shared.Util)

local MovementGrowthService = {}

local lastPositions: { [Player]: Vector3 } = {}

function MovementGrowthService.Init(sizeService, treadmillService)
	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				local character = Util.getCharacter(player)
				local root = Util.getRootPart(character)
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
				if distance <= 0 then
					continue
				end

				if distance > Config.AntiExploit.MaxDistancePerTick then
					continue
				end

				local multiplier = treadmillService.GetMultiplier(player) * sizeService.GetRebirthMultiplier(player)
				local growthDelta = distance * Config.GrowthPerMeter * multiplier
				sizeService.AddSize(player, growthDelta)
			end

			Util.safeWait(Config.AntiExploit.TickRateSeconds)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		lastPositions[player] = nil
	end)
end

return MovementGrowthService
