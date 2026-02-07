--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Remotes = require(Shared.Remotes)
local Util = require(Shared.Util)

local SmashService = {}

local smashCooldown: { [BasePart]: number } = {}
local stompCooldown: { [Player]: number } = {}
local playerBumpCooldown: { [string]: number } = {}

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

local function applyKnockback(targetRoot: BasePart, sourceRoot: BasePart, force: number)
	local dir = (targetRoot.Position - sourceRoot.Position)
	if dir.Magnitude < 0.1 then
		dir = Vector3.new(0, 0, 1)
	end
	targetRoot:ApplyImpulse((dir.Unit + Vector3.new(0, 0.35, 0)) * force * targetRoot.AssemblyMass)
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
	currencyService.AddTokens(player, cfg.RewardTokens)
	effectsService.Emit(player, "Smash", { Kind = kind, Reward = cfg.RewardCoins })
	effectsService.Feedback(player, "+SMASH TOKENS")

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

local function wireNPC(npcRoot: BasePart, sizeService, currencyService, upgradeService, effectsService)
	npcRoot.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		local playerRoot = Util.getRootPart(hit.Parent)
		if not playerRoot then
			return
		end
		local playerSize = sizeService.GetSize(player)
		if playerSize >= Config.Smashables.NPC.RequiredSize then
			handleSmash(npcRoot, player, sizeService, currencyService, upgradeService, effectsService)
			applyKnockback(npcRoot, playerRoot, 35)
		else
			local resist = 1 - math.clamp(upgradeService.KnockbackResistance(player), 0, 0.65)
			applyKnockback(playerRoot, npcRoot, ((npcRoot:GetAttribute("Force") or 80) :: number) * resist)
			effectsService.Feedback(player, "NPC SHOVED YOU")
		end
	end)

	task.spawn(function()
		while npcRoot.Parent do
			local a = (npcRoot:GetAttribute("PatrolA") or (npcRoot.Position.X - 6)) :: number
			local b = (npcRoot:GetAttribute("PatrolB") or (npcRoot.Position.X + 6)) :: number
			local target = Vector3.new(a, npcRoot.Position.Y, npcRoot.Position.Z)
			for i = 1, 30 do
				npcRoot.CFrame = npcRoot.CFrame:Lerp(CFrame.new(target), 0.08)
				task.wait(0.05)
			end
			target = Vector3.new(b, npcRoot.Position.Y, npcRoot.Position.Z)
			for i = 1, 30 do
				npcRoot.CFrame = npcRoot.CFrame:Lerp(CFrame.new(target), 0.08)
				task.wait(0.05)
			end
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

	for _, instance in ipairs(CollectionService:GetTagged(Constants.TAG_NPC)) do
		if instance:IsA("BasePart") then
			wireNPC(instance, sizeService, currencyService, upgradeService, effectsService)
		end
	end
	CollectionService:GetInstanceAddedSignal(Constants.TAG_NPC):Connect(function(instance)
		if instance:IsA("BasePart") then
			wireNPC(instance, sizeService, currencyService, upgradeService, effectsService)
		end
	end)

	for _, zone in ipairs(CollectionService:GetTagged(Constants.TAG_COLLISION_ZONE)) do
		if zone:IsA("BasePart") then
			zone.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then
					return
				end
				local root = Util.getRootPart(hit.Parent)
				if not root then
					return
				end
				for _, other in ipairs(Players:GetPlayers()) do
					if other ~= player then
						local otherRoot = Util.getRootPart(Util.getCharacter(other))
						if otherRoot and (otherRoot.Position - root.Position).Magnitude < 8 then
							local key = tostring(math.min(player.UserId, other.UserId)) .. ":" .. tostring(math.max(player.UserId, other.UserId))
							if playerBumpCooldown[key] and os.clock() - playerBumpCooldown[key] < 2 then
								continue
							end
							playerBumpCooldown[key] = os.clock()
							local diff = sizeService.GetSize(player) - sizeService.GetSize(other)
							if math.abs(diff) > 5 then
								if diff > 0 then
									applyKnockback(otherRoot, root, ((zone:GetAttribute("Knockback") or 45) :: number))
								else
									applyKnockback(root, otherRoot, ((zone:GetAttribute("Knockback") or 45) :: number))
								end
							end
						end
					end
				end
			end)
		end
	end

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

RunService.Stepped:Connect(function()
	for key, time in pairs(playerBumpCooldown) do
		if os.clock() - time > 10 then
			playerBumpCooldown[key] = nil
		end
	end
end)

return SmashService
