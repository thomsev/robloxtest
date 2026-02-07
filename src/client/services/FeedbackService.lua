--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Remotes = require(ReplicatedStorage.Shared.Remotes)
local Toast = require(script.Parent.Parent.ui.Toast)

local FeedbackService = {}

local function sound(id: string, vol: number)
	local s = Instance.new("Sound")
	s.SoundId = id
	s.Volume = vol
	s.Parent = SoundService
	s:Play()
	s.Ended:Connect(function() s:Destroy() end)
end

function FeedbackService.Init()
	Remotes.getFeedbackEvent().OnClientEvent:Connect(function(message: string)
		Toast.Show(message)
		sound("rbxassetid://9118828567", 0.25)
	end)
	Remotes.getEffectsEvent().OnClientEvent:Connect(function(effect: string)
		if effect == "Smash" then
			sound("rbxassetid://138186576", 0.6)
		elseif effect == "Pulse" then
			sound("rbxassetid://6026984224", 0.25)
		end
	end)
end

return FeedbackService
