--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local SmashService = {}
local cooldown: { [string]: number } = {}

local function key(a: number, b: string): string
	return tostring(a) .. ":" .. b
end

local function burst(part: BasePart)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Lifetime = NumberRange.new(0.3, 0.5)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(15, 20)
	emitter.Parent = part
	emitter:Emit(30)
	Debris:AddItem(emitter, 1)
end

function SmashService.Init(growthService, effectsService)
	for _, npc in ipairs(CollectionService:GetTagged(Constants.TAG_NPC)) do
		if npc:IsA("BasePart") then
			npc.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if not player then
					return
				end
				local k = key(player.UserId, npc:GetDebugId())
				if cooldown[k] and os.clock() - cooldown[k] < 1.2 then
					return
				end
				cooldown[k] = os.clock()
				local root = Util.getRootPart(Util.getCharacter(player))
				if not root then
					return
				end
				local size = growthService.GetSize(player)
				if size >= Config.NPC.RequiredSizeToSmash then
					growthService.AddCoins(player, Config.NPC.RewardCoins)
					growthService.AddSize(player, Config.NPC.RewardSize)
					effectsService.Feedback(player, "SMASH! +bonus")
					effectsService.Emit(player, "Smash", {})
					burst(npc)
				else
					root:ApplyImpulse((root.Position - npc.Position).Unit * Config.NPC.ShoveForce * root.AssemblyMass + Vector3.new(0, 35, 0))
					effectsService.Feedback(player, "Bully Bot shoved you")
				end
			end)
		end
	end

	for _, risk in ipairs(CollectionService:GetTagged(Constants.TAG_RISK_LANE)) do
		if risk:IsA("BasePart") then
			risk.Touched:Connect(function(hit)
				local player = Players:GetPlayerFromCharacter(hit.Parent)
				if player then
					growthService.AddCoins(player, (risk:GetAttribute("BonusCoins") or 10) :: number)
					growthService.AddSize(player, 0.5)
					effectsService.Feedback(player, "Risk lane bonus!")
				end
			end)
		end
	end
end

return SmashService
