local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local SetSubject = ReplicatedStorage.SetSubject
local InfectedAbilityFunction = ReplicatedStorage.Functions.InfectedAbility
local InfectedAbilityResult = ReplicatedStorage.Events.InfectedAbilityResult

local SurvivorTeam = game:GetService("Teams"):WaitForChild("Survivors")
local InfectedTeam = game:GetService("Teams"):WaitForChild("Infected")

local InfectedScreams = {1158092384, 1158093982, 1158094154, 1158094311, 1158094454, 1158094691}

local function Tween(Object, Time, Customization)
	game:GetService("TweenService"):Create(Object, TweenInfo.new(Time), Customization):Play()
end

local function decimalRandom(minimum, maximum)
	return math.random()*(maximum-minimum) + minimum
end

local function ColorBody(Character)
	local Tones = {Color3.fromRGB(116, 134, 157), Color3.fromRGB(120, 144, 130), Color3.fromRGB(39, 70, 45), Color3.fromRGB(152, 194, 219)}
	local SkinSelection = Tones[math.random(1,#Tones)]
	Character:WaitForChild("Body Colors").HeadColor3 = SkinSelection
	Character:WaitForChild("Body Colors").LeftArmColor3 = SkinSelection
	Character:WaitForChild("Body Colors").RightArmColor3 = SkinSelection
	Character:WaitForChild("Body Colors").LeftLegColor3 = SkinSelection
	Character:WaitForChild("Body Colors").RightLegColor3 = SkinSelection
	Character:WaitForChild("Body Colors").TorsoColor3 = SkinSelection
end

local function ColorBodyHeavy(Character)
	local SkinSelection = Color3.fromRGB(163, 162, 165)
	Character:WaitForChild("Body Colors").HeadColor3 = SkinSelection
	Character:WaitForChild("Body Colors").LeftArmColor3 = SkinSelection
	Character:WaitForChild("Body Colors").RightArmColor3 = SkinSelection
	Character:WaitForChild("Body Colors").LeftLegColor3 = SkinSelection
	Character:WaitForChild("Body Colors").RightLegColor3 = SkinSelection
	Character:WaitForChild("Body Colors").TorsoColor3 = SkinSelection
end

local function DesertOutfit(character, Special)
	if Special == "Bloater" then
		local Number = math.random(1,5)
		local Storage = game.ServerStorage.Infected.Accessories["Desert Wartorn"]
		local ClothingContent = Storage["Outfit"..Number]:GetChildren()
		for i = 1, #ClothingContent do
			ClothingContent[i]:Clone().Parent = character
		end
		local FaceId = {6797440099, 6797440388, 6797455282, 6797460023, 6797465110, 6797472035, 6797477271}
		local Val = FaceId[math.random(1,#FaceId)]
		character.Head:WaitForChild("face").Texture = ("rbxassetid://" .. Val)
	elseif Special == "Ravager" or Special == "Wrecker" then
		local Number = math.random(1,5)
		local Storage = game.ServerStorage.Infected.Accessories["Desert Wartorn"]
		local ClothingContent = Storage["Outfit"..Number]:GetChildren()
		for i = 1, #ClothingContent do
			if ClothingContent[i]:IsA("Shirt") or ClothingContent[i]:IsA("Pants") then
				ClothingContent[i]:Clone().Parent = character
			end
		end
		local FaceId = {6797440099, 6797440388, 6797455282, 6797460023, 6797465110, 6797472035, 6797477271}
		local Val = FaceId[math.random(1,#FaceId)]
		character.Head:WaitForChild("face").Texture = ("rbxassetid://" .. Val)
	else
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
end

ReplicatedStorage.Events.InfectedSelection.OnServerEvent:Connect(function(plr, PlayerName, InfectedClass)
	local players = game.Players:GetPlayers()
	for i = 1, #players do
		if players[i].Name == PlayerName then
			local Character = players[i].Character
			if InfectedClass == "Walker" then
				local BasicAttackClone = game.ServerStorage.Classes.Walker.Attack:Clone()
				BasicAttackClone.Parent = players[i].Backpack
				local AnimationClone = game.ServerStorage.Classes.Walker.Animate:Clone()
				AnimationClone.Parent = Character
				if Character:FindFirstChild("Shirt") ~= nil then
					Character:WaitForChild("Shirt"):Destroy()
				end
				if Character:FindFirstChild("Pants") ~= nil then
					Character:WaitForChild("Pants"):Destroy()
				end
				ColorBody(Character)
				Character:WaitForChild("Humanoid").WalkSpeed = 18
				wait()
				DesertOutfit(Character, "None")
				ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = "Walker"
				Character.Class.Value = "Walker"
				local ID = InfectedScreams[math.random(1,#InfectedScreams)]
				Character.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
				Character.TEAM.Value = "Infected"
				Character.Class.Value = InfectedClass
				plr.PlayerGui:WaitForChild("InfectedAbilityGui").ToolBar.Visible = false
			elseif InfectedClass == "Runner" then
				local BasicAttackClone = game.ServerStorage.Classes.Runner.Attack:Clone()
				BasicAttackClone.Parent = players[i].Backpack
				local AnimationClone = game.ServerStorage.Classes.Runner.Animate:Clone()
				AnimationClone.Parent = Character
				if Character:FindFirstChild("Shirt") ~= nil then
					Character:WaitForChild("Shirt"):Destroy()
				end
				if Character:FindFirstChild("Pants") ~= nil then
					Character:WaitForChild("Pants"):Destroy()
				end
				ColorBody(Character)
				Character:WaitForChild("Humanoid").WalkSpeed = 22
				wait()
				DesertOutfit(Character, "None")
				ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = "Runner"
				Character.Class.Value = "Runner"
				local ID = InfectedScreams[math.random(1,#InfectedScreams)]
				Character.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
				Character.TEAM.Value = "Infected"
				Character.Class.Value = InfectedClass
				plr.PlayerGui:WaitForChild("InfectedAbilityGui").ToolBar.Visible = false
			elseif InfectedClass == "Bloater" then
				local CurrentCharacter = players[i].Character
				local ChosenCharacter = ServerStorage.Infected.Rigs.Bloater:Clone()
				ChosenCharacter.Name = players[i].Name
				ChosenCharacter.Parent = workspace
				players[i].Character = ChosenCharacter
				SetSubject:FireClient(players[i],ChosenCharacter.Humanoid)
				local BasicAttackClone = game.ServerStorage.Classes.Bloater.Attack:Clone()
				BasicAttackClone.Parent = players[i].Backpack
				local AnimationClone = game.ServerStorage.Classes.Bloater.Animate:Clone()
				AnimationClone.Parent = ChosenCharacter
				local BloaterExplosionClone = game.ServerStorage.Classes.Bloater.BloaterExplosion:Clone()
				BloaterExplosionClone.Parent = ChosenCharacter
				BloaterExplosionClone.Disabled = false
				ColorBody(ChosenCharacter)
				DesertOutfit(ChosenCharacter, "Bloater")
				ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = "Bloater"
				Character.Class.Value = "Bloater"
				local ID = InfectedScreams[math.random(1,#InfectedScreams)]
				ChosenCharacter.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
				ChosenCharacter.TEAM.Value = "Infected"
				ChosenCharacter.Class.Value = InfectedClass
				plr.PlayerGui:WaitForChild("InfectedAbilityGui").ToolBar.Visible = true
				local Connection

				local function onDied()
					wait(game.Players.RespawnTime)
					ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = ""
					players[i]:LoadCharacter()
					if Connection then
						Connection:Disconnect()
					end
				end

				Connection = ChosenCharacter.Humanoid.Died:Connect(onDied)
			elseif InfectedClass == "Wrecker" then
				local CurrentCharacter = players[i].Character
				local ChosenCharacter = ServerStorage.Infected.Rigs.Wrecker:Clone()
				ChosenCharacter.Name = players[i].Name
				ChosenCharacter.Parent = workspace
				players[i].Character = ChosenCharacter
				SetSubject:FireClient(players[i],ChosenCharacter.Humanoid)
				local BasicAttackClone = game.ServerStorage.Classes.Wrecker.Attack:Clone()
				BasicAttackClone.Parent = players[i].Backpack
				local AnimationClone = game.ServerStorage.Classes.Wrecker.Animate:Clone()
				AnimationClone.Parent = ChosenCharacter
				ColorBodyHeavy(ChosenCharacter)
				DesertOutfit(ChosenCharacter, InfectedClass)
				ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = InfectedClass
				Character.Class.Value = "Wrecker"
				local ID = InfectedScreams[math.random(1,#InfectedScreams)]
				ChosenCharacter.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
				ChosenCharacter.TEAM.Value = "Infected"
				ChosenCharacter.Class.Value = InfectedClass
				local Connection
				ReplicatedStorage.Events.WarningMessage:FireAllClients("Wrecker")
				local function onDied()
					wait(game.Players.RespawnTime)
					ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = ""
					players[i]:LoadCharacter()
					if Connection then
						Connection:Disconnect()
					end
				end
				plr.PlayerGui:WaitForChild("InfectedAbilityGui").ToolBar.Visible = true
				Connection = ChosenCharacter.Humanoid.Died:Connect(onDied)
			elseif InfectedClass == "Ravager" then
				local CurrentCharacter = players[i].Character
				local ChosenCharacter = ServerStorage.Infected.Rigs.Ravager:Clone()
				ChosenCharacter.Name = players[i].Name
				ChosenCharacter.Parent = workspace
				players[i].Character = ChosenCharacter
				SetSubject:FireClient(players[i],ChosenCharacter.Humanoid)
				local BasicAttackClone = game.ServerStorage.Classes.Ravager.Attack:Clone()
				BasicAttackClone.Parent = players[i].Backpack
				local AnimationClone = game.ServerStorage.Classes.Ravager.Animate:Clone()
				AnimationClone.Parent = ChosenCharacter
				ColorBodyHeavy(ChosenCharacter)
				DesertOutfit(ChosenCharacter, InfectedClass)
				ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = InfectedClass
				Character.Class.Value = "Ravager"
				local ID = InfectedScreams[math.random(1,#InfectedScreams)]
				ChosenCharacter.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
				ChosenCharacter.TEAM.Value = "Infected"
				ChosenCharacter.Class.Value = InfectedClass
				local Connection
				ReplicatedStorage.Events.WarningMessage:FireAllClients("Ravager")
				local function onDied()
					wait(game.Players.RespawnTime)
					ReplicatedStorage.GameData:WaitForChild("PlayerStatus"):WaitForChild(PlayerName):WaitForChild("ClassValue").Value = ""
					players[i]:LoadCharacter()
					if Connection then
						Connection:Disconnect()
					end
				end
				plr.PlayerGui:WaitForChild("InfectedAbilityGui").ToolBar.Visible = true
				Connection = ChosenCharacter.Humanoid.Died:Connect(onDied)
			end
			players[i].PlayerGui:WaitForChild("InfectedChooser").Enabled = false
		end
	end
end)

ReplicatedStorage.Events.RequestSpawn.OnServerEvent:Connect(function(plr)
	if plr.Team == InfectedTeam then
		local Players = game.Players:GetPlayers()
		local InfectedStartPoints = game.Workspace:WaitForChild("Map"):WaitForChild(ServerStorage.Maps.MapData.CurrentMap.Value):WaitForChild("InfectedSpawn"):GetChildren()
		local InfectedNumber = math.random(1, #InfectedStartPoints)
		local ClosestSpawnPoint = InfectedStartPoints[InfectedNumber]
		local Survivors = {}
		for i = 1, #Players do
			if Players[i].Team == SurvivorTeam then
				table.insert(Survivors, Players[i])
			end
		end
		for i = 1, #InfectedStartPoints do
			for j = 1, #Survivors do
				if (Survivors[j].Character.HumanoidRootPart.Position - InfectedStartPoints[i].Position).Magnitude < (ClosestSpawnPoint.Position).Magnitude then
					ClosestSpawnPoint = InfectedStartPoints[i]
				end
			end
		end
		plr.Character:MoveTo(ClosestSpawnPoint.Position)
		Survivors = nil
		--[[
		local Count = #InfectedStartPoints
		local InfectedNumber = math.random(1, Count)
		plr.Character:MoveTo(InfectedStartPoints[InfectedNumber].Position)]]
	end
end)

local InfectedAbility = ReplicatedStorage.Events.InfectedAbility
local CraterCreator = require(ServerStorage.Modules.CraterModule)
InfectedAbility.OnServerEvent:Connect(function(Player, Class, Ability)
	if Class == "Wrecker" then
		if Ability == "Charge" then
			Player.Character.Humanoid.WalkSpeed = 60
			Player.Character.Humanoid.JumpPower = 0
			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://10620281137"
			local playAnim = Player.Character.Humanoid:LoadAnimation(anim)
			playAnim:Play()
			local ScreamSound = Instance.new("Sound")
			ScreamSound.Parent = Player.Character.Head
			ScreamSound.SoundId = "rbxassetid://1981263954"
			ScreamSound.PlaybackSpeed = decimalRandom(0.8, 1)
			local Equalizer = Instance.new("EqualizerSoundEffect")
			Equalizer.Parent = ScreamSound
			ScreamSound:Play()
			local Impact = false
			local CrashSound = Instance.new("Sound")
			CrashSound.SoundId = "rbxassetid://3923230963"
			CrashSound.Parent = Player.Character.Torso
			wait(1)
			Player.Character["Right Arm"].Touched:Connect(function(hit)
				if hit.Parent:FindFirstChild("Humanoid") and Impact == false then
					Impact = true
					Player.Character.Humanoid.WalkSpeed = 17
					Player.Character.Humanoid.JumpPower = 50
					playAnim:Stop()
					InfectedAbilityResult:FireClient(Player, Class, Ability)
					local RaycastCheck = 1

					local RayOrigin = hit.Parent.Torso.Position
					local RayDirection = Vector3.new(0, -100, 0) 

					local Params = RaycastParams.new()
					Params.FilterType = Enum.RaycastFilterType.Blacklist
					Params.FilterDescendantsInstances = {Player.Character}

					local Result = workspace:Raycast(RayOrigin, RayDirection, Params)

					CraterCreator.Create(8,Result.Position,3)
					
					local DebrisPart = Instance.new("Part")
					DebrisPart.Size = Vector3.new(.2,.2,.2)
					DebrisPart.Anchored = true
					DebrisPart.CanCollide = false
					DebrisPart.Transparency = 1
					DebrisPart.Position = Result.Position
					DebrisPart.Parent = workspace.Debris


					if hit.Parent.Name ~= "Infected_AI" then
						local EnemyPlayer = game.Players:GetPlayerFromCharacter(hit.Parent)
						if EnemyPlayer then
							if EnemyPlayer.Team ~= InfectedTeam then
								EnemyPlayer.Character.Humanoid.Health = 0
								local Debris = ReplicatedStorage.Assets.ImpactBlood:Clone()
								Debris.Parent = DebrisPart
							end
						end
					end
					CrashSound:Play()
					wait(1)
					DebrisPart:Destroy()
				elseif (hit:IsA("Part") or hit:IsA("MeshPart") or hit:IsA("UnionOperation")) and not hit.Parent:FindFirstChild("Humanoid") and hit.CanCollide == true and Impact == false then
					Impact = true
					Player.Character.Humanoid.WalkSpeed = 17
					Player.Character.Humanoid.JumpPower = 50
					playAnim:Stop()
					InfectedAbilityResult:FireClient(Player, Class, Ability)
					local RaycastCheck = 1

					local RayOrigin = Player.Character.HumanoidRootPart.Position
					local RayDirection = Vector3.new(0, -100, 0) 

					local Params = RaycastParams.new()
					Params.FilterType = Enum.RaycastFilterType.Blacklist
					Params.FilterDescendantsInstances = {Player.Character}

					local Result = workspace:Raycast(RayOrigin, RayDirection, Params)

					CraterCreator.Create(8,Result.Position,3)
					Player.Character.Humanoid.Health = Player.Character.Humanoid.Health - 50
					CrashSound:Play()
				end
			end)
			wait(3)
			playAnim:Destroy()
			CrashSound:Destroy()
			ScreamSound:Destroy()
		end
	elseif Class == "Ravager" then
		if Ability == "Super Jump" then
			Player.Character.Humanoid.JumpPower = 150
			Player.Character.Humanoid.Jump = true
			wait()
			Player.Character.Humanoid.JumpPower = 50
		elseif Ability == "Super Jump Land" then
			local RaycastCheck = 1

			local RayOrigin = Player.Character.HumanoidRootPart.Position
			local RayDirection = Vector3.new(0, -100, 0) 

			local Params = RaycastParams.new()
			Params.FilterType = Enum.RaycastFilterType.Blacklist
			Params.FilterDescendantsInstances = {Player.Character}

			local Result = workspace:Raycast(RayOrigin, RayDirection, Params)

			local anim = Instance.new("Animation")
			anim.AnimationId = "rbxassetid://10598905766"
			local playAnim = Player.Character.Humanoid:LoadAnimation(anim)
			playAnim:Play()

			local SmashSound = Instance.new("Sound")
			SmashSound.SoundId = "rbxassetid://3923230963"
			SmashSound.Parent = Player.Character.Torso
			SmashSound:Play()

			local DebrisPart = Instance.new("Part")
			DebrisPart.Size = Vector3.new(.2,.2,.2)
			DebrisPart.Anchored = true
			DebrisPart.CanCollide = false
			DebrisPart.Transparency = 1
			DebrisPart.Position = Result.Position
			DebrisPart.Parent = workspace.Debris

			local Debris = ReplicatedStorage.Assets.RavagerSmashDebris:Clone()
			Debris.Parent = DebrisPart

			playAnim:GetMarkerReachedSignal("Start"):Connect(function(value)
				Player.Character.HumanoidRootPart.Anchored = true
			end)
			playAnim:GetMarkerReachedSignal("Finish"):Connect(function(value)
				Player.Character.HumanoidRootPart.Anchored = false
				Debris.Enabled = false
				wait(2)
				DebrisPart:Destroy()
			end)

			local NewExplosion = Instance.new("Explosion")
			NewExplosion.BlastPressure = 0
			NewExplosion.BlastRadius = 5
			NewExplosion.ExplosionType = "NoCraters"
			NewExplosion.Parent = game.Workspace.Debris
			NewExplosion.Position = Result.Position
			NewExplosion.Visible = false
			local HitOnce = false


			NewExplosion.Hit:Connect(function(HitPart, PartDistance)
				local HumanoidValue = HitPart.Parent:FindFirstChildOfClass('Humanoid')
				if HumanoidValue ~= nil then
					local PlayerValue = game.Players:GetPlayerFromCharacter(HitPart.Parent)
					if PlayerValue ~= nil then
						if PlayerValue.Team ~= InfectedTeam and HitOnce == false and HumanoidValue.Parent.Name ~= "Infected_AI" then
							HitOnce = true
							HumanoidValue:TakeDamage(65)
						end
					end
				end
			end)

			if Result then
				CraterCreator.Create(8,Result.Position,3)
				wait()
				wait(2)
				SmashSound:Destroy()
				HitOnce = false
			end
		end
	elseif Class == "Bloater" then
		if Ability == "Explode" then
			Player.Character.Humanoid.Health = 0
		elseif Ability == "Gas" then
			local Effect = ReplicatedStorage.Assets.BloaterAreaGas:Clone()
			Effect.Parent = Player.Character.Torso
			local GasSound = Instance.new("Sound")
			GasSound.SoundId = "rbxassetid://137065982"
			GasSound.Parent = Player.Character.Torso
			GasSound.Looped = true
			GasSound:Play()
			local BloaterGasRadius = ReplicatedStorage.Assets.BloaterGasRadius:Clone()
			local Weld = Instance.new("WeldConstraint")
			Weld.Part0 = Player.Character.Torso
			Weld.Part1 = BloaterGasRadius
			Weld.Parent = Weld.Part0
			BloaterGasRadius.Parent = Player.Character.Torso
			BloaterGasRadius.Position = Player.Character.Torso.Position
			for i = 1, 60 do
				wait(1)
			end
			Tween(GasSound, 2, {Volume = 0});
			wait(2)
			GasSound:Destroy()
			BloaterGasRadius:Destroy()
			Effect:Destroy()
		end
	end
end)

InfectedAbilityFunction.OnServerInvoke = function(Player, Class, Ability)
	if Class == "Wrecker" then
		if Ability == "Slam" then
			for i,enemy in pairs(workspace:GetChildren()) do 
				if not enemy:FindFirstChild("Humanoid") then ---if its not a dummy end the script
				elseif enemy:FindFirstChild("Humanoid") ~= nil then
					if game.Players:GetPlayerFromCharacter(enemy) ~= nil then
						if (Player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude <= 10 and enemy.Name ~= Player.Name then
							local mainChar = Player.Character
							mainChar.Humanoid.WalkSpeed = 0
							enemy.Humanoid.WalkSpeed = 0
							mainChar.HumanoidRootPart.CFrame = CFrame.new(mainChar.HumanoidRootPart.Position,Vector3.new(enemy.HumanoidRootPart.Position.X,mainChar.HumanoidRootPart.Position.Y,enemy.HumanoidRootPart.Position.Z)) ---make plr face the dummy
							enemy.HumanoidRootPart.CFrame = mainChar.HumanoidRootPart.CFrame * CFrame.new(0,0,-6) -- position the dummy to teleport to 5 stud from you
							enemy.HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position,Vector3.new(mainChar.HumanoidRootPart.Position.X,enemy.HumanoidRootPart.Position.Y,mainChar.HumanoidRootPart.Position.Z)) ---make dummy face the plr

							mainChar.HumanoidRootPart.Anchored = true
							enemy.HumanoidRootPart.Anchored = true

							local Animation1 = Instance.new("Animation")
							Animation1.AnimationId = "rbxassetid://10674977055"
							local playAnim1 = Player.Character.Humanoid:LoadAnimation(Animation1)  ---the player animation
							local Animation2 = Instance.new("Animation")
							Animation2.AnimationId = "rbxassetid://10676585706"
							local playAnim2 = enemy.Humanoid:LoadAnimation(Animation2) ----the enemy animation
							local SmashSound = Instance.new("Sound")
							SmashSound.SoundId = "rbxassetid://9083980682"
							SmashSound.Parent = Player.Character.Torso
							playAnim1:GetMarkerReachedSignal("Smash"):Connect(function(value)
								enemy.Humanoid.Health = enemy.Humanoid.Health - 12
								SmashSound:Play()
							end)

							task.wait(.5)  ----this is optional i am making the script to wait just so both animation can load
							playAnim1:Play()---play both of the animation
							playAnim2:Play()
							playAnim1.Stopped:Wait() ---wait for the player animation to finish then make the player move again(i recommend you to wait for the player animation to finish and not the dummy)
							mainChar.HumanoidRootPart.Anchored = false
							mainChar.Humanoid.WalkSpeed = 17
							playAnim2.Stopped:Wait()
							enemy.HumanoidRootPart.Anchored = false
							enemy.Humanoid.WalkSpeed = 16
							playAnim1:Destroy()
							playAnim2:Destroy()
							return true
						end
					end
				end
			end
		end
	elseif Class == "Ravager" then
		if Ability == "Slam" then
			for i,enemy in pairs(workspace:GetChildren()) do 
				if not enemy:FindFirstChild("Humanoid") then
				elseif enemy:FindFirstChild("Humanoid") ~= nil then
					if game.Players:GetPlayerFromCharacter(enemy) ~= nil then
						if (Player.Character.HumanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude <= 10 and enemy.Name ~= Player.Name then
							print(enemy.Name)
							local mainChar = Player.Character
							mainChar.Humanoid.WalkSpeed = 0
							enemy.Humanoid.WalkSpeed = 0
							mainChar.HumanoidRootPart.CFrame = CFrame.new(mainChar.HumanoidRootPart.Position,Vector3.new(enemy.HumanoidRootPart.Position.X,mainChar.HumanoidRootPart.Position.Y,enemy.HumanoidRootPart.Position.Z)) ---make plr face the dummy
							enemy.HumanoidRootPart.CFrame = mainChar.HumanoidRootPart.CFrame * CFrame.new(0,-2,-7) -- position the dummy to teleport to 5 stud from you
							enemy.HumanoidRootPart.CFrame = CFrame.new(enemy.HumanoidRootPart.Position,Vector3.new(mainChar.HumanoidRootPart.Position.X,enemy.HumanoidRootPart.Position.Y,mainChar.HumanoidRootPart.Position.Z)) ---make dummy face the plr

							mainChar.HumanoidRootPart.Anchored = true
							enemy.HumanoidRootPart.Anchored = true

							local Animation1 = Instance.new("Animation")
							Animation1.AnimationId = "rbxassetid://10695640532"
							local playAnim1 = Player.Character.Humanoid:LoadAnimation(Animation1)  ---the player animation
							local Animation2 = Instance.new("Animation")
							Animation2.AnimationId = "rbxassetid://10695626586"
							local playAnim2 = enemy.Humanoid:LoadAnimation(Animation2) ----the enemy animation
							local SmashSound = Instance.new("Sound")
							SmashSound.SoundId = "rbxassetid://155288625"
							SmashSound.Parent = Player.Character.Torso
							playAnim2:GetMarkerReachedSignal("Impact"):Connect(function(value)
								enemy.Humanoid.Health = enemy.Humanoid.Health - 60
								SmashSound:Play()
							end)

							task.wait(.5)  ----this is optional i am making the script to wait just so both animation can load
							playAnim1:Play()---play both of the animation
							playAnim2:Play()
							playAnim1.Stopped:Wait() ---wait for the player animation to finish then make the player move again(i recommend you to wait for the player animation to finish and not the dummy)
							playAnim2.Stopped:Wait()
							mainChar.HumanoidRootPart.Anchored = false
							mainChar.Humanoid.WalkSpeed = 17
							enemy.HumanoidRootPart.Anchored = false
							enemy.Humanoid.WalkSpeed = 16
							playAnim1:Destroy()
							playAnim2:Destroy()
							return true
						end
					end
				end
			end
		end
	end
end