--!strict

local Config = {
	Origin = CFrame.new(0, 5, 0),
	BaseWalkSpeed = 16,
	MaxWalkSpeed = 40,
	GrowthPerStud = 0.16,
	CoinPerStud = 0.45,
	FeedbackPulseSeconds = 5,
	PassiveGrowthPulse = 0.8,
	FallRespawnY = -20,
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
