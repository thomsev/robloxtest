--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(script.Parent.BuilderUtil)

local BuildFinale = {}

-- WHY: provide a memorable finish with higher stakes and clear celebration payoff.
function BuildFinale.Build(root: Instance, startCF: CFrame)
	for i = 0, 5 do
		local cf = startCF * CFrame.new(0, i * 5, i * 12)
		Util.makePart(root, "FinalBeam_" .. i, Vector3.new(7, 2, 10), cf, Color3.fromRGB(150, 220, 120))
	end
	Util.makeCheckpoint(root, 4, startCF * CFrame.new(0, 28, 72))

	local finish = Util.makePart(root, "FinishPlatform", Vector3.new(34, 2, 34), startCF * CFrame.new(0, 34, 92), Color3.fromRGB(120, 255, 150))
	finish.Material = Enum.Material.Neon
	local pad = Util.makePart(root, "SummitPad", Vector3.new(14, 1, 14), finish.CFrame * CFrame.new(0, 1.6, 0), Color3.fromRGB(255, 235, 59))
	CollectionService:AddTag(pad, Constants.TAG_SUMMIT)
	Util.makeSign(root, "FINISH! Claim reward burst", finish.CFrame * CFrame.new(0, 5, 0))
	return startCF * CFrame.new(0, 34, 110)
end

return BuildFinale
