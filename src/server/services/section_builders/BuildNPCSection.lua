--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(script.Parent.BuilderUtil)

local BuildNPCSection = {}

-- WHY: add interaction pressure with Bully Bots using clear shove/smash rules.
function BuildNPCSection.Build(root: Instance, startCF: CFrame)
	for i = 0, 4 do
		local cf = startCF * CFrame.new(0, i * 2, i * 18)
		Util.makePart(root, "NPCPath_" .. i, Vector3.new(10, 2, 14), cf, Color3.fromRGB(255, 120, 110))
		if i > 0 then
			local bot = Util.makePart(root, "BullyBot_" .. i, Vector3.new(3, 5, 3), cf * CFrame.new(0, 4, 0), Color3.fromRGB(220, 55, 55))
			bot:SetAttribute("PatrolA", bot.Position + Vector3.new(-4, 0, 0))
			bot:SetAttribute("PatrolB", bot.Position + Vector3.new(4, 0, 0))
			CollectionService:AddTag(bot, Constants.TAG_NPC)
		end
	end
	Util.makeSign(root, "Bully Bots: dodge or SMASH when big", startCF * CFrame.new(0, 8, 24))
	return startCF * CFrame.new(0, 10, 94)
end

return BuildNPCSection
