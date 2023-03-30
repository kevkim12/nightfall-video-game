local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SurvivorTeam = game:GetService("Teams"):WaitForChild("Survivors")
local InfectedTeam = game:GetService("Teams"):WaitForChild("Infected")
local AsistanceMarker = ReplicatedStorage.Assets.AssistanceMarker

local SecureEquipmentData = ReplicatedStorage.EquipmentData:Clone()
SecureEquipmentData.Parent = ServerStorage
local SecureCharacterData = ReplicatedStorage.CharacterData:Clone()
SecureCharacterData.Parent = ServerStorage

local SurvivorTag = ReplicatedStorage.Assets.SurvivorTag

local MaleScreams = {232921590, 232921580, 232921573, 166221318, 167094166, 166221285, 166221367, 169907033, 166221396}
local FemaleScreams = {5538537294, 5538539107, 5538544605, 5538540460, 5538546663, 5538547181}
local InfectedScreams = {1158092384, 1158093982, 1158094154, 1158094311, 1158094454, 1158094691}

ReplicatedStorage.Events.RequestAssistance.OnServerEvent:Connect(function(player)
	ReplicatedStorage.Events.RequestResponse:FireAllClients(player.Name)
end)

local function ColorInfectedBody(character)
	local Tones = {Color3.fromRGB(116, 134, 157), Color3.fromRGB(120, 144, 130), Color3.fromRGB(39, 70, 45), Color3.fromRGB(152, 194, 219)}
	local SkinSelection = Tones[math.random(1,#Tones)]
	character:FindFirstChild("Body Colors").HeadColor3 = SkinSelection
	character:FindFirstChild("Body Colors").LeftArmColor3 = SkinSelection
	character:FindFirstChild("Body Colors").RightArmColor3 = SkinSelection
	character:FindFirstChild("Body Colors").LeftLegColor3 = SkinSelection
	character:FindFirstChild("Body Colors").RightLegColor3 = SkinSelection
	character:FindFirstChild("Body Colors").TorsoColor3 = SkinSelection
end

local function ColorSurvivorBody(character, v1, v2, v3)
	character:FindFirstChild("Body Colors").HeadColor3 = Color3.fromRGB(v1, v2, v3)
	character:FindFirstChild("Body Colors").LeftArmColor3 = Color3.new(v1, v2, v3)
	character:FindFirstChild("Body Colors").RightArmColor3 = Color3.new(v1, v2, v3)
	character:FindFirstChild("Body Colors").RightLegColor3 = Color3.new(v1, v2, v3)
	character:FindFirstChild("Body Colors").TorsoColor3 = Color3.new(v1, v2, v3)
end

local function DesertOutfit(character)
	local Number = math.random(1,10)
	local Storage = game.ServerStorage.Infected.Accessories["Desert Wartorn"]
	local ClothingContent = Storage["Outfit"..Number]:GetChildren()
	for i = 1, #ClothingContent do
		ClothingContent[i]:Clone().Parent = character
	end
	local FaceId = {6797440099, 6797440388, 6797455282, 6797460023, 6797465110, 6797472035, 6797477271}
	local Val = FaceId[math.random(1,#FaceId)]
	character.Head:WaitForChild("face").Texture = ("rbxassetid://" .. Val)
end

game.Players.PlayerAdded:connect(function(Player)
	local ReadyValue = Instance.new("BoolValue")
	ReadyValue.Parent = ReplicatedStorage.GameData:WaitForChild("PlayerStatus")
	ReadyValue.Value = false
	ReadyValue.Name = Player.Name
	
	local VoteStatus = Instance.new("BoolValue")
	VoteStatus.Parent = ReplicatedStorage.GameData:WaitForChild("PlayerStatus")
	VoteStatus.Value = false
	VoteStatus.Name = "MapVote"
	VoteStatus.Parent = ReadyValue
	
	local PlayerSquad = ServerStorage:WaitForChild("Content").PlayerSquad:Clone()
	PlayerSquad.Name = Player.Name
	PlayerSquad.Parent = ReplicatedStorage.GameData:WaitForChild("PlayerSquad")
	local PlayerData = ServerStorage:WaitForChild("Content").PlayerData:Clone()
	PlayerData.Name = Player.Name
	PlayerData.Parent = ReplicatedStorage.GameData:WaitForChild("PlayerData")
	
	local PlayerEnergy = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("PlayerEnergy")
	local PlayerEnergyValue = Instance.new("IntValue")
	PlayerEnergyValue.Name = Player.Name
	PlayerEnergyValue.Parent = PlayerEnergy
	
	local PlayerStamina = ReplicatedStorage:WaitForChild("GameData"):WaitForChild("PlayerStamina")
	local PlayerStaminaValue = Instance.new("IntValue")
	PlayerStaminaValue.Name = Player.Name
	PlayerStaminaValue.Parent = PlayerStamina
	
	local FirstTimeValue = Instance.new("BoolValue")
	FirstTimeValue.Parent = ReadyValue
	FirstTimeValue.Value = true
	FirstTimeValue.Name = "FirstTime"
	local ClassValue = Instance.new("StringValue")
	ClassValue.Parent = ReadyValue
	ClassValue.Name = "ClassValue"
	local BackpackType = Instance.new("StringValue")
	BackpackType.Parent = ReadyValue
	BackpackType.Value = "None"
	BackpackType.Name = "ToolbarType"
	
	ReplicatedStorage.Events.ToggleReady.OnServerEvent:Connect(function(player, isReady)
		game.ReplicatedStorage.Events.PlayerStatus:FireAllClients(player.Name, isReady)
		if Player.Name == player.Name then
			if isReady == true then
				ReplicatedStorage.GameData.PlayerStatus[player.Name].Value = true
				if ReplicatedStorage.GameData.GameActive.Value == true then
					player.Team = InfectedTeam
					player:LoadCharacter()
					player.PlayerGui:WaitForChild("MainGui").GameStatus.Visible = true
					player.PlayerGui:WaitForChild("MainGui").Objective.Visible = true
					player.PlayerGui:WaitForChild("MenuGui").Enabled = false
					player.PlayerGui:WaitForChild("MainGui").PlayerBars.Visible = true
					player.PlayerGui:WaitForChild("DamageGui").Frame.Visible = true
					local SelectedMap = ServerStorage.Maps.MapData.CurrentMap.Value
					local InfectedStartPoints = game.Workspace:WaitForChild("Map"):WaitForChild(SelectedMap):WaitForChild("InfectedSpawn")
					local InfectedSpawns = InfectedStartPoints:GetChildren()
					player.Character:MoveTo(InfectedSpawns[math.random(1,#InfectedSpawns)].Position)
					ReplicatedStorage.Events.ChangeCamera:FireClient(player, "Default")
					ReplicatedStorage.Events.UpdateStages:FireClient(player, ReplicatedStorage.GameData.Stage.Value)
					ReplicatedStorage.Events.SoundEffect:FireClient(player, "Menu", "Stop")
					ReplicatedStorage.Events.SoundEffect:FireClient(player, "Spawn", "Play")
					if ServerStorage.Maps.MapData.WeatherActive.Value == true then
						ReplicatedStorage.Events.Weather:FireClient(Player, ServerStorage.Maps.MapData.Weather.Value, "Start 2")
					end
				end
			elseif isReady == false then
				ReplicatedStorage.GameData.PlayerStatus[player.Name].Value = false
			end
		end
	end)
	
	ReplicatedStorage.Events.Party.OnServerEvent:Connect(function(player, Command)
		if Player.Name == player.Name then
			if Command == "Create" then
				ReplicatedStorage.GameData.PlayerSquad:FindFirstChild(Player.Name).PartyOwner.Value = true
				ReplicatedStorage.GameData.PlayerSquad:FindFirstChild(Player.Name).InParty.Value = true
			elseif Command == "Leave" then
				ReplicatedStorage.GameData.PlayerSquad:FindFirstChild(Player.Name).PartyOwner.Value = false
				ReplicatedStorage.GameData.PlayerSquad:FindFirstChild(Player.Name).InParty.Value = false
			end
		end
	end)
	
	Player:GetPropertyChangedSignal("Team"):Connect(function()
		ReplicatedStorage.Events.TeamChange:FireAllClients(Player, Player.Team)
	end)
	
	Player.CharacterAdded:connect(function(Character)
		wait()
		if Player.Team == SurvivorTeam then
			ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("FirstTime").Value = false
			Player.PlayerGui.MainGui.PlayerBars.HealthBar.Visible = true
			local ScarsClone = ServerStorage.Content.Scripts.Scars:Clone()
			ScarsClone.Parent = Character
			local DeathFaceClone = ServerStorage.Content.Scripts.DeathFace:Clone()
			DeathFaceClone.Parent = Character
			local ClothesChildren = ServerStorage.CharacterContent.Clothes[ReplicatedStorage.GameData.PlayerData[Player.Name].Character.Clothes.Value]:GetChildren()
			local HeadChildren = ServerStorage.CharacterContent.Head[ReplicatedStorage.GameData.PlayerData[Player.Name].Character.Head.Value]:GetChildren()
			for i = 1, #ClothesChildren do
				local ClothesClone = ClothesChildren[i]:Clone()
				ClothesClone.Parent = Character
			end
			for i = 1, #HeadChildren do
				local HeadClone = HeadChildren[i]:Clone()
				HeadClone.Parent = Character
			end
			Character.Head:WaitForChild("face").Texture = ReplicatedStorage.CharacterData.Face[ReplicatedStorage.GameData.PlayerData[Player.Name].Character.Face.Value].Icon.Value
			local Tone = ReplicatedStorage.GameData.PlayerData[Player.Name].Character["Skin Tone"].Value
			if Tone == "Option1" then
				ColorSurvivorBody(Character, 255, 216, 185)
			elseif Tone == "Option2" then
				ColorSurvivorBody(Character, 255, 207, 169)
			elseif Tone == "Option3" then
				ColorSurvivorBody(Character, 255, 208, 164)
			elseif Tone == "Option4" then
				ColorSurvivorBody(Character, 245, 197, 148)
			elseif Tone == "Option5" then
				ColorSurvivorBody(Character, 245, 187, 136)
			elseif Tone == "Option6" then
				ColorSurvivorBody(Character, 245, 182, 130)
			elseif Tone == "Option7" then
				ColorSurvivorBody(Character, 201, 156, 125)
			elseif Tone == "Option8" then
				ColorSurvivorBody(Character, 178, 126, 89)
			elseif Tone == "Option9" then
				ColorSurvivorBody(Character, 150, 104, 70)
			elseif Tone == "Option10" then
				ColorSurvivorBody(Character, 100, 68, 47)
			elseif Tone == "Option11" then
				ColorSurvivorBody(Character, 76, 50, 35)
			elseif Tone == "Option12" then
				ColorSurvivorBody(Character, 57, 35, 21)
			end
			local ID = MaleScreams[math.random(1,#MaleScreams)]
			Character.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
			Character.TEAM.Value = "Survivors"
			SurvivorTag:Clone().Parent = Character.Head
			Character.Class.Value = "Survivor"
			Player.PlayerGui:WaitForChild("DamageGui").Frame.Visible = true
			local InteractScript = ServerStorage.Classes.Survivor.Interact:Clone()
			InteractScript.Parent = Player.PlayerGui
			local AnimationClone = game.ServerStorage.Classes.Survivor.Animate:Clone()
			AnimationClone.Parent = Character
		end
		if Player.Team == game.Teams:WaitForChild("Infected") then
			Player.PlayerGui:WaitForChild("DamageGui").Frame.Visible = true
			Player.PlayerGui.MainGui.PlayerBars.HealthBar.Visible = true
			local InfectedCameraClone = game.ServerStorage.Infected.InfectedCamera:Clone()
			InfectedCameraClone.Parent = Character
			if ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("FirstTime").Value == true then
				ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("FirstTime").Value = false
				if game.ReplicatedStorage.GameData.Theme.Value == "Desert Wartorn" then
					local ZombieChance = math.random(1, 12)
					if ZombieChance >= 1 and ZombieChance <= 4 then
						local BasicAttackClone = game.ServerStorage.Classes.Runner.Attack:Clone()
						BasicAttackClone.Parent = Player.Backpack
						local AnimationClone = game.ServerStorage.Classes.Runner.Animate:Clone()
						AnimationClone.Parent = Character
						if Character:FindFirstChild("Shirt") ~= nil then
							Character:WaitForChild("Shirt"):Destroy()
						end
						if Character:FindFirstChild("Pants") ~= nil then
							Character:WaitForChild("Pants"):Destroy()
						end
						ColorInfectedBody(Character)
						Character:WaitForChild("Humanoid").WalkSpeed = 22
						wait()
						DesertOutfit(Character)
						ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("ClassValue").Value = "Runner"
						Character.Class.Value = "Runner"
					else
						local BasicAttackClone = game.ServerStorage.Classes.Walker.Attack:Clone()
						BasicAttackClone.Parent = Player.Backpack
						local AnimationClone = game.ServerStorage.Classes.Walker.Animate:Clone()
						AnimationClone.Parent = Character
						if Character:FindFirstChild("Shirt") ~= nil then
							Character:WaitForChild("Shirt"):Destroy()
						end
						if Character:FindFirstChild("Pants") ~= nil then
							Character:WaitForChild("Pants"):Destroy()
						end
						ColorInfectedBody(Character)
						Character:WaitForChild("Humanoid").WalkSpeed = 17
						wait()
						DesertOutfit(Character)
						ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("ClassValue").Value = "Walker"
						Character.Class.Value = "Walker"
					end
					local ID = InfectedScreams[math.random(1,#InfectedScreams)]
					Character.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
					Character.TEAM.Value = "Infected"
				end
			elseif ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("ClassValue").Value == "Bloater" then
				Player.PlayerGui:WaitForChild("InfectedChooser").Enabled = false
				game.ReplicatedStorage.Events.ChangeCamera:FireClient(Player, "Reset")
			elseif ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("ClassValue").Value == "Wrecker" then
				Player.PlayerGui:WaitForChild("InfectedChooser").Enabled = false
				game.ReplicatedStorage.Events.ChangeCamera:FireClient(Player, "Reset")
			elseif ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("ClassValue").Value == "Ravager" then
				Player.PlayerGui:WaitForChild("InfectedChooser").Enabled = false
				game.ReplicatedStorage.Events.ChangeCamera:FireClient(Player, "Reset")
			else
				Player.PlayerGui:WaitForChild("InfectedChooser").Enabled = true
				game.ReplicatedStorage.Events.ChangeCamera:FireClient(Player, "Custom 1")
				ReplicatedStorage.Events.InfectedScreen:FireAllClients(Player.Name)
				Player.PlayerGui.InfectedAbilityGui.ToolBar.Visible = false
				Player.PlayerGui.MainGui.PlayerBars.HealthBar.Visible = false
			end
		end
		repeat wait() until Character:FindFirstChild("Humanoid") ~= nil
		Character.Humanoid.Died:connect(function()
			if Player.Team == SurvivorTeam then
				ReplicatedStorage.Events.PlayerDeath:FireAllClients(Player.Name)
				Player.Team = InfectedTeam
				local DeathMarkerClone = ReplicatedStorage.Assets.DeathMarker:Clone()
				DeathMarkerClone.Parent = Character:WaitForChild("Head")
				Character.Head:WaitForChild("SurvivorTag"):Destroy()
			elseif Player.Team == InfectedTeam then
				if ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(Player.Name):WaitForChild("ClassValue").Value == "Bloater" then
					Character.Torso.Mesh.MeshId = "rbxassetid://36780113"
				end
			end
			Character.Head:WaitForChild("Death"):Play()
			local Tag = Character.Humanoid:FindFirstChild("creator")
			local Class = Character:FindFirstChild("Class")
			if Tag ~= nil and Class ~= nil then
				if Tag.Value ~= nil and Class.Value ~= nil then
					ReplicatedStorage.Events.RequestReward:Fire("Kill", Tag.Value, Class.Value)
				end 
			end
		end)
	end)
end)

game.Players.PlayerRemoving:Connect(function(Player)
	local ReadyValue = ReplicatedStorage.GameData.PlayerStatus:FindFirstChild(Player.Name)
	local DataFolder = ReplicatedStorage.GameData.PlayerData:FindFirstChild(Player.Name)
	local SquadFolder = ReplicatedStorage.GameData.PlayerSquad:FindFirstChild(Player.Name)
	local PlayerEnergy = ReplicatedStorage.GameData.PlayerEnergy:FindFirstChild(Player.Name)
	local PlayerStamina = ReplicatedStorage.GameData.PlayerStamina:FindFirstChild(Player.Name)
	if ReadyValue ~= nil then
		ReadyValue:Destroy()
	end
	if DataFolder ~= nil then
		DataFolder:Destroy()
	end
	if SquadFolder ~= nil then
		SquadFolder:Destroy()
	end
	if PlayerEnergy ~= nil then
		PlayerEnergy:Destroy()
	end
	if PlayerStamina ~= nil then
		PlayerStamina:Destroy()
	end
end)