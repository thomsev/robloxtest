--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(script.Parent.SectionUtil)

local Section6 = {}

function Section6.Build(ctx, model)
	local y = ctx.startY
	local summit = Util.placeRingStep(ctx.center, ctx.radius - 2, ctx.startAngle + 18, y + 8)
	Util.makePart(model, "SummitPlatform", Vector3.new(30, 2, 30), CFrame.new(summit), Color3.fromRGB(120, 255, 150))
	local pad = Util.makePart(model, "SummitPad", Vector3.new(12, 1, 12), CFrame.new(summit + Vector3.new(0, 1.6, 0)), Color3.fromRGB(255, 235, 59))
	CollectionService:AddTag(pad, Constants.TAG_SUMMIT)
	Util.makeSign(model, "SUMMIT! Claim Growth Burst", summit + Vector3.new(0, 2, 0))
	return { EndAngle = ctx.startAngle + 40, EndY = y + 10, Checkpoint = summit + Vector3.new(0, 3, 0) }
end

return Section6
