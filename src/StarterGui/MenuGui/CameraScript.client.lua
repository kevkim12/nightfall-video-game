local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Camera = game.Workspace.CurrentCamera

local Player = game.Players.LocalPlayer
repeat wait() until Player.Character
local CameraUtil = require(ReplicatedStorage.Modules.CameraUtil)
local functions = CameraUtil.Functions
local shakePresets = CameraUtil.ShakePresets

local cameraInstance = workspace.CurrentCamera
local camera = CameraUtil.Init(cameraInstance)

Camera.CameraType = Enum.CameraType.Scriptable 
camera:Lock(game.Workspace.CameraPart)

--[[
	-- FUNCTIONS --
	DisableControls
	StartFromCurrentCamera 
	EndWithCurrentCamera
	EndWithDefaultCamera
	YieldAfterCutscene
	FreezeCharacter
	CustomCamera
	
	-- SHAKE PRESETS --
	Bump
	Explosion
	Earthquake
	BadTrip
	HandheldCamera
	Vibration
	RoughDriving
]]--

-- REST OF YOUR CODE GOES BELOW HERE!
ReplicatedStorage.Events.ChangeCamera.OnClientEvent:Connect(function(Type)
	if Type == "Custom" then
		camera:Lock(game.Workspace.CameraPart)
		Camera.CameraType = Enum.CameraType.Scriptable
	elseif Type == "Custom 1" then
		camera:Lock(game.Workspace.MapCamera)
		Camera.CameraType = Enum.CameraType.Scriptable
	else
		Camera.CameraType = Enum.CameraType.Custom 
		camera:Reset()
	end
end)

script.Parent.Frame.Menu.TopBar.Store.MouseButton1Click:Connect(function()
	camera:Lock(game.Workspace.StoreCamera)
	Camera.CameraType = Enum.CameraType.Scriptable
end)

script.Parent.Frame.Menu.TopBar.Home.MouseButton1Click:Connect(function()
	camera:Lock(game.Workspace.CameraPart)
	Camera.CameraType = Enum.CameraType.Scriptable
end)


ShakeDist = 25
local function onDescendantAdded(desc)
	if desc:IsA("Explosion") then
		local ExDist = (game.Players.LocalPlayer.Character.Head.Position - desc.Position).magnitude
		local ShakeMagnitude = ExDist/(desc.BlastRadius/8)
		if ShakeMagnitude < ShakeDist then
			local cameraShake = camera:CreateShake()
			cameraShake:Start()
			cameraShake:ShakeOnce(desc.BlastRadius/2, 10, 0, 1.5)
		end
	end
end

game.Workspace.DescendantAdded:Connect(onDescendantAdded)