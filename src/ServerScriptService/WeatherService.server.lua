local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local MapFolder = game.Workspace:WaitForChild("Map")
local WeatherValue = ServerStorage.Maps.MapData.Weather
local WeatherActive = ServerStorage.Maps.MapData.WeatherActive
local CloudsModule = require(game.ReplicatedStorage.Modules.CloudsModule)
local CloudsFolder = game.Workspace:WaitForChild("Clouds")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local function DefaultLighting()
	Lighting.Brightness = 1
	Lighting.Ambient = Color3.fromRGB(25,25,25)
	Lighting.ExposureCompensation = 0.018
	Lighting.Atmosphere.Density = 0.395
	Lighting.Atmosphere.Color = Color3.fromRGB(157,117,84)
	Lighting.Atmosphere.Decay = Color3.fromRGB(97,62,13)
	Lighting.Atmosphere.Glare = 1.93
	Lighting.Atmosphere.Haze = 0.72
	Lighting.ColorCorrection.TintColor = Color3.fromRGB(255, 245, 233)
	Lighting.ColorCorrection.Enabled = false
end

ReplicatedStorage.GameData.GameActive.Changed:Connect(function()
	if ReplicatedStorage.GameData.GameActive.Value == true then
		if ServerStorage.Maps.MapData.CurrentMap.Value == "Warzone" then
			DefaultLighting()
			local WeatherChance = math.random(1, 10)
			local StartTime = 0
			if WeatherChance == 1 then
				CloudsModule.Clouds:new(
					{
						Tallness = 40; -- Default Value = 40
						Offset = 0; -- Default Value = 0
						Density = 0.2; -- Default Value = 0.2
						Speed = 5; -- Default Value = 5
						Height = 500; -- Default Value = 500
						Size = 3.572; -- Default Value = 3.572
						ShadowCast = false; -- Default Value = true
						CloudType = "Stratus" -- Default Value = "Cumulus"
					}
				)
				StartTime = math.random(30, 360)
				wait(StartTime)
				WeatherActive.Value = true
				WeatherValue = "Normal Rain"
				ReplicatedStorage.Events.Weather:FireAllClients(WeatherValue, "Start")
			elseif WeatherChance > 1 and WeatherChance < 4 then
				Lighting.Atmosphere.Color = Color3.fromRGB(207, 108, 50)
				Lighting.Atmosphere.Decay = Color3.fromRGB(42, 26, 5)
				--Lighting.Blur.Enabled = true
				--Lighting.Blur.Size = 2
				Lighting.ColorCorrection.TintColor = Color3.fromRGB(255,195,125)
				Lighting.ColorCorrection.Enabled = true
				StartTime = math.random(15, 20)
				wait(StartTime)
				WeatherActive.Value = true
				WeatherValue = "Dust Storm"
				ReplicatedStorage.Events.Weather:FireAllClients(WeatherValue, "Start")
				wait(math.random(10,15))
				local tweenTime = 45
				local tweenInfo = TweenInfo.new(
					tweenTime, -- Time
					Enum.EasingStyle.Linear, -- EasingStyle
					Enum.EasingDirection.InOut, -- EasingDirection
					0, -- RepeatCount
					false, -- Reverses
					0 -- DelayTime
				)
				local DensityGoals = {Density = 0.677}
				local GlareGoals = {Glare = 10}
				local HazeGoals = {Haze = 10}
				local DensityTween = TweenService:Create(Lighting.Atmosphere, tweenInfo, DensityGoals)
				local GlareTween = TweenService:Create(Lighting.Atmosphere, tweenInfo, GlareGoals)
				local HazeTween = TweenService:Create(Lighting.Atmosphere, tweenInfo, HazeGoals)
				DensityTween:Play()
				GlareTween:Play()
				HazeTween:Play()
				
				WeatherActive.Changed:Connect(function()
					if WeatherActive.Value == false then
						DensityTween:Cancel()
						GlareTween:Cancel()
						HazeTween:Cancel()
						DefaultLighting()
					end
				end)
			end
		elseif ServerStorage.Maps.MapData.CurrentMap.Value == "District" then
			DefaultLighting()
			Lighting.Brightness = 1
			Lighting.Ambient = Color3.fromRGB(57,57,57)
			Lighting.ExposureCompensation = 0
			Lighting.Atmosphere.Decay = Color3.fromRGB(0,0,0)
			local WeatherChance = math.random(1, 10)
			local StartTime = 0
			if WeatherChance == 1 then
				Lighting.Atmosphere.Color = Color3.fromRGB(255,255,255)
				CloudsModule.Clouds:new(
					{
						Tallness = 40; -- Default Value = 40
						Offset = 0; -- Default Value = 0
						Density = 0.2; -- Default Value = 0.2
						Speed = 5; -- Default Value = 5
						Height = 500; -- Default Value = 500
						Size = 3.572; -- Default Value = 3.572
						ShadowCast = false; -- Default Value = true
						CloudType = "Stratus" -- Default Value = "Cumulus"
					}
				)
				StartTime = math.random(30, 360)
				wait(StartTime)
				WeatherActive.Value = true
				WeatherValue = "Heavy Rain"
				ReplicatedStorage.Events.Weather:FireAllClients(WeatherValue, "Start")
				local tweenTime = 45
				local tweenInfo = TweenInfo.new(
					tweenTime, -- Time
					Enum.EasingStyle.Linear, -- EasingStyle
					Enum.EasingDirection.InOut, -- EasingDirection
					0, -- RepeatCount
					false, -- Reverses
					0 -- DelayTime
				)
				local DensityGoals = {Density = 0.5}
				local HazeGoals = {Haze = 4}
				local DensityTween = TweenService:Create(Lighting.Atmosphere, tweenInfo, DensityGoals)
				local HazeTween = TweenService:Create(Lighting.Atmosphere, tweenInfo, HazeGoals)
				DensityTween:Play()
				HazeTween:Play()
			end
		elseif ServerStorage.Maps.MapData.CurrentMap.Value == "Arctic" then
			DefaultLighting()	
			Lighting.Brightness = 0
			Lighting.Ambient = Color3.fromRGB(125, 125, 125)
			Lighting.ExposureCompensation = 0
			Lighting.Atmosphere.Decay = Color3.fromRGB(0, 0, 0)
			Lighting.Atmosphere.Color = Color3.fromRGB(212, 212, 212)
		end
	else
		WeatherActive.Value = false
		DefaultLighting()
		ReplicatedStorage.Events.Weather:FireAllClients(WeatherValue, "Stop")
		local CloudContent = CloudsFolder:GetChildren()
		if CloudContent ~= nil then
			for i = 1, #CloudContent do
				CloudContent[i]:Destroy()
			end
		end
	end
end)