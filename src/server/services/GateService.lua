--!strict

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)

local GateService = {}

local touchCooldown: { [string]: number } = {}

local function gateKey(player: Player, gate: Instance): string
	return tostring(player.UserId) .. ":" .. gate:GetDebugId()
end

local function handleGateTouched(gate: BasePart, hit: BasePart, sizeService, effectsService)
	local character = hit.Parent
	if not character or not character:IsA("Model") then
		return
	end
	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end

	local key = gateKey(player, gate)
	if touchCooldown[key] and os.clock() - touchCooldown[key] < 0.8 then
		return
	end
	touchCooldown[key] = os.clock()

	local requiredSize = (gate:GetAttribute("RequiredSize") or 1) :: number
	if sizeService.GetSize(player) < requiredSize then
		local returnPart = gate.Parent and gate.Parent:FindFirstChild("GateReturn")
		if returnPart and returnPart:IsA("BasePart") and character.PrimaryPart then
			character:PivotTo(returnPart.CFrame + Vector3.new(0, 4, 0))
		end
		effectsService.Feedback(player, string.format("TOO SMALL! Need %.0f", requiredSize))
		effectsService.Emit(player, "TooSmall", { Required = requiredSize })
		return
	end

	player:SetAttribute(Constants.ATTR_CHECKPOINT, gate:GetFullName())
end

function GateService.Init(sizeService, effectsService)
	local function wire(gate)
		if gate:IsA("BasePart") then
			gate.Touched:Connect(function(hit)
				handleGateTouched(gate, hit, sizeService, effectsService)
			end)
		end
	end
	for _, instance in ipairs(CollectionService:GetTagged(Constants.TAG_SIZE_GATE)) do
		wire(instance)
	end
	CollectionService:GetInstanceAddedSignal(Constants.TAG_SIZE_GATE):Connect(wire)
end

return GateService
