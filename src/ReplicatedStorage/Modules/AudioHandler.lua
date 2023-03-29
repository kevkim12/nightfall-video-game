local AudioHandler = {}

local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = Workspace.CurrentCamera

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local PlayAudio = Remotes.PlayAudio

local Utilities = require(Modules.Utilities)
local Thread = Utilities.Thread

function AudioHandler:PlayAudio(Audio, LowAmmoAudio, Replicate)
	local Sound = Instance.new("Sound")
	Sound.SoundId = Audio.SoundId
	Sound.EmitterSize = Audio.EmitterSize or 10
	Sound.MaxDistance = Audio.MaxDistance or 10000
	Sound.Volume = Audio.Volume or 0.5
	Sound.PlaybackSpeed = Audio.Pitch or 1
	Sound.TimePosition = Audio.TimePosition or 0
	Sound.Name = Audio.Name or "Sound"
	Sound.Parent = Audio.Origin
	local DistantSound = nil
	
	if Audio.Echo then
		local Position = Audio.Origin.ClassName == "Attachment" and Audio.Origin.WorldPosition or Audio.Origin.Position
		local Distance = math.min(1000, (Camera.CFrame.p - Position).Magnitude)
		if Distance > 200 then
			local DistantSoundIds = Audio.DistantSoundIds or {177174605}
			local DistantSoundVolume = Audio.DistantSoundVolume or 1.5
			DistantSound = Instance.new("Sound")
			DistantSound.SoundId = "rbxassetid://"..DistantSoundIds[math.random(#DistantSoundIds)] 
			DistantSound.Volume = DistantSoundVolume
			DistantSound.EmitterSize = 100
			DistantSound.Parent = Audio.Origin
					
			Sound.Pitch = 1 - Distance / 2000
			local ReverbSoundEffect = Instance.new("ReverbSoundEffect")
			ReverbSoundEffect.DryLevel = 0
			ReverbSoundEffect.WetLevel = (Distance / 1000) * -20
			ReverbSoundEffect.Parent = Sound
			
			local EqualizerSoundEffect = Instance.new("EqualizerSoundEffect")
			EqualizerSoundEffect.LowGain = (Distance / 1000) * -15
			EqualizerSoundEffect.MidGain = (Distance / 1000) * 5
			EqualizerSoundEffect.HighGain = 0
			EqualizerSoundEffect.Parent = Sound
		end
	end
	
	if Audio.Silenced then
		Sound.PlaybackSpeed	= Sound.PlaybackSpeed * 1.5
		
		local EqualizerSoundEffect	= Instance.new("EqualizerSoundEffect")
		EqualizerSoundEffect.HighGain = 0
		EqualizerSoundEffect.LowGain = -7
		EqualizerSoundEffect.MidGain = -15
		EqualizerSoundEffect.Priority = 0
		EqualizerSoundEffect.Parent = Sound
	end

	--[[Thread:Delay(Audio.SoundDelay or 0, function()
		Sound:Play()
		Debris:AddItem(Sound, Sound.TimeLength / Sound.PlaybackSpeed)
		if DistantSound then
			DistantSound:Play()
			DistantSound.Ended:Connect(function()
				if DistantSound then
					DistantSound:Destroy()
				end
			end)
		end
	end)]]

	Thread:Delay(Audio.SoundDelay or 0, function()
		repeat Thread:Wait() until Sound.TimeLength ~= 0
		Sound:Play()
		if DistantSound then
			DistantSound:Play()
			DistantSound.Ended:Connect(function()
				if DistantSound then
					DistantSound:Destroy()
				end
			end)
		end
		repeat Thread:Wait() until Sound.Playing == false
		Sound:Destroy()
	end)

	if LowAmmoAudio then
		if LowAmmoAudio.Enabled then
			if LowAmmoAudio.CurrentAmmo <= LowAmmoAudio.AmmoPerMag / 5 then
				local LowAmmoSound = Instance.new("Sound")
				LowAmmoSound.SoundId = LowAmmoAudio.SoundId
				LowAmmoSound.EmitterSize = LowAmmoAudio.EmitterSize or 10
				LowAmmoSound.MaxDistance = LowAmmoAudio.MaxDistance or 10000
				LowAmmoSound.Volume = LowAmmoAudio.Volume or 0.5
				LowAmmoSound.PlaybackSpeed = LowAmmoAudio.Pitch or (math.max(math.abs(LowAmmoAudio.CurrentAmmo / 10 - 1), 0.4))
				LowAmmoSound.Name = "LowAmmoSound"
				LowAmmoSound.Parent = LowAmmoAudio.Origin
				LowAmmoSound:Play()
				Debris:AddItem(LowAmmoSound, LowAmmoSound.TimeLength / LowAmmoSound.PlaybackSpeed)
			end
		end
	end
	
	if Replicate then
		PlayAudio:FireServer(Audio, LowAmmoAudio, nil)
	end
end

return AudioHandler