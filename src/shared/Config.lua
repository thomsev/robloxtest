--!strict

local Config = {
	GrowthPerMeter = 0.2,
	DistanceCoinsPerMeter = 0.55,
	SectionCompleteCoins = 180,
	TreadmillBoostMultiplier = 2,
	MaxSize = 260,
	BaseWalkSpeed = 16,
	MaxWalkSpeed = 52,
	ScaleApplyIntervalSeconds = 0.12,
	AutoSaveSeconds = 60,
	RebirthRequiredSize = 150,
	RebirthGrowthBonus = 0.26,
	RebirthGodModeSeconds = 8,
	RebirthSizeReset = 1,
	GiantStompCooldown = 14,
	GiantStompMinSize = 85,
	PassiveCoinPulseSeconds = 4,
	PassiveCoinPulseAmount = 5,
	AntiExploit = {
		MaxDistancePerTick = 30,
		TickRateSeconds = 0.25,
		MaxGrowthPerTick = 4,
	},
	SpeedDifficulty = {
		PerSize = 0.06,
		PerWorldLevel = 1.1,
		PerRebirth = 0.7,
		JumpPowerPenaltyPerWorld = 1.2,
	},
	SizeTiers = {
		{ Name = "Tiny", Min = 1, Color = Color3.fromRGB(173, 216, 255), FootstepVolume = 0.2, FOV = 70 },
		{ Name = "Normal", Min = 12, Color = Color3.fromRGB(194, 255, 182), FootstepVolume = 0.3, FOV = 72 },
		{ Name = "Big", Min = 35, Color = Color3.fromRGB(255, 235, 149), FootstepVolume = 0.45, FOV = 76 },
		{ Name = "Huge", Min = 70, Color = Color3.fromRGB(255, 178, 120), FootstepVolume = 0.65, FOV = 82 },
		{ Name = "MASSIVE", Min = 110, Color = Color3.fromRGB(255, 111, 111), FootstepVolume = 0.85, FOV = 88 },
	},
	Upgrades = {
		RunSpeed = { BaseCost = 60, CostGrowth = 1.45, MaxLevel = 18, PerLevel = 1.2 },
		GrowthRate = { BaseCost = 75, CostGrowth = 1.55, MaxLevel = 18, PerLevel = 0.08 },
		SmashMultiplier = { BaseCost = 90, CostGrowth = 1.6, MaxLevel = 15, PerLevel = 0.12 },
		JumpAssist = { BaseCost = 40, CostGrowth = 1.4, MaxLevel = 8, PerLevel = 2.5 },
		KnockbackResist = { BaseCost = 50, CostGrowth = 1.45, MaxLevel = 8, PerLevel = 0.08 },
		TrailFx = { BaseCost = 25, CostGrowth = 1.5, MaxLevel = 6, PerLevel = 1 },
	},
	Worlds = {
		{ Id = 1, Name = "CITY START", ThemeColor = Color3.fromRGB(255, 210, 70), PortalRequirement = 1, RequiredRebirth = 0, Spawn = Vector3.new(120, 10, 0), Levels = 4, LevelHeight = 26 },
		{ Id = 2, Name = "TOY FACTORY", ThemeColor = Color3.fromRGB(115, 224, 255), PortalRequirement = 75, RequiredRebirth = 1, Spawn = Vector3.new(420, 10, 0), Levels = 5, LevelHeight = 32 },
		{ Id = 3, Name = "SKY KITCHEN", ThemeColor = Color3.fromRGB(255, 170, 200), PortalRequirement = 130, RequiredRebirth = 2, Spawn = Vector3.new(760, 10, 0), Levels = 6, LevelHeight = 36 },
	},
	Smashables = {
		Crate = { RequiredSize = 20, RewardSize = 1.8, RewardCoins = 18, RewardTokens = 1, RespawnSeconds = 10 },
		Wall = { RequiredSize = 55, RewardSize = 3.8, RewardCoins = 40, RewardTokens = 2, RespawnSeconds = 14 },
		Brick = { RequiredSize = 10, RewardSize = 0.9, RewardCoins = 10, RewardTokens = 1, RespawnSeconds = 8 },
		NPC = { RequiredSize = 25, RewardSize = 1.4, RewardCoins = 22, RewardTokens = 3, RespawnSeconds = 6 },
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
