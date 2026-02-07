--!strict

local Util = require(script.Parent.BuilderUtil)

local BuildOnboarding = {}

-- WHY: teach movement + growth with wide ramps and no failure traps.
function BuildOnboarding.Build(root: Instance, startCF: CFrame)
	for i = 0, 4 do
		local cf = startCF * CFrame.new(0, i * 2, i * 18)
		Util.makePart(root, "OnboardRamp_" .. i, Vector3.new(20, 2, 16), cf * CFrame.Angles(math.rad(-6), 0, 0), Color3.fromRGB(120, 220, 255))
	end
	Util.makeSign(root, "Run to grow. Jump to keep momentum.", startCF * CFrame.new(0, 8, 20))
	Util.makeArrow(root, startCF * CFrame.new(0, 2, 30))
	return startCF * CFrame.new(0, 10, 92)
end

return BuildOnboarding
