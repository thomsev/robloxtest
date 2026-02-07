--!strict

local Config = {
	TowerCenter = Vector3.new(0, 0, 0),
	TowerRadius = 42,
	BaseHeight = 8,
	SectionHeightStep = 26,
	BaseWalkSpeed = 16,
	MaxWalkSpeed = 40,
	GrowthPerStud = 0.16,
	CoinPerStud = 0.45,
	FeedbackPulseSeconds = 5,
	PassiveGrowthPulse = 0.8,
	FallRespawnY = -10,
	Sections = {
		{ Name = "Onboarding", Challenge = "Learn run + jump", Width = 22, Gap = 4, SpeedMultiplier = 1, CheckpointAfter = true },
		{ Name = "Control", Challenge = "Speed control", Width = 14, Gap = 6, SpeedMultiplier = 1.12, CheckpointAfter = true },
		{ Name = "Jump Timing", Challenge = "Jump precision", Width = 11, Gap = 8, SpeedMultiplier = 1.2, CheckpointAfter = true },
		{ Name = "Interference", Challenge = "Bully Bot dodging", Width = 10, Gap = 7, SpeedMultiplier = 1.25, CheckpointAfter = true },
		{ Name = "Mastery", Challenge = "Narrow + steep", Width = 8, Gap = 9, SpeedMultiplier = 1.33, CheckpointAfter = true },
		{ Name = "Summit", Challenge = "Payoff", Width = 26, Gap = 0, SpeedMultiplier = 1.35, CheckpointAfter = false },
	},
	NPC = {
		RequiredSizeToSmash = 35,
		ShoveForce = 65,
		RewardCoins = 20,
		RewardSize = 1.4,
	},
	SummitReward = {
		Coins = 250,
		Size = 8,
	},
}

return Config
