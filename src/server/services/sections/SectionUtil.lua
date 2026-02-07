--!strict

local SectionUtil = {}

function SectionUtil.makePart(parent: Instance, name: string, size: Vector3, cf: CFrame, color: Color3): Part
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cf
	part.Color = color
	part.Material = Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

function SectionUtil.placeRingStep(center: Vector3, radius: number, angleDeg: number, y: number): Vector3
	local r = math.rad(angleDeg)
	return Vector3.new(center.X + math.cos(r) * radius, y, center.Z + math.sin(r) * radius)
end

function SectionUtil.makeSign(parent: Instance, text: string, position: Vector3)
	local billboard = Instance.new("Part")
	billboard.Name = "Sign"
	billboard.Anchored = true
	billboard.CanCollide = false
	billboard.Transparency = 1
	billboard.Size = Vector3.new(1, 1, 1)
	billboard.Position = position
	billboard.Parent = parent

	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 50)
	gui.AlwaysOnTop = true
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.Parent = billboard

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.fromScale(1, 1)
	lbl.BackgroundTransparency = 0.2
	lbl.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	lbl.TextColor3 = Color3.new(1, 1, 1)
	lbl.Font = Enum.Font.FredokaOne
	lbl.TextScaled = true
	lbl.Text = text
	lbl.Parent = gui
end

return SectionUtil
