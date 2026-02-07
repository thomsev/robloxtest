--!strict

-- Deprecated: section tuning now lives directly in section_builder modules.
local SectionConfig = {}

function SectionConfig.Get(_index: number)
	return nil
end

function SectionConfig.Count(): number
	return 0
end

return SectionConfig
