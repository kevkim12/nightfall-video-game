local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")

local ToolModule = require(Tool:WaitForChild("MainModule"))

local Player = game:GetService("Players").LocalPlayer
local PlayerCharacter

local Mouse = Player:GetMouse()

local MainSettings = ToolModule.MainSettings
local WeaponTags = MainSettings.WeaponTags
local VisualSettings = ToolModule.VisualSettings

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FMKClientModules = ReplicatedStorage:WaitForChild("Modules")
local FMKGF = FMKClientModules:WaitForChild("MeleeGlobalFunctions")
FMKGF = require(FMKGF)

local ClientEF = Tool:WaitForChild("Events")

local ChargeEF = ClientEF:WaitForChild("Charge")
local AttackEF = ClientEF:WaitForChild("Attack")
local VisualiseEF = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local InputEF = ClientEF:WaitForChild("Input")
local AbilityEF = ClientEF:WaitForChild("Ability")
local MiscEF = ClientEF:WaitForChild("Misc")

local Initiate_Server = AttackEF:WaitForChild("Initiate_Server")

local Attack_Server = AttackEF:WaitForChild("Attack_Server")

local StartCharge = ChargeEF:WaitForChild("StartCharge")
local EndCharge = ChargeEF:WaitForChild("EndCharge")

local StartChainsaw = ChargeEF:WaitForChild("StartChainsaw")
local EndChainsaw = ChargeEF:WaitForChild("EndChainsaw")

local SendInput = InputEF:WaitForChild("SendInput")
local SendInput2 = InputEF:WaitForChild("SendInput2")
local ReleaseInput = InputEF:WaitForChild("ReleaseInput")

local SE = VisualiseEF:WaitForChild("ScreenshakeEvent")
local SB = SE:WaitForChild("ScreenshakeBindable")

local HandleClang = MiscEF:WaitForChild("HandleClang")

local ClientModules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")

local GetAbilities = AbilityEF:WaitForChild("GetAbilities")

local Equipped = false
local Active = false

local OnDelay = false

local HitboxReady = false

local Charging = false

function logprint(Value)
	if VisualSettings["DisablePrintWarnMessages"] ~= nil then
		print(Value)
	end
end

function logwarn(Value)
	if VisualSettings["DisablePrintWarnMessages"] ~= nil then
		warn(Value)
	end
end

local ChargeBar = script:WaitForChild("ChargeBar")
local AbilityUI = script:WaitForChild("AbilityUI")
local DurabilityUI = script:WaitForChild("DurabilityUI")

local TotalAttackFrames = 0
local CurrentAttackFrame = 1

local Tick = 0
local ChargeAmount = 0

--

local AnimationsPlaying = {}

