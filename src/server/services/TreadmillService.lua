--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local TreadmillService = {}
local onTreadmill: { [Player]: number } = {}

local function trackPart(part: BasePart)
	part.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			onTreadmill[player] = (onTreadmill[player] or 0) + 1
		end
	end)
	part.TouchEnded:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			onTreadmill[player] = math.max((onTreadmill[player] or 1) - 1, 0)
		end
	end)
end

function TreadmillService.GetMultiplier(player: Player): number
	if (onTreadmill[player] or 0) <= 0 then
		return 1
	end
	local root = Util.getRootPart(Util.getCharacter(player))
	if not root then
		return 1
	end
	for _, part in ipairs(CollectionService:GetTagged(Constants.TAG_TREADMILL)) do
		if part:IsA("BasePart") then
			local localPos = part.CFrame:PointToObjectSpace(root.Position)
			if math.abs(localPos.X) <= (part.Size.X / 2) and math.abs(localPos.Z) <= (part.Size.Z / 2) then
				return ((part:GetAttribute("BoostMultiplier") or Config.TreadmillBoostMultiplier) :: number)
			end
		end
	end
	return 1
end

function TreadmillService.Init()
	for _, part in ipairs(CollectionService:GetTagged(Constants.TAG_TREADMILL)) do
		if part:IsA("BasePart") then
			trackPart(part)
		end
	end
	CollectionService:GetInstanceAddedSignal(Constants.TAG_TREADMILL):Connect(function(part)
		if part:IsA("BasePart") then
			trackPart(part)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		onTreadmill[player] = nil
	end)
end

return TreadmillService
