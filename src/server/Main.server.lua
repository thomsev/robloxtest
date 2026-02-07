--!strict

local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Remotes = require(Shared.Remotes)

local servicesFolder = script.Parent:WaitForChild("services")
local MapBootstrapService = require(servicesFolder.MapBootstrapService)
local SizeService = require(servicesFolder.SizeService)
local TreadmillService = require(servicesFolder.TreadmillService)
local GateService = require(servicesFolder.GateService)
local MovementGrowthService = require(servicesFolder.MovementGrowthService)
local DataStoreService = require(servicesFolder.DataStoreService)

local feedbackEvent = Remotes.getFeedbackEvent()

MapBootstrapService.Init()
SizeService.Init()
TreadmillService.Init()
GateService.Init(SizeService)
MovementGrowthService.Init(SizeService, TreadmillService)
DataStoreService.Init(SizeService)

local map = workspace:WaitForChild("GeneratedMap")
local rebirthPad = map:WaitForChild("RebirthPad") :: BasePart

rebirthPad.Touched:Connect(function(hit)
	local character = hit.Parent
	if not character or not character:IsA("Model") then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	if SizeService.Rebirth(player) then
		feedbackEvent:FireClient(player, "Rebirth! Multiplier increased.")
	else
		feedbackEvent:FireClient(player, string.format("Need size %.0f to rebirth.", Config.RebirthRequiredSize))
	end
end)
