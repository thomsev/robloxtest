--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)

local CameraService = {}

function CameraService.Init()
	local player = Players.LocalPlayer
	local function refresh()
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local section = (player:GetAttribute(Constants.ATTR_SECTION) or 1) :: number
		local fov = math.clamp(70 + section * 2, 70, 84)
		TweenService:Create(camera, TweenInfo.new(0.25), { FieldOfView = fov }):Play()
	end
	player:GetAttributeChangedSignal(Constants.ATTR_SECTION):Connect(refresh)
	refresh()
end

return CameraService
