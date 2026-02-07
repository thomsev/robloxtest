--!strict

local Util = require(script.Parent.SectionUtil)

local Section5 = {}

function Section5.Build(ctx, model)
	local y = ctx.startY
	for i = 0, 7 do
		local pos = Util.placeRingStep(ctx.center, ctx.radius - 5, ctx.startAngle + i * 12, y + i * 2.5)
		local beam = Util.makePart(model, "S5_Beam_" .. i, Vector3.new(8, 2, 8), CFrame.new(pos) * CFrame.Angles(math.rad(24), 0, 0), Color3.fromRGB(255, 244, 145))
		beam.Orientation = Vector3.new(24, beam.Orientation.Y, 0)
	end
	Util.makeSign(model, "Mastery climb: jump earlier", Util.placeRingStep(ctx.center, ctx.radius + 6, ctx.startAngle + 36, y + 12))
	return { EndAngle = ctx.startAngle + 98, EndY = y + 20, Checkpoint = Util.placeRingStep(ctx.center, ctx.radius - 5, ctx.startAngle + 100, y + 21) }
end

return Section5
