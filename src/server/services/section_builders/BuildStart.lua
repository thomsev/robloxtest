--!strict

local Util = require(script.Parent.BuilderUtil)

local BuildStart = {}

-- WHY: create a safe, obvious starting space so players understand direction in <10s.
function BuildStart.Build(root: Instance, startCF: CFrame)
	Util.makePart(root, "StartPad", Vector3.new(36, 2, 40), startCF, Color3.fromRGB(255, 223, 72))
	Util.makeArrow(root, startCF * CFrame.new(0, 1.2, 12))
	Util.makeArrow(root, startCF * CFrame.new(0, 1.2, 22))
	Util.makeSign(root, "THE GROWTH RUN ->", startCF * CFrame.new(0, 4, 0))
	Util.makeCheckpoint(root, 1, startCF * CFrame.new(0, 1.6, 18))

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Neutral = true
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.CFrame = startCF * CFrame.new(0, 2, -10)
	spawn.Parent = root

	return startCF * CFrame.new(0, 0, 40)
end

return BuildStart
