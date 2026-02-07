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

function Remotes.getFeedbackEvent(): RemoteEvent
	local folder = getFolder()
	local existing = folder:FindFirstChild(Constants.FEEDBACK_EVENT)
	if existing and existing:IsA("RemoteEvent") then
		return existing
	end

	local remote = Instance.new("RemoteEvent")
	remote.Name = Constants.FEEDBACK_EVENT
	remote.Parent = folder
	return remote
end

return Remotes
