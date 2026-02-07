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

print(STARTUP_TAG, "Starting server bootstrap")

local sharedFolder = waitForChildWithTimeout(ReplicatedStorage, "Shared", LOOKUP_TIMEOUT)
if not sharedFolder or not sharedFolder:IsA("Folder") then
	warn(STARTUP_TAG, "ReplicatedStorage/Shared not found. Check Rojo mapping for src/shared -> ReplicatedStorage/Shared.")
	return
end
print(STARTUP_TAG, "Found shared folder:", sharedFolder:GetFullName())

local Config = requireModuleFrom(sharedFolder, "Config")
local Remotes = requireModuleFrom(sharedFolder, "Remotes")
if not Config or not Remotes then
	warn(STARTUP_TAG, "Shared modules failed to load. Aborting server startup.")
	return
end

local servicesFolder = waitForChildWithTimeout(script.Parent, "services", LOOKUP_TIMEOUT)
if not servicesFolder or not servicesFolder:IsA("Folder") then
	warn(STARTUP_TAG, ("Missing services folder under %s"):format(script.Parent:GetFullName()))
	return
end
print(STARTUP_TAG, "Found services folder:", servicesFolder:GetFullName())

local MapBootstrapService = requireModuleFrom(servicesFolder, "MapBootstrapService")
local SizeService = requireModuleFrom(servicesFolder, "SizeService")
local TreadmillService = requireModuleFrom(servicesFolder, "TreadmillService")
local GateService = requireModuleFrom(servicesFolder, "GateService")
local MovementGrowthService = requireModuleFrom(servicesFolder, "MovementGrowthService")
local DataStoreService = requireModuleFrom(servicesFolder, "DataStoreService")

if not MapBootstrapService or not SizeService or not TreadmillService or not GateService or not MovementGrowthService then
	warn(STARTUP_TAG, "One or more core services failed to load. Aborting startup.")
	return
end

local feedbackEvent = Remotes.getFeedbackEvent()

print(STARTUP_TAG, "Initializing map bootstrap")
local mapOk, mapErr = pcall(function()
	MapBootstrapService.Init()
end)
if not mapOk then
	warn(STARTUP_TAG, "MapBootstrapService.Init failed:", mapErr)
	return
end

local generatedMap = Workspace:FindFirstChild("GeneratedMap")
if not generatedMap then
	generatedMap = waitForChildWithTimeout(Workspace, "GeneratedMap", 5)
end
if not generatedMap then
	warn(STARTUP_TAG, "Workspace.GeneratedMap was not created.")
	return
end
print(STARTUP_TAG, "Generated map ready:", generatedMap:GetFullName())

print(STARTUP_TAG, "Initializing gameplay services")
SizeService.Init()
TreadmillService.Init()
GateService.Init(SizeService)
MovementGrowthService.Init(SizeService, TreadmillService)
print(STARTUP_TAG, "Core services initialized")

if DataStoreService and type(DataStoreService.Init) == "function" then
	task.spawn(function()
		local ok, err = pcall(function()
			DataStoreService.Init(SizeService)
		end)
		if not ok then
			warn(STARTUP_TAG, "DataStoreService.Init failed (continuing without persistence):", err)
		else
			print(STARTUP_TAG, "DataStore service initialized")
		end
	end)
else
	warn(STARTUP_TAG, "DataStoreService missing or invalid; continuing without persistence.")
end

local rebirthPad = generatedMap:FindFirstChild("RebirthPad")
if rebirthPad and rebirthPad:IsA("BasePart") then
	print(STARTUP_TAG, "Wiring RebirthPad touch handler")
	rebirthPad.Touched:Connect(function(hit: BasePart)
		local character = hit.Parent
		if not character or not character:IsA("Model") then
			return
		end

		local player = Players:GetPlayerFromCharacter(character)
		if not player then
			return
		end

		if SizeService.Rebirth(player) then
			feedbackEvent:FireClient(player, "Rebirth! Multiplier increased.")
		else
			feedbackEvent:FireClient(player, string.format("Need size %.0f to rebirth.", Config.RebirthRequiredSize))
		end
	end)
else
	warn(STARTUP_TAG, "RebirthPad missing from GeneratedMap; rebirth interaction disabled.")
end

print(STARTUP_TAG, "Server startup complete")
