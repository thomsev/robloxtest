--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Remotes = require(Shared.Remotes)

local EffectsService = {}

local feedbackEvent = Remotes.getFeedbackEvent()
local effectsEvent = Remotes.getEffectsEvent()

function EffectsService.Feedback(player: Player, message: string)
	feedbackEvent:FireClient(player, message)
end

function EffectsService.BroadcastFeedback(message: string)
	feedbackEvent:FireAllClients(message)
end

function EffectsService.Emit(player: Player, effectType: string, payload: {[string]: any}?)
	effectsEvent:FireClient(player, effectType, payload or {})
end

function EffectsService.EmitAll(effectType: string, payload: {[string]: any}?)
	effectsEvent:FireAllClients(effectType, payload or {})
end

return EffectsService
