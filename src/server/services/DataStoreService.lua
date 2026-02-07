--!strict

local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)

local DataService = {}
local store = DataStoreService:GetDataStore("GrowthRun_v1")

local attrs = {
	Constants.ATTR_SIZE,
	Constants.ATTR_COINS,
	Constants.ATTR_CHECKPOINT,
	Constants.ATTR_SECTION,
}

local function key(player: Player): string
	return "player_" .. tostring(player.UserId)
end

local function save(player: Player)
	local payload = {}
	for _, attr in ipairs(attrs) do
		payload[attr] = player:GetAttribute(attr)
	end
	local ok, err = pcall(function()
		store:SetAsync(key(player), payload)
	end)
	if not ok then
		warn("[DataStoreService] Save failed for", player.Name, err)
	end
end

local function load(player: Player)
	local ok, data = pcall(function()
		return store:GetAsync(key(player))
	end)
	if not ok then
		warn("[DataStoreService] Load failed for", player.Name, data)
		return
	end
	if type(data) ~= "table" then
		return
	end
	for _, attr in ipairs(attrs) do
		local v = data[attr]
		if type(v) == "number" or type(v) == "string" then
			player:SetAttribute(attr, v)
		end
	end
end

function DataService.Init()
	if RunService:IsStudio() then
		warn("[DataStoreService] Studio mode detected: persistence disabled (no-op).")
		return
	end

	Players.PlayerAdded:Connect(load)
	Players.PlayerRemoving:Connect(save)
	game:BindToClose(function()
		for _, player in ipairs(Players:GetPlayers()) do
			save(player)
		end
	end)
end

return DataService
