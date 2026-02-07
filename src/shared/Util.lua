--!strict

local Util = {}

function Util.clamp(value: number, minValue: number, maxValue: number): number
	if value < minValue then
		return minValue
	end
	if value > maxValue then
		return maxValue
	end
	return value
end

function Util.safeWait(seconds: number?): nil
	task.wait(seconds or 0)
end

function Util.getCharacter(player: Player): Model?
	return player.Character
end

function Util.getHumanoid(character: Model?): Humanoid?
	if not character then
		return nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid:IsA("Humanoid") then
		return humanoid
	end
	return nil
end

function Util.getRootPart(character: Model?): BasePart?
	if not character then
		return nil
	end
	local root = character:FindFirstChild("HumanoidRootPart")
	if root and root:IsA("BasePart") then
		return root
	end
	return nil
end

function Util.formatNumber(value: number): string
	if value >= 1000 then
		return string.format("%.1fk", value / 1000)
	end
	return string.format("%.2f", value)
end

return Util
