--!strict

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local WorldBuilder = require(script.Parent.WorldBuilder)

local MapBootstrapService = {}

function MapBootstrapService.Init()
	local oldGenerated = Workspace:FindFirstChild("GeneratedMap")
	if oldGenerated then
		oldGenerated:Destroy()
	end
	local oldTower = Workspace:FindFirstChild("GrowthTower")
	if oldTower then
		oldTower:Destroy()
	end

	local generated = Instance.new("Model")
	generated.Name = "GeneratedMap"
	generated.Parent = Workspace

	-- Build from one explicit origin so layout stays deterministic and readable.
	WorldBuilder.Build(generated, Config.Origin)
end

return MapBootstrapService