function PlayRandomAnimation(AType, AttackFrame, NoPlay)
	--warn("searching to play random aniamtion")
	local returningMain
	--warn("PlayRandomAnimation", AType, AttackFrame, NoPlay)
	if AType ~= nil then
		local TableRandom
		
		local function SearchAnimations(TypeToUse)
			TableRandom = {}
			for _,Animation in pairs(AttackFrame ~= nil and AttackFrame.AnimationTable or require(Tool.MainModule[CurrentAttackFrame]).AnimationTable) do
				if Animation.animationType == TypeToUse then
					table.insert(TableRandom,{Animation.ID, FMKGF:AddressTableValue(Animation.speed), Animation.animationType, Animation.hitboxTimes})
				end
			end
		end
		
		SearchAnimations(AType)
		--warn("ONE")
		
		if TableRandom ~= nil then
			--warn("TWO")
			local function PlayAnimationLF()
				local returning = false
				local Animation = TableRandom[Random.new():NextInteger(1,#TableRandom)]
				if Animation ~= nil and PlayerCharacter ~= nil then
					if NoPlay == nil then
						local IAnimation = Instance.new("Animation",Tool.Handle)
						IAnimation.AnimationId = Animation[1]
						local PAnimation = PlayerCharacter:FindFirstChildOfClass("Humanoid"):LoadAnimation(IAnimation)
						-- logprint(Animation[2])
						returning = true
						--warn("PlayRandomAnimation")
						PAnimation:Play(nil,nil,Animation[2])
						table.insert(AnimationsPlaying,{PAnimation,Animation[3]})
						IAnimation:Destroy()
					end
					if Animation[4] ~= nil then
						returningMain = Animation[4]
					end
				end
				return returning
			end
			
			local PAF = PlayAnimationLF()
			
			if PAF == false then
				--warn("THREE")
				logwarn("No animation found for type : "..AType)
				local function PlayNormalAttack()
					logwarn("Attempt to use Attack instead.")
					SearchAnimations("Attack")
					PlayAnimationLF()
				end
				if AType == "AttackMaxCharge" then
					logwarn("Attempt to use AttackCharge instead")
					SearchAnimations("AttackCharge")
					local PAF = PlayAnimationLF()
					if PAF == false then
						logwarn("Failed to use AttackCharge.")
						PlayNormalAttack()
					end
				elseif AType == "AttackCharge" then
					PlayNormalAttack()
				end
			end
			
		end
	end
	return returningMain
end

function StopAnimation(AType)
	local Select = 0
	--warn("StopAnimation", AType, #AnimationsPlaying)
	for i = 1, #AnimationsPlaying do
		Select = Select + 1
		local Animation = AnimationsPlaying[Select]
		--print("Select Animation ", Select, " : ", Animation, " : ", AType, " // ", Animation[1], " : ", Animation[1].Stopped)
		if Animation[2] == AType then
			--print("animation stopped!", Animation[1])
			table.remove(AnimationsPlaying,Select)
			Select = Select - 1
			Animation[1]:Stop()
		elseif Animation[1] ~= nil and tostring(Animation[1].Stopped) == ("Signal Stopped") then
			table.remove(AnimationsPlaying,Select)
			Select = Select - 1
		end
		RunService.Heartbeat:wait()
	end
end

--

local SoundTable = {}

function PlaySound(Sound, SType, SParent)
	local SoundInstance = Instance.new("Sound")
	SoundInstance.SoundId = Sound[1]
	SoundInstance.PlaybackSpeed = FMKGF:AddressTableValue(Sound[2]) or 1
	SoundInstance.Volume = FMKGF:AddressTableValue(Sound[3]) or 0.5
	SoundInstance.TimePosition = FMKGF:AddressTableValue(Sound[4]) or 0
	SoundInstance.Name = SType
		
	if SType == "ChainsawLoop" then
		SoundInstance.Looped = true
	end
	table.insert(SoundTable, SoundInstance)
		
	if SParent == nil then SoundInstance.Parent = Handle else SoundInstance.Parent = SParent end
	--
	local corouPlaySound = coroutine.wrap(function()
		--
		wait(FMKGF:AddressTableValue(Sound[5]) or 0)
		repeat RunService.Heartbeat:wait() until SoundInstance.TimeLength ~= 0
		SoundInstance:Play()
		logprint("Sound TimeLength = "..SoundInstance.TimeLength.." / Sound PlaybackSpeed = "..SoundInstance.PlaybackSpeed)
		logprint("Sound Playing For : "..SoundInstance.TimeLength / SoundInstance.PlaybackSpeed)
		repeat RunService.Heartbeat:wait() until SoundInstance.Playing == false
		table.remove(SoundTable, table.find(SoundTable, SoundInstance))
		SoundInstance:Destroy(); SoundInstance = nil
		--
	end)
	corouPlaySound()	
end

function PlayRandomSound(SType,SParent, ArgumentTable, AttackFrame)
	if SType ~= nil then
		local TableRandom = {}
		for _, Sound in pairs(AttackFrame ~= nil and AttackFrame.SoundsTable or require(Tool.MainModule[CurrentAttackFrame]).SoundsTable) do
			if Sound.soundType == SType then
				local Pass = false
				if ArgumentTable ~= nil then
					logwarn("ArgumentTable not nil [ SType = "..SType.." ]")
					for v, argValue in pairs(ArgumentTable) do
						if Sound[v] ~= nil then -- Finds name of a value (ex : material)
							--
							if Sound[v][1] ~= nil then -- Checks if it's a table
								for _, vaValue in pairs(Sound[v]) do
									if vaValue == argValue then -- Checks if a value in the table matches a value in the argument table.
										Pass = true
									end
								end
							elseif Sound[v][1] == nil then -- If it's not a table
								if Sound[v] == argValue then -- Checks if the sound valie matches a value in the argument table.
									Pass = true
								end
							end
							--
						end
					end

				elseif ArgumentTable == nil then
					Pass = true
				end
				if Pass == true then
					table.insert(TableRandom,{Sound.soundID,Sound.pitch,Sound.volume,Sound.timeposition,Sound.delaysound})
				end
			end
		end
		if TableRandom ~= nil then
			local Sound = TableRandom[Random.new():NextInteger(1,#TableRandom)]
			if Sound ~= nil then
				PlaySound(Sound, SType, SParent)
			else
				local WarnText = "No sound found for type : "..SType.."."
				if SType == "ChargeImpactSound" or SType == "MaxChargeImpactSound" then
					local FRSImpact = FindRandomSound("ImpactSound")
					if FRSImpact ~= nil then
						PlaySound(FRSImpact, SType, SParent)
						WarnText = WarnText.." Playing ImpactSound instead"	
					end
				elseif SType == "ChargeSwing" or SType == "MaxChargeSwing" then
					local FRSImpact = FindRandomSound("Swing")
					if FRSImpact ~= nil then
						PlaySound(FRSImpact, SType, SParent)
						WarnText = WarnText.." Playing Swing instead"	
					end
				end
				--warn(WarnText)
			end
		end
	end
end

function StopSound(soundType) -- unfinished. only works for chainsaw.
	--print("StopSound ", soundType)
	local Count = 0
	for _, Sound in pairs(SoundTable) do
		Count = Count + 1
		--warn(Sound.Name, soundType)
		if ((soundType ~= nil and (Sound.Name == soundType)) or (soundType == nil and true)) and Sound:IsA("Sound") then
			--warn("Sound stopped")
			Sound:Stop()
			Sound:Destroy()
			table.remove(SoundTable, Count)
			Count = Count - 1
		elseif Sound == nil then
			table.remove(SoundTable, Count)
			Count = Count - 1
		end
	end
end

function FindRandomSound(SType, AttackFrame)
	local Return = nil
	if SType ~= nil then
		local TableRandom = {}
		for _,Sound in pairs(AttackFrame ~= nil and AttackFrame.SoundsTable or require(Tool.MainModule[CurrentAttackFrame]).SoundsTable) do
			if Sound.soundType == SType then
				table.insert(TableRandom,{Sound.soundID,Sound.pitch,Sound.volume,Sound.timeposition,Sound.delaysound})
			end
		end
		if TableRandom ~= nil then
			local Sound = TableRandom[Random.new():NextInteger(1,#TableRandom)]
			if Sound ~= nil then
				Return = Sound
			end
		end
	end
	return Return
end

--

function HandleAbilityDelay(Ability)
	local Frame = Ability[5]
	Frame.AbilityCooldownTimer.Visible = true
	Frame.AbilityCooldownTimer.Text = Ability[2]
	
	Frame.AbilityKey.TextTransparency = 1
	Frame.AbilityCooldownBar.Size = UDim2.new(0, 0, 0.071, 0)
	TweenService:Create(Frame.AbilityKey,TweenInfo.new(tonumber(Ability[2]),Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{TextTransparency = 0}):Play()
	TweenService:Create(Frame.AbilityCooldownBar,TweenInfo.new(tonumber(Ability[2]),Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{Size = UDim2.new(1,0,0.071,0)}):Play()
	
	local iLoop = coroutine.wrap(function() 
		for _ = 1,Ability[2] do
			wait(1)
			Frame.AbilityCooldownTimer.Text = Frame.AbilityCooldownTimer.Text - 1
		end
		Frame.AbilityCooldownTimer.Visible = false
	end)
	iLoop()
end

function FindMiscEffects(eName, AttackFrame)
	if eName and AttackFrame then
		local effectTable = {}
		
		for _, effect in pairs(AttackFrame.MiscTable) do
			if effect.effectName == eName then
				table.insert(effectTable, effect)
			end
		end
		
		if effectTable[1] == nil then
			return nil
		else
			return effectTable
		end
		
	end
end

function FindClangData(AF, hit)
	local AClang = FindMiscEffects("AttackClang", AF)
	for _, ACL in pairs(AClang) do
		local Pass = true
		for i, property in pairs(ACL.AttackClangLimit) do
			if i == "Transparency" then
				if hit.Transparency >= property[1]
					and hit.Transparency <= property[2] then
				else
					Pass = false
				end
			elseif i == "CanCollidable" then
				if hit.CanCollide ~= property then
					Pass = false
				end
			elseif i == "Anchored" then
				if hit.Anchored ~= property then
					Pass = false
				end
			elseif i == "Material" then
				local SPass = false
				for _, materialName in pairs(property) do
					logprint(materialName)
					if hit.Material.Name == materialName then
						mName = materialName
						SPass = true
					end
				end
				if SPass == false then
					Pass = false
				end
			end
		end
		if Pass == true then
			logprint"CLANG!"
			--warn("CLANG!", ACL, ACL.StopAnimationOnActivate)
			PlayRandomSound("AttackClang", nil, {material = mName}, AF)
			if ACL.StopAnimationOnActivate == true then
				--warn("It's true! IT'S TRUE!!!!!!")
				StopAnimation("Attack")
				StopAnimation("AttackCharge")
				StopAnimation("AttackMaxCharge")
			end
			if ACL.StopSoundOnActivate == true then
				StopSound("Swing")
				StopSound("ChargeSwing")
				StopSound("MaxChargeSwing")
			end
			local ACSS = FindMiscEffects("AttackClangScreenshake", AF)
			if ACSS ~= nil then
				ACSS = ACSS[Random.new():NextInteger(1, #ACSS)]
				local Pass = false
				if ACSS.Material ~= nil then
					for _, MV in pairs(ACSS.Material) do
						if MV == mName then
							Pass = true
						end
					end
				else
					Pass = true
				end
				if Pass == true then
					SB:Fire(FMKGF:AddressTableValue(ACSS.ScreenshakeLongevity), FMKGF:AddressTableValue(ACSS.ScreenshakeIntensity), ACSS.ScreenshakeVariant)
				end
			end
		end
	end
end

local Abilities = {}
local ISAbilities = GetAbilities:InvokeServer()

ReleaseInput.OnClientEvent:Connect(function(AN)
	for _,AB in pairs(Abilities) do
		if AB[1] == AN then
			HandleAbilityDelay(AB)
		end
	end
end)

for i, Ability in pairs(ISAbilities) do
	if #Ability ~= 0 then
		local aFrame = AbilityUI.aFrameEXAMPLE:Clone()
		aFrame.Parent = AbilityUI
		aFrame.Position = UDim2.new(1, -220, 1, -120 - (110*(i-1)))
		aFrame.AbilityNameFrame.AbilityName.Text = Ability[1]
		aFrame.AbilityDescription.Text = Ability[2]
		aFrame.AbilityKey.Text = string.gsub(tostring(Ability[4]) , "Enum.KeyCode.", "")
		aFrame.Visible = true
		table.insert(Abilities,{Ability[1],Ability[3],Ability[4],Ability[2],aFrame})
	end
end

for _,AFrame in pairs(Tool.MainModule:GetChildren()) do
	if AFrame:IsA("ModuleScript") then
		if tonumber(AFrame.Name) ~= nil then
			TotalAttackFrames = TotalAttackFrames + 1
		end
	end
end

function GetChargeAmount(AttackFrame)
	ChargeAmount = Tick/AttackFrame.ChargeLength
	if ChargeAmount > 1 then ChargeAmount = 1 end
	-- logprint("CHARGE AMOUNT : "..ChargeAmount)
end

local AnimationsPlaying = {}

function ChargeBar_Move()
	while RunService.Heartbeat:wait() do
		if Equipped == true then
			ChargeBar.Frame.Position=UDim2.new(0,Mouse.X,0,Mouse.Y-5)
			if ChargeBar.Frame.Bar.Size.X.Scale < 1 or Charging == true then
				ChargeBar.Enabled = true
				if Charging == true then ChargeBar.Frame.Bar.BackgroundColor3 = Color3.fromRGB(255,170,0) else ChargeBar.Frame.Bar.BackgroundColor3 = Color3.fromRGB(255,255,255) end
			else
				ChargeBar.Enabled = false
			end
		elseif Equipped == false then
			break
		end
	end
end

function ChargeBar_Charge(AMT)
	if AMT and ChargeBar then
		logprint("CHARGE BAR HAS BEEN MOVED WOOP WOOP (AMT : "..AMT..")")
		ChargeBar.Frame.Bar.Size = UDim2.new(0, 0, 1, 0)
		TweenService:Create(ChargeBar.Frame.Bar, TweenInfo.new(AMT,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0), {Size = UDim2.new(1, 0, 1, 0)}):Play()
	end
end

ClientEF:WaitForChild("Misc"):WaitForChild("EnableChargeBar").OnClientEvent:Connect(ChargeBar_Charge)

function AlterDurabilityUI(DUI)
	local TDR = math.ceil(Tool:WaitForChild("ServerScript"):FindFirstChild("TDR").Value)
	local CDR = math.ceil(Tool:WaitForChild("ServerScript"):FindFirstChild("CDR").Value)
	if DUI ~= nil and TDR and CDR then
		DUI.MainFrame.DurabilityBar.Size = UDim2.new(CDR/TDR, 0, 1, 0)
		DUI.MainFrame.DurabilityPercent.Text = math.ceil(((CDR/TDR)*100)).."%"
		if VisualSettings.DurabilityPoints then
			DUI.MainFrame.DurabilityPoints.Text = CDR.." / "..TDR
		end
	end
end

local BTTween
local TTTween
local TSTTween 

function ClearAllDurabilityUI()
	for _, GUI in pairs(Player.PlayerGui:GetChildren()) do
		if GUI.Name == "DurabilityUI" then
			GUI:Destroy()
		end
	end
end

function DurabilityActivate()
	if DurabilityUI ~= nil and MainSettings.EnableWeaponDurability == true then
		ClearAllDurabilityUI()
		local CDurabilityUI = DurabilityUI:Clone()
		
		AlterDurabilityUI(CDurabilityUI)
		
		CDurabilityUI.Enabled = true
		CDurabilityUI.Parent = Player.PlayerGui
		
		CDurabilityUI.MainFrame.WeaponName.Text = Tool.Name
		
		coroutine.wrap(function()
			wait(VisualSettings.DurabilityUIWait or 0.75)
			for _, UIE in pairs(CDurabilityUI:GetDescendants()) do
				BTTween = TweenService:Create(UIE, VisualSettings.DurabilityUITween, {BackgroundTransparency = 1})
				BTTween:Play()
				if UIE:IsA("TextLabel") then
					TTTween = TweenService:Create(UIE, VisualSettings.DurabilityUITween, {TextTransparency = 1})
					TTTween:Play()
					TSTTween = TweenService:Create(UIE, VisualSettings.DurabilityUITween, {TextStrokeTransparency = 1})
					TSTTween:Play()
				end
			end
		end)()
		
	end
end

local TDR
local CDR

local PrevCDR

if MainSettings.EnableWeaponDurability == true then
	TDR = Tool.ServerScript:WaitForChild("TDR")
	CDR = Tool.ServerScript:WaitForChild("CDR")
	PrevCDR = CDR.Value
	if TDR and CDR then
		CDR.Changed:Connect(function()
			if (CDR.Value - PrevCDR) < 0 and CDR.Value > 0 then
				DurabilityActivate()
			end
			PrevCDR = CDR.Value
		end)
	end
end

--function DurabilityDeactivate()
--	if DurabilityUI ~= nil and MainSettings.EnableWeaponDurability == true then
--		DurabilityUI.Enabled = false
--		if TTTween ~= nil then
--			TTTween:Pause()
--		end
--		if BTTween ~= nil then
--			BTTween:Pause()
--		end
--		if TSTTween ~= nil then
--			TSTTween:Pause()
--		end
--		for _, UIE in pairs(DurabilityUI:GetDescendants()) do
--			if UIE.Name == "MainFrame" then
--				UIE.BackgroundTransparency = 0.5
--			elseif UIE.Name == "DurabilityBar" then
--				UIE.BackgroundTransparency = 0.75
--			elseif UIE:IsA("TextLabel") then
--				UIE.TextTransparency = 0
--				UIE.TextStrokeTransparency = 0
--			end
--		end
--	end
--end

local SwordEquippedTime = 0

Tool.Equipped:Connect(function()
	SwordEquippedTime = SwordEquippedTime + 1
	logprint("SwordEquippedTime = "..SwordEquippedTime)
	Equipped = true
	--
	if Handle:FindFirstChild("EquipSound") ~= nil then
		Handle.EquipSound:Play()
	end
	if Handle:FindFirstChild("IdleSound") ~= nil then
		Handle.IdleSound:Play()
	end
	--
	if PlayerCharacter == nil then
		PlayerCharacter = Tool.Parent
	end
	if Abilities[1] ~= nil then
		AbilityUI.Parent = Player.PlayerGui
	end
	if PlayerCharacter and PlayerCharacter:FindFirstChildOfClass("Humanoid") then
		
		for _, Animation in pairs(MainSettings.MainAnimationTable) do
			if Animation.Type == "Equip" then
				if Handle:FindFirstChild("EAnimation") == nil then
					local EAnimation = Instance.new("Animation",Handle)
					EAnimation.Name = "EAnimation"
					EAnimation.AnimationId = Animation.ID
				end
				if Handle:FindFirstChild("EAnimation") then
					EAnimationLoad = PlayerCharacter:FindFirstChildOfClass("Humanoid"):LoadAnimation(Handle.EAnimation)
					EAnimationLoad:Play(nil,nil,Animation.Speed)
				end
			elseif Animation.Type == "Idle" then
				coroutine.wrap(function()
					if EAnimationLoad then
						EAnimationLoad.Stopped:Wait()
					end
					if Handle:FindFirstChild("IAnimation") == nil then
						local IAnimation = Instance.new("Animation",Handle)
						IAnimation.Name = "IAnimation"
						IAnimation.AnimationId = Animation.ID
					end
					if Handle:FindFirstChild("IAnimation") then
						IAnimationLoad = PlayerCharacter:FindFirstChildOfClass("Humanoid"):LoadAnimation(Handle.IAnimation)
						IAnimationLoad:Play(nil,nil,Animation.Speed)
					end
				end)()
			end
		end
		
	end
	if WeaponTags.EquipAttackDelay and WeaponTags.EquipAttackDelay > 0 then
		ChargeBar_Charge(WeaponTags.EquipAttackDelay)
		local Coroutine = coroutine.create(function()
			if Equipped == true then
				-- logprint("Active!")
				Active = true
			end
		end)
		local SET = SwordEquippedTime
		delay(WeaponTags.EquipAttackDelay,function()
			coroutine.resume(Coroutine)
			
			-- ===== IDLE INSPECTION BELOW ===== --
	
			local IdleInspectionTable = {}
			for _, Anm in pairs(MainSettings["MainAnimationTable"]) do
				if Anm.Type == "IdleInspection" then
					table.insert(IdleInspectionTable, Anm)
				end
			end
			
			if IdleInspectionTable[1] ~= nil then
	
				corouPlayIdleInspection = coroutine.wrap(function()
					local Timer
			
					local function waitcorou(timevar)
						for i = 1, timevar*50 do
							RunService.Heartbeat:wait()
							if Equipped == false then
								return true
							end
						end
						return nil
					end
			
					while true do
						logprint("IdleInspection Ping")
						local BreakPairs = false
						if Equipped == true and SET == SwordEquippedTime then
							for _, Animation in pairs(IdleInspectionTable) do
								if BreakPairs == false then
									local Rnd = Random.new():NextNumber(1, 100)
									logprint("Rnd = "..Rnd.." / Animation Frequency = "..Animation.Frequency)
									if Rnd < Animation.Frequency then
										logprint("Play Pass!")
										BreakPairs = true
										if Handle:FindFirstChild("FrequencyAnim") == nil then
											local FANIM = Instance.new("Animation",Handle)
											FANIM.Name = "FrequencyAnim"
											FANIM.AnimationId = Animation.ID
										end
										if Handle:FindFirstChild("FrequencyAnim") then
											local FANIMLoad = PlayerCharacter:FindFirstChildOfClass("Humanoid"):LoadAnimation(Handle.EAnimation)
											FANIMLoad:Play(nil,nil,Animation.Speed)
										end
										wait(Animation.LoopDelay)
									end
								end
							end
						else
							break
						end
						local Waiting = waitcorou(1)
						if Waiting == true then
							break
						end
					end
				end)
				corouPlayIdleInspection()
			
			end
			
		end)
	else
		Active = true
	end
	if MainSettings.TotalWeaponDurability then
		DurabilityActivate()
	end
	if ChargeBar and VisualSettings.EnableChargeBar then
		ChargeBar.Parent = Player.PlayerGui
		ChargeBar_Move()
	end
	
	
end)

Tool.Unequipped:Connect(function()
	-- logprint("Inactive!")
	Equipped = false
	Active = false
	if ChargeBar then
		ChargeBar.Parent = script
	end
	if AbilityUI then
		AbilityUI.Parent = script
	end
	if EAnimationLoad ~= nil then
		EAnimationLoad:Stop()
	end
	if IAnimationLoad ~= nil then
		IAnimationLoad:Stop()
	end
	if Handle:FindFirstChild("IdleSound") ~= nil then
		Handle.IdleSound:Play()
	end
	if corouPlayIdleInspection ~= nil then
		coroutine.yield(corouPlayIdleInspection)
	end
	ClearAllDurabilityUI()
	PlayerCharacter = nil
end)

local Holding = false

local ClientImpactTableHandle1 = {}
local ClientImpactTableHandle2 = {}

local RaycastHBModule = require(ClientModules:WaitForChild("RaycastHitbox"))

local HitboxEnabled = false
local Hitbox

local SCRaycastInitiate = AttackEF:WaitForChild("SCRaycastInitiate")

function FindTarget(Player, CAttackFrame)
	logprint"F1"
	if PlayerCharacter ~= nil and Tool ~= nil then
		logprint"F2"
		
		logprint("FINDING TARGET IN CLIENT")
		logprint(CAttackFrame)
		
		local AF = require(Tool.MainModule[CAttackFrame])
		if AF == nil then
			logprint("AF == nil")
			AF = require(Tool.MainModule[CurrentAttackFrame])
		end
		
		ClientImpactTableHandle1 = {}
		ClientImpactTableHandle2 = {}
		local FRHT = FindMiscEffects("ResetHitboxTimes", AF)
		if FRHT ~= nil then
			FRHT = FRHT[Random.new():NextInteger(1, #FRHT)]
			for i, v in pairs(FRHT.HitboxTable) do
				delay(v, function()
					--print("Reset table!")
					ClientImpactTableHandle1 = {}
					ClientImpactTableHandle2 = {}
				end)
			end
		end
		
		logprint("AF Delay : "..AF.AttackDelay)
		
		if AF ~= nil then
			
			local hitboxTimes
			if ChargeAmount > 0 then
				hitboxTimes = PlayRandomAnimation("AttackCharge", AF)
				PlayRandomSound("ChargeSwing", nil, nil, AF)
			elseif ChargeAmount == 1 then
				hitboxTimes = PlayRandomAnimation("AttackMaxCharge", AF)
				PlayRandomSound("MaxChargeSwing", nil, nil, AF)
			else
				-- print("hiGDFGHDFGSDFGHADFH")
				hitboxTimes = PlayRandomAnimation("Attack", AF)
				PlayRandomSound("Swing", nil, nil, AF)
			end
			
			Hitbox = RaycastHBModule:Deinitialize(Tool)
			Hitbox = RaycastHBModule:Initialize(Tool, {PlayerCharacter})
			
			--print("Hitbox Enabled", " // HitboxTimes : ", hitboxTimes)
			Hitbox:HitStart()
			if HBConnect ~= nil then
				HBConnect:Disconnect()
			end
			
			local AttackClangBool = false
			HBConnect = Hitbox.OnHit:Connect(function(hit, point, hum)
				--warn("hit ", hit, " point ", point, " hum ", hum)
				if hit and hum ~= ("AttackClang")
				and (table.find(ClientImpactTableHandle1, hum) == nil and AF.Handle1Hitbox == true or table.find(ClientImpactTableHandle2, hum) == nil and AF.Handle2Hitbox == true) 
				and hit.Parent:IsA("Tool") 
				and hit.Parent:FindFirstChild("ServerScript")
				and hit.Parent.ServerScript:FindFirstChild("Block")
				and point and (hit.Parent.ServerScript.Block.Value == true or WeaponTags.PassiveBlocking) then
					--warn("hello")
					if point.Attachment.Parent.Name == "Handle2" and AF.Handle2Hitbox == true then
						table.insert(ClientImpactTableHandle2, hum)
					elseif AF.Handle1Hitbox == true then
						table.insert(ClientImpactTableHandle1, hum)
					end
					--warn("Clang 1!")
					logprint"Handle the clang."
					PlayRandomSound("AttackClang", nil, {material = mName}, AF)
					--warn("Clang 2!")
					--FindClangData(AF, hit)
					--warn("Clang 3!")
					HandleClang:FireServer(hit, point, hum, AF, CAttackFrame)
					--warn("Clang 4!")
				elseif hit and point and hum and hum ~= ("AttackClang") and (table.find(ClientImpactTableHandle1, hum) == nil and AF.Handle1Hitbox == true or table.find(ClientImpactTableHandle2, hum) == nil and AF.Handle2Hitbox == true) then
					local SetHandle
					--warn("hello 2")
					if point.Attachment.Parent.Name == "Handle2" and AF.Handle2Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle2")
						table.insert(ClientImpactTableHandle2, hum)
					elseif AF.Handle1Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle")
						table.insert(ClientImpactTableHandle1, hum)
					end
					logprint("Pre-Attack_Server with AF Delay : "..AF.AttackDelay.." and AF Name : "..CAttackFrame)
					Attack_Server:FireServer(hum.Parent, SetHandle, nil, AF, CAttackFrame)
				elseif AttackClangBool == false then
					--print("Checking for AttackClang")
					local AttackClangE = FindMiscEffects("AttackClang", AF)
					if AttackClangE and hit and point and hum == ("AttackClang") then
						AttackClangBool = true
						--warn("AttackClang Client")
						HandleClang:FireServer(hit, point, hum, AF, CAttackFrame)
						FindClangData(AF, hit)
					end
				end
			end)
			
			if WeaponTags.ChainsawAttack == nil then
				coroutine.wrap(function()
					wait( math.clamp(hitboxTimes[2], hitboxTimes[1], AF.AttackDelay) or AF.AttackDelay )
					--print("Hitbox Disabled")
					HitboxEnabled = false
					if Hitbox ~= nil then
						Hitbox:HitStop()
					end
					if HBConnect ~= nil then
						HBConnect:Disconnect()
					end
				end)()
			end
			
		end
		
	end
end

SCRaycastInitiate.OnClientEvent:Connect(FindTarget)

local ChainsawOn = false

function StartChainsawF()
	if Player ~= nil and PlayerCharacter ~= nil and Active == true and Equipped == true and OnDelay == false then
		local Player = game:GetService("Players"):GetPlayerFromCharacter(PlayerCharacter)
		if Player ~= nil then
			logprint"Chainsaw initiated CLIENT"
			OnDelay = true
			
			PlayRandomAnimation("ChainsawStart")
			PlayRandomSound("ChainsawStart")
			
			wait(WeaponTags.ChainsawAttackBeginDelay)
			
			--warn("ChainsawOn : ", ChainsawOn)
			if ChainsawOn == true then
				logprint("Chainsaw began CLIENT")
				
				PlayRandomAnimation("ChainsawLoop")
				PlayRandomSound("ChainsawLoop")
				
				HitboxEnabled = true
				ClientImpactTableHandle1 = {}
				ClientImpactTableHandle2 = {}
				
				--warn"Finding target?"
				FindTarget(Player, CurrentAttackFrame)
				
				local corouHitboxLoop = coroutine.wrap(function()
					while wait(WeaponTags.ChainsawTargetAttackCooldown) do
						ClientImpactTableHandle1 = {}
						ClientImpactTableHandle2 = {}
					end
				end)
				corouHitboxLoop()
				
			end
			
		end
	end
end

function EndChainsawF()
	if WeaponTags.ChainsawAttack and PlayerCharacter ~= nil and OnDelay == true then
		logprint"Chainsaw ended CLIENT" 
		ChainsawOn = false
		HitboxEnabled = false
		if Hitbox ~= nil then
			Hitbox:HitStop()
		end
		if HBConnect ~= nil then
			HBConnect:Disconnect()
		end
		delay(require(Tool.MainModule[CurrentAttackFrame]).AttackDelay,function()
			OnDelay = false
		end)
	end
end

------------------

local OnDelay2 = false

Tool.ChildAdded:Connect(function(child)
	if child.Name == ("DisableWeapon") then
		--
		if WeaponTags.ChainsawAttack and OnDelay == true and OnDelay2 == false then
			EndChainsaw:FireServer()
			EndChainsawF();
		end
		--
	end
end)


UIS.InputBegan:Connect(function(Input, Core)
	if Input and (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) and FMKGF:FindDisableWeapon(Tool) == false then
		Tick = os.clock()
		Holding = true
		
		if WeaponTags.ChainsawAttack == nil then
		repeat
			local ChargeDone = false
			if Equipped and Active and OnDelay == false and Tool.ServerScript.ServerDelay.Value == false then
				
				local AttackFrame = require(Tool.MainModule[CurrentAttackFrame])
				local AIAttackCharge = FindMiscEffects("AttackCharge", AttackFrame)
				
				if AIAttackCharge ~= nil and Equipped and Active and OnDelay == false and Tool.ServerScript.ServerDelay.Value == false then
					AIAttackCharge = AIAttackCharge[1]
					Charging = true
					local ChargingSoundS
					
					StartCharge:FireServer(AttackFrame)
					ChargeBar_Charge(AIAttackCharge.ChargeLength)
					delay(AIAttackCharge.ChargeLength,function()
						ChargeBar.Frame.Bar.Size = UDim2.new(1,0,1,0)	
					end)
					
					local Max = false
					
					while RunService.Heartbeat:wait() do
						local STick = math.abs(Tick - os.clock())
						if Charging == false or Equipped == false or Active == false then
							break
						end
					end
					
					ChargeDone = true
					if ChargingSoundS ~= nil then
						ChargingSoundS:Destroy()
					end
					EndCharge:FireServer()
				end
				
				if AttackFrame and Active and Equipped and FindMiscEffects("ThrowingAttack", AttackFrame) == nil then
					
					local ATKDelay = AttackFrame.AttackDelay
					local AAC = FindMiscEffects("AttackCharge", AttackFrame)
					
					ChargeAmount = 0
					
					if AAC ~= nil then
						AAC = AAC[1]
						GetChargeAmount(AAC)
						if AAC.ChargeAlterTable ~= nil then -- Gradual Increase
							-- logprint'Client Yes'
							ATKDelay = ATKDelay + (ATKDelay * (AttackFrame.AttackDelay)*ChargeAmount)
						end
					end
					
					logprint("ATKDelay for Client : "..ATKDelay)
					ChargeBar_Charge(ATKDelay)
					
					Initiate_Server:FireServer(Mouse.hit)
					OnDelay = true
					
					logprint("CHARGE = "..ChargeAmount)
					
					local hitboxTimes
					if ChargeAmount > 0 then
						hitboxTimes = PlayRandomAnimation("AttackCharge", AttackFrame, true)
					elseif ChargeAmount == 1 then
						hitboxTimes = PlayRandomAnimation("AttackMaxCharge", AttackFrame, true)
					else
						hitboxTimes = PlayRandomAnimation("Attack", AttackFrame, true)
					end
					
					delay(hitboxTimes[1] or 0,function()
						-- logprint'Hitbox Ready'
						HitboxEnabled = true
						FindTarget(Player, CurrentAttackFrame, hitboxTimes)
					end)
					
					wait(ATKDelay)
					CurrentAttackFrame = CurrentAttackFrame + 1
					if CurrentAttackFrame > TotalAttackFrames then
						CurrentAttackFrame = 1
					end
					OnDelay = false
					HitboxReady = false
					ClientImpactTableHandle1 = {}
					ClientImpactTableHandle2 = {}
					
				elseif FindMiscEffects("ThrowingAttack", AttackFrame) ~= nil then
					
					local ATKDelay = AttackFrame.AttackDelay
					Initiate_Server:FireServer(Mouse.hit)
					OnDelay = true
					PlayRandomAnimation("Attack")
					ChargeBar_Charge(ATKDelay)
					
					wait(ATKDelay)
					OnDelay = false
					HitboxReady = false
					
				end
			end
			wait(.1)
		until Holding == false or (WeaponTags.autoSwing == nil) or ChargeDone == true
		
		elseif WeaponTags.ChainsawAttack and Equipped and Active and OnDelay == false and Tool.ServerScript.ServerDelay.Value == false then
			logprint"CHAINSAW!!"
			StartChainsaw:FireServer()
			ChainsawOn = true
			StartChainsawF()
		end
		
	elseif Input and Input.UserInputType == Enum.UserInputType.Keyboard and Active == true and Core == false then
		SendInput2:FireServer(Input.KeyCode, 1) -- key hold
	end
end)

UIS.InputEnded:Connect(function(Input, Core)
	if Input and Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
		Tick = math.abs(Tick - os.clock())
		Holding = false
		Charging = false
		--warn("Ending chainsaw : ", OnDelay, OnDelay2)
		if WeaponTags.ChainsawAttack and ChainsawOn == true and OnDelay2 == false then
			--print("CHAINSAWON ===================== ", ChainsawOn, "TYPE 1")
			ChainsawOn = false
			--print("CHAINSAWON ===================== ", ChainsawOn, "TYPE 2")
			OnDelay2 = true
			
			local ATKDelay = require(Tool.MainModule[CurrentAttackFrame]).AttackDelay
			EndChainsaw:FireServer()
			EndChainsawF()
			StopAnimation("ChainsawLoop")
			StopSound("ChainsawLoop")
			PlayRandomAnimation("ChainsawEnd")
			PlayRandomSound("ChainsawEnd")
			ChargeBar_Charge(ATKDelay)
			
			wait(ATKDelay)
			OnDelay = false
			OnDelay2 = false
			HitboxReady = false
		end
	elseif Input and Input.UserInputType == Enum.UserInputType.Keyboard and Core == false and (Tool.Parent:FindFirstChild("DisableWeapon") ~= nil and Tool.Parent.DisableWeapon.Value == false or Tool.Parent:FindFirstChild("DisableWeapon") == nil) then
		if Active == true then
			SendInput:FireServer(Input.KeyCode, Mouse.Hit)
		end
		SendInput2:FireServer(Input.KeyCode, 2) -- key release
	end
end)