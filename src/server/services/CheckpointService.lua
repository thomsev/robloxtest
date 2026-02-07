--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local CheckpointService = {}
local checkpoints: { [number]: BasePart } = {}

function CheckpointService.Init(effectsService, growthService)
	for _, cp in ipairs(CollectionService:GetTagged(Constants.TAG_CHECKPOINT)) do
		if cp:IsA("BasePart") then
			checkpoints[(cp:GetAttribute("Index") or 0) :: number] = cp
			cp.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then
					return
				end
				local idx = (cp:GetAttribute("Index") or 1) :: number
				if idx > ((player:GetAttribute(Constants.ATTR_CHECKPOINT) or 0) :: number) then
					player:SetAttribute(Constants.ATTR_CHECKPOINT, idx)
					player:SetAttribute(Constants.ATTR_SECTION, idx + 1)
					effectsService.Feedback(player, "Checkpoint " .. idx .. " reached!")
				end
			end)
		end
	end

	task.spawn(function()
		while true do
			for _, player in ipairs(Players:GetPlayers()) do
				local root = Util.getRootPart(Util.getCharacter(player))
				if root and root.Position.Y < Config.FallRespawnY then
					local idx = (player:GetAttribute(Constants.ATTR_CHECKPOINT) or 0) :: number
					local cp = checkpoints[idx]
					local target = if cp then cp.Position + Vector3.new(0, 5, 0) else Config.Origin.Position + Vector3.new(0, 5, 0)
					local char = Util.getCharacter(player)
					if char and char.PrimaryPart then
						char:PivotTo(CFrame.new(target))
					end
					local vxz = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z).Magnitude
					local msg = if vxz > 22 then "Too fast! feather your movement" else "Jump earlier!"
					player:SetAttribute(Constants.ATTR_LAST_HINT, msg)
					effectsService.Feedback(player, msg)
				end
			end
			task.wait(0.3)
		end
	end)

	local summitTouched: { [number]: number } = {}
	local summit = CollectionService:GetTagged(Constants.TAG_SUMMIT)
	for _, pad in ipairs(summit) do
		if pad:IsA("BasePart") then
			pad.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then
					return
				end
				if summitTouched[player.UserId] and os.clock() - summitTouched[player.UserId] < 6 then
					return
				end
				summitTouched[player.UserId] = os.clock()
				growthService.AddCoins(player, Config.SummitReward.Coins)
				growthService.AddSize(player, Config.SummitReward.Size)
				effectsService.Feedback(player, "SUMMIT! Huge reward claimed")
				player:SetAttribute(Constants.ATTR_LAST_HINT, "Re-run for a faster clear")
			end)
		end
	end
end

return CheckpointService
