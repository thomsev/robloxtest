--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local WorldService = {}
local sectionTouched: { [string]: number } = {}

local function worldById(id: number)
	for _, world in ipairs(Config.Worlds) do
		if world.Id == id then
			return world
		end
	end
	return nil
end

local function teleport(player: Player, target: Vector3)
	local character = Util.getCharacter(player)
	if character and character.PrimaryPart then
		character:PivotTo(CFrame.new(target))
	end
end

local function teleportToWorld(player: Player, worldId: number, sizeService)
	local world = worldById(worldId)
	if not world then
		return
	end
	player:SetAttribute(Constants.ATTR_WORLD, worldId)
	if sizeService then
		sizeService.ApplyScaling(player)
	end
	teleport(player, world.Spawn)
end

local function canEnterWorld(player: Player, world): boolean
	local size = (player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number
	local rebirths = (player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number
	local unlocked = (player:GetAttribute(Constants.ATTR_WORLD_UNLOCK) or 1) :: number
	return size >= world.PortalRequirement and rebirths >= world.RequiredRebirth and unlocked >= world.Id
end

function WorldService.Init(sizeService, currencyService, effectsService)
	Players.PlayerAdded:Connect(function(player)
		if player:GetAttribute(Constants.ATTR_WORLD) == nil then
			player:SetAttribute(Constants.ATTR_WORLD, 0)
		end
		if player:GetAttribute(Constants.ATTR_WORLD_UNLOCK) == nil then
			player:SetAttribute(Constants.ATTR_WORLD_UNLOCK, 1)
		end
		player.CharacterAdded:Connect(function()
			task.delay(0.2, function()
				local cpName = player:GetAttribute(Constants.ATTR_CHECKPOINT)
				if type(cpName) == "string" and cpName ~= "" then
					local cp = Workspace:FindFirstChild(cpName, true)
					if cp and cp:IsA("BasePart") then
						teleport(player, cp.Position + Vector3.new(0, 4, 0))
						return
					end
				end
				player:SetAttribute(Constants.ATTR_WORLD, 0)
				sizeService.ApplyScaling(player)
				teleport(player, Vector3.new(0, 6, 0))
			end)
		end)
	end)

	for _, portal in ipairs(CollectionService:GetTagged(Constants.TAG_WORLD_PORTAL)) do
		if portal:IsA("BasePart") then
			portal.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then
					return
				end
				local targetWorldId = (portal:GetAttribute("WorldId") or 1) :: number
				local world = worldById(targetWorldId)
				if not world then
					return
				end
				if not canEnterWorld(player, world) then
					effectsService.Feedback(player, string.format("Need Size %.0f / Rebirth %d", world.PortalRequirement, world.RequiredRebirth))
					return
				end
				teleportToWorld(player, targetWorldId, sizeService)
				effectsService.Feedback(player, "NEW WORLD RUN!")
			end)
		end
	end

	for _, cp in ipairs(CollectionService:GetTagged(Constants.TAG_CHECKPOINT)) do
		if cp:IsA("BasePart") then
			cp.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then
					return
				end
				player:SetAttribute(Constants.ATTR_CHECKPOINT, cp.Name)
				effectsService.Feedback(player, "CHECKPOINT SAVED")
				currencyService.AddCoins(player, 20)
			end)
		end
	end

	local map = Workspace:FindFirstChild("GeneratedMap")
	if map then
		for _, desc in ipairs(map:GetDescendants()) do
			if desc:IsA("BasePart") and desc:GetAttribute("SectionComplete") then
				desc.Touched:Connect(function(hit)
					local player = Players:GetPlayerFromCharacter(hit.Parent)
					if not player then
						return
					end
					local key = tostring(player.UserId) .. desc:GetDebugId()
					if sectionTouched[key] and os.clock() - sectionTouched[key] < 5 then
						return
					end
					sectionTouched[key] = os.clock()
					currencyService.AddCoins(player, Config.SectionCompleteCoins)
					local worldId = (desc:GetAttribute("WorldId") or 1) :: number
					local unlock = math.max((player:GetAttribute(Constants.ATTR_WORLD_UNLOCK) or 1) :: number, worldId + 1)
					player:SetAttribute(Constants.ATTR_WORLD_UNLOCK, math.min(unlock, #Config.Worlds))
					effectsService.Feedback(player, "WORLD CLEARED! RETURN TO LOBBY")
					player:SetAttribute(Constants.ATTR_WORLD, 0)
					sizeService.ApplyScaling(player)
					teleport(player, Vector3.new(0, 6, 0))
				end)
			end
		end
	end
end

return WorldService
