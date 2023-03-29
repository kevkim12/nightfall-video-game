local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function temp (player)
	local frame = ReplicatedStorage:WaitForChild("Assets").PlayerTag:Clone()
	frame.Parent = script.Parent.List
	frame.Name = player.Name
	frame.Title.PlayerName.Text = player.Name
	frame.PlayerName.Value = player.Name
	--frame.Emblem.Image = ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name).Profile.Emblem.Value
	--frame.Title.Image = ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name).Profile.Title.Value
	frame.Visible = true
	if game.ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(player.Name) ~= nil then
		if game.ReplicatedStorage.GameData.PlayerStatus[player.Name].Value == true then
			script.Parent.List:WaitForChild(player.Name).BackgroundColor3 = Color3.new(106/255, 165/255, 118/255)
			script.Parent.List:WaitForChild(player.Name).Ready.Value = true
		end
	end
end

ReplicatedStorage.Events.PlayerStatus.OnClientEvent:Connect(function(playerName, isReady)
	if isReady == true then
		script.Parent.List:WaitForChild(playerName).BackgroundColor3 = Color3.new(106/255, 165/255, 118/255)
		script.Parent.List:WaitForChild(playerName).Ready.Value = true
	elseif isReady == false then
		script.Parent.List:WaitForChild(playerName).BackgroundColor3 = Color3.new(165/255, 165/255, 165/255)
		script.Parent.List:WaitForChild(playerName).Ready.Value = false
	end
end)

game.Players.PlayerAdded:Connect(function(plr)
	temp(plr)
end)

for _,players in pairs(game.Players:GetChildren()) do
	temp(players)
end

game.Players.PlayerRemoving:Connect(function(plr)
	for i,v in pairs(script.Parent.List:GetChildren()) do
		if v.Name == plr.Name then
			v:remove()
		end
	end
end)

