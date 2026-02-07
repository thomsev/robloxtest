--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local GrowthService = {}
local lastPos: { [Player]: Vector3 } = {}
local lastPulse: { [Player]: number } = {}

function GrowthService.GetSize(player: Player): number
	return ((player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number)
end

function GrowthService.AddSize(player: Player, amount: number)
	local next = math.max(1, GrowthService.GetSize(player) + amount)
	player:SetAttribute(Constants.ATTR_SIZE, next)
	local hum = Util.getHumanoid(Util.getCharacter(player))
	if hum then
		local section = (player:GetAttribute(Constants.ATTR_SECTION) or 1) :: number
		hum.WalkSpeed = math.clamp(Config.BaseWalkSpeed + (next * 0.05) + (section * 1.5), Config.BaseWalkSpeed, Config.MaxWalkSpeed)
	end
end

function GrowthService.AddCoins(player: Player, amount: number)
	player:SetAttribute(Constants.ATTR_COINS, ((player:GetAttribute(Constants.ATTR_COINS) or 0) :: number) + math.floor(amount))
end

function GrowthService.Init(effectsService)
	Players.PlayerAdded:Connect(function(player)
		player:SetAttribute(Constants.ATTR_SIZE, 1)
		player:SetAttribute(Constants.ATTR_COINS, 0)
		player:SetAttribute(Constants.ATTR_SECTION, 1)
		player:SetAttribute(Constants.ATTR_CHECKPOINT, 0)
		player:SetAttribute(Constants.ATTR_LAST_HINT, "Reach the next checkpoint")
	end)

	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				local root = Util.getRootPart(Util.getCharacter(player))
				if not root then
					continue
				end
				local p = root.Position
				local lp = lastPos[player]
				lastPos[player] = p
				if lp then
					local d = (p - lp).Magnitude
					if d > 0 and d < 28 then
						GrowthService.AddSize(player, d * Config.GrowthPerStud)
						GrowthService.AddCoins(player, d * Config.CoinPerStud)
					end
				end
				local now = os.clock()
				if not lastPulse[player] or now - lastPulse[player] >= Config.FeedbackPulseSeconds then
					lastPulse[player] = now
					GrowthService.AddSize(player, Config.PassiveGrowthPulse)
					effectsService.Feedback(player, "+Growth! keep climbing")
					effectsService.Emit(player, "Pulse", {})
				end
			end
			task.wait(0.25)
		end
	end)
end

return GrowthService
