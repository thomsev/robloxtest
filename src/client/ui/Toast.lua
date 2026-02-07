--!strict

local Players = game:GetService("Players")

local Toast = {}

function Toast.Show(message: string)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")
	local gui = playerGui:FindFirstChild("RunGrowToast")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "RunGrowToast"
		(gui :: ScreenGui).ResetOnSpawn = false
		gui.Parent = playerGui
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(360, 44)
	label.Position = UDim2.new(0.5, -180, 0.15, 0)
	label.BackgroundColor3 = Color3.fromRGB(33, 33, 33)
	label.BackgroundTransparency = 0.15
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = message
	label.Parent = gui

	task.delay(2.3, function()
		if label and label.Parent then
			label:Destroy()
		end
	end)
end

return Toast
