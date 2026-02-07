--!strict

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Toast = {}

function Toast.Show(message: string)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local gui = playerGui:FindFirstChild("RunGrowToast")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "RunGrowToast"
		(gui :: ScreenGui).ResetOnSpawn = false
		gui.Parent = playerGui
	end

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromOffset(420, 52)
	label.Position = UDim2.new(0.5, -210, 0.12, 0)
	label.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	label.BackgroundTransparency = 0.2
	label.BorderSizePixel = 0
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.FredokaOne
	label.Text = message
	label.Parent = gui

	TweenService:Create(label, TweenInfo.new(0.12), { Position = UDim2.new(0.5, -210, 0.1, 0) }):Play()
	task.delay(2.2, function()
		if label and label.Parent then
			TweenService:Create(label, TweenInfo.new(0.2), { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
			task.delay(0.22, function()
				if label then
					label:Destroy()
				end
			end)
		end
	end)
end

return Toast
