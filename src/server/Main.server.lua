--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local services = script.Parent:WaitForChild("services")
local EffectsService = require(services.EffectsService)
local WorldBuilder = require(services.WorldBuilder)
local GrowthService = require(services.GrowthService)
local CheckpointService = require(services.CheckpointService)
local NPCService = require(services.NPCService)
local SmashService = require(services.SmashService)

WorldBuilder.Build()
GrowthService.Init(EffectsService)
CheckpointService.Init(EffectsService, GrowthService)
NPCService.Init()
SmashService.Init(GrowthService, EffectsService)

print("[Main.server] Growth Tower online", #Config.Sections, "sections")
