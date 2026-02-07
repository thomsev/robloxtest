--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Constants = require(Shared.Constants)

local CurrencyService = {}

function CurrencyService.GetCoins(player: Player): number
	return ((player:GetAttribute(Constants.ATTR_COINS) or 0) :: number)
end

function CurrencyService.SetCoins(player: Player, amount: number)
	local coins = math.max(0, math.floor(amount))
	player:SetAttribute(Constants.ATTR_COINS, coins)

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local coinValue = leaderstats:FindFirstChild(Constants.ATTR_COINS)
		if coinValue and coinValue:IsA("IntValue") then
			coinValue.Value = coins
		end
	end
end

function CurrencyService.AddCoins(player: Player, amount: number)
	if amount <= 0 then
		return
	end
	CurrencyService.SetCoins(player, CurrencyService.GetCoins(player) + amount)
end

function CurrencyService.TrySpend(player: Player, amount: number): boolean
	if amount <= 0 then
		return true
	end
	local coins = CurrencyService.GetCoins(player)
	if coins < amount then
		return false
	end
	CurrencyService.SetCoins(player, coins - amount)
	return true
end

function CurrencyService.Init()
	Players.PlayerAdded:Connect(function(player)
		if player:GetAttribute(Constants.ATTR_COINS) == nil then
			player:SetAttribute(Constants.ATTR_COINS, 0)
		end
	end)
end

return CurrencyService
