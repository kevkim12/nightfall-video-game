local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Map1_Votes = 0
local Map2_Votes = 0
local Map3_Votes = 0

ReplicatedStorage.Events.VoteSelection.OnServerEvent:Connect(function(Player, Vote)
	if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(Player.Name):FindFirstChild("MapVote") ~= nil then
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(Player.Name):FindFirstChild("MapVote").Value ~= true then
			if Vote == 1 then
				ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(Player.Name):FindFirstChild("MapVote").Value = true
				Map1_Votes = Map1_Votes + 1
			elseif Vote == 2 then
				ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(Player.Name):FindFirstChild("MapVote").Value = true
				Map2_Votes = Map2_Votes + 1
			elseif Vote == 3 then
				ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(Player.Name):FindFirstChild("MapVote").Value = true
				Map3_Votes = Map3_Votes + 1
			end
		end
		ReplicatedStorage.Events.UpdateVotes:FireAllClients(Map1_Votes, Map2_Votes, Map3_Votes)
	end
end)

ReplicatedStorage.Events.ResetVotes.Event:Connect(function()
	Map1_Votes = 0
	Map2_Votes = 0
	Map3_Votes = 0
	
	local PlayerStatuses = ReplicatedStorage.GameData.PlayerStatus:GetChildren()
	for i = 1, #PlayerStatuses do
		PlayerStatuses[i]:FindFirstChild("MapVote").Value = false
	end
end)

ServerStorage.Functions.VoteResult.OnInvoke = function()
	if Map1_Votes > Map2_Votes and Map1_Votes > Map3_Votes then
		return "Map 1"
	elseif Map2_Votes > Map1_Votes and Map2_Votes > Map3_Votes then
		return "Map 2"
	elseif Map3_Votes > Map1_Votes and Map3_Votes > Map2_Votes then
		return "Map 3"
	elseif (Map1_Votes == Map2_Votes) == Map3_Votes then
		local Selection = math.random(1,3)
		if Selection == 1 then
			return "Map 1"
		elseif Selection == 2 then
			return "Map 2"
		else
			return "Map 3"
		end
	elseif Map1_Votes == Map2_Votes then
		local Selection = math.random(1,2)
		if Selection == 1 then
			return "Map 1"
		else
			return "Map 2"
		end
	elseif Map2_Votes == Map3_Votes then
		local Selection = math.random(1,2)
		if Selection == 1 then
			return "Map 2"
		else
			return "Map 3"
		end
	elseif Map1_Votes == Map3_Votes then
		local Selection = math.random(1,2)
		if Selection == 1 then
			return "Map 1"
		else
			return "Map 3"
		end
	else
		local Selection = math.random(1,3)
		if Selection == 1 then
			return "Map 1"
		elseif Selection == 2 then
			return "Map 2"
		else
			return "Map 3"
		end
	end
end