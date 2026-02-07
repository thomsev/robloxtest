--!strict

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Constants = require(ReplicatedStorage.Shared.Constants)

local BuilderUtil = {}

function BuilderUtil.makePart(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

function BuilderUtil.makeArrow(parent: Instance, cf: CFrame)
	local arrow = BuilderUtil.makePart(parent, "Arrow", Vector3.new(6, 0.6, 10), cf, Color3.fromRGB(255, 255, 255))
	arrow.Material = Enum.Material.Neon
	return arrow
end

function BuilderUtil.makeSign(parent: Instance, text: string, cf: CFrame)
	local anchor = BuilderUtil.makePart(parent, "SignAnchor", Vector3.new(1, 1, 1), cf, Color3.fromRGB(255, 255, 255))
	anchor.Transparency = 1
	anchor.CanCollide = false
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(260, 60)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	gui.Parent = anchor
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 0.25
	lbl.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.FredokaOne
	lbl.TextScaled = true
	lbl.Text = text
	lbl.Parent = gui
end

function BuilderUtil.makeCheckpoint(parent: Instance, index: number, cf: CFrame)
	local cp = BuilderUtil.makePart(parent, "Checkpoint_" .. index, Vector3.new(12, 1, 8), cf, Color3.fromRGB(90, 255, 95))
	cp.Material = Enum.Material.Neon
	cp:SetAttribute("Index", index)
	CollectionService:AddTag(cp, Constants.TAG_CHECKPOINT)
end

return BuilderUtil
