--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Util = require(Shared.Util)

local TreadmillService = {}

local onTreadmill: { [Player]: number } = {}

local function trackPart(part: BasePart)
	part.Touched:Connect(function(hit)
		local character = hit.Parent
		if not character or not character:IsA("Model") then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end
		onTreadmill[player] = (onTreadmill[player] or 0) + 1
	end)

	part.TouchEnded:Connect(function(hit)
		local character = hit.Parent
		if not character or not character:IsA("Model") then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end
		onTreadmill[player] = math.max((onTreadmill[player] or 1) - 1, 0)
	end)
end

function TreadmillService.GetMultiplier(player: Player): number
	if (onTreadmill[player] or 0) <= 0 then
		return 1
	end

	local character = Util.getCharacter(player)
	local root = Util.getRootPart(character)
	if not root then
		return 1
	end

	for _, part in ipairs(CollectionService:GetTagged("Treadmill")) do
		if part:IsA("BasePart") then
			local localPos = part.CFrame:PointToObjectSpace(root.Position)
			local insideBounds = math.abs(localPos.X) <= (part.Size.X / 2)
				and math.abs(localPos.Y) <= (part.Size.Y / 2) + 3
				and math.abs(localPos.Z) <= (part.Size.Z / 2)
			if not insideBounds then
				continue
			end

			local boost = part:GetAttribute("BoostMultiplier")
			if type(boost) == "number" then
				return boost
			end
		end
	end

	return Config.TreadmillBoostMultiplier
end

function TreadmillService.Init()
	for _, instance in ipairs(CollectionService:GetTagged("Treadmill")) do
		if instance:IsA("BasePart") then
			trackPart(instance)
		end
	end

	CollectionService:GetInstanceAddedSignal("Treadmill"):Connect(function(instance)
		if instance:IsA("BasePart") then
			trackPart(instance)
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		onTreadmill[player] = nil
	end)
end

return TreadmillService
