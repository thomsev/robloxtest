--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(script.Parent.SectionUtil)

local Section4 = {}

function Section4.Build(ctx, model)
	local y = ctx.startY
	for i = 0, 5 do
		local pos = Util.placeRingStep(ctx.center, ctx.radius - 2, ctx.startAngle + i * 15, y + i * 2)
		local ramp = Util.makePart(model, "S4_Ramp_" .. i, Vector3.new(10, 2, 11), CFrame.new(pos) * CFrame.Angles(math.rad(18), 0, 0), Color3.fromRGB(255, 120, 110))
		ramp.Orientation = Vector3.new(18, ramp.Orientation.Y, 0)
	end
	for i = 1, 3 do
		local p = Util.placeRingStep(ctx.center, ctx.radius - 1, ctx.startAngle + i * 24, y + i * 4)
		local bot = Util.makePart(model, "BullyBot_" .. i, Vector3.new(3, 5, 3), CFrame.new(p), Color3.fromRGB(230, 55, 55))
		bot:SetAttribute("PatrolA", p + Vector3.new(-5, 0, 0))
		bot:SetAttribute("PatrolB", p + Vector3.new(5, 0, 0))
		CollectionService:AddTag(bot, Constants.TAG_NPC)
	end
	Util.makeSign(model, "Small gets shoved. Big can SMASH", Util.placeRingStep(ctx.center, ctx.radius + 8, ctx.startAngle + 42, y + 9))
	return { EndAngle = ctx.startAngle + 96, EndY = y + 14, Checkpoint = Util.placeRingStep(ctx.center, ctx.radius - 2, ctx.startAngle + 100, y + 15) }
end

return Section4
