--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local STARTUP_TAG = "[Main.server]"
local LOOKUP_TIMEOUT = 10

local function waitForChildWithTimeout(parent: Instance, childName: string, timeoutSeconds: number): Instance?
	local startedAt = os.clock()
	local child = parent:FindFirstChild(childName)
	while not child and os.clock() - startedAt < timeoutSeconds do
		task.wait(0.1)
		child = parent:FindFirstChild(childName)
	end
	return child
end

local function requireModuleFrom(parent: Instance, moduleName: string): any?
	local module = parent:FindFirstChild(moduleName)
	if not module or not module:IsA("ModuleScript") then
		warn(STARTUP_TAG, ("Missing ModuleScript '%s' under %s"):format(moduleName, parent:GetFullName()))
		return nil
	end
	local ok, result = pcall(require, module)
	if not ok then
		warn(STARTUP_TAG, ("Failed requiring '%s': %s"):format(module:GetFullName(), tostring(result)))
		return nil
	end
	return result
end

local sharedFolder = waitForChildWithTimeout(ReplicatedStorage, "Shared", LOOKUP_TIMEOUT)
if not sharedFolder then
	warn(STARTUP_TAG, "ReplicatedStorage/Shared missing")
	return
end

local Config = requireModuleFrom(sharedFolder, "Config")
local Constants = requireModuleFrom(sharedFolder, "Constants")
if not Config or not Constants then
	return
end

local servicesFolder = waitForChildWithTimeout(script.Parent, "services", LOOKUP_TIMEOUT)
if not servicesFolder then
	warn(STARTUP_TAG, "Missing services folder")
	return
end

local MapBootstrapService = requireModuleFrom(servicesFolder, "MapBootstrapService")
local EffectsService = requireModuleFrom(servicesFolder, "EffectsService")
local SizeService = requireModuleFrom(servicesFolder, "SizeService")
local CurrencyService = requireModuleFrom(servicesFolder, "CurrencyService")
local UpgradeService = requireModuleFrom(servicesFolder, "UpgradeService")
local TreadmillService = requireModuleFrom(servicesFolder, "TreadmillService")
local GateService = requireModuleFrom(servicesFolder, "GateService")
local MovementGrowthService = requireModuleFrom(servicesFolder, "MovementGrowthService")
local SmashService = requireModuleFrom(servicesFolder, "SmashService")
local WorldService = requireModuleFrom(servicesFolder, "WorldService")
local DataService = requireModuleFrom(servicesFolder, "DataStoreService")

if not (MapBootstrapService and EffectsService and SizeService and CurrencyService and UpgradeService and TreadmillService and GateService and MovementGrowthService and SmashService and WorldService) then
	warn(STARTUP_TAG, "Failed to load one or more services")
	return
end

MapBootstrapService.Init()
SizeService.Init()
CurrencyService.Init()
TreadmillService.Init()
UpgradeService.Init(CurrencyService, EffectsService)
GateService.Init(SizeService, EffectsService)
SmashService.Init(SizeService, CurrencyService, UpgradeService, EffectsService)
WorldService.Init(SizeService, CurrencyService, EffectsService)
MovementGrowthService.Init(SizeService, TreadmillService, CurrencyService, UpgradeService, EffectsService)

if DataService and type(DataService.Init) == "function" then
	task.spawn(function()
		DataService.Init(SizeService, CurrencyService)
	end)
end

Players.PlayerAdded:Connect(function(player)
	local now = os.time()
	local nextClaim = (player:GetAttribute(Constants.ATTR_DAILY_NEXT) or 0) :: number
	if now >= nextClaim then
		CurrencyService.AddCoins(player, Config.DailyReward.Coins)
		player:SetAttribute(Constants.ATTR_DAILY_NEXT, now + Config.DailyReward.CooldownSeconds)
		player:SetAttribute(Constants.ATTR_DAILY_BOOST_UNTIL, now + Config.DailyReward.GrowthBoostSeconds)
		EffectsService.Feedback(player, "DAILY REWARD!")
	end
end)

local rebirthPad = Workspace:WaitForChild("GeneratedMap"):FindFirstChild("RebirthPad", true)
if rebirthPad and rebirthPad:IsA("BasePart") then
	rebirthPad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player then
			return
		end
		if not SizeService.Rebirth(player, EffectsService, CurrencyService) then
			EffectsService.Feedback(player, string.format("REBIRTH READY at %.0f", Config.RebirthRequiredSize))
		end
	end)
end

print(STARTUP_TAG, "RUN BIGGER systems online")
