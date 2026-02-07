--!strict

local CollectionService = game:GetService("CollectionService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)

local MapBootstrapService = {}

local function makePart(name: string, size: Vector3, cf: CFrame, color: Color3, parent: Instance): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.CFrame = cf
	part.Anchored = true
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
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

local function buildLobby(parent: Instance)
	local lobby = Instance.new("Model")
	lobby.Name = "Lobby"
	lobby.Parent = parent

	makePart("LobbyFloor", Vector3.new(180, 2, 180), CFrame.new(0, 0, 0), Color3.fromRGB(45, 48, 75), lobby)
	makePart("SpawnPad", Vector3.new(14, 2, 14), CFrame.new(0, 2, 0), Color3.fromRGB(255, 225, 95), lobby)

	for i = 1, 3 do
		local x = -45 + (i * 22)
		local treadmill = makePart("LobbyTreadmill_" .. i, Vector3.new(14, 1, 18), CFrame.new(x, 2.5, 35), Color3.fromRGB(167, 91, 255), lobby)
		treadmill:SetAttribute("BoostMultiplier", Config.TreadmillBoostMultiplier + i * 0.2)
		CollectionService:AddTag(treadmill, Constants.TAG_TREADMILL)
	end

	local rebirthPad = makePart("RebirthPad", Vector3.new(10, 1, 10), CFrame.new(70, 2, 0), Color3.fromRGB(255, 235, 59), lobby)
	rebirthPad:SetAttribute("IsRebirthPad", true)

	for i, world in ipairs(Config.Worlds) do
		local portal = makePart("Portal_" .. world.Name, Vector3.new(10, 16, 2), CFrame.new(-65 + (i - 1) * 28, 10, -42), world.ThemeColor, lobby)
		portal.Material = Enum.Material.Neon
		portal:SetAttribute("WorldId", world.Id)
		portal:SetAttribute("RequiredSize", world.PortalRequirement)
		portal:SetAttribute("RequiredRebirth", world.RequiredRebirth)
		CollectionService:AddTag(portal, Constants.TAG_WORLD_PORTAL)
	end

	for i = 1, 4 do
		local zone = makePart("CollisionRamp_" .. i, Vector3.new(14, 1, 18), CFrame.new(-30 + (i * 20), 2.5, 66), Color3.fromRGB(255, 105, 105), lobby)
		zone:SetAttribute("Knockback", 48)
		CollectionService:AddTag(zone, Constants.TAG_COLLISION_ZONE)
	end
end

local function buildWorld(worldConfig, parent: Instance)
	local worldModel = Instance.new("Model")
	worldModel.Name = worldConfig.Name
	worldModel.Parent = parent

	local laneLength = 82
	for level = 1, worldConfig.Levels do
		local y = worldConfig.Spawn.Y + (level - 1) * worldConfig.LevelHeight
		local centerZ = worldConfig.Spawn.Z + (level - 1) * (laneLength + 26)
		local width = math.max(8, 24 - level * 2)
		makePart(("Path_%d"):format(level), Vector3.new(width, 1, laneLength), CFrame.new(worldConfig.Spawn.X, y, centerZ), worldConfig.ThemeColor, worldModel)

		if level > 1 then
			local ramp = makePart(("Ramp_%d"):format(level), Vector3.new(width - 2, 3, 22), CFrame.new(worldConfig.Spawn.X + 10, y - 12, centerZ - laneLength * 0.5 - 8) * CFrame.Angles(math.rad(20), 0, 0), Color3.fromRGB(70, 70, 70), worldModel)
			CollectionService:AddTag(ramp, Constants.TAG_COLLISION_ZONE)
			ramp:SetAttribute("Knockback", 58 + level * 4)
		end

		local cp = makePart(("W%d_Checkpoint_%d"):format(worldConfig.Id, level), Vector3.new(width, 1, 6), CFrame.new(worldConfig.Spawn.X, y + 0.7, centerZ - laneLength * 0.5 + 10), Color3.fromRGB(80, 255, 95), worldModel)
		cp.Transparency = 0.2
		cp:SetAttribute("CheckpointId", string.format("W%d_L%d", worldConfig.Id, level))
		cp:SetAttribute("WorldId", worldConfig.Id)
		cp:SetAttribute("RespawnX", worldConfig.Spawn.X)
		cp:SetAttribute("RespawnY", y + 4)
		cp:SetAttribute("RespawnZ", centerZ - laneLength * 0.5 + 16)
		CollectionService:AddTag(cp, Constants.TAG_CHECKPOINT)

		for i = 1, 4 + level do
			local gapOffset = -laneLength * 0.35 + i * (laneLength / (5 + level))
			local islandWidth = math.max(4, width - level - 3)
			makePart(("Jump_%d_%d"):format(level, i), Vector3.new(islandWidth, 1, 7), CFrame.new(worldConfig.Spawn.X + ((i % 2 == 0) and 5 or -5), y + 2, centerZ + gapOffset), worldConfig.ThemeColor:Lerp(Color3.new(1, 1, 1), 0.2), worldModel)
		end
	end

	for i = 1, worldConfig.Levels * 4 do
		local kind = (i % 3 == 0 and "Wall") or (i % 2 == 0 and "Crate") or "Brick"
		local z = worldConfig.Spawn.Z + 20 + i * 16
		local y = worldConfig.Spawn.Y + (math.floor(i / 4) * worldConfig.LevelHeight)
		local smashable = makePart(kind .. "_" .. i, Vector3.new(4, 4, 4), CFrame.new(worldConfig.Spawn.X + ((i % 2 == 0) and -9 or 9), y + 2, z), Color3.fromRGB(255 - i * 2, 140 + (i % 3) * 30, 90 + i * 2), worldModel)
		addSmashable(smashable, kind)
	end

	for i = 1, worldConfig.Levels do
		local npcRoot = makePart("Interferer_" .. i, Vector3.new(3, 5, 3), CFrame.new(worldConfig.Spawn.X + 6, worldConfig.Spawn.Y + (i - 1) * worldConfig.LevelHeight + 4, worldConfig.Spawn.Z + 22 + i * 24), Color3.fromRGB(255, 75, 75), worldModel)
		npcRoot:SetAttribute("PatrolA", worldConfig.Spawn.X - 7)
		npcRoot:SetAttribute("PatrolB", worldConfig.Spawn.X + 7)
		npcRoot:SetAttribute("Force", 75 + i * 10)
		CollectionService:AddTag(npcRoot, Constants.TAG_NPC)
	end

	local finish = makePart("Finish", Vector3.new(20, 1, 12), CFrame.new(worldConfig.Spawn.X, worldConfig.Spawn.Y + (worldConfig.Levels - 1) * worldConfig.LevelHeight + 2, worldConfig.Spawn.Z + worldConfig.Levels * 110), Color3.fromRGB(255, 240, 60), worldModel)
	finish:SetAttribute("SectionComplete", true)
	finish:SetAttribute("WorldId", worldConfig.Id)
end

function MapBootstrapService.Init()
	if Workspace:FindFirstChild("GeneratedMap") then
		return
	end

	local map = Instance.new("Model")
	map.Name = "GeneratedMap"
	map.Parent = Workspace

	buildLobby(map)
	for _, worldConfig in ipairs(Config.Worlds) do
		buildWorld(worldConfig, map)
	end
end

return MapBootstrapService
