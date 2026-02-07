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

local function teleportToWorld(player: Player, worldId: number)
	local world = worldById(worldId)
	if not world then
		return
	end
	player:SetAttribute(Constants.ATTR_WORLD, worldId)
	local character = Util.getCharacter(player)
	if character and character.PrimaryPart then
		character:PivotTo(CFrame.new(world.Spawn))
	end
end

function WorldService.Init(sizeService, currencyService, effectsService)
	Players.PlayerAdded:Connect(function(player)
		if player:GetAttribute(Constants.ATTR_WORLD) == nil then
			player:SetAttribute(Constants.ATTR_WORLD, 1)
		end
		player.CharacterAdded:Connect(function()
			task.delay(0.2, function()
				teleportToWorld(player, (player:GetAttribute(Constants.ATTR_WORLD) or 1) :: number)
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
				local required = (portal:GetAttribute("RequiredSize") or 1) :: number
				if sizeService.GetSize(player) < required then
					effectsService.Feedback(player, string.format("TOO SMALL! Need %.0f", required))
					return
				end
				local targetWorldId = (portal:GetAttribute("WorldId") or 1) :: number
				teleportToWorld(player, targetWorldId)
				effectsService.Feedback(player, "WORLD UNLOCKED!")
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
					effectsService.Feedback(player, "SECTION CLEAR!")
				end)
			end
		end
	end
end

return WorldService
