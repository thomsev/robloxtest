--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(script.Parent.Constants)

local Remotes = {}

local function getFolder(): Folder
	local existing = ReplicatedStorage:FindFirstChild(Constants.REMOTES_FOLDER)
	if existing and existing:IsA("Folder") then
		return existing
	end

	local folder = Instance.new("Folder")
	folder.Name = Constants.REMOTES_FOLDER
	folder.Parent = ReplicatedStorage
	return folder
end

local function getRemoteEvent(name: string): RemoteEvent
	local folder = getFolder()
	local existing = folder:FindFirstChild(name)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = folder
	return remote
end

function Remotes.getFeedbackEvent(): RemoteEvent
	return getRemoteEvent(Constants.FEEDBACK_EVENT)
end

function Remotes.getEffectsEvent(): RemoteEvent
	return getRemoteEvent(Constants.EFFECTS_EVENT)
end

function Remotes.getUpgradeRequestEvent(): RemoteEvent
	return getRemoteEvent(Constants.UPGRADE_REQUEST)
end

function Remotes.getStompRequestEvent(): RemoteEvent
	return getRemoteEvent(Constants.STOMP_REQUEST)
end

return Remotes
