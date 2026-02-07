--!strict

local STARTUP_TAG = "[Main.client]"

local uiFolder = script.Parent:FindFirstChild("ui")
if not uiFolder or not uiFolder:IsA("Folder") then
	warn(STARTUP_TAG, ("Optional folder 'ui' not found under %s; skipping HUD init."):format(script.Parent:GetFullName()))
	return
end

local hudModule = uiFolder:FindFirstChild("HUD")
if not hudModule or not hudModule:IsA("ModuleScript") then
	warn(STARTUP_TAG, "Optional UI module 'ui/HUD' not found; skipping HUD init.")
	return
end

local okRequire, HUD = pcall(require, hudModule)
if not okRequire then
	warn(STARTUP_TAG, "Failed to require ui/HUD:", HUD)
	return
end

if type(HUD) == "table" and type(HUD.Init) == "function" then
	local okInit, initErr = pcall(HUD.Init)
	if not okInit then
		warn(STARTUP_TAG, "HUD.Init failed:", initErr)
		return
	end
	print(STARTUP_TAG, "HUD initialized")
else
	warn(STARTUP_TAG, "ui/HUD does not export Init(); skipping HUD init.")
end
