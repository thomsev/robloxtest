--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Remotes = require(Shared.Remotes)

local HUD = {}

local upgradeEvent = Remotes.getUpgradeRequestEvent()
local stompEvent = Remotes.getStompRequestEvent()

local function nextGoal(size: number): number
	local best = Config.RebirthRequiredSize
	for _, world in ipairs(Config.Worlds) do
		if size < world.PortalRequirement then
			return world.PortalRequirement
		end
	end
	for _, tier in ipairs(Config.SizeTiers) do
		if size < tier.Min then
			best = tier.Min
			break
		end
	end
	return best
end

function HUD.Init()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "RunGrowHUD"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(360, 210)
	root.Position = UDim2.fromOffset(16, 16)
	root.BackgroundColor3 = Color3.fromRGB(20, 22, 33)
	root.BackgroundTransparency = 0.18
	root.BorderSizePixel = 0
	root.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -8, 0, 32)
	title.Position = UDim2.fromOffset(8, 4)
	title.BackgroundTransparency = 1
	title.Font = Enum.Font.FredokaOne
	title.Text = "RUN BIGGER!"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Parent = root

	local sizeBarBg = Instance.new("Frame")
	sizeBarBg.Size = UDim2.fromOffset(340, 24)
	sizeBarBg.Position = UDim2.fromOffset(10, 44)
	sizeBarBg.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	sizeBarBg.BorderSizePixel = 0
	sizeBarBg.Parent = root

	local sizeBar = Instance.new("Frame")
	sizeBar.Size = UDim2.fromScale(0, 1)
	sizeBar.BackgroundColor3 = Color3.fromRGB(96, 231, 120)
	sizeBar.BorderSizePixel = 0
	sizeBar.Parent = sizeBarBg

	local info = Instance.new("TextLabel")
	info.Size = UDim2.fromOffset(340, 72)
	info.Position = UDim2.fromOffset(10, 75)
	info.BackgroundTransparency = 1
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top
	info.Font = Enum.Font.GothamBold
	info.TextColor3 = Color3.fromRGB(255, 255, 255)
	info.TextScaled = true
	info.Parent = root

	local buttons = { "RunSpeed", "GrowthRate", "SmashMultiplier" }
	for i, key in ipairs(buttons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(108, 28)
		button.Position = UDim2.fromOffset(10 + (i - 1) * 116, 152)
		button.BackgroundColor3 = Color3.fromRGB(255, 170, 70)
		button.Text = "+ " .. key
		button.Font = Enum.Font.FredokaOne
		button.TextScaled = true
		button.Parent = root
		button.MouseButton1Click:Connect(function()
			upgradeEvent:FireServer(key)
		end)
	end

	local stompButton = Instance.new("TextButton")
	stompButton.Size = UDim2.fromOffset(340, 28)
	stompButton.Position = UDim2.fromOffset(10, 184)
	stompButton.BackgroundColor3 = Color3.fromRGB(255, 90, 90)
	stompButton.Text = "GIANT STOMP"
	stompButton.Font = Enum.Font.FredokaOne
	stompButton.TextScaled = true
	stompButton.Parent = root
	stompButton.MouseButton1Click:Connect(function()
		stompEvent:FireServer()
	end)

	local function refresh()
		local size = (player:GetAttribute(Constants.ATTR_SIZE) or 1) :: number
		local rebirths = (player:GetAttribute(Constants.ATTR_REBIRTHS) or 0) :: number
		local coins = (player:GetAttribute(Constants.ATTR_COINS) or 0) :: number
		local tier = (player:GetAttribute(Constants.ATTR_SIZE_TIER) or "Tiny") :: string
		local goal = nextGoal(size)

		info.Text = string.format("Size %.1f (%s)\nCoins %d  Rebirths %d\nNEXT GOAL: %.0f", size, tier, coins, rebirths, goal)
		local alpha = math.clamp(size / goal, 0, 1)
		TweenService:Create(sizeBar, TweenInfo.new(0.2), { Size = UDim2.fromScale(alpha, 1) }):Play()
	end

	refresh()
	for _, attr in ipairs({ Constants.ATTR_SIZE, Constants.ATTR_REBIRTHS, Constants.ATTR_COINS, Constants.ATTR_SIZE_TIER }) do
		player:GetAttributeChangedSignal(attr):Connect(refresh)
	end
end

return HUD
