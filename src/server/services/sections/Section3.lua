--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)
local Util = require(script.Parent.SectionUtil)

local Section3 = {}

function Section3.Build(ctx, model)
	local y = ctx.startY
	for i = 0, 4 do
		local pos = Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + i * 18, y + i * 2)
		Util.makePart(model, "S3_Safe_" .. i, Vector3.new(11, 2, 9), CFrame.new(pos), Color3.fromRGB(255, 170, 220))
	end
	for i = 1, 4 do
		local bonus = Util.placeRingStep(ctx.center, ctx.radius + 9, ctx.startAngle + i * 18, y + i * 2 + 1)
		local risk = Util.makePart(model, "S3_Risk_" .. i, Vector3.new(7, 2, 8), CFrame.new(bonus), Color3.fromRGB(255, 80, 185))
		risk:SetAttribute("BonusCoins", 12)
		CollectionService:AddTag(risk, Constants.TAG_RISK_LANE)
	end
	Util.makeSign(model, "Risk lane: +Coins +Growth", Util.placeRingStep(ctx.center, ctx.radius + 10, ctx.startAngle + 30, y + 8))
	return { EndAngle = ctx.startAngle + 100, EndY = y + 12, Checkpoint = Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + 104, y + 14) }
end

return Section3
