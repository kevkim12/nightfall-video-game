wait(1)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Options = script.Parent.Options
local Stage = ReplicatedStorage.GameData.Stage
local InfectedClass = script.Parent.InfectedClass
local Timer = 5
local SpawnStatus = false
local InfectedTeam = game:GetService("Teams"):WaitForChild("Infected")

local Camera = game.Workspace.CurrentCamera
local CameraUtil = require(ReplicatedStorage.Modules.CameraUtil)
local functions = CameraUtil.Functions
local shakePresets = CameraUtil.ShakePresets

local cameraInstance = workspace.CurrentCamera
local camera = CameraUtil.Init(cameraInstance)

local SelectSound = script.Parent.Sounds.Select
local SpawnText = script.Parent.Spawn.TextLabel

Options["11_Walker"].MouseButton1Click:Connect(function()
	if InfectedClass.Value ~= "Walker" then
		InfectedClass.Value = "Walker"
		SelectSound:Play()
	end
	
end)

Options["12_Runner"].MouseButton1Click:Connect(function()
	if InfectedClass.Value ~= "Runner" then
		InfectedClass.Value = "Runner"
		SelectSound:Play()
	end
end)

Options["13_Bloater"].MouseButton1Click:Connect(function()
	if InfectedClass.Value ~= "Bloater" then
		InfectedClass.Value = "Bloater"
		SelectSound:Play()
	end
end)

Options["41_Wrecker"].MouseButton1Click:Connect(function()
	if InfectedClass.Value ~= "Wrecker" then
		InfectedClass.Value = "Wrecker"
		SelectSound:Play()
	end
end)

Options["52_Ravager"].MouseButton1Click:Connect(function()
	if InfectedClass.Value ~= "Ravager" then
		InfectedClass.Value = "Ravager"
		SelectSound:Play()
	end
end)

local function SpawnClass()
	if Player.Team == InfectedTeam then
		if InfectedClass.Value == "Walker" then
			ReplicatedStorage.Events.InfectedSelection:FireServer(Player.Name, InfectedClass.Value)
		elseif InfectedClass.Value == "Runner" then
			ReplicatedStorage.Events.InfectedSelection:FireServer(Player.Name, InfectedClass.Value)
		elseif InfectedClass.Value == "Bloater" then
			ReplicatedStorage.Events.InfectedSelection:FireServer(Player.Name, InfectedClass.Value)
		elseif InfectedClass.Value == "Wrecker" then
			ReplicatedStorage.Events.InfectedSelection:FireServer(Player.Name, InfectedClass.Value)
		elseif InfectedClass.Value == "Ravager" then
			ReplicatedStorage.Events.InfectedSelection:FireServer(Player.Name, InfectedClass.Value)
		end
		Camera.CameraType = Enum.CameraType.Custom 
		camera:Reset()
		ReplicatedStorage.Events.RequestSpawn:FireServer(Player.Name)
		SelectSound:Play()
	end
end

script.Parent.Spawn.MouseButton1Click:Connect(function()
	SpawnClass()
	SpawnStatus = false
end)

if Stage.Value == 1 then
	Options["11_Walker"].Visible = true
	Options["12_Runner"].Visible = true
	Options["13_Bloater"].Visible = true
	Options["41_Wrecker"].Visible = false
	Options["52_Ravager"].Visible = false
elseif Stage.Value == 2 then
	Options["11_Walker"].Visible = true
	Options["12_Runner"].Visible = true
	Options["13_Bloater"].Visible = true
	Options["41_Wrecker"].Visible = false
	Options["52_Ravager"].Visible = false
elseif Stage.Value == 3 then
	Options["11_Walker"].Visible = true
	Options["12_Runner"].Visible = true
	Options["13_Bloater"].Visible = true
	Options["41_Wrecker"].Visible = false
	Options["52_Ravager"].Visible = false
elseif Stage.Value == 4 then
	Options["11_Walker"].Visible = true
	Options["12_Runner"].Visible = true
	Options["13_Bloater"].Visible = true
	Options["41_Wrecker"].Visible = false
	Options["52_Ravager"].Visible = false
elseif Stage.Value == 5 then
	Options["11_Walker"].Visible = true
	Options["12_Runner"].Visible = true
	Options["13_Bloater"].Visible = true
	Options["41_Wrecker"].Visible = true
	Options["52_Ravager"].Visible = true
end

Stage.Changed:Connect(function()
	if Stage.Value == 1 then
		Options["11_Walker"].Visible = true
		Options["12_Runner"].Visible = true
		Options["13_Bloater"].Visible = true
		Options["41_Wrecker"].Visible = false
		Options["52_Ravager"].Visible = false
	elseif Stage.Value == 2 then
		Options["11_Walker"].Visible = true
		Options["12_Runner"].Visible = true
		Options["13_Bloater"].Visible = true
		Options["41_Wrecker"].Visible = false
		Options["52_Ravager"].Visible = false
	elseif Stage.Value == 3 then
		Options["11_Walker"].Visible = true
		Options["12_Runner"].Visible = true
		Options["13_Bloater"].Visible = true
		Options["41_Wrecker"].Visible = false
		Options["52_Ravager"].Visible = false
	elseif Stage.Value == 4 then
		Options["11_Walker"].Visible = true
		Options["12_Runner"].Visible = true
		Options["13_Bloater"].Visible = true
		Options["41_Wrecker"].Visible = false
		Options["52_Ravager"].Visible = false
	elseif Stage.Value == 5 then
		Options["11_Walker"].Visible = true
		Options["12_Runner"].Visible = true
		Options["13_Bloater"].Visible = true
		Options["41_Wrecker"].Visible = true
		Options["52_Ravager"].Visible = true
	end
end)

InfectedClass.Changed:Connect(function()
	local OptionContent = script.Parent.Options:GetChildren()
	for i = 1, #OptionContent do
		if OptionContent[i]:IsA("ImageButton") then
			OptionContent[i].BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		end
	end
	if InfectedClass.Value == "Walker" then
		Options["11_Walker"].BackgroundColor3 = Color3.fromRGB(188, 255, 204)
	elseif InfectedClass.Value == "Runner" then
		Options["12_Runner"].BackgroundColor3 = Color3.fromRGB(188, 255, 204)
	elseif InfectedClass.Value == "Bloater" then
		Options["13_Bloater"].BackgroundColor3 = Color3.fromRGB(188, 255, 204)
	elseif InfectedClass.Value == "Wrecker" then
		Options["41_Wrecker"].BackgroundColor3 = Color3.fromRGB(188, 255, 204)
	elseif InfectedClass.Value == "Ravager" then
		Options["52_Ravager"].BackgroundColor3 = Color3.fromRGB(188, 255, 204)
	end
end)

ReplicatedStorage.Events.InfectedScreen.OnClientEvent:Connect(function(PlayerName)
	if Player.Name == PlayerName then
		SpawnStatus = true
		local Count = Timer
		for i = 1, Timer do
			SpawnText.Text = "SPAWNING [" .. Count .. "]"
			wait(1)
			Count = Count - 1
		end
		if SpawnStatus == true then
			SpawnClass()
		end
	end
end)