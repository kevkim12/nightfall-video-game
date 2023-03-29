-- MeleeEffectsReplication

local ReS = game:GetService("ReplicatedStorage")

local FMK_VEvents = ReS:WaitForChild("Events")
local VisualiseEffects = FMK_VEvents:WaitForChild("VisualiseEffects")

local FMK_CModules = ReS:WaitForChild("Modules")
local FMKGF = require(FMK_CModules:WaitForChild("MeleeGlobalFunctions"))

--

local RS = game:GetService("RunService")

local PL = game:GetService("Players")
local Player = PL.LocalPlayer

--local PlayerCharacter = Player.Character or Player.CharacterAdded:wait()
--Player.CharacterAdded:connect(function(Ch)
--	PlayerCharacter = Ch
--end)

local AnimationsPlaying = {}
local SoundTable = {}
local MAT = {}

--

function StopAnimation(AType)
	local Select = 0
	for _,Animation in pairs(AnimationsPlaying) do
		Select = Select + 1
		if Animation[2] == AType then
			Animation[1]:Stop()
			table.remove(AnimationsPlaying,Select)
		end
	end
end

function StopMainAnimation(Animation)
	if Animation then
		for _, CAnim in pairs(MAT) do
			if CAnim[1] == Animation then
				CAnim[2]:Stop()
				table.remove(MAT, table.find(MAT, CAnim))
			end
		end
	end
end

function StopSound(Data)
	local soundType = Data[1]
	local Count = 0
	for i, Sound in pairs(SoundTable) do
		Count = Count + 1
		if ((soundType ~= nil and (Sound.Name == soundType)) or (soundType == nil and true)) and Sound:IsA("Sound") then
			Sound:Stop()
			Sound:Destroy()
			table.remove(SoundTable, i)
			Count = Count - 1
		elseif Sound == nil then
			table.remove(SoundTable, i)
			Count = Count - 1
		end
	end
	wait(0.1)
end

--

VisualiseEffects.OnClientEvent:connect(function(Type, Data, PlayerCharacter)
	if Type == 1 then --] Play Animation
		
		local IAnimation = Instance.new("Animation", PlayerCharacter)
		IAnimation.AnimationId = Data[1]
		local PAnimation = PlayerCharacter:FindFirstChildOfClass("Humanoid"):LoadAnimation(IAnimation)
		-- logprint(Animation[2])
		PAnimation:Play(nil,nil,Data[2])
		table.insert(AnimationsPlaying,{PAnimation,Data[3]})
		warn("Play Animation : ", #AnimationsPlaying)
		IAnimation:Destroy()
		
	elseif Type == 2 then --] Stop Animation
		StopAnimation(Data)
	elseif Type == 3 then --] Play Sound
		
		local SoundInstance = Instance.new("Sound")
		table.insert(SoundTable, SoundInstance)
		local Sound = Data[1]
		local SType = Data[2]
		local SParent = Data[3]
		local Handle = Data[4]

		SoundInstance.SoundId = Sound[1]
		SoundInstance.PlaybackSpeed = FMKGF:AddressTableValue(Sound[2]) or 1
		SoundInstance.Volume = FMKGF:AddressTableValue(Sound[3]) or 0.5
		SoundInstance.TimePosition = FMKGF:AddressTableValue(Sound[4]) or 0
		SoundInstance.Name = Data[2]
		--	
		if SType == "ChainsawLoop" then
			SoundInstance.Looped = true
		end
		--	
		if SParent == nil then SoundInstance.Parent = Handle else SoundInstance.Parent = SParent end
		--
		local corouPlaySound = coroutine.wrap(function()
			--
			wait(FMKGF:AddressTableValue(Sound[5]) or 0)
			repeat RS.Heartbeat:wait() until SoundInstance.TimeLength ~= 0
			SoundInstance:Play()
			-- logprint("Sound TimeLength = "..SoundInstance.TimeLength.." / Sound PlaybackSpeed = "..SoundInstance.PlaybackSpeed)
			-- logprint("Sound Playing For : "..SoundInstance.TimeLength / SoundInstance.PlaybackSpeed)
			repeat RS.Heartbeat:wait() until SoundInstance.Playing == false
			table.remove(SoundTable, table.find(SoundTable, SoundInstance))
			SoundInstance:Destroy(); SoundInstance = nil
			--
		end)
		corouPlaySound()	
		
	elseif Type == 4 then --] Stop Sound
		StopSound(Data)
	elseif Type == 5 then --] Play Main Sound ( type 2 )
		
		for _, sound in pairs(Data) do
			if sound:IsA("Sound") then sound:Play() end
		end
		
	elseif Type == 6 then --] Stop Main Sound ( type 2 )
		
		for _, sound in pairs(Data) do
			if sound:IsA("Sound") then sound:Stop() end
		end
		
	elseif Type == 7 then --] Play MainAnimation
		
		local PlayerCharHum = Data[1]
		local SelectedAnim = Data[2]
		local Animation = Data[3]
		
		local AnimI = Instance.new("Animation", PlayerCharHum)
		AnimI.AnimationId = SelectedAnim.ID
		local AnimLoad = PlayerCharHum:LoadAnimation(AnimI)
		AnimLoad:Play(nil, nil, SelectedAnim.Speed)
		table.insert(MAT, {Animation, AnimLoad})
		
	elseif Type == 8 then --] Stop MainAnimation
		StopMainAnimation(Data[1])
	end
end)