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

local function objectiveText(size: number, rebirths: number, unlock: number): string
	for _, world in ipairs(Config.Worlds) do
		if unlock < world.Id then
			return string.format("Grow to %.0f and rebirth %d for %s", world.PortalRequirement, world.RequiredRebirth, world.Name)
		end
	end
	if size < Config.RebirthRequiredSize then
		return string.format("Reach %.0f size and REBIRTH", Config.RebirthRequiredSize)
	end
	return string.format("Rebirth now to raise chaos power (R%d)", rebirths)
end

function HUD.Init()
	local player = Players.LocalPlayer
	local gui = Instance.new("ScreenGui")
	gui.Name = "RunGrowHUD"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local root = Instance.new("Frame")
	root.Size = UDim2.fromOffset(390, 270)
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
	title.Text = "RUN • SMASH • CLIMB"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Parent = root

	local sizeBarBg = Instance.new("Frame")
	sizeBarBg.Size = UDim2.fromOffset(366, 24)
	sizeBarBg.Position = UDim2.fromOffset(12, 42)
	sizeBarBg.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
	sizeBarBg.BorderSizePixel = 0
	sizeBarBg.Parent = root

	local sizeBar = Instance.new("Frame")
	sizeBar.Size = UDim2.fromScale(0, 1)
	sizeBar.BackgroundColor3 = Color3.fromRGB(96, 231, 120)
	sizeBar.BorderSizePixel = 0
	sizeBar.Parent = sizeBarBg

	local info = Instance.new("TextLabel")
	info.Size = UDim2.fromOffset(366, 92)
	info.Position = UDim2.fromOffset(12, 74)
	info.BackgroundTransparency = 1
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top
	info.Font = Enum.Font.GothamBold
	info.TextColor3 = Color3.fromRGB(255, 255, 255)
	info.TextScaled = true
	info.Parent = root

	local buttons = { "RunSpeed", "GrowthRate", "SmashMultiplier", "JumpAssist", "KnockbackResist", "TrailFx" }
	for i, key in ipairs(buttons) do
		local button = Instance.new("TextButton")
		button.Size = UDim2.fromOffset(120, 28)
		button.Position = UDim2.fromOffset(12 + ((i - 1) % 3) * 126, 172 + math.floor((i - 1) / 3) * 34)
		button.BackgroundColor3 = key == "TrailFx" and Color3.fromRGB(255, 125, 225) or Color3.fromRGB(255, 170, 70)
		button.Text = "+ " .. key
		button.Font = Enum.Font.FredokaOne
		button.TextScaled = true
		button.Parent = root
		button.MouseButton1Click:Connect(function()
			upgradeEvent:FireServer(key)
		end)
	end

	local stompButton = Instance.new("TextButton")
	stompButton.Size = UDim2.fromOffset(366, 28)
	stompButton.Position = UDim2.fromOffset(12, 240)
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
		local tokens = (player:GetAttribute(Constants.ATTR_SMASH_TOKENS) or 0) :: number
		local tier = (player:GetAttribute(Constants.ATTR_SIZE_TIER) or "Tiny") :: string
		local unlock = (player:GetAttribute(Constants.ATTR_WORLD_UNLOCK) or 1) :: number

		info.Text = string.format("Size %.1f (%s)  Rebirth %d\nCoins %d  Smash Tokens %d\nNEXT: %s", size, tier, rebirths, coins, tokens, objectiveText(size, rebirths, unlock))
		local alpha = math.clamp(size / Config.RebirthRequiredSize, 0, 1)
		TweenService:Create(sizeBar, TweenInfo.new(0.2), { Size = UDim2.fromScale(alpha, 1) }):Play()
	end

	refresh()
	for _, attr in ipairs({ Constants.ATTR_SIZE, Constants.ATTR_REBIRTHS, Constants.ATTR_COINS, Constants.ATTR_SMASH_TOKENS, Constants.ATTR_SIZE_TIER, Constants.ATTR_WORLD_UNLOCK }) do
		player:GetAttributeChangedSignal(attr):Connect(refresh)
	end
end

return HUD
