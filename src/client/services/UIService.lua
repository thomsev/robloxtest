--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Constants = require(ReplicatedStorage.Shared.Constants)

local UIService = {}

function UIService.Init()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "GrowthTowerHUD"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local panel = Instance.new("TextLabel")
	panel.Size = UDim2.fromOffset(430, 120)
	panel.Position = UDim2.fromOffset(16, 16)
	panel.BackgroundColor3 = Color3.fromRGB(25, 27, 38)
	panel.BackgroundTransparency = 0.2
	panel.TextColor3 = Color3.new(1, 1, 1)
	panel.TextXAlignment = Enum.TextXAlignment.Left
	panel.TextYAlignment = Enum.TextYAlignment.Top
	panel.Font = Enum.Font.GothamBold
	panel.TextScaled = true
	panel.Parent = gui

	local function refresh()
		local section = (player:GetAttribute(Constants.ATTR_SECTION) or 1) :: number
		local size = (player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number
		local coins = (player:GetAttribute(Constants.ATTR_COINS) or 0) :: number
		local hint = (player:GetAttribute(Constants.ATTR_LAST_HINT) or "Reach next checkpoint") :: string
		local nextName = Config.Sections[math.min(section, #Config.Sections)].Name
		local risk = if section == 3 then "Risk lane bonus active" else "Risk lane appears in Section 3"
		panel.Text = string.format("THE GROWTH TOWER\nSize %.1f  Coins %d\nNext checkpoint: Section %d (%s)\n%s\nTip: %s", size, coins, math.min(section, #Config.Sections), nextName, risk, hint)
	end

	for _, attr in ipairs({ Constants.ATTR_SECTION, Constants.ATTR_SIZE, Constants.ATTR_COINS, Constants.ATTR_LAST_HINT }) do
		player:GetAttributeChangedSignal(attr):Connect(refresh)
	end
	refresh()
end

return UIService
