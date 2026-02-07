--!strict

local Util = require(script.Parent.SectionUtil)

local Section2 = {}

function Section2.Build(ctx, model)
	local y = ctx.startY
	for i = 0, 6 do
		local pos = Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + i * 14, y + i * 2)
		local part = Util.makePart(model, "S2_Path_" .. i, Vector3.new(14, 2, 12), CFrame.new(pos), Color3.fromRGB(110, 225, 255))
		if i == 3 then
			part.CFrame = part.CFrame * CFrame.Angles(0, 0, math.rad(8))
		end
	end
	Util.makeSign(model, "Speed is rising: short taps", Util.placeRingStep(ctx.center, ctx.radius + 5, ctx.startAngle + 34, y + 7))
	return { EndAngle = ctx.startAngle + 98, EndY = y + 14, Checkpoint = Util.placeRingStep(ctx.center, ctx.radius, ctx.startAngle + 100, y + 16) }
end

return Section2
