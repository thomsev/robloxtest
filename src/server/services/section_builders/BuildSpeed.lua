--!strict

local Util = require(script.Parent.BuilderUtil)

local BuildSpeed = {}

-- WHY: make speed the main challenge via narrower downhill-aligned ramps.
function BuildSpeed.Build(root: Instance, startCF: CFrame)
	for i = 0, 5 do
		local cf = startCF * CFrame.new(0, -i * 1.5, i * 16)
		Util.makePart(root, "SpeedRamp_" .. i, Vector3.new(12, 2, 14), cf * CFrame.Angles(math.rad(10), 0, 0), Color3.fromRGB(255, 200, 95))
		if i % 2 == 0 then
			Util.makeArrow(root, cf * CFrame.new(0, 1.2, 2))
		end
	end
	Util.makeSign(root, "Too fast? short movement taps", startCF * CFrame.new(0, 6, 26))
	Util.makeCheckpoint(root, 3, startCF * CFrame.new(0, -6, 86))
	return startCF * CFrame.new(0, -8, 100)
end

return BuildSpeed
