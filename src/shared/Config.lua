--!strict

local Config = {
	GrowthPerMeter = 0.25,
	TreadmillBoostMultiplier = 2.0,
	MaxSize = 120,
	BaseWalkSpeed = 16,
	WalkSpeedBonusPerSize = 0.06,
	MaxWalkSpeed = 24,
	GateRequirements = { 10, 20, 35, 50, 70 },
	RebirthRequiredSize = 100,
	RebirthGrowthBonus = 0.25,
	AutoSaveSeconds = 60,
	ScaleApplyIntervalSeconds = 0.15,
	AntiExploit = {
		MaxDistancePerTick = 22,
		TickRateSeconds = 0.25,
		MaxGrowthPerTick = 2.5,
	},
}

return Config
