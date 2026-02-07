--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)
local Remotes = require(Shared.Remotes)

local GateService = {}

local touchCooldown: { [string]: number } = {}
local feedbackEvent = Remotes.getFeedbackEvent()

local function gateKey(player: Player, gate: Instance): string
	return tostring(player.UserId) .. ":" .. gate:GetDebugId()
end

local function handleGateTouched(gate: BasePart, hit: BasePart, sizeService)
	local character = hit.Parent
	if not character or not character:IsA("Model") then
		return
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local cooldownKey = gateKey(player, gate)
	local now = os.clock()
	if touchCooldown[cooldownKey] and now - touchCooldown[cooldownKey] < 0.8 then
		return
	end
	touchCooldown[cooldownKey] = now

	local requiredSize = (gate:GetAttribute("RequiredSize") or 1) :: number
	local playerSize = sizeService.GetSize(player)
	if playerSize < requiredSize then
		local returnPart = gate.Parent and gate.Parent:FindFirstChild("GateReturn")
		if returnPart and returnPart:IsA("BasePart") and character.PrimaryPart then
			character:PivotTo(returnPart.CFrame + Vector3.new(0, 4, 0))
		end
		feedbackEvent:FireClient(player, string.format("Too small! Need size %.0f.", requiredSize))
		return
	end

	player:SetAttribute(Constants.ATTR_CHECKPOINT, gate.Name)
end

local function wireGate(gate: BasePart, sizeService)
	gate.Touched:Connect(function(hit)
		handleGateTouched(gate, hit, sizeService)
	end)
end

function GateService.Init(sizeService)
	for _, instance in ipairs(CollectionService:GetTagged("SizeGate")) do
		if instance:IsA("BasePart") then
			wireGate(instance, sizeService)
		end
	end

	CollectionService:GetInstanceAddedSignal("SizeGate"):Connect(function(instance)
		if instance:IsA("BasePart") then
			wireGate(instance, sizeService)
		end
	end)
end

return GateService
