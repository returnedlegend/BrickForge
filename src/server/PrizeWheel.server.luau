-- Rewards and cooldowns are controlled by the server, never the client.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local event = Instance.new("RemoteEvent")
event.Name = "PrizeWheel"
event.Parent = ReplicatedStorage
local prizes = {10, 25, 50, 15, 100, 20, 75, 250}
local random = Random.new()
local nextSpin = {}
local function setup(player)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player
	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Parent = stats
end
Players.PlayerAdded:Connect(setup)
for _, player in Players:GetPlayers() do setup(player) end
Players.PlayerRemoving:Connect(function(player) nextSpin[player] = nil end)
event.OnServerEvent:Connect(function(player)
	local now = os.clock()
	if now < (nextSpin[player] or 0) then return end
	local stats = player:FindFirstChild("leaderstats")
	local coins = stats and stats:FindFirstChild("Coins")
	if not coins then return end
	nextSpin[player] = now + 10
	local index = random:NextInteger(1, #prizes)
	event:FireClient(player, "Spin", index, prizes[index])
	task.delay(4, function()
		if player.Parent ~= Players then return end
		coins.Value += prizes[index]
		event:FireClient(player, "Award", prizes[index])
	end)
end)
