--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local services = script.Parent:WaitForChild("services")
local EffectsService = require(services.EffectsService)
local MapBootstrapService = require(services.MapBootstrapService)
local GrowthService = require(services.GrowthService)
local CheckpointService = require(services.CheckpointService)
local NPCService = require(services.NPCService)
local SmashService = require(services.SmashService)
local DataService = require(services.DataStoreService)

MapBootstrapService.Init()
GrowthService.Init(EffectsService)
CheckpointService.Init(EffectsService, GrowthService)
NPCService.Init()
SmashService.Init(GrowthService, EffectsService)

local ok, err = pcall(function()
	DataService.Init()
end)
if not ok then
	warn("[Main.server] DataService failed; continuing without persistence:", err)
end

print("[Main.server] Growth Run online", Config.Origin)
