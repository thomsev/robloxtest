--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared.Config)
local Constants = require(Shared.Constants)
local Remotes = require(Shared.Remotes)

local Toast = require(script.Parent.ui.Toast)

local player = Players.LocalPlayer
local feedbackEvent = Remotes.getFeedbackEvent()
local effectsEvent = Remotes.getEffectsEvent()

local function playSound(soundId: string, volume: number, playbackSpeed: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.PlaybackSpeed = playbackSpeed or 1
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

local function tierConfig(name: string)
	for _, tier in ipairs(Config.SizeTiers) do
		if tier.Name == name then
			return tier
		end
	end
	return Config.SizeTiers[1]
end

local function updateCameraForTier()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local tier = tierConfig((player:GetAttribute(Constants.ATTR_SIZE_TIER) or "Tiny") :: string)
	TweenService:Create(cam, TweenInfo.new(0.2), { FieldOfView = tier.FOV }):Play()
end

local function screenShake()
	local cam = workspace.CurrentCamera
	if not cam then
		return
	end
	local base = cam.CFrame
	cam.CFrame = base * CFrame.new(math.random(-2, 2) * 0.08, math.random(-1, 1) * 0.08, 0)
	task.delay(0.05, function()
		if cam then
			cam.CFrame = base
		end
	end)
end

feedbackEvent.OnClientEvent:Connect(function(message: string)
	Toast.Show(message)
	playSound("rbxassetid://9118828567", 0.28)
end)

effectsEvent.OnClientEvent:Connect(function(effectType: string, payload)
	if effectType == "TierChange" then
		Toast.Show("NOW " .. tostring(payload.Tier) .. "!")
		playSound("rbxassetid://6026984224", 0.5)
		updateCameraForTier()
	elseif effectType == "Smash" then
		playSound("rbxassetid://138186576", 0.65, 0.9)
		screenShake()
	elseif effectType == "Rebirth" then
		playSound("rbxassetid://1843529276", 0.75)
		screenShake()
		Toast.Show("REBIRTH READY!")
	elseif effectType == "TooSmall" then
		Toast.Show("TOO SMALL!")
	elseif effectType == "Ragdoll" then
		playSound("rbxassetid://12222216", 0.45)
	elseif effectType == "Stomp" then
		playSound("rbxassetid://9113420770", 0.8)
		screenShake()
	end
end)

player:GetAttributeChangedSignal(Constants.ATTR_SIZE_TIER):Connect(updateCameraForTier)

player.CharacterAdded:Connect(function(character)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	humanoid.Running:Connect(function(speed)
		if speed > 2 then
			local tier = tierConfig((player:GetAttribute(Constants.ATTR_SIZE_TIER) or "Tiny") :: string)
			playSound("rbxassetid://13114759", tier.FootstepVolume, 0.95)
		end
	end)
end)
