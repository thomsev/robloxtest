--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)

local MapBootstrapService = {}
local jumpPadDebounce: { [BasePart]: { [number]: number } } = {}

local function makePart(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Anchored = true
	part.Color = color
	part.Material = Enum.Material.Plastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function addSmashable(part: BasePart, kind: string)
	part:SetAttribute("SmashKind", kind)
	part:SetAttribute("RequiredSize", Config.Smashables[kind].RequiredSize)
	CollectionService:AddTag(part, Constants.TAG_SMASHABLE)
end

local function connectHazardKill(part: BasePart)
	part.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if humanoid and humanoid.Health > 0 then
			humanoid.Health = 0
		end
	end)
end

local function addJumpPad(parent: Instance, worldConfig, index: number)
	local xOffset = (index % 2 == 0) and 11 or -11
	local z = worldConfig.Spawn.Z + 90 + index * 78
	local pad = makePart("JumpPad_" .. index, Vector3.new(8, 1, 8), CFrame.new(xOffset, worldConfig.Spawn.Y - 2, z), Color3.fromRGB(72, 186, 255), parent)
	pad.Material = Enum.Material.Neon
	pad:SetAttribute("JumpBoost", 95 + worldConfig.Id * 6)
	jumpPadDebounce[pad] = {}

	pad.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end
		local root = character:FindFirstChild("HumanoidRootPart")
		if not root or not root:IsA("BasePart") then
			return
		end
		local now = os.clock()
		local perPlayerDebounce = jumpPadDebounce[pad]
		if perPlayerDebounce[player.UserId] and now - perPlayerDebounce[player.UserId] < 1.1 then
			return
		end
		perPlayerDebounce[player.UserId] = now
		local boost = (pad:GetAttribute("JumpBoost") or 95) :: number
		root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X * 0.7, boost, root.AssemblyLinearVelocity.Z + 14)
	end)
end

local function buildLaneDecor(parent: Instance, worldConfig)
	for i = 1, 20 do
		local z = worldConfig.Spawn.Z + 20 + i * 20
		local laneX = (i % 2 == 0) and -14 or 14
		local strip = makePart("BoostStrip_" .. i, Vector3.new(6, 0.6, 10), CFrame.new(laneX, worldConfig.Spawn.Y - 2.2, z), Color3.fromRGB(255, 255, 255), parent)
		strip.Material = Enum.Material.Neon
		strip.Transparency = 0.25

		if i % 3 == 0 then
			local ramp = makePart("Ramp_" .. i, Vector3.new(8, 1, 12), CFrame.new(-laneX, worldConfig.Spawn.Y - 1.8, z + 8) * CFrame.Angles(math.rad(-12), 0, 0), Color3.fromRGB(255, 199, 74), parent)
			ramp.Material = Enum.Material.SmoothPlastic
		end
	end
end

local function addJumpWalls(parent: Instance, worldConfig)
	for i = 1, 6 do
		local wallHeight = 6 + (i % 2)
		local z = worldConfig.Spawn.Z + 120 + i * 52
		local wall = makePart("JumpWall_" .. i, Vector3.new(30, wallHeight, 3), CFrame.new(0, worldConfig.Spawn.Y - 2 + wallHeight * 0.5, z), Color3.fromRGB(255, 124, 124), parent)
		wall.Material = Enum.Material.Slate

		local sideGap = makePart("JumpWallGapMarker_" .. i, Vector3.new(6, 0.6, 8), CFrame.new((i % 2 == 0 and -16 or 16), worldConfig.Spawn.Y - 2.2, z), Color3.fromRGB(255, 236, 125), parent)
		sideGap.Material = Enum.Material.Neon
		sideGap.Transparency = 0.35
	end
end

local function addLavaBalanceSection(parent: Instance, worldConfig)
	for i = 1, 3 do
		local zCenter = worldConfig.Spawn.Z + 180 + i * 90
		local lava = makePart("LavaPool_" .. i, Vector3.new(36, 1, 40), CFrame.new(0, worldConfig.Spawn.Y - 3.3, zCenter), Color3.fromRGB(255, 89, 0), parent)
		lava.Material = Enum.Material.Neon
		lava.Transparency = 0.1
		connectHazardKill(lava)

		for beamIndex = 1, 3 do
			local beamX = (beamIndex - 2) * 8
			local beam = makePart("BalanceBeam_" .. i .. "_" .. beamIndex, Vector3.new(2.2, 0.9, 40), CFrame.new(beamX, worldConfig.Spawn.Y + 1.1, zCenter), Color3.fromRGB(255, 238, 130), parent)
			beam.Material = Enum.Material.Wood
		end

		local entryPad = makePart("BeamEntry_" .. i, Vector3.new(30, 1, 8), CFrame.new(0, worldConfig.Spawn.Y - 2, zCenter - 24), Color3.fromRGB(95, 95, 95), parent)
		entryPad.Material = Enum.Material.Concrete
	end
end

