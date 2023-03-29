local bar = script.Parent:WaitForChild("Bar")
local hpText = script.Parent:WaitForChild("HP")
local player = game.Players.LocalPlayer
repeat wait() until player.Character
local connection_health
local connection_max_health
local character = player.Character

local function update()
	local humanoid = character:WaitForChild("Humanoid")
	bar:TweenSize(UDim2.new(humanoid.Health / humanoid.MaxHealth, 0, 1, 0), Enum.EasingDirection.In, Enum.EasingStyle.Quint, .1, true)
end

local function setConnections()
	local humanoid = character:WaitForChild("Humanoid")
	connection_health = humanoid:GetPropertyChangedSignal("Health"):Connect(update)
	connection_max_health = humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update)
	update()
end

player.CharacterAdded:Connect(function(char)
	character = char
	if connection_health then connection_health:Disconnect() end
	if connection_max_health then connection_max_health:Disconnect() end
	setConnections()
end)

setConnections()