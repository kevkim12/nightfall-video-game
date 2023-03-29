local Zone = require(game:GetService("ServerStorage").Modules.Zone)
local container = script.Parent
local zone = Zone.new(container)
local InfectedTeam = game:GetService("Teams"):WaitForChild("Infected")
local SurvivorTeam = game:GetService("Teams"):WaitForChild("Survivors")

local Victims = {}

local function ShowEffect(Player)
	local fadeDuration = 2
	local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	game:GetService("TweenService"):Create(Player.PlayerGui.DamageGui.Frame.GasWarning, tweenInfo, {ImageTransparency = 0}):Play()
end

local function HideEffect(Player)
	local fadeDuration = 2
	local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	local HideTween = game:GetService("TweenService"):Create(Player.PlayerGui.DamageGui.Frame.GasWarning, tweenInfo, {ImageTransparency = 1}):Play()
	HideTween.Completed:Connect(function()
		Player.PlayerGui.DamageGui.Frame.GasWarning.Visible = false
		Player.PlayerGui.DamageGui.Frame.GasWarning.Biohazard.Visible = true
	end)
end

zone.playerEntered:Connect(function(player)
	if player.Team == SurvivorTeam then
		table.insert(Victims, player)
		player.PlayerGui.DamageGui.Frame.GasWarning.Biohazard.Visible = true
		player.PlayerGui.DamageGui.Frame.GasWarning.Visible = true
		ShowEffect(player)
	end
end)

zone.playerExited:Connect(function(player)
	if player.Team == SurvivorTeam then
		local index = table.find(Victims, player)
		table.remove(Victims, index)
		player.PlayerGui.DamageGui.Frame.GasWarning.Biohazard.Visible = false
		HideEffect(player)
	end
end)

while true do
	wait(1)
	for i = 1, #Victims do
		Victims[i].Character.Humanoid.Health = Victims[i].Character.Humanoid.Health - 2.5
	end
end