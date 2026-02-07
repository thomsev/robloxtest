--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)

local Toast = require(script.Parent.ui.Toast)

local feedbackEvent = Remotes.getFeedbackEvent()

local function playPing()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://9118828567"
	sound.Volume = 0.25
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

feedbackEvent.OnClientEvent:Connect(function(message: string)
	Toast.Show(message)
	playPing()
end)
