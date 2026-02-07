--!strict

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)

local MapBootstrapService = {}

local function makePart(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Anchored = true
	part.Material = Enum.Material.Plastic
	part.Color = color
	part.TopSurface = Enum.SurfaceType.Studs
	part.BottomSurface = Enum.SurfaceType.Inlet
	part.Parent = parent
	return part
end

local function createStuds(parentPart: BasePart, parent: Instance)
	for x = -2, 2 do
		for z = -2, 2 do
			local stud = Instance.new("Part")
			stud.Name = "Stud"
			stud.Shape = Enum.PartType.Cylinder
			stud.Size = Vector3.new(0.4, 0.2, 0.4)
			stud.Orientation = Vector3.new(0, 0, 90)
			stud.Color = parentPart.Color
			stud.Material = Enum.Material.Plastic
			stud.Anchored = true
			stud.CanCollide = false
			stud.CFrame = parentPart.CFrame * CFrame.new(x * 2, parentPart.Size.Y / 2 + 0.1, z * 2)
			stud.Parent = parent
		end
	end
end

function MapBootstrapService.Init()
	if Workspace:FindFirstChild("GeneratedMap") then
		return
	end

	local map = Instance.new("Model")
	map.Name = "GeneratedMap"
	map.Parent = Workspace

	local spawnArea = makePart("SpawnPlatform", Vector3.new(40, 1, 30), CFrame.new(0, 0, 0), Color3.fromRGB(255, 223, 80), map)
	createStuds(spawnArea, map)

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(0, 2, 0)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.TopSurface = Enum.SurfaceType.Studs
	spawn.Parent = map

	local trackStartZ = 30
	for i = 1, 20 do
		local track = makePart(
			"Track_" .. i,
			Vector3.new(20, 1, 16),
			CFrame.new(0, 0, trackStartZ + i * 16),
			if i % 2 == 0 then Color3.fromRGB(76, 176, 80) else Color3.fromRGB(100, 181, 246),
			map
		)
		if i % 5 == 0 then
			createStuds(track, map)
		end
	end

	for i, required in Config.GateRequirements do
		local gateModel = Instance.new("Model")
		gateModel.Name = "Gate_" .. i
		gateModel.Parent = map

		local zPos = 70 + i * 52
		makePart("LeftPillar", Vector3.new(3, 20, 3), CFrame.new(-11, 10, zPos), Color3.fromRGB(244, 67, 54), gateModel)
		makePart("RightPillar", Vector3.new(3, 20, 3), CFrame.new(11, 10, zPos), Color3.fromRGB(244, 67, 54), gateModel)
		local header = makePart("Header", Vector3.new(25, 3, 3), CFrame.new(0, 19, zPos), Color3.fromRGB(255, 152, 0), gateModel)
		header.TopSurface = Enum.SurfaceType.Smooth

		local gateTrigger = makePart("GateTrigger", Vector3.new(22, 10, 2), CFrame.new(0, 5, zPos), Color3.fromRGB(255, 255, 255), gateModel)
		gateTrigger.Transparency = 1
		gateTrigger.CanCollide = false
		gateTrigger:SetAttribute("RequiredSize", required)
		CollectionService:AddTag(gateTrigger, "SizeGate")

		local returnPart = makePart("GateReturn", Vector3.new(6, 1, 6), CFrame.new(0, 1, zPos - 12), Color3.fromRGB(158, 158, 158), gateModel)
		returnPart.Transparency = 0.35
		returnPart.TopSurface = Enum.SurfaceType.Smooth
	end

	for i = 1, 2 do
		local zPos = 120 + i * 110
		local treadmill = makePart("Treadmill_" .. i, Vector3.new(16, 1, 12), CFrame.new(0, 1.2, zPos), Color3.fromRGB(171, 71, 188), map)
		treadmill:SetAttribute("BoostMultiplier", Config.TreadmillBoostMultiplier + (i - 1) * 0.5)
		CollectionService:AddTag(treadmill, "Treadmill")
	end

	local finish = makePart("FinishPlatform", Vector3.new(30, 1, 20), CFrame.new(0, 1, 420), Color3.fromRGB(255, 87, 34), map)
	createStuds(finish, map)

	local sign = Instance.new("Part")
	sign.Name = "FinishSign"
	sign.Size = Vector3.new(18, 8, 1)
	sign.CFrame = CFrame.new(0, 8, 430)
	sign.Anchored = true
	sign.Material = Enum.Material.Plastic
	sign.Color = Color3.fromRGB(33, 33, 33)
	sign.Parent = map

	local rebirthPad = makePart("RebirthPad", Vector3.new(10, 1, 10), CFrame.new(0, 1.5, 415), Color3.fromRGB(255, 235, 59), map)
	rebirthPad:SetAttribute("IsRebirthPad", true)
end

return MapBootstrapService
