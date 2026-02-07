--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)

local STORE = DataStoreService:GetDataStore("RunGrowObby_PlayerData_v1")

local DataService = {}

local function keyForPlayer(player: Player): string
	return "player_" .. tostring(player.UserId)
end

function DataService.LoadPlayer(player: Player)
	local ok, data = pcall(function()
		return STORE:GetAsync(keyForPlayer(player))
	end)
	if not ok then
		warn("Failed to load player data:", player.UserId, data)
		return
	end

	if type(data) == "table" then
		if type(data.Size) == "number" then
			player:SetAttribute(Constants.ATTR_SIZE, data.Size)
		end
		if type(data.Rebirths) == "number" then
			player:SetAttribute(Constants.ATTR_REBIRTHS, data.Rebirths)
		end
	end
end

function DataService.SavePlayer(player: Player)
	local payload = {
		Size = player:GetAttribute(Constants.ATTR_SIZE) or 1,
		Rebirths = player:GetAttribute(Constants.ATTR_REBIRTHS) or 0,
	}

	local ok, err = pcall(function()
		STORE:SetAsync(keyForPlayer(player), payload)
	end)
	if not ok then
		warn("Failed to save player data:", player.UserId, err)
	end
end

function DataService.Init(sizeService)
	Players.PlayerAdded:Connect(function(player)
		DataService.LoadPlayer(player)
		sizeService.SetSize(player, (player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number)
	end)

	Players.PlayerRemoving:Connect(function(player)
		DataService.SavePlayer(player)
	end)

	task.spawn(function()
		while true do
			task.wait(Config.AutoSaveSeconds)
			for _, player in Players:GetPlayers() do
				DataService.SavePlayer(player)
			end
		end
	end)

	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			DataService.SavePlayer(player)
		end
	end)
end

return DataService
