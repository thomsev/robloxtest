--!strict

local Util = require(script.Parent.SectionUtil)

local Section1 = {}

function Section1.Build(ctx, model)
	local y = ctx.startY
	for i = 0, 5 do
		local pos = Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + i * 16, y + i * 2)
		Util.makePart(model, "S1_Platform_" .. i, Vector3.new(22, 2, 16), CFrame.new(pos), Color3.fromRGB(255, 223, 72))
	end
	Util.makeSign(model, "Run + Jump to grow", Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + 8, y + 4))
	Util.makeSign(model, "Checkpoint ahead", Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + 48, y + 12))
	return { EndAngle = ctx.startAngle + 96, EndY = y + 12, Checkpoint = Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + 96, y + 14) }
end

return Section1
