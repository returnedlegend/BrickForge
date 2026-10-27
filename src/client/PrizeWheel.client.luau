local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local event = ReplicatedStorage:WaitForChild("PrizeWheel")
local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "BrickForgePrizeWheel"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")
local function create(class, properties, parent)
	local object = Instance.new(class)
	for key, value in properties do object[key] = value end
	object.Parent = parent
	return object
end
local function round(object, radius)
	create("UICorner", {CornerRadius = UDim.new(0, radius)}, object)
end
local open = create("TextButton", {
	Size = UDim2.fromOffset(150, 44), Position = UDim2.new(0, 16, 0.5, -22),
	BackgroundColor3 = Color3.fromRGB(255, 194, 55), Text = "COIN WHEEL",
	Font = Enum.Font.GothamBold, TextSize = 18, TextColor3 = Color3.fromRGB(26, 30, 48),
}, gui)
round(open, 12)
local panel = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(340, 460), BackgroundColor3 = Color3.fromRGB(24, 29, 48), Visible = false,
}, gui)
round(panel, 20)
local scale = create("UIScale", {}, panel)
local function resize()
	local camera = workspace.CurrentCamera
	if camera then scale.Scale = math.min(1, (camera.ViewportSize.X - 20) / 340, (camera.ViewportSize.Y - 60) / 460) end
end
local function label(text, position, size, parent)
	return create("TextLabel", {Text = text, Position = position, Size = size,
		BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1),
		Font = Enum.Font.GothamBold, TextSize = 18}, parent)
end
label("BRICKFORGE • PRIZE WHEEL", UDim2.fromOffset(10, 12), UDim2.fromOffset(285, 28), panel).TextSize = 16
local close = create("TextButton", {Text = "×", Size = UDim2.fromOffset(32, 32), Position = UDim2.new(1, -38, 0, 8),
	BackgroundTransparency = 1, TextColor3 = Color3.new(1, 1, 1), TextSize = 28}, panel)
local balance = label("Coins: 0", UDim2.fromOffset(20, 45), UDim2.fromOffset(300, 25), panel)
local wheel = create("Frame", {AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(170, 208),
	Size = UDim2.fromOffset(250, 250), BackgroundColor3 = Color3.fromRGB(48, 58, 88)}, panel)
round(wheel, 125)
create("UIStroke", {Thickness = 5, Color = Color3.fromRGB(255, 194, 55)}, wheel)
local prizes = {10, 25, 50, 15, 100, 20, 75, 250}
for index, prize in prizes do
	local angle = math.rad((index - 1) * 45)
	local slot = label(tostring(prize), UDim2.fromOffset(125 + math.sin(angle) * 88, 125 - math.cos(angle) * 88), UDim2.fromOffset(54, 36), wheel)
	slot.AnchorPoint = Vector2.new(0.5, 0.5)
	slot.Rotation = (index - 1) * 45
	slot.BackgroundTransparency = 0
	slot.BackgroundColor3 = Color3.fromHSV((index - 1) / 8, 0.65, 0.75)
	round(slot, 10)
end
label("COINS", UDim2.fromOffset(85, 107), UDim2.fromOffset(80, 36), wheel)
local pointer = label("▼", UDim2.fromOffset(150, 69), UDim2.fromOffset(40, 35), panel)
pointer.TextColor3 = Color3.fromRGB(255, 222, 89)
pointer.TextSize = 32
pointer.ZIndex = 3
local status = label("Every spin wins!", UDim2.fromOffset(10, 343), UDim2.fromOffset(320, 28), panel)
local spin = create("TextButton", {Text = "SPIN — FREE", Position = UDim2.fromOffset(40, 379), Size = UDim2.fromOffset(260, 44),
	BackgroundColor3 = Color3.fromRGB(255, 194, 55), TextColor3 = Color3.fromRGB(26, 30, 48), Font = Enum.Font.GothamBold, TextSize = 20}, panel)
round(spin, 12)
label("Session coins • 10 seconds between spins", UDim2.fromOffset(10, 430), UDim2.fromOffset(320, 20), panel).TextSize = 12
open.Activated:Connect(function() resize(); panel.Visible = not panel.Visible end)
close.Activated:Connect(function() panel.Visible = false end)
local busy = false
spin.Activated:Connect(function()
	if busy then return end
	busy = true
	spin.Text = "Starting…"
	event:FireServer()
end)
event.OnClientEvent:Connect(function(action, value, reward)
	if action == "Spin" then
		busy = true
		status.Text = "Spinning…"
		wheel.Rotation = wheel.Rotation % 360
		local target = 360 * 5 + (-(value - 1) * 45) % 360
		TweenService:Create(wheel, TweenInfo.new(4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Rotation = target}):Play()
		task.spawn(function()
			for remaining = 10, 1, -1 do
				spin.Text = "Next spin in " .. remaining .. "s"
				task.wait(1)
			end
			busy = false
			spin.Text = "SPIN — FREE"
		end)
	elseif action == "Award" then
		status.Text = "You won " .. value .. " coins!"
	end
end)
local coins = player:WaitForChild("leaderstats"):WaitForChild("Coins")
local function update() balance.Text = "Coins: " .. coins.Value end
coins:GetPropertyChangedSignal("Value"):Connect(update)
update()
