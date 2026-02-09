--!strict

local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("Config"))
local Constants = require(Shared:WaitForChild("Constants"))

local player = Players.LocalPlayer

local COLOR_EFFECT_NAME = "RunGrowWorldColor"
local BLUR_EFFECT_NAME = "RunGrowWorldBlur"
local TWEEN_INFO = TweenInfo.new(0.85, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function ensureColorEffect(): ColorCorrectionEffect
	local existing = Lighting:FindFirstChild(COLOR_EFFECT_NAME)
	if existing and existing:IsA("ColorCorrectionEffect") then
		return existing
	end

	local effect = Instance.new("ColorCorrectionEffect")
	effect.Name = COLOR_EFFECT_NAME
	effect.Parent = Lighting
	return effect
end

local function ensureBlurEffect(): BlurEffect
	local existing = Lighting:FindFirstChild(BLUR_EFFECT_NAME)
	if existing and existing:IsA("BlurEffect") then
		return existing
	end

	local effect = Instance.new("BlurEffect")
	effect.Name = BLUR_EFFECT_NAME
	effect.Size = 0
	effect.Parent = Lighting
	return effect
end

local function applyWorldVisuals(worldId: number)
	local worldVisuals = Config.WorldVisuals[worldId] or Config.WorldVisuals.Default
	if not worldVisuals then
		return
	end

	local color = ensureColorEffect()
	local blur = ensureBlurEffect()

	TweenService:Create(color, TWEEN_INFO, {
		TintColor = worldVisuals.TintColor,
		Contrast = worldVisuals.Contrast,
		Saturation = worldVisuals.Saturation,
		Brightness = worldVisuals.Brightness,
	}):Play()

	TweenService:Create(blur, TWEEN_INFO, {
		Size = worldVisuals.BlurSize,
	}):Play()
end

local function onWorldAttributeChanged()
	local worldId = (player:GetAttribute(Constants.ATTR_WORLD) or 1) :: number
	applyWorldVisuals(worldId)
end

player:GetAttributeChangedSignal(Constants.ATTR_WORLD):Connect(onWorldAttributeChanged)
onWorldAttributeChanged()
