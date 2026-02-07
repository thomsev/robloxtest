--!strict

local BuildStart = require(script.section_builders.BuildStart)
local BuildOnboarding = require(script.section_builders.BuildOnboarding)
local BuildGaps = require(script.section_builders.BuildGaps)
local BuildSpeed = require(script.section_builders.BuildSpeed)
local BuildNPCSection = require(script.section_builders.BuildNPCSection)
local BuildFinale = require(script.section_builders.BuildFinale)

local WorldBuilder = {}

function WorldBuilder.Build(root: Model, startCF: CFrame)
	local cursor = startCF
	cursor = BuildStart.Build(root, cursor)
	cursor = BuildOnboarding.Build(root, cursor)
	cursor = BuildGaps.Build(root, cursor)
	cursor = BuildSpeed.Build(root, cursor)
	cursor = BuildNPCSection.Build(root, cursor)
	cursor = BuildFinale.Build(root, cursor)
	return cursor
end

return WorldBuilder
