--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(script.Parent.Constants)

local Remotes = {}

local function getFolder(): Folder
	local folder = ReplicatedStorage:FindFirstChild(Constants.REMOTES_FOLDER)
	if folder and folder:IsA("Folder") then
		return folder
	end
	folder = Instance.new("Folder")
	folder.Name = Constants.REMOTES_FOLDER
	folder.Parent = ReplicatedStorage
	return folder
end

local function getRemoteEvent(name: string): RemoteEvent
	local folder = getFolder()
	local remote = folder:FindFirstChild(name)
	if remote and remote:IsA("RemoteEvent") then
		return remote
	end
	remote = Instance.new("RemoteEvent")
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

return Remotes
