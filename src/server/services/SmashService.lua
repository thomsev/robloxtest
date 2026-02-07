--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Remotes = require(Shared.Remotes)
local Util = require(Shared.Util)

local SmashService = {}

local smashCooldown: { [BasePart]: number } = {}
local stompCooldown: { [Player]: number } = {}

local stompEvent = Remotes.getStompRequestEvent()

local function breakFx(part: BasePart)
	local burst = Instance.new("ParticleEmitter")
	burst.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	burst.Speed = NumberRange.new(12, 20)
	burst.Lifetime = NumberRange.new(0.25, 0.5)
	burst.Rate = 0
	burst.Parent = part
	burst:Emit(45)
	Debris:AddItem(burst, 1)
end

local function respawn(part: BasePart, originalCF: CFrame, respawnSeconds: number)
	part.CanCollide = false
	part.Transparency = 1
	task.delay(respawnSeconds, function()
		if part.Parent then
			part.CFrame = originalCF
			part.Transparency = 0
			part.CanCollide = true
		end
	end)
end

local function handleSmash(part: BasePart, player: Player, sizeService, currencyService, upgradeService, effectsService)
	if smashCooldown[part] and os.clock() - smashCooldown[part] < 0.4 then
		return
	end
	smashCooldown[part] = os.clock()

	local kind = (part:GetAttribute("SmashKind") or "Brick") :: string
	local cfg = Config.Smashables[kind]
	if not cfg then
		return
	end

	local size = sizeService.GetSize(player)
	if size < cfg.RequiredSize then
		effectsService.Feedback(player, "TOO SMALL!")
		return
	end

	local mult = upgradeService.SmashMultiplier(player)
	sizeService.AddSize(player, cfg.RewardSize * mult, effectsService, upgradeService)
	currencyService.AddCoins(player, math.floor(cfg.RewardCoins * mult))
	effectsService.Emit(player, "Smash", { Kind = kind, Reward = cfg.RewardCoins })
	effectsService.Feedback(player, "SMASHED!")

	local originalCF = part.CFrame
	breakFx(part)
	respawn(part, originalCF, cfg.RespawnSeconds)
end

local function ragdoll(character: Model)
	local hum = Util.getHumanoid(character)
	if not hum then
		return
	end
	hum.PlatformStand = true
	task.delay(1.1, function()
		if hum and hum.Parent then
			hum.PlatformStand = false
		end
	end)
end

local function launchObstacle(part: BasePart)
	part.Anchored = false
	part:ApplyImpulse(Vector3.new(math.random(-50, 50), 180, math.random(90, 180)) * part.AssemblyMass)
	task.delay(2.5, function()
		if part and part.Parent then
			part.Anchored = true
		end
	end)
end

function SmashService.Init(sizeService, currencyService, upgradeService, effectsService)
	local function wireSmashable(instance)
		if not instance:IsA("BasePart") then
			return
		end
		instance.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				handleSmash(instance, player, sizeService, currencyService, upgradeService, effectsService)
			end
		end)
	end

	for _, instance in ipairs(CollectionService:GetTagged(Constants.TAG_SMASHABLE)) do
		wireSmashable(instance)
	end
	CollectionService:GetInstanceAddedSignal(Constants.TAG_SMASHABLE):Connect(wireSmashable)

	local function wireObstacle(instance)
		if not instance:IsA("BasePart") then
			return
		end
		instance.Touched:Connect(function(hit)
			local character = hit.Parent
			if not character then
				return
			end
			local player = Players:GetPlayerFromCharacter(character)
			if not player then
				return
			end
			if sizeService.GetSize(player) < 30 then
				ragdoll(character)
				effectsService.Emit(player, "Ragdoll", {})
			else
				launchObstacle(instance)
				effectsService.Emit(player, "Impact", {})
			end
		end)
	end

	for _, instance in ipairs(CollectionService:GetTagged(Constants.TAG_OBSTACLE)) do
		wireObstacle(instance)
	end
	CollectionService:GetInstanceAddedSignal(Constants.TAG_OBSTACLE):Connect(wireObstacle)

	stompEvent.OnServerEvent:Connect(function(player)
		local now = os.clock()
		if stompCooldown[player] and now < stompCooldown[player] then
			return
		end
		if sizeService.GetSize(player) < Config.GiantStompMinSize then
			return
		end
		stompCooldown[player] = now + Config.GiantStompCooldown
		effectsService.Emit(player, "Stomp", { Cooldown = Config.GiantStompCooldown })

		local root = Util.getRootPart(Util.getCharacter(player))
		if not root then
			return
		end
		for _, obstacle in ipairs(CollectionService:GetTagged(Constants.TAG_OBSTACLE)) do
			if obstacle:IsA("BasePart") and (obstacle.Position - root.Position).Magnitude < 24 then
				launchObstacle(obstacle)
			end
		end
	end)
end

return SmashService
