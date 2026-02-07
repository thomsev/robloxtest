--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)

local NPCService = {}

function NPCService.Init()
	for _, npc in ipairs(CollectionService:GetTagged(Constants.TAG_NPC)) do
		if npc:IsA("BasePart") then
			task.spawn(function()
				while npc.Parent do
					local a = npc:GetAttribute("PatrolA")
					local b = npc:GetAttribute("PatrolB")
					if typeof(a) == "Vector3" and typeof(b) == "Vector3" then
						for _, target in ipairs({ a, b }) do
							for _ = 1, 20 do
								npc.CFrame = npc.CFrame:Lerp(CFrame.new(target), 0.1)
								task.wait(0.05)
							end
						end
					else
						task.wait(0.2)
					end
				end
			end)
		end
	end
end

return NPCService
