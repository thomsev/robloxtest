--!strict

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local SectionConfig = require(script.Parent.SectionConfig)

local SectionModules = {
	require(script.sections.Section1),
	require(script.sections.Section2),
	require(script.sections.Section3),
	require(script.sections.Section4),
	require(script.sections.Section5),
	require(script.sections.Section6),
}

local WorldBuilder = {}

local function makeCheckpoint(parent: Instance, index: number, pos: Vector3)
	local cp = Instance.new("Part")
	cp.Name = "Checkpoint_" .. index
	cp.Anchored = true
	cp.Size = Vector3.new(10, 1, 10)
	cp.CFrame = CFrame.new(pos)
	cp.Color = Color3.fromRGB(90, 255, 95)
	cp.Material = Enum.Material.Neon
	cp:SetAttribute("Index", index)
	CollectionService:AddTag(cp, Constants.TAG_CHECKPOINT)
	cp.Parent = parent
end

function WorldBuilder.Build()
	local existing = Workspace:FindFirstChild("GrowthTower")
	if existing then
		existing:Destroy()
	end

	local tower = Instance.new("Model")
	tower.Name = "GrowthTower"
	tower.Parent = Workspace

	local core = Instance.new("Part")
	core.Name = "TowerCore"
	core.Anchored = true
	core.Size = Vector3.new(32, 220, 32)
	core.CFrame = CFrame.new(Config.TowerCenter + Vector3.new(0, 110, 0))
	core.Color = Color3.fromRGB(247, 92, 92)
	core.Material = Enum.Material.Plastic
	core.Parent = tower

	local spawnPad = Instance.new("SpawnLocation")
	spawnPad.Anchored = true
	spawnPad.Size = Vector3.new(16, 1, 16)
	spawnPad.CFrame = CFrame.new(Config.TowerCenter + Vector3.new(Config.TowerRadius, Config.BaseHeight, 0))
	spawnPad.Neutral = true
	spawnPad.Parent = tower

	local angle = 0
	local y = Config.BaseHeight + 2
	for i = 1, SectionConfig.Count() do
		local section = SectionModules[i]
		local result = section.Build({ center = Config.TowerCenter, radius = Config.TowerRadius, startAngle = angle, startY = y, section = SectionConfig.Get(i) }, tower)
		if SectionConfig.Get(i).CheckpointAfter then
			makeCheckpoint(tower, i, result.Checkpoint)
		end
		angle = result.EndAngle
		y = result.EndY
	end

	return tower
end

return WorldBuilder
