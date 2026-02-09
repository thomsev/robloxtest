--!strict

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local MonsterService = {}

local MONSTER_FOLDER = "WorldMonsters"
local MONSTER_COUNT_PER_WORLD = 2
local UPDATE_INTERVAL = 0.45
local ACQUIRE_RANGE = 140
local ATTACK_RANGE = 5.5
local MONSTER_TOUCH_DAMAGE = 22

local monsters: { Model } = {}
local attackDebounce: { [number]: number } = {}

local function makeMonster(worldId: number, spawnPos: Vector3, index: number): Model
	local monster = Instance.new("Model")
	monster.Name = string.format("Chaser_%d_%d", worldId, index)
	monster:SetAttribute("WorldId", worldId)

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2.5, 2.5, 1.5)
	root.Color = Color3.fromRGB(170, 40, 40)
	root.Material = Enum.Material.Slate
	root.CFrame = CFrame.new(spawnPos + Vector3.new(0, 4, 0))
	root.Anchored = false
	root.CanCollide = true
	root.Parent = monster

	local torso = Instance.new("Part")
	torso.Name = "Torso"
	torso.Size = Vector3.new(3.5, 3.5, 2.2)
	torso.Color = Color3.fromRGB(230, 60, 60)
	torso.Material = Enum.Material.SmoothPlastic
	torso.CFrame = root.CFrame * CFrame.new(0, 1.9, 0)
	torso.Anchored = false
	torso.CanCollide = true
	torso.Parent = monster

	local weld = Instance.new("WeldConstraint")
	weld.Part0 = root
	weld.Part1 = torso
	weld.Parent = root

	local humanoid = Instance.new("Humanoid")
	humanoid.WalkSpeed = 15 + worldId
	humanoid.JumpPower = 46
	humanoid.AutoRotate = true
	humanoid.Parent = monster

	monster.PrimaryPart = root

	root.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		local targetHumanoid = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if not targetHumanoid or targetHumanoid.Health <= 0 then
			return
		end
		local now = os.clock()
		if attackDebounce[player.UserId] and now - attackDebounce[player.UserId] < 1 then
			return
		end
		attackDebounce[player.UserId] = now
		targetHumanoid:TakeDamage(MONSTER_TOUCH_DAMAGE)
	end)

	return monster
end

local function getNearestTarget(monster: Model): (Player?, Vector3?)
	local root = monster.PrimaryPart
	if not root then
		return nil, nil
	end
	local worldId = (monster:GetAttribute("WorldId") or 1) :: number
	local bestPlayer: Player? = nil
	local bestPos: Vector3? = nil
	local bestDistance = ACQUIRE_RANGE

	for _, player in ipairs(Players:GetPlayers()) do
		if (player:GetAttribute(Constants.ATTR_WORLD) or 1) == worldId then
			local character = Util.getCharacter(player)
			local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
			if targetRoot and targetRoot:IsA("BasePart") then
				local dist = (targetRoot.Position - root.Position).Magnitude
				if dist < bestDistance then
					bestDistance = dist
					bestPlayer = player
					bestPos = targetRoot.Position
				end
			end
		end
	end

	return bestPlayer, bestPos
end

function MonsterService.Init(effectsService)
	local map = Workspace:FindFirstChild("GeneratedMap")
	if not map then
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = MONSTER_FOLDER
	folder.Parent = map

	for _, world in ipairs(Config.Worlds) do
		for i = 1, MONSTER_COUNT_PER_WORLD do
			local xOffset = (i % 2 == 0) and -12 or 12
			local zOffset = 95 + i * 120
			local monster = makeMonster(world.Id, world.Spawn + Vector3.new(xOffset, 0, zOffset), i)
			monster.Parent = folder
			table.insert(monsters, monster)
		end
	end

	task.spawn(function()
		while true do
			for _, monster in ipairs(monsters) do
				local humanoid = monster:FindFirstChildOfClass("Humanoid")
				local root = monster.PrimaryPart
				if humanoid and root and humanoid.Health > 0 then
					local targetPlayer, targetPos = getNearestTarget(monster)
					if targetPlayer and targetPos then
						humanoid:MoveTo(targetPos)
						if (targetPos - root.Position).Magnitude <= ATTACK_RANGE then
							effectsService.Feedback(targetPlayer, "A MONSTER IS ON YOU!")
						end
					else
						local worldId = (monster:GetAttribute("WorldId") or 1) :: number
						local worldSpawn = Config.Worlds[worldId].Spawn
						humanoid:MoveTo(worldSpawn + Vector3.new(0, 0, 80))
					end
				end
			end
			task.wait(UPDATE_INTERVAL)
		end
	end)

	print("[MonsterService] Chaser monsters online")
end

return MonsterService
