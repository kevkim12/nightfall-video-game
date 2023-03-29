local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local InfectedTeam = Teams:WaitForChild("Infected")
local SurvivorTeam = Teams:WaitForChild("Survivors")


local function temp (player)
	local frame = ReplicatedStorage:WaitForChild("Assets").LeaderboardTag:Clone()
	frame.Name = player.Name
	frame.PlayerName.Text = player.Name
	frame.Visible = true
	if player.Team == SurvivorTeam then
		frame.Visible = true
		frame.Parent = script.Parent.Lists.Survivors
	elseif player.Team == InfectedTeam then
		frame.Visible = true
		frame.Parent = script.Parent.Lists.Infected
	else
		frame.Visible = false
		frame.Parent = script.Parent.Lists.Survivors
	end
end

ReplicatedStorage.Events.TeamChange.OnClientEvent:Connect(function(Player, PlayerTeam)
	local frame = script.Parent.Lists.Survivors:FindFirstChild(Player.Name) or script.Parent.Lists.Infected:FindFirstChild(Player.Name)
	if Player.Team == SurvivorTeam then
		frame.Visible = true
		frame.Parent = script.Parent.Lists.Survivors
	elseif Player.Team == InfectedTeam then
		frame.Visible = true
		frame.Parent = script.Parent.Lists.Infected
	else
		frame.Visible = false
		frame.Parent = script.Parent.Lists.Survivors
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	temp(plr)
end)

for _,players in pairs(game.Players:GetChildren()) do
	temp(players)
end

game.Players.PlayerRemoving:Connect(function(plr)
	for i,v in pairs(script.Parent.Lists:GetChildren()) do
		if v.Name == plr.Name then
			v:remove()
		end
	end
end)

