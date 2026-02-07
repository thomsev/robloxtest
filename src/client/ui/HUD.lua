--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Util = require(Shared.Util)

local HUD = {}

local function getNextGate(size: number): number?
	for _, requirement in ipairs(Config.GateRequirements) do
		if size < requirement then
			return requirement
		end
	end
	return nil
end

function HUD.Init()
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local gui = Instance.new("ScreenGui")
	gui.Name = "RunGrowHUD"
	gui.ResetOnSpawn = false
	gui.Parent = playerGui

	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(280, 120)
	frame.Position = UDim2.fromOffset(16, 16)
	frame.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local uiList = Instance.new("UIListLayout")
	uiList.Padding = UDim.new(0, 4)
	uiList.Parent = frame

	local function makeLine(name: string): TextLabel
		local label = Instance.new("TextLabel")
		label.Name = name
		label.Size = UDim2.new(1, -10, 0, 34)
		label.BackgroundTransparency = 1
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Parent = frame
		return label
	end

	local sizeLabel = makeLine("Size")
	local rebirthLabel = makeLine("Rebirths")
	local goalLabel = makeLine("NextGate")

	local function refresh()
		local size = (player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number
		local rebirths = (player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number
		local nextGate = getNextGate(size)

		sizeLabel.Text = "Size: " .. Util.formatNumber(size)
		rebirthLabel.Text = "Rebirths: " .. tostring(rebirths)
		goalLabel.Text = if nextGate then "Next Gate: " .. tostring(nextGate) else "Next Gate: MAX CLEARED"
	end

	refresh()
	player:GetAttributeChangedSignal(Constants.ATTR_SIZE):Connect(refresh)
	player:GetAttributeChangedSignal(Constants.ATTR_REBIRTHS):Connect(refresh)
end

return HUD
