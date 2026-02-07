--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)

local STORE = DataStoreService:GetDataStore("RunBigger_PlayerData_v2")

local DataService = {}

local persistedAttrs = {
	Constants.ATTR_SIZE,
	Constants.ATTR_REBIRTHS,
	Constants.ATTR_COINS,
	Constants.ATTR_WORLD,
	Constants.ATTR_SPEED_LEVEL,
	Constants.ATTR_GROWTH_LEVEL,
	Constants.ATTR_SMASH_LEVEL,
	Constants.ATTR_DAILY_NEXT,
	Constants.ATTR_DAILY_BOOST_UNTIL,
	Constants.ATTR_BEST_SIZE,
}

local function keyForPlayer(player: Player): string
	return "player_" .. tostring(player.UserId)
end

function DataService.LoadPlayer(player: Player)
	local ok, data = pcall(function()
		return STORE:GetAsync(keyForPlayer(player))
	end)
	if not ok or type(data) ~= "table" then
		return
	end
	for _, attr in ipairs(persistedAttrs) do
		if type(data[attr]) == "number" or type(data[attr]) == "string" then
			player:SetAttribute(attr, data[attr])
		end
	end
end

function DataService.SavePlayer(player: Player)
	local payload = {}
	for _, attr in ipairs(persistedAttrs) do
		payload[attr] = player:GetAttribute(attr)
	end
	pcall(function()
		STORE:SetAsync(keyForPlayer(player), payload)
	end)
end

function DataService.Init(sizeService, currencyService)
	Players.PlayerAdded:Connect(function(player)
		DataService.LoadPlayer(player)
		sizeService.SetSize(player, (player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number)
		currencyService.SetCoins(player, (player:GetAttribute(Constants.ATTR_COINS) or 0) :: number)
	end)

	Players.PlayerRemoving:Connect(DataService.SavePlayer)

	task.spawn(function()
		while true do
			task.wait(Config.AutoSaveSeconds)
			for _, player in ipairs(Players:GetPlayers()) do
				DataService.SavePlayer(player)
			end
		end
	end)

	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			DataService.SavePlayer(player)
		end
	end)
end

return DataService