local function buildWorld(worldConfig, parent: Instance)
	local worldModel = Instance.new("Model")
	worldModel.Name = worldConfig.Name
	worldModel.Parent = parent

	local floor = makePart("Floor", Vector3.new(42, 1, worldConfig.Length), CFrame.new(worldConfig.Spawn + Vector3.new(0, -3, worldConfig.Length * 0.5)), worldConfig.ThemeColor, worldModel)
	floor.Material = Enum.Material.SmoothPlastic

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Size = Vector3.new(8, 1, 8)
	spawn.CFrame = CFrame.new(worldConfig.Spawn)
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Parent = worldModel

	buildLaneDecor(worldModel, worldConfig)
	addJumpWalls(worldModel, worldConfig)
	addLavaBalanceSection(worldModel, worldConfig)

	for i = 1, 8 do
		local z = worldConfig.Spawn.Z + 40 + i * (worldConfig.Length / 10)
		local gate = makePart("Gate_" .. i, Vector3.new(24, 12, 2), CFrame.new(0, worldConfig.Spawn.Y + 4, z), Color3.fromRGB(255, 255, 255), worldModel)
		gate.Transparency = 1
		gate.CanCollide = false
		gate:SetAttribute("RequiredSize", 8 + i * 10 + (worldConfig.Id - 1) * 12)
		CollectionService:AddTag(gate, Constants.TAG_SIZE_GATE)

		local returnPad = makePart("GateReturn", Vector3.new(6, 1, 6), CFrame.new(0, worldConfig.Spawn.Y - 2, z - 10), Color3.fromRGB(80, 80, 80), worldModel)
		returnPad.Transparency = 0.35
	end

	for i = 1, 4 do
		local treadmill = makePart("Treadmill_" .. i, Vector3.new(16, 1, 14), CFrame.new((i % 2 == 0 and 10 or -10), worldConfig.Spawn.Y - 2, worldConfig.Spawn.Z + 55 + i * 66), Color3.fromRGB(160, 90, 210), worldModel)
		treadmill:SetAttribute("BoostMultiplier", Config.TreadmillBoostMultiplier + i * 0.16)
		CollectionService:AddTag(treadmill, Constants.TAG_TREADMILL)
	end

	for i = 1, 5 do
		addJumpPad(worldModel, worldConfig, i)
	end

	for i = 1, 24 do
		local kind = (i % 3 == 0 and "Wall") or (i % 2 == 0 and "Crate") or "Brick"
		local height = kind == "Wall" and 10 or (kind == "Crate" and 5 or 3)
		local size = kind == "Wall" and Vector3.new(10, height, 2) or (kind == "Crate" and Vector3.new(4, 4, 4) or Vector3.new(3, 3, 3))
		local x = ((i % 5) - 2) * 6
		local z = worldConfig.Spawn.Z + 30 + i * 14
		local smashable = makePart(kind .. "_" .. i, size, CFrame.new(x, worldConfig.Spawn.Y - 1 + (height / 2), z), Color3.fromRGB(255 - i * 3, 150 + (i % 3) * 20, 90 + i * 2), worldModel)
		addSmashable(smashable, kind)
	end

	for i = 1, 12 do
		local x = (i % 3 == 0 and 0) or (i % 2 == 0 and -13 or 13)
		local obstacle = makePart("Obstacle_" .. i, Vector3.new(6, 6, 6), CFrame.new(x, worldConfig.Spawn.Y + 1, worldConfig.Spawn.Z + 58 + i * 26), Color3.fromRGB(240, 70, 70), worldModel)
		CollectionService:AddTag(obstacle, Constants.TAG_OBSTACLE)
	end

	local finish = makePart("Finish", Vector3.new(28, 1, 16), CFrame.new(0, worldConfig.Spawn.Y - 2, worldConfig.Spawn.Z + worldConfig.Length - 20), Color3.fromRGB(255, 240, 60), worldModel)
	finish:SetAttribute("SectionComplete", true)

	if worldConfig.Id < #Config.Worlds then
		local nextWorld = Config.Worlds[worldConfig.Id + 1]
		local portal = makePart("PortalTo_" .. nextWorld.Name, Vector3.new(12, 14, 2), CFrame.new(0, worldConfig.Spawn.Y + 5, worldConfig.Spawn.Z + worldConfig.Length - 5), Color3.fromRGB(80, 200, 255), worldModel)
		portal.Material = Enum.Material.Neon
		portal:SetAttribute("WorldId", nextWorld.Id)
		portal:SetAttribute("RequiredSize", nextWorld.PortalRequirement)
		CollectionService:AddTag(portal, Constants.TAG_WORLD_PORTAL)
	end

	return floor
end

function MapBootstrapService.Init()
	if Workspace:FindFirstChild("GeneratedMap") then
		return
	end

	local map = Instance.new("Model")
	map.Name = "GeneratedMap"
	map.Parent = Workspace

	for _, worldConfig in ipairs(Config.Worlds) do
		buildWorld(worldConfig, map)
	end

	local rebirthPad = makePart("RebirthPad", Vector3.new(10, 1, 10), CFrame.new(0, 2, Config.Worlds[#Config.Worlds].Spawn.Z + Config.Worlds[#Config.Worlds].Length + 20), Color3.fromRGB(255, 235, 59), map)
	rebirthPad:SetAttribute("IsRebirthPad", true)
end

return MapBootstrapService
