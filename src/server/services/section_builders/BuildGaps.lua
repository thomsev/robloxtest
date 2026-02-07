--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(script.Parent.BuilderUtil)

local BuildGaps = {}

-- WHY: introduce readable jump timing with a safe lane and optional risk-reward lane.
function BuildGaps.Build(root: Instance, startCF: CFrame)
	for i = 0, 4 do
		local z = i * 20
		Util.makePart(root, "GapSafe_" .. i, Vector3.new(16, 2, 12), startCF * CFrame.new(-8, 0, z), Color3.fromRGB(255, 170, 220))
		Util.makePart(root, "SafeRailL_" .. i, Vector3.new(1, 3, 12), startCF * CFrame.new(-16, 2, z), Color3.fromRGB(230, 230, 230))
		Util.makePart(root, "SafeRailR_" .. i, Vector3.new(1, 3, 12), startCF * CFrame.new(0, 2, z), Color3.fromRGB(230, 230, 230))
		if i > 0 then
			local risk = Util.makePart(root, "GapRisk_" .. i, Vector3.new(9, 2, 10), startCF * CFrame.new(12, 1, z + 4), Color3.fromRGB(255, 95, 175))
			risk:SetAttribute("BonusCoins", 14)
			CollectionService:AddTag(risk, Constants.TAG_RISK_LANE)
		end
	end
	Util.makeSign(root, "Safe lane left / Risk bonus right", startCF * CFrame.new(0, 6, 18))
	Util.makeCheckpoint(root, 2, startCF * CFrame.new(-8, 1.6, 88))
	return startCF * CFrame.new(0, 3, 104)
end

return BuildGaps
