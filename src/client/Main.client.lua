--!strict

if _G.GrowthTowerClientStarted then
	return
end
_G.GrowthTowerClientStarted = true

local services = script.Parent:WaitForChild("services")
require(services.FeedbackService).Init()
require(services.CameraService).Init()
require(services.UIService).Init()
