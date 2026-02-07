--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Shared.Config)

local SectionConfig = {}

function SectionConfig.Get(index: number)
	return Config.Sections[index]
end

function SectionConfig.Count(): number
	return #Config.Sections
end

return SectionConfig
