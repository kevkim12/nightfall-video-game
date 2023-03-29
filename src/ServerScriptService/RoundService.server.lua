local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IntermissionTime
local GameTime
local Victory = true
StageTesting = false
EnableAI = true

if game:GetService("RunService"):IsStudio() then
	IntermissionTime = 3
	GameTime = 720
	StageTesting = true
	EnableAI = false
	--180
else
	IntermissionTime = 30
	GameTime = 720
end

local MapModels = ServerStorage.Maps:GetChildren()
local CurrentMaps = {}
local MapQueue = {}


for i = 1, #MapModels do
	if MapModels[i]:IsA("Model") then
		table.insert(CurrentMaps, MapModels[i].Name)
		table.insert(MapQueue, MapModels[i].Name)
	end
end
local SelectedMap = CurrentMaps[math.random(1, #CurrentMaps)]
local Modes = {"Survival"}
local Objective = Modes[math.random(1, #Modes)]
local LoopStatus
local PlayerVerification

ReplicatedStorage.GameData.Map.Value = SelectedMap

local function Shuffle(t)
	local j, temp
	for i = #t, 1, -1 do
		j = math.random(i)
		temp = t[i]
		t[i] = t[j]
		t[j] = temp
	end
end

Shuffle(MapQueue)

local Map1
local Map2
local Map3
local PrevMap

local MapQueueStore = {}

for i = 1, #MapQueue do
	if MapQueue[i] == SelectedMap then
		table.insert(MapQueueStore, MapQueue[i])
		table.remove(MapQueue, i)
		table.insert(MapQueue, MapQueueStore[1])
		table.remove(MapQueueStore, 1)
	end
end

local function GetFirstInQueue()
	local Selection = MapQueue[1]
	table.insert(MapQueueStore, MapQueue[1])
	table.remove(MapQueue, 1)
	return Selection
end

local function InsertMapQueue()
	table.insert(MapQueue, MapQueueStore[1])
	table.remove(MapQueueStore, 1)
end

local function MapVotingEnd()
	ReplicatedStorage.Events.EndVoteScreen:FireAllClients()
	local VoteResult = ServerStorage.Functions.VoteResult:Invoke()
	if VoteResult == "Map 1" then
		SelectedMap = ReplicatedStorage.GameData.Map.Map1.Value
		Objective = ReplicatedStorage.GameData.Map.Map1.Mode.Value
		ReplicatedStorage.GameData.Map.Value = SelectedMap
	elseif VoteResult == "Map 2" then
		SelectedMap = ReplicatedStorage.GameData.Map.Map2.Value
		Objective = ReplicatedStorage.GameData.Map.Map2.Mode.Value
		ReplicatedStorage.GameData.Map.Value = SelectedMap
	elseif VoteResult == "Map 3" then
		SelectedMap = ReplicatedStorage.GameData.Map.Map3.Value
		Objective = ReplicatedStorage.GameData.Map.Map3.Mode.Value
		ReplicatedStorage.GameData.Map.Value = SelectedMap
	end
end

local function VoteCountdown()
	local Timer = 20
	for i = 1, 20 do
		ReplicatedStorage.Events.VoteCountdown:FireAllClients(Timer)
		Timer = Timer - 1
		wait(1)
	end
	MapVotingEnd()
end

local function MapVotingStart()
	local Map1 = GetFirstInQueue()
	local Mode1 = Modes[math.random(1, #Modes)]
	ReplicatedStorage.GameData.Map.Map1.Value = Map1
	ReplicatedStorage.GameData.Map.Map1.Mode.Value = Mode1
	local Map2 = GetFirstInQueue()
	local Mode2 = Modes[math.random(1, #Modes)]
	ReplicatedStorage.GameData.Map.Map2.Value = Map2
	ReplicatedStorage.GameData.Map.Map2.Mode.Value = Mode2
	local Map3 = GetFirstInQueue()
	local Mode3 = Modes[math.random(1, #Modes)]
	ReplicatedStorage.GameData.Map.Map3.Value = Map3
	ReplicatedStorage.GameData.Map.Map3.Mode.Value = Mode3
	ReplicatedStorage.Events.StartVoteScreen:FireAllClients(Map1, Mode1, Map2, Mode2, Map3, Mode3)
	InsertMapQueue()
	InsertMapQueue()
	InsertMapQueue()
	ReplicatedStorage.Events.ResetVotes:Fire()
	VoteCountdown()
end

local SurvivorTeam = game.Teams:WaitForChild("Survivors")
local InfectedTeam = game.Teams:WaitForChild("Infected")
local MenuTeam = game.Teams:WaitForChild("Menu")

local function CheckMap()
	if game.Workspace.Map:FindFirstChild(SelectedMap) ~= nil then
		return true
	else
		return false
	end
end

local function LoadMap()
	if SelectedMap == "Warzone" then
		ReplicatedStorage.GameData.Theme.Value = "Desert Wartorn"
		ServerStorage.Maps.MapData.CurrentMap.Value = SelectedMap
		local TempFolder = Instance.new("Folder")
		TempFolder.Parent = game.Workspace.Map
		TempFolder.Name = SelectedMap
		local ChosenMap = ServerStorage.Maps:WaitForChild(SelectedMap)
		for k, v in ipairs(ChosenMap:GetChildren()) do
			v:Clone().Parent = workspace.Map[SelectedMap]
			game:GetService("RunService").Stepped:wait()
		end
		-----------------=========================================
	elseif SelectedMap == "District" then
		ReplicatedStorage.GameData.Theme.Value = "Desert Wartorn"
		ServerStorage.Maps.MapData.CurrentMap.Value = SelectedMap
		local TempFolder = Instance.new("Folder")
		TempFolder.Parent = game.Workspace.Map
		TempFolder.Name = SelectedMap
		local ChosenMap = game.ServerStorage.Maps:WaitForChild(SelectedMap)
		for k, v in ipairs(ChosenMap:GetChildren()) do
			v:Clone().Parent = workspace.Map[SelectedMap]
			game:GetService("RunService").Stepped:wait()
		end
	elseif SelectedMap == "Sewers" then
		ReplicatedStorage.GameData.Theme.Value = "Desert Wartorn"
		ServerStorage.Maps.MapData.CurrentMap.Value = SelectedMap
		local TempFolder = Instance.new("Folder")
		TempFolder.Parent = game.Workspace.Map
		TempFolder.Name = SelectedMap
		local ChosenMap = game.ServerStorage.Maps:WaitForChild(SelectedMap)
		for k, v in ipairs(ChosenMap:GetChildren()) do
			v:Clone().Parent = workspace.Map[SelectedMap]
			game:GetService("RunService").Stepped:wait()
		end
	elseif SelectedMap == "Arctic" then
		ReplicatedStorage.GameData.Theme.Value = "Desert Wartorn"
		ServerStorage.Maps.MapData.CurrentMap.Value = SelectedMap
		local TempFolder = Instance.new("Folder")
		TempFolder.Parent = game.Workspace.Map
		TempFolder.Name = SelectedMap
		local ChosenMap = game.ServerStorage.Maps:WaitForChild(SelectedMap)
		for k, v in ipairs(ChosenMap:GetChildren()) do
			v:Clone().Parent = workspace.Map[SelectedMap]
			game:GetService("RunService").Stepped:wait()
		end
	end
end

local function CountReadyPlayers()
	local players = game.Players:GetPlayers()
	local count = 0
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				count = count + 1
			end
		end
	end
	return count
end

local function CountAlivePlayers(SurvivorTeam)
	local playersOnTeam = game:GetService("Teams")["Survivors"]:GetPlayers()
	local numberPlayersOnTeam = #playersOnTeam
	return numberPlayersOnTeam
end

local function CountInfected(InfectedTeam)
	local playersOnTeam = game:GetService("Teams")["Infected"]:GetPlayers()
	local numberPlayersOnTeam = #playersOnTeam
	return numberPlayersOnTeam
end

local function formatTime(input)
	local output
	if type(input) ~= "number" or input < 0 then
		output = "--:--"
	else
		local formatString = "%i:%.2i"
		local seconds = math.floor(input % 60)
		local minutes = math.floor(input / 60)
		output = formatString:format(minutes, seconds)
	end
	return output
end

local IsLoading = false

local function NeedPlayer()
	if ReplicatedStorage.GameData.NeedPlayer.Value == false and IsLoading == false then
		ReplicatedStorage.GameData.NeedPlayer.Value = true
	end
end

local function Loading()
	if ReplicatedStorage.GameData.Loading.Value == false then
		ReplicatedStorage.GameData.Loading.Value = true
	end
end

function IntermissionTimer()
	local Type = "INTERMISSION"
	local Timer = IntermissionTime
	for count = 1, IntermissionTime + 1 do
		wait(1)
		ReplicatedStorage.Events.UpdateTimer:FireAllClients(Timer, Type)
		Timer = Timer - 1
		if Timer < 5 then
			ReplicatedStorage.Events.SoundEffect:FireAllClients("Beep", "Play")
		end
	end
end

local function IntermissionCountdown()
	local Intermission = 0
	return Intermission
end

local function SelectPlayer()
	local players = game.Players:GetPlayers()
	local selected
	local Searching = true
	while Searching == true do
		wait()
		selected = players[math.random(1,#players)]
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(selected.Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[selected.Name].Value == true then
				Searching = false
			end
		end
	end
	return selected
end

local function AssignTeamsRandom()
	local players = game.Players:GetPlayers()
	local ActivePlayers = 0
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				ActivePlayers = ActivePlayers + 1
				local player = players[i]
				player.Team = SurvivorTeam
			end
		end
	end
	if ActivePlayers > 1 then
		local SelectedPlayer = SelectPlayer()
		SelectedPlayer.Team = InfectedTeam
	end
end

local InfectedQueue = {}
local InfectedReserve = {}

local function CleanInfectedQueue()
	--print("Pre-InfectedQueue Contents: " .. #InfectedQueue)
	for i = 1, #InfectedQueue do
		--print(InfectedQueue[i])
		if InfectedQueue[i] ~= nil then
			if Players:FindFirstChild(InfectedQueue[i]) == nil then
				table.remove(InfectedQueue, i)
			end
		else
			--print("Nil condition")
		end
	end
	--print("InfectedReserve Contents: " .. #InfectedReserve)
	--print("InfectedQueue Contents: " .. #InfectedQueue)
end

local function AssignTeams() -- Queue
	local TotalPlayers = Players:GetChildren()
	local ActivePlayers = 0
	local FoundPlayer = false
	local InfectedPlayerIndex = 1
	local SelectedPlayer
	CleanInfectedQueue()
	for i = 1, #TotalPlayers do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(TotalPlayers[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[TotalPlayers[i].Name].Value == true then
				ActivePlayers = ActivePlayers + 1
			end
		end
	end
	if ActivePlayers > 1 then
		for i = 1, #InfectedQueue do
			if Players:FindFirstChild(InfectedQueue[i]) ~= nil then
				if ReplicatedStorage.GameData.PlayerStatus[InfectedQueue[i]].Value == true and FoundPlayer == false then
					Players:FindFirstChild(InfectedQueue[i]).Team = InfectedTeam
					InfectedPlayerIndex = i
					FoundPlayer = true
					--print(Players:FindFirstChild(InfectedQueue[i]).Name .. " is infected")
				elseif ReplicatedStorage.GameData.PlayerStatus[InfectedQueue[i]].Value == true and FoundPlayer == true then
					Players:FindFirstChild(InfectedQueue[i]).Team = SurvivorTeam
					--print(Players:FindFirstChild(InfectedQueue[i]).Name .. " is a survivor")
				end
			else
				table.remove(InfectedQueue, i)
				--print("Removed " .. InfectedQueue[i] .. " from list")
			end
		end
		table.insert(InfectedReserve, InfectedQueue[InfectedPlayerIndex])
		table.remove(InfectedQueue, InfectedPlayerIndex)
		table.insert(InfectedQueue, InfectedReserve[1])
		table.remove(InfectedReserve, 1)
	elseif ActivePlayers == 1 then
		for i = 1, #TotalPlayers do
			if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(TotalPlayers[i].Name) ~= nil then
				if ReplicatedStorage.GameData.PlayerStatus[TotalPlayers[i].Name].Value == true then
					TotalPlayers[i].Team = SurvivorTeam
				end
			end 
		end
	end
end



Players.PlayerAdded:Connect(function(Player)
	table.insert(InfectedQueue, Player.Name)
	--print("Added " ..  Player.Name .. " to infected queue")
end)

local function ShowToolbar()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true and players[i].Team == SurvivorTeam then
				players[i].PlayerGui:WaitForChild("BackpackGui").ToolBar.Visible = true
			end
		end
	end
end

local function HideToolbar()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				players[i].PlayerGui:WaitForChild("BackpackGui").ToolBar.Visible = false
			end
		end
	end
end

local function SpawnPlayers()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				local player = players[i]
				player:LoadCharacter()
			end
		end
	end
end

local function MovePlayers()
	local players = game.Players:GetPlayers()
	local SurvivorStartPoints = game.Workspace:WaitForChild("Map"):WaitForChild(SelectedMap):WaitForChild("SurvivorSpawn")
	local InfectedStartPoints = game.Workspace:WaitForChild("Map"):WaitForChild(SelectedMap):WaitForChild("InfectedSpawn")
	local SurvivorSpawns = SurvivorStartPoints:GetChildren()
	local InfectedSpawns = InfectedStartPoints:GetChildren()
	
	local Survivors = {}
	local Infected = {}
	for i = 1, #players do
		if players[i].Team == SurvivorTeam then
			table.insert(Survivors, players[i])
		elseif players[i].Team == InfectedTeam then
			table.insert(Infected, players[i])
		end
	end
	
	local SurvivorSpawnCount = 1
	local InfectedSpawnCount = 1
	while #Survivors > 0 do
		if SurvivorSpawns[SurvivorSpawnCount] ~= nil then
			Survivors[1].Character:MoveTo(SurvivorSpawns[SurvivorSpawnCount].Position)
			Survivors[1].Character:WaitForChild("HumanoidRootPart").Anchored = true
			SurvivorSpawnCount = SurvivorSpawnCount + 1
			table.remove(Survivors, 1)
		else
			SurvivorSpawnCount = 1
			Survivors[1].Character:MoveTo(SurvivorSpawns[SurvivorSpawnCount].Position)
			Survivors[1].Character:WaitForChild("HumanoidRootPart").Anchored = true
			table.remove(Survivors, 1)
		end
	end
	while #Infected > 0 do
		if InfectedSpawns[InfectedSpawnCount] ~= nil then
			Infected[1].Character:MoveTo(InfectedSpawns[InfectedSpawnCount].Position)
			Infected[1].Character:WaitForChild("HumanoidRootPart").Anchored = true
			InfectedSpawnCount = InfectedSpawnCount + 1
			table.remove(Infected, 1)
		else
			InfectedSpawnCount = 1
			Infected[1].Character:MoveTo(InfectedSpawns[InfectedSpawnCount].Position)
			Infected[1].Character:WaitForChild("HumanoidRootPart").Anchored = true
			table.remove(Infected, 1)
		end
	end
	wait()
	for i = 1, #SurvivorSpawns do
		SurvivorSpawns[i]:Destroy()
	end
end

local function UnanchorPlayers()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if players[i].Team == SurvivorTeam or players[i].Team == InfectedTeam then
			players[i].Character:WaitForChild("HumanoidRootPart").Anchored = false
		end
	end
end

local function ChangeCamera(Type)
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				if Type == "Default" then
					ReplicatedStorage.Events.ChangeCamera:FireClient(players[i], Type)
				elseif Type == "Custom" then
					ReplicatedStorage.Events.ChangeCamera:FireClient(players[i], Type)
				end
			end
		end
	end
end

local function IncrementStage(Stage)
	ReplicatedStorage.Events.SoundEffect:FireAllClients("NextStage", "Play")
	ReplicatedStorage.Events.ScreenEffect:FireAllClients("NextStage", "Increment", Stage)
end

local function ApplyMessage()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if players[i].Team == InfectedTeam then
			ReplicatedStorage.Events.ApplyMessage:FireClient(players[i], "Infected", "MASSACRE ALL SURVIVORS")
		elseif players[i].Team == SurvivorTeam then
			if Objective == "Survival" then
				ReplicatedStorage.Events.ApplyMessage:FireClient(players[i], "Survivors", "FIGHT AND SURVIVE")
			end
		end
	end
end

Stage1Time = 720
Stage2Time = 600
Stage3Time = 480
Stage4Time = 360
Stage5Time = 180
if StageTesting == true then
	Stage1Time = 720
	Stage2Time = 718
	Stage3Time = 717
	Stage4Time = 716
	Stage5Time = 715
end
Stage1AI = 30
Stage2AI = 35
Stage3AI = 40
Stage4AI = 45
Stage5AI = 50
if EnableAI == false then
	Stage1AI = 0
	Stage2AI = 0
	Stage3AI = 0
	Stage4AI = 0
	Stage5AI = 0
end

local AICurrent = ServerStorage.Infected.Capacity:WaitForChild("AICurrent")
local AIMax = ServerStorage.Infected.Capacity:WaitForChild("AIMax")
local AICurrent = ServerStorage.Infected.Capacity:WaitForChild("AICurrent")

local function GameTimer()
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Spawn", "Play")
	local Type = "GAME"
	local Timer = GameTime
	local Stage
	while Timer ~= 0 do
		wait(1)
		ReplicatedStorage.Events.UpdateTimer:FireAllClients(formatTime(Timer), Type)
		if Timer == Stage1Time or Timer == Stage2Time or Timer == Stage3Time or Timer == Stage4Time or Timer == Stage5Time then
			if Timer == Stage1Time then
				Stage = 1
				ReplicatedStorage.GameData.Stage.Value = Stage
				AIMax.Value = Stage1AI
			elseif Timer == Stage2Time then -- 720
				Stage = 2
				ReplicatedStorage.GameData.Stage.Value = Stage
				AIMax.Value = Stage2AI
			elseif Timer == Stage3Time then -- 540
				Stage = 3
				ReplicatedStorage.GameData.Stage.Value = Stage
				AIMax.Value = Stage3AI
			elseif Timer == Stage4Time then -- 360
				Stage = 4
				ReplicatedStorage.GameData.Stage.Value = Stage
				AIMax.Value = Stage4AI
			elseif Timer == Stage5Time then -- 180
				Stage = 5
				ReplicatedStorage.GameData.Stage.Value = Stage
				AIMax.Value = Stage5AI
			end
			IncrementStage(Stage)
		end
		if Timer == 897 then
			ApplyMessage()
		end
		Timer = Timer - 1
		if CountAlivePlayers() == 0 then
			Timer = 0 -- CHANGE
			Victory = false
		--[[elseif CountInfected() == 0 then
			Timer = 0
			Victory = true]]
		end
	end
end

local function RemoveMap()
	local Map = game.Workspace.Map:WaitForChild(PrevMap):GetChildren()
	for i = 1, #Map do
		Map[i]:Destroy()
		game:GetService("RunService").Stepped:wait()
	end
	game.Workspace.Map:WaitForChild(PrevMap):Destroy()
end

local function HideGuis()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				players[i].PlayerGui:WaitForChild("MainGui").GameStatus.Visible = true
				players[i].PlayerGui:WaitForChild("MainGui").Objective.Visible = true
				players[i].PlayerGui:WaitForChild("MenuGui").Enabled = false
				players[i].PlayerGui:WaitForChild("MainGui").PlayerBars.Visible = true
				players[i].PlayerGui:WaitForChild("DamageGui").Frame.Visible = true
			end
		end
	end
end

local function ShowGuis()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				players[i].PlayerGui:WaitForChild("MainGui").GameStatus.Visible = false
				players[i].PlayerGui:WaitForChild("MainGui").Objective.Visible = false
				players[i].PlayerGui:WaitForChild("MenuGui").Enabled = true
				players[i].PlayerGui:WaitForChild("MainGui").PlayerBars.Visible = false
				players[i].PlayerGui:WaitForChild("DamageGui").Frame.Visible = false
				if players[i].Team == SurvivorTeam then
				elseif players[i].Team == InfectedTeam then
					players[i].PlayerGui:WaitForChild("InfectedAbilityGui").ToolBar.Visible = false
				end
			end
		end
	end
end

local function GetLoadout()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(players[i].Name) ~= nil then
			if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
				if players[i].Team == SurvivorTeam then
					local Tools = ServerStorage.Tools
					local EquippedFolder = ReplicatedStorage.GameData.PlayerData:WaitForChild(players[i].Name):WaitForChild("Equipment")
					local Primary = EquippedFolder:WaitForChild("Primary").Value
					local Secondary = EquippedFolder:WaitForChild("Secondary").Value
					local Item = EquippedFolder:WaitForChild("Item").Value
					local PrimaryClone
					local SecondaryClone
					local ItemClone
					if players[i].Backpack:FindFirstChildWhichIsA("Tool") == nil then
						ReplicatedStorage.GameData.PlayerStatus[players[i].Name].ToolbarType.Value = "Secondary 1"
						PrimaryClone = Tools:FindFirstChild(Primary):Clone()
						SecondaryClone = Tools:FindFirstChild(Secondary):Clone()
						ItemClone = Tools:FindFirstChild(Item):Clone()
						wait()
						PrimaryClone.Parent = players[i]:WaitForChild("Backpack")
						SecondaryClone.Parent = players[i]:WaitForChild("Backpack")
						ItemClone.Parent = players[i]:WaitForChild("Backpack")
					end
				end
			end
		end
	end
end

local function FadeScreen()
	local players = game.Players:GetPlayers()
	local fadeDuration = 2
	local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
			game:GetService("TweenService"):Create(players[i].PlayerGui.MainGui.Fade, tweenInfo, {BackgroundTransparency = 0}):Play()
		end
	end
end

local function LoadingTheme()
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Load", "Play")
end

local function MapLoadScreen()
	local MapTime = "00:00"
	local MapTemp = 0
	if SelectedMap == "Warzone" then
		local MapHour = math.random(1,4)
		local MapMin = math.random(1,59)
		if MapHour < 10 then
			MapTime = "0" .. MapHour .. ":"
		else
			MapTime = MapHour .. ":" 
		end
		if MapMin < 10 then
			MapTime = MapTime .. "0" .. MapMin .. " AM"
		else
			MapTime = MapTime .. MapMin .. " AM"
		end
		MapTemp = math.random(40, 60)
	elseif SelectedMap == "District" then
		local MapHour = math.random(1,4)
		local MapMin = math.random(1,59)
		if MapHour < 10 then
			MapTime = "0" .. MapHour .. ":"
		else
			MapTime = MapHour .. ":" 
		end
		if MapMin < 10 then
			MapTime = MapTime .. "0" .. MapMin .. " AM"
		else
			MapTime = MapTime .. MapMin .. " AM"
		end
		MapTemp = math.random(60, 70)
	elseif SelectedMap == "Sewers" then
		local MapHour = math.random(1,4)
		local MapMin = math.random(1,59)
		if MapHour < 10 then
			MapTime = "0" .. MapHour .. ":"
		else
			MapTime = MapHour .. ":" 
		end
		if MapMin < 10 then
			MapTime = MapTime .. "0" .. MapMin .. " AM"
		else
			MapTime = MapTime .. MapMin .. " AM"
		end
		MapTemp = math.random(70, 85)
	elseif SelectedMap == "Arctic" then
		local MapHour = math.random(1,4)
		local MapMin = math.random(1,59)
		if MapHour < 10 then
			MapTime = "0" .. MapHour .. ":"
		else
			MapTime = MapHour .. ":" 
		end
		if MapMin < 10 then
			MapTime = MapTime .. "0" .. MapMin .. " AM"
		else
			MapTime = MapTime .. MapMin .. " AM"
		end
		MapTemp = math.random(-50, -20)
	end
	
	ReplicatedStorage.Events.LoadScreen:FireAllClients("Map", "Play", SelectedMap, Objective, MapTime, MapTemp)
end

local function HideMapLoadScreen()
	ReplicatedStorage.Events.LoadScreen:FireAllClients("Map", "Stop", SelectedMap, Objective, "00:00", 0)
end

local function UnfadeScreen()
	local players = game.Players:GetPlayers()
	local fadeDuration = 2
	local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
			game:GetService("TweenService"):Create(players[i].PlayerGui.MainGui.Fade, tweenInfo, {BackgroundTransparency = 1}):Play()
		end
	end
end

local function DisableCameras()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
			if players[i].Team == InfectedTeam then
				if players[i].Character:FindFirstChild("InfectedCamera") ~= nil then
					players[i].Character:FindFirstChild("InfectedCamera"):Destroy()
				end
			end
		end
	end
end

local function HideFade()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
			players[i].PlayerGui.MainGui.Fade.BackgroundTransparency = 1
		end
	end
end

local function StopMusicStart()
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Menu", "Stop")
end

local function StopMusicEnd()
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Spawn", "Stop")
end

local function VictoryScreen()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
			players[i].PlayerGui:WaitForChild("MainGui").PlayerBars.Visible = false
		end
	end
	wait(1)
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Victory", "Play")
	ReplicatedStorage.Events.ScreenEffect:FireAllClients("Victory", "Play", "None")
	wait(10)
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Victory", "Stop")
	ReplicatedStorage.Events.ScreenEffect:FireAllClients("Victory", "Stop", "None")
	wait(1)
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Menu", "Play")
end

local function DefeatScreen()
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if ReplicatedStorage.GameData.PlayerStatus[players[i].Name].Value == true then
			players[i].PlayerGui:WaitForChild("MainGui").PlayerBars.Visible = false
		end
	end
	wait(1)
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Defeat", "Play")
	ReplicatedStorage.Events.ScreenEffect:FireAllClients("Defeat", "Play", "None")
	wait(10)
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Defeat", "Stop")
	ReplicatedStorage.Events.ScreenEffect:FireAllClients("Defeat", "Stop", "None")
	wait(1)
	ReplicatedStorage.Events.SoundEffect:FireAllClients("Menu", "Play")
end

local function ResetGame()
	ReplicatedStorage.Events.ScreenEffect:FireAllClients("NextStage", "Reset", "None")
	ReplicatedStorage.Events.UpdateTimer:FireAllClients(formatTime(0), "GAME")
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(players[i].Name):WaitForChild("FirstTime").Value = true
	end
end

local function RemoveNPC()
	local NPC = game.Workspace.NPC:GetChildren()
	if NPC ~= nil then
		for i = 1, #NPC do
			if NPC[i] ~= nil then
				NPC[i]:Destroy()
			end
		end
	end
end

local function RemoveLoot()
	local Loot = game.Workspace.Loot:GetChildren()
	if Loot ~= nil then
		for i = 1, #Loot do
			if Loot[i] ~= nil then
				Loot[i]:Destroy()
			end
		end
	end
end

local MapCamera = game.Workspace.MapCamera
local function SetMapCam()
	if SelectedMap == "Warzone" then
		MapCamera.Position = Vector3.new(230.695, 82.798, 69.286)
		MapCamera.Orientation = Vector3.new(-15, 60, 0)
	elseif SelectedMap == "District" then
		MapCamera.Position = Vector3.new(-55.4, 160.04, 230.5)
		MapCamera.Orientation = Vector3.new(-15, -30, 0)
	elseif SelectedMap == "Arctic" then
		MapCamera.Position = Vector3.new(-188.305, 106.798, -342.714)
		MapCamera.Orientation = Vector3.new(-15, 60, 0)
	end
end

while true do
	wait()
	LoopStatus = true
	repeat
		if CheckMap() == false then
			wait(10)
			ReplicatedStorage.Events.MenuMessage:FireAllClients("LOADING " .. string.upper(SelectedMap))
			LoadMap()
		end
		while CountReadyPlayers() < 1 do -- 2
			wait()
			NeedPlayer()
			CountReadyPlayers()
			ShowGuis()
		end
		if CountReadyPlayers() > 0 then -- 1
			ReplicatedStorage.GameData.Loading.Value = false
			IntermissionTimer()
			ShowGuis()
			PlayerVerification = true
		else
			PlayerVerification = false
		end
		if PlayerVerification == true then
			if CountReadyPlayers() < 0 then -- 1
				LoopStatus = false
			elseif CountReadyPlayers() > 0 then -- 1
				Victory = true
				StopMusicStart()
				IsLoading = true
				ReplicatedStorage.Events.StatusLock:FireAllClients("Lock")
				ReplicatedStorage.GameData.StatusLocked.Value = true
				SetMapCam()
				wait(1)
				ReplicatedStorage.GameData.NeedPlayer.Value = false
				ReplicatedStorage.Events.MenuMessage:FireAllClients("STARTING GAME")
				AssignTeams()
				FadeScreen()
				AICurrent.Value = 0
				LoadingTheme()
				MapLoadScreen()
				wait(5)
				ReplicatedStorage.GameData.GameActive.Value = true
				SpawnPlayers()
				wait()
				ShowToolbar()
				GetLoadout()
				MovePlayers()
				wait(10)
				ReplicatedStorage.Events.SoundEffect:FireAllClients("Load", "Stop")
				ChangeCamera("Default")
				HideGuis()
				UnanchorPlayers()
				HideMapLoadScreen()
				UnfadeScreen()
				wait()
				IsLoading = false
				ReplicatedStorage.Events.StatusLock:FireAllClients("Unlock")
				ReplicatedStorage.GameData.StatusLocked.Value = false
				GameTimer()
				StopMusicEnd()
				FadeScreen()
				ReplicatedStorage.GameData.GameActive.Value = false
				if Victory == true then
					VictoryScreen()
				else
					DefeatScreen()
				end
				PrevMap = SelectedMap
				HideToolbar()
				ChangeCamera("Custom")
				ShowGuis()
				ResetGame()
				RemoveNPC()
				RemoveLoot()
				Stage = 0
				ReplicatedStorage.GameData.Stage.Value = Stage
				AIMax.Value = 0
				AICurrent.Value = 0
				Loading() -- ReplicatedStorage.GameData.Loading.Value = true 
				MapVotingStart()
				ReplicatedStorage.Events.MenuMessage:FireAllClients("REMOVING PREVIOUS MAP")
				RemoveMap()
			end
		end
	until LoopStatus == false
end