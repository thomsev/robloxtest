--!strict

local Config = {
	GrowthPerMeter = 0.18,
	DistanceCoinsPerMeter = 0.45,
	SectionCompleteCoins = 120,
	TreadmillBoostMultiplier = 1.8,
	MaxSize = 220,
	BaseWalkSpeed = 16,
	MaxWalkSpeed = 34,
	ScaleApplyIntervalSeconds = 0.12,
	AutoSaveSeconds = 60,
	RebirthRequiredSize = 140,
	RebirthGrowthBonus = 0.22,
	RebirthGodModeSeconds = 8,
	RebirthSizeReset = 1,
	GiantStompCooldown = 14,
	GiantStompMinSize = 85,
	AntiExploit = {
		MaxDistancePerTick = 24,
		TickRateSeconds = 0.25,
		MaxGrowthPerTick = 3.2,
	},
	SizeTiers = {
		{ Name = "Tiny", Min = 1, Color = Color3.fromRGB(173, 216, 255), FootstepVolume = 0.2, FOV = 70 },
		{ Name = "Normal", Min = 12, Color = Color3.fromRGB(194, 255, 182), FootstepVolume = 0.3, FOV = 72 },
		{ Name = "Big", Min = 35, Color = Color3.fromRGB(255, 235, 149), FootstepVolume = 0.45, FOV = 76 },
		{ Name = "Huge", Min = 70, Color = Color3.fromRGB(255, 178, 120), FootstepVolume = 0.65, FOV = 82 },
		{ Name = "MASSIVE", Min = 110, Color = Color3.fromRGB(255, 111, 111), FootstepVolume = 0.85, FOV = 88 },
	},
	Upgrades = {
		RunSpeed = { BaseCost = 60, CostGrowth = 1.45, MaxLevel = 15, PerLevel = 1.1 },
		GrowthRate = { BaseCost = 75, CostGrowth = 1.55, MaxLevel = 15, PerLevel = 0.08 },
		SmashMultiplier = { BaseCost = 90, CostGrowth = 1.6, MaxLevel = 12, PerLevel = 0.12 },
	},
	Worlds = {
		{
			Id = 1,
			Name = "LEGO CITY",
			ThemeColor = Color3.fromRGB(255, 210, 70),
			PortalRequirement = 1,
			Spawn = Vector3.new(0, 4, 0),
			Length = 360,
		},
		{
			Id = 2,
			Name = "TOY FACTORY",
			ThemeColor = Color3.fromRGB(115, 224, 255),
			PortalRequirement = 70,
			Spawn = Vector3.new(0, 4, 800),
			Length = 420,
		},
		{
			Id = 3,
			Name = "KITCHEN",
			ThemeColor = Color3.fromRGB(255, 170, 200),
			PortalRequirement = 120,
			Spawn = Vector3.new(0, 4, 1700),
			Length = 460,
		},
	},
	Smashables = {
		Crate = { RequiredSize = 20, RewardSize = 1.8, RewardCoins = 18, RespawnSeconds = 10 },
		Wall = { RequiredSize = 55, RewardSize = 3.8, RewardCoins = 40, RespawnSeconds = 14 },
		Brick = { RequiredSize = 10, RewardSize = 0.9, RewardCoins = 10, RespawnSeconds = 8 },
	},
	DailyReward = {
		CooldownSeconds = 20 * 60 * 60,
		Coins = 180,
		GrowthBoostSeconds = 180,
		GrowthMultiplier = 1.3,
	},
	Gamepasses = {
		GrowthPlus10 = 0,
		CosmeticTrail = 0,
	},
}

return Config
