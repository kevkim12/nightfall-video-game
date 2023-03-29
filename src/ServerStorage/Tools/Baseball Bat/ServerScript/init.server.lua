local Tool = script.Parent
local Handle = Tool:WaitForChild("Handle")
local Players = game:GetService("Players")

local ScriptContext = game:GetService("ScriptContext")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FMKClientModules = ReplicatedStorage:WaitForChild("Modules")
local FMKGF = FMKClientModules:WaitForChild("MeleeGlobalFunctions")
FMKGF = require(FMKGF)

local ToolModule = require(Tool:WaitForChild("MainModule"))

local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Modules")

local FEMeleeKitEventsFolder = Tool:WaitForChild("Events")
local EFCharge = FEMeleeKitEventsFolder:WaitForChild("Charge")
local EFAttack = FEMeleeKitEventsFolder:WaitForChild("Attack")
local EFVisualise = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local EFInput = FEMeleeKitEventsFolder:WaitForChild("Input")
local EFAbility = FEMeleeKitEventsFolder:WaitForChild("Ability")
local EFMisc = FEMeleeKitEventsFolder:WaitForChild("Misc")

local ConstantModule = require(ServerModulesFolder:WaitForChild("ConstantModule"))
local AbilityModule = require(ServerModulesFolder:WaitForChild("AbilityModule"))

local MainSettings = ToolModule.MainSettings
local WeaponTags = MainSettings.WeaponTags
local AttackSettings = ToolModule.AttackSettings
local VisualSettings = ToolModule.VisualSettings

local Initiate_Server = EFAttack:WaitForChild("Initiate_Server")
local Initiate_ServerBE = Initiate_Server:WaitForChild("Initiate_ServerBE")

local Attack_ServerRE = EFAttack:WaitForChild("Attack_Server")

local SendInput = EFInput:WaitForChild("SendInput")
local SendInput2 = EFInput:WaitForChild("SendInput2")
local ReleaseInput = EFInput:WaitForChild("ReleaseInput")

local GetAbilities = EFAbility:WaitForChild("GetAbilities")

local RepairWeapon = EFMisc:WaitForChild("RepairWeapon")
local EnableChargeBar = EFMisc:WaitForChild("EnableChargeBar")

local HandleClang = EFMisc:WaitForChild("HandleClang")

local Tick = 0
local ChargeAmount = 0
local IsNPC = false

local StartCharge = EFCharge:WaitForChild("StartCharge")
local EndCharge = EFCharge:WaitForChild("EndCharge")

local StartChargeBE = StartCharge:WaitForChild("StartChargeBE")
local EndChargeBE = EndCharge:WaitForChild("EndChargeBE")

local StartChainsaw = EFCharge:WaitForChild("StartChainsaw")
local EndChainsaw = EFCharge:WaitForChild("EndChainsaw")

local VI = EFVisualise:WaitForChild("VisualiseIndicators")
local SE = EFVisualise:WaitForChild("ScreenshakeEvent")
local VE = EFVisualise:WaitForChild("VisualiseEffects")

local ServerDelay = script:WaitForChild("ServerDelay")

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

local PlayerCharacter

--

function VEFireFunc(Type, Data, MoreInfo)
	local GetPlayer = Players:GetPlayerFromCharacter(PlayerCharacter)
	--warn("VEFireFunc!!!!!!!!!", Data)
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= GetPlayer then
			--warn("DATA : ", Data)
			--warn(PlayerCharacter)
			VE:FireClient(player, Type, Data, PlayerCharacter)
		elseif MoreInfo and MoreInfo[1] ~= nil then
			--warn("DATA : ", Data)
			--warn("MORE INFO : ", MoreInfo)
			VE:FireClient(player, Type, Data, MoreInfo[2])
		end
	end
end

--

local Abilities = {}

for _,Ability in pairs(AbilityModule) do
	for _,ToolSetAbility in pairs(ToolModule.Abilities) do
		if Ability.AbilityName == ToolSetAbility then
			table.insert(Abilities, {Ability, false, Enum.KeyCode[Ability.AbilityKeybind]})
		end
	end
end

local function GetAbilitiesFunc()
	local AbilityTable = {}
	for _, Ability in pairs(AbilityModule) do
		for _,ToolSetAbility in pairs(ToolModule.Abilities) do
			if Ability.AbilityName == ToolSetAbility then
				table.insert(AbilityTable, {Ability.AbilityName, Ability.AbilityDescription, Ability.AbilityCooldown, Ability.AbilityKeybind})
			end
		end
	end
	logprint(#AbilityTable.." abilities in weapon "..Tool.Name)
	return AbilityTable
end
GetAbilities.OnServerInvoke = GetAbilitiesFunc

--

if WeaponTags.TotalWeaponDurability then
	local TotalDurability = script:FindFirstChild("TDR") or Instance.new("IntValue", script)
	if TotalDurability.Name == "Value" then
		TotalDurability.Name = "TDR"
		TotalDurability.Value = FMKGF:AddressTableValue(WeaponTags.TotalWeaponDurability)
	end
	local CurrentDurability = script:FindFirstChild("CDR") or Instance.new("IntValue", script)
	if CurrentDurability.Name == "Value" then
		CurrentDurability.Name = "CDR"
		CurrentDurability.Value = TotalDurability.Value
	end
end

function PlayMainSound(Sound)
	if Sound then
		local SelectedSound
		local SST = {}
		for _, CSound in pairs(MainSettings.MainSoundsTable) do
			if CSound.Type == Sound then
				table.insert(SST, CSound)
			end
		end
		SelectedSound = SST[Random.new():NextInteger(1, #SST)]
		if SelectedSound ~= nil then
			local SSI = Instance.new("Sound", Handle)
			SSI.SoundId = SelectedSound.ID
			SSI.PlaybackSpeed = FMKGF:AddressTableValue(SelectedSound.Speed)
			SSI.Volume = FMKGF:AddressTableValue(SelectedSound.Volume)
			SSI.PlayOnRemove = true
			SSI:Destroy()
		elseif SelectedSound == nil then
			logwarn("Cannot find MainSound : "..Sound)
		end
	end
end

--

local MAT = {} -- MainAnimationTable

function PlayMainAnimation(Animation)
	if Animation and PlayerCharacter ~= nil and PlayerCharacter:FindFirstChildOfClass("Humanoid") ~= nil then
		local PlayerCharHum = PlayerCharacter:FindFirstChildOfClass("Humanoid")
		local SelectedAnim
		for _, CAnim in pairs(MainSettings.MainAnimationTable) do
			if CAnim.Type == Animation then
				SelectedAnim = CAnim
			end
		end
		if SelectedAnim ~= nil then
			warn("PlayMainAnimation ", Animation)
			if IsNPC and IsNPC == true then
				local AnimI = Instance.new("Animation", PlayerCharHum)
				AnimI.AnimationId = SelectedAnim.ID
				local AnimLoad = PlayerCharHum:LoadAnimation(AnimI)
				AnimLoad:Play(nil, nil, SelectedAnim.Speed)
				table.insert(MAT, {Animation, AnimLoad})
			else
				warn("part 1 ", Animation)
				VEFireFunc(7, {PlayerCharHum, SelectedAnim, Animation}, {"here"})
				table.insert(MAT, {Animation})
			end
		elseif SelectedAnim == nil then
			logwarn("Cannot find MainAnimation : "..Animation)
		end
	end
end

function StopMainAnimation(Animation)
	if Animation then
		for _, CAnim in pairs(MAT) do
			if CAnim[1] == Animation then
				if CAnim[2] and CAnim[2] ~= nil then CAnim[2]:Stop() end
				VEFireFunc(8, {Animation}, {"here"})
				table.remove(MAT, table.find(MAT, CAnim))
			end
		end
	end
end

--

function CheckIfBroke(CDR)
	if CDR.Value <= 0 then
		CDR.Value = 0
		PlayMainSound("WeaponBreak")
		return true
	end
end

function HandleDurability(Amnt)
	if script:FindFirstChild("CDR") ~= nil and script:FindFirstChild("TDR") ~= nil then
		script.CDR.Value = math.clamp(script.CDR.Value - Amnt, 0, math.huge)
		if Amnt > 0 then
			PlayMainSound("WeaponTakeDamage")
		end
		local CIB = CheckIfBroke(script.CDR)
		return CIB
	end
end

local StopAttackPreMature = false

--

local TotalAttackFrames = 0
local CurrentAttackFrame = 1
local AttackFrameWaitingFor = nil -- Is set when InitiateWeapon (specifically ActivateRaycastInClient) is ran to prevent exploit bypassing of said AttackFrame.

--

function HandleClangF(Player, hit, point, hum, AF, SAFName)
	--warn("HandleClang Function")
	--print(AttackFrameWaitingFor, SAFName)
	if AttackFrameWaitingFor ~= SAFName then Player:Kick("uhhhh") end
	local AClang = FindMiscEffects("AttackClang", AF)
	if hit:IsA("BasePart")
	and hit.Parent ~= Tool
	and hit ~= Handle
	and hit ~= Handle2
	and StopAttackPreMature == false then
		--warn("step 1")
		if hit.Parent:IsA("Tool")
		and hit.Parent:FindFirstChild("ServerScript") ~= nil
		and hit.Parent:FindFirstChild("MainModule") ~= nil
		and hit.Parent.ServerScript:FindFirstChild("Block") ~= nil then
			--warn("going the blockin path")
			local hMM = require(hit.Parent.MainModule)
			local tHum = hit.Parent.Parent:FindFirstChildOfClass("Humanoid")
			if hMM ~= nil and tHum ~= nil and hMM.MainSettings.WeaponTags.AttackBlock ~= nil then
				local CBAPass = false
				if (hMM.MainSettings.WeaponTags.PassiveBlocking and hit.Parent.ServerScript.ServerDelay.Value == false)
				or hit.Parent.ServerScript.ServerDelay.Value == true
				or hit.Parent.ServerScript.Block.Value == true then
					CBAPass = true
				end		
				if CBAPass == true and StopAttackPreMature == false then -- Successful block
					local SetHandle
					if WeaponTags.ChainsawAttack == nil then
						StopAttackPreMature = true
					end
					--
					if hit.Parent:FindFirstChild("Events")
						and hit.Parent.Events:FindFirstChild("Misc")
						and hit.Parent.Events.Misc:FindFirstChild("ActivateAttackBlock") then
						hit.Parent.Events.Misc.ActivateAttackBlock:Fire()
					end
					--
					if point.Attachment.Parent.Name == "Handle2" and AF.Handle2Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle2")
					elseif AF.Handle1Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle")
					end
					--
					local dRed
					if hMM.MainSettings.WeaponTags.PassiveBlocking then dRed = hMM.MainSettings.WeaponTags.PassiveBlockingDamageReduction else dRed = hMM.MainSettings.WeaponTags.AttackBlockDamageReduction end
					--warn("ReduceDamage", dRed)
					--warn(tHum.Parent)
					Attack_Server(Player, tHum.Parent, SetHandle, {{"ReduceDamage", dRed}, ["AttackServerPass"] = true}, AF, CurrentAttackFrame)
				end		
			end
		end		
		if AClang ~= nil then
			--warn("going the clangin path")
			local mName
			for _, ACL in pairs(AClang) do
				--print("ACL added", ACL)
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
					--warn("CLANG!")
					logprint"CLANG!"
					StopAttackPreMature = true
					PlayRandomSound("AttackClang", nil, {material = mName}, AF)
					if ACL.StopAnimationOnActivate == true then
						--warn("stopping animations")
						StopAnimation("Attack")
						StopAnimation("AttackCharge")
						StopAnimation("AttackMaxCharge")
					end
					if ACL.StopSoundOnActivate == true then
						StopSound("Swing")
						StopSound("ChargeSwing")
						StopSound("MaxChargeSwing")
					end
					HandleDurability(FMKGF:AddressTableValue(ACL.DurabilityLoss))
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
							SE:FireClient(Player, FMKGF:AddressTableValue(ACSS.ScreenshakeLongevity), FMKGF:AddressTableValue(ACSS.ScreenshakeIntensity), ACSS.ScreenshakeVariant)
						end
					end
				end
			end		
		end		
	end
end
HandleClang.OnServerEvent:Connect(HandleClangF)

--

RepairWeapon.Event:Connect(function(RepairAmount)
	if WeaponTags.TotalWeaponDurability
	and script:FindFirstChild("CDR") ~= nil
	and script:FindFirstChild("TDR") ~= nil
	and RepairAmount ~= nil then
		script.CDR.Value = math.clamp(RepairAmount or 0, 0, script.TDR.Value)
	end
end)

for _,AFrame in pairs(Tool.MainModule:GetChildren()) do
	if AFrame:IsA("ModuleScript") then
		if tonumber(AFrame.Name) ~= nil then
			TotalAttackFrames = TotalAttackFrames + 1
		end
	end
end

function GetChargeAmount(AIAttackCharge)
	ChargeAmount = Tick/AIAttackCharge.ChargeLength
	if ChargeAmount > 1 then ChargeAmount = 1 end
end

function AlterStatAfterCharge(Value,TableStat,AttackInfo) -- TableStat MUST have gone through FMKGF:AddressTableValue!
	local AIAttackCharge = FindMiscEffects("AttackCharge", AttackInfo)
	if AIAttackCharge ~= nil then
		AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
		if AIAttackCharge.ChargeAlterTable ~= nil or AIAttackCharge.ChargeAlterTable == nil and ChargeAmount == 1 then
			return Value + (Value * ( TableStat - 1)*ChargeAmount )
		else
			return Value
		end
	else
		return Value
	end
end

function AssertCriticalChance(ACC,Damage)
	local CChance = ACC.CriticalChance[1]
	local RandomNumber = Random.new():NextInteger(1,ACC.CriticalChance[2])
	if RandomNumber <= CChance then
		return {true,Damage * ACC.CriticalDamageIncrease}
	else
		return {false,nil}
	end
end

local SoundTable = {}

function PlaySound(Sound, SType, SParent, MoreInfo)
	VEFireFunc(3, {Sound, SType, SParent, Handle}, MoreInfo or {})
	
	--local SoundInstance = Instance.new("Sound")
	--SoundInstance.SoundId = Sound[1]
	--SoundInstance.PlaybackSpeed = FMKGF:AddressTableValue(Sound[2]) or 1
	--SoundInstance.Volume = FMKGF:AddressTableValue(Sound[3]) or 0.5
	--SoundInstance.TimePosition = FMKGF:AddressTableValue(Sound[4]) or 0
	--SoundInstance.Name = ("RandSound")
		
	--if SType == "ChainsawLoop" then
	--	SoundInstance.Looped = true
	--	table.insert(SoundTable, SoundInstance)
	--end
		
	--if SParent == nil then SoundInstance.Parent = Handle else SoundInstance.Parent = SParent end
	----
	--local corouPlaySound = coroutine.wrap(function()
	--	--
	--  wait(FMKGF:AddressTableValue(Sound[5]) or 0)
	--	repeat RunService.Heartbeat:wait() until SoundInstance.TimeLength ~= 0
	--	SoundInstance:Play()
	--	logprint("Sound TimeLength = "..SoundInstance.TimeLength.." / Sound PlaybackSpeed = "..SoundInstance.PlaybackSpeed)
	--	logprint("Sound Playing For : "..SoundInstance.TimeLength / SoundInstance.PlaybackSpeed)
	--	repeat RunService.Heartbeat:wait() until SoundInstance.Playing == false
	--	SoundInstance:Destroy(); SoundInstance = nil
	--	--
	--end)
	--corouPlaySound()
end

function PlayRandomSound(SType,SParent, ArgumentTable, AttackFrame, MoreInfo)
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
				PlaySound(Sound, SType, SParent, MoreInfo)
			else
				local WarnText = "No sound found for type : "..SType.."."
				if SType == "ChargeImpactSound" or SType == "MaxChargeImpactSound" then
					local FRSImpact = FindRandomSound("ImpactSound")
					if FRSImpact ~= nil then
						PlaySound(FRSImpact, SType, SParent, MoreInfo)
						WarnText = WarnText.." Playing ImpactSound instead"	
					end
				elseif SType == "ChargeSwing" or SType == "MaxChargeSwing" then
					local FRSImpact = FindRandomSound("Swing")
					if FRSImpact ~= nil then
						PlaySound(FRSImpact, SType, SParent)
						WarnText = WarnText.." Playing Swing instead"	
					end
				end
			end
		end
	end
end

function StopSound(soundType) -- unfinished. only works for chainsaw.
	VEFireFunc(4, {soundType}, {"aaa"})
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

function EmitHurtParticle(Particle,SParent,Amount)
	if Particle ~= nil and SParent ~= nil then
		local CParticle = Particle:Clone()
		CParticle.Parent = SParent
		CParticle:Emit(Amount)
		game:GetService("Debris"):AddItem(CParticle,CParticle.Lifetime.Max)
	end
end

function HandleAbilityDelay(Ability)
	Ability[2] = true
	delay(Ability[1].AbilityCooldown,function()
		Ability[2] = false
	end)
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

SendInput.OnServerEvent:Connect(function(Player, Input, MouseCFrame) -- Sends input based on key press.
	if Input and (MouseCFrame and typeof(MouseCFrame) == 'CFrame') then
		for _,Ability in pairs(Abilities) do
			if Input == Ability[3] and Ability[2] == false then
				if Ability[1].PreventExecutionDuringAttackFrame == true and ServerDelay.Value == false or Ability[1].PreventExecutionDuringAttackFrame == false then
					HandleAbilityDelay(Ability)
					ReleaseInput:FireClient(Player,Ability[1].AbilityName)
					Ability[1].AbilityServerFunc(Player, Tool, MouseCFrame)
				end
			end
		end
	elseif MouseCFrame and (typeof(MouseCFrame) == 'CFrame') == false then Player:Kick("No") end
end)

local KeyHolding = {}

function CheckKeyHolding(Key)
	for keyVal, kC in pairs(KeyHolding) do
		if kC == Key then
			table.remove(KeyHolding, table.find(KeyHolding, Key))
			return true
		end
	end
end

local Enabled = false

-- AttackBlock

local ABlockingEnabled = true

local ABlocking = false
local ABTempDelay = false

local Count = 0

local OrigWS

local BlockValue = script:WaitForChild("Block")
local AAB = EFMisc:WaitForChild("ActivateAttackBlock")
--

--[[
	EquipTypes
	==========
	
	1 - holding
	2 - released
--]]

AAB.Event:Connect(function()
	PlayMainSound("AttackBlockImpact")
	PlayMainAnimation("AttackBlockImpact")
	if WeaponTags.TotalWeaponDurability then
		HandleDurability( FMKGF:AddressTableValue(WeaponTags.AttackBlockDurabilityLoss) )
	end
end)

SendInput2.OnServerEvent:Connect(function(Player, Input, EquipType) -- Sends input based on key hold / release.
	if Input then
		local CKH = CheckKeyHolding(Input)
		if CKH == nil then
			table.insert(KeyHolding, Input)
		end
		-- check-again factors
		if CKH == true and EquipType == 1 then
			CheckKeyHolding(Input)
		elseif CKH == nil and EquipType == 2 then
			CheckKeyHolding(Input)
		end
		--
		function EndBlock()
			if ABlocking == true then
				ABlocking = false
				BlockValue.Value = false
				if PlayerCharacter ~= nil and PlayerCharacter:FindFirstChildOfClass("Humanoid") ~= nil then
					PlayerCharacter:FindFirstChildOfClass("Humanoid").WalkSpeed = OrigWS
				end
				ABlockingEnabled = false
				if VisualSettings.EnableChargeBar then
					EnableChargeBar:FireClient(Player, WeaponTags.AttackBlockEndDelay)
				end
				delay(WeaponTags.AttackBlockEndDelay, function()
					ABlockingEnabled = true
				end)
				StopMainAnimation("AttackBlockLoop")
				PlayMainSound("AttackBlockEnd")
				PlayMainAnimation("AttackBlockEnd")
			end
		end
		--
		if Enabled == true then
			if WeaponTags.AttackBlock and Input == WeaponTags.AttackBlockKey and ABlockingEnabled == true then
				if ABTempDelay == true then
					ABTempDelay = false
					return
				end
				Count = Count + 1
				local OCount = Count
				if ABlocking == false and CKH == nil and EquipType == 1 then
					ABlocking = true
					if PlayerCharacter ~= nil and PlayerCharacter:FindFirstChildOfClass("Humanoid") ~= nil then
						OrigWS = PlayerCharacter:FindFirstChildOfClass("Humanoid").WalkSpeed
						PlayerCharacter:FindFirstChildOfClass("Humanoid").WalkSpeed = WeaponTags.AttackBlockWalkspeedChange
					end
					PlayMainSound("AttackBlockStart")
					PlayMainAnimation("AttackBlockStart")
					wait(WeaponTags.AttackBlockStartDelay)
					if ABlocking == true then
						BlockValue.Value = true
						StopMainAnimation("AttackBlockLoop")
						PlayMainAnimation("AttackBlockLoop")
						PlayMainSound("AttackBlockLoop")
						coroutine.wrap(function()
							wait(WeaponTags.AttackBlockHoldMax)
							if ABlocking == true and OCount == Count then
								EndBlock(true)
							end
						end)()
					end
				elseif ABlocking == true and EquipType == 2 then
					EndBlock()
				end
			end
		end
	end
end)

function AddMotor6D(Arm, GripName)
	if WeaponTags.Motor6DGripType then
		if WeaponTags.Motor6DGripType == 1 then
			local getWeld = Arm:WaitForChild(GripName)
			local motor = Instance.new("Motor6D")
			motor.Name = "HandleMotor6D"
			motor.Part0 = getWeld.Part0
			motor.Part1 = getWeld.Part1
			getWeld:Destroy()
			motor.Parent = Arm
		elseif WeaponTags.Motor6DGripType == 2 then
			local getWeld = Arm:WaitForChild(GripName)
			local CJ = CFrame.new(Handle.Position)
			local w = Instance.new("Motor6D")
			w.Name = "HandleMotor6D"
			w.Part0 = Arm
			w.Part1 = Handle
			w.C0 = (Arm.CFrame:inverse() * CJ) * CFrame.Angles(Handle.CFrame:toEulerAnglesXYZ()) 
			w.C1 = (Handle.CFrame:inverse() * CJ) * CFrame.Angles(Handle.CFrame:toEulerAnglesXYZ())
			getWeld:Destroy()
			w.Parent = Arm
		end
	end
end

local ExistingHandle2 = Tool:FindFirstChild("Handle2")
if ExistingHandle2 then ExistingHandle2 = ExistingHandle2:Clone(); Tool:FindFirstChild("Handle2"):Destroy() end

Tool.Equipped:Connect(function()
	--if Handle:FindFirstChild("EquipSound") ~= nil then
	--	Handle.EquipSound:Play()
	--end
	--if Handle:FindFirstChild("IdleSound") ~= nil then
	--	Handle.IdleSound:Play()
	--end
	--
	if PlayerCharacter == nil then
		if Tool.Parent:FindFirstChildOfClass("Humanoid") then
			PlayerCharacter = Tool.Parent
		end
	end
	if Players:GetPlayerFromCharacter(PlayerCharacter) == nil then
		IsNPC = true
	else
		IsNPC = false
	end
	--
	local SoundTable = {}
	if Handle:FindFirstChild("EquipSound") ~= nil then
		table.insert(SoundTable, Handle.EquipSound)
	end
	if Handle:FindFirstChild("IdleSound") ~= nil then
		table.insert(SoundTable, Handle.IdleSound)
	end
	VEFireFunc(5, SoundTable)
	--
	if WeaponTags.WeaponWalkspeedChange and PlayerCharacter ~= nil then
		OriginalWalkSpeed = PlayerCharacter:FindFirstChildOfClass("Humanoid").WalkSpeed
		PlayerCharacter:FindFirstChildOfClass("Humanoid").WalkSpeed = WeaponTags.WeaponWalkspeedChange
	end
	local Left = PlayerCharacter:FindFirstChild("LeftHand") ~= nil and PlayerCharacter["LeftHand"] or PlayerCharacter:FindFirstChild("Left Arm")
	local Right = PlayerCharacter:FindFirstChild("RightHand") ~= nil and PlayerCharacter["RightHand"] or PlayerCharacter:FindFirstChild("Right Arm")
	if WeaponTags.dualWield then
		Handle2 = ExistingHandle2 and ExistingHandle2:Clone() or Handle:Clone()
		Handle2.Name = "Handle2"
		if Handle2:FindFirstChild("EquipSound") ~= nil then Handle2.EquipSound:Destroy() end
		Handle2.Parent = Tool
		Handle2.CanCollide = false
		if Right then
			local LeftWeld = Instance.new("Weld",Handle2)
			LeftWeld.Part0 = Left
			LeftWeld.Part1 = Handle2
			LeftWeld.C0 = CFrame.new(0,-1,0,1,0,-0,0,0,1,0,-1,-0)
			LeftWeld.C1 = Tool.Grip
			LeftWeld.Name = "LeftGrip"
			Handle2.CanCollide = false
		end
		AddMotor6D(Handle2, "LeftGrip")
	end
	AddMotor6D(Right, "RightGrip")
	Enabled = true
end)

Tool.Unequipped:Connect(function()
	Enabled = false
	if EndBlock ~= nil then
		EndBlock(true)
	end
	if WeaponTags.dualWield == true then
		Handle2:Destroy()
	end
	if OriginalWalkSpeed ~= nil and PlayerCharacter ~= nil then
		PlayerCharacter:FindFirstChildOfClass("Humanoid").WalkSpeed = OriginalWalkSpeed
	end
	PlayerCharacter = nil
end)

local ServerImpactTableHandle1 = {}
local ServerImpactTableHandle2 = {}

function DealDamage(Target,Damage,BonusTable,AttackInfo) -- AttackInfo is an optional argument.
	if Target:FindFirstChildOfClass("Humanoid") ~= nil then
		Target:FindFirstChildOfClass("Humanoid"):TakeDamage(math.floor(Damage))
		
		local ConstantsTable = {}
		if WeaponTags.TotalWeaponDurability then
			local ATKSlash = FindMiscEffects("AttackDurability", AttackInfo)
			if ATKSlash ~= nil then
				ATKSlash = ATKSlash[Random.new():NextInteger(1, #ATKSlash)]
				local HD = HandleDurability(FMKGF:AddressTableValue(ATKSlash.AttackSlashDU))
				if HD == true then
					return
				end
			end
		end
		
		if VisualSettings.VisibleDamageTag then -- Damage Tag
			VI:FireAllClients(Target,Damage,BonusTable)
		end
		
		local AIConstantInflicts = FindMiscEffects("ConstantInflicts", AttackInfo)
		if AIConstantInflicts ~= nil then
			for _,Constant in pairs(AIConstantInflicts[Random.new():NextInteger(1, #AIConstantInflicts)].ConstantTable) do -- Constant Check
				for _,ModuleConstants in pairs(ConstantModule) do
					if Constant[1] == ModuleConstants.ConstantName then
						table.insert(ConstantsTable,{Constant,ModuleConstants})
					end
				end
			end
		end
		
		for _,VConstant in pairs(ConstantsTable) do -- Verified Constant
			local CChance = VConstant[1][2][1]
			local RandomNumber = Random.new():NextInteger(1,VConstant[1][2][2])
			if RandomNumber <= CChance then
				local DisablePESpawn = false
				for _,V in pairs(Target:GetChildren()) do
					if V.Name == "ConstantScript" and V:FindFirstChild("ConstantValue") then
						if V.ConstantValue.Value == VConstant[1][1] then -- Cleanup
							V:Destroy()
							if VConstant[2].CustomBillboardRoute ~= nil and Target:FindFirstChild("Head") then
								for _,V in pairs(Target:FindFirstChild("Head"):GetChildren()) do
									if V:IsA("BillboardGui") and V.Name == VConstant[2].CustomBillboardRoute.Name then
										V:Destroy()
									end
								end
							end
							if VConstant[2].ConstantParticleRoute ~= nil then
								for _,Part in pairs(Target:GetChildren()) do
									if Part:IsA("Part") or Part:IsA("WedgePart") or Part:IsA("CornerWedgePart") or Part:IsA("UnionOperation") then
										for _,PoP in pairs(Part:GetChildren()) do
											if PoP:IsA("ParticleEmitter") and PoP.Name == VConstant[2].ConstantParticleRoute.Name then DisablePESpawn = true end
										end
									end
								end
							end
						end
					end
				end
				
				local CScript = Tool.ServerScript.ConstantScript:Clone()
				if not VisualSettings.VisibleDamageTag then
					local DisableTags = Instance.new("BoolValue")
					DisableTags.Name = ("DisableTags")
					DisableTags.Parent = CScript
				end
				CScript.Parent = Target
				--local UsingTool = Instance.new("ObjectValue")
				--UsingTool.Name = ("UsingTool")
				--UsingTool.Value = Tool
				--UsingTool.Parent = CScript
				local ConstantValue = Instance.new("StringValue",CScript)
				ConstantValue.Name = "ConstantValue"
				ConstantValue.Value = VConstant[1][1]
				if DisablePESpawn == true then
					local DisablePEValue = Instance.new("StringValue",CScript)
					DisablePEValue.Name = "DisablePE"
				end
				CScript.Disabled = false
				
			end
		end
		
		local PHarshImpact = FindMiscEffects("HarshImpact", AttackInfo)
		local TargetHum = Target:FindFirstChild("Humanoid")
		if PHarshImpact ~= nil then
			for AMT = 1, #PHarshImpact do
				local HImpact = PHarshImpact[AMT]
				for _,HIPParentRoute in pairs(HImpact.HIPPR) do
					if HIPParentRoute == "Handle1" then
						EmitHurtParticle(HImpact.HIPER,Tool:FindFirstChild("Handle"),HImpact.HIPA)
					elseif HIPParentRoute == "Handle2" then
						EmitHurtParticle(HImpact.HIPER,Tool:FindFirstChild("Handle2"),HImpact.HIPA)
					elseif TargetHum then
						local NewStringRoute = string.gsub(HIPParentRoute, "Target", "")
						if TargetHum.RigType == Enum.HumanoidRigType.R6 then
							NewStringRoute = string.gsub(NewStringRoute, "Arm", " Arm")
							NewStringRoute = string.gsub(NewStringRoute, "Leg", " Leg")
						elseif TargetHum.RigType == Enum.HumanoidRigType.R15 then
							NewStringRoute = string.gsub(NewStringRoute, "Arm", "UpperArm")
							NewStringRoute = string.gsub(NewStringRoute, "Leg", "UpperLeg")
						end
						pcall(function()
							if Target[HIPParentRoute] then
								EmitHurtParticle(HImpact.HIPER, Target[HIPParentRoute], HImpact.HIPA)
							end
						end)
					end
				end
				RunService.Heartbeat:wait()
			end
		end
		
		local PLifesteal = FindMiscEffects("Lifesteal", AttackInfo)
		if PLifesteal ~= nil then -- Lifesteal
			PLifesteal = PLifesteal[Random.new():NextInteger(1, #PLifesteal)]
			local LifestealPercentageN = FMKGF:AddressTableValue(PLifesteal.LifestealPercentage)
			if LifestealPercentageN ~= nil then
				PlayerCharacter:FindFirstChildOfClass("Humanoid").Health = PlayerCharacter:FindFirstChildOfClass("Humanoid").Health + (Damage * (LifestealPercentageN/100) )
			end
		end
		
		local AIAttackCharge = FindMiscEffects("AttackCharge", AttackInfo)
		if AIAttackCharge ~= nil then
			AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
			if ChargeAmount == 1 then
--				logprint'MaxChargeImpact'
				PlayRandomSound("MaxChargeImpactSound", nil, nil, AttackInfo, {Target, true})
			else
--				logprint'ChargeImpact'
				PlayRandomSound("ChargeImpactSound", nil, nil, AttackInfo, {Target, true})
			end
		elseif AIAttackCharge == nil and BonusTable[1] == nil then
--			logprint'NormalImpact'
			PlayRandomSound("ImpactSound", nil, nil, AttackInfo, {Target, true})
		end
		
		for _,Bonus in pairs(BonusTable) do
			if Bonus == "CriticalChance" then
--				logprint'CriticalImpact'
				PlayRandomSound("CriticalImpact", nil, nil, AttackInfo)
			elseif Bonus == "Backstab" then
				PlayRandomSound("Backstab", nil, nil, AttackInfo)
			end
		end
		
	else
		return logwarn("No humanoid found in "..Target.Name.."!")
	end
end

function AttackTarget(Player,Target,CAttackFrame,AttackInfo,ATHandle,AdditionalTable) -- AdditionalTable Accepted Commands [ReduceDamage only, you can add more yourself, if you want to, though.]
	if Target and AttackInfo then
		local BonusTable = {}
		local BaseDamage = FMKGF:AddressTableValue(AttackInfo.BaseDamage)
		
		-- Before Damage
		
		if WeaponTags.CreatorTag and Target:FindFirstChildOfClass("Humanoid") ~= nil then -- Creator Tag
			if Target:FindFirstChildOfClass("Humanoid"):FindFirstChild("creator") ~= nil then
				Target:FindFirstChildOfClass("Humanoid").creator:Destroy()
			end
			local cTag = Instance.new("ObjectValue", Target:FindFirstChildOfClass("Humanoid"))
			cTag.Name = "creator"
			cTag.Value = Player
			if tonumber(WeaponTags.CreatorTag or 5) ~= nil then
				game:GetService("Debris"):AddItem(cTag, WeaponTags.CreatorTag or 5)
			else
				game:GetService("Debris"):AddItem(cTag,1)
			end
		end
		
		local PTargetScreenshake = FindMiscEffects("TargetScreenshake", AttackInfo)
		local TargetCentre = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Torso")
		if TargetCentre and PTargetScreenshake ~= nil then -- Screenshake
			PTargetScreenshake = PTargetScreenshake[Random.new():NextInteger(1, #PTargetScreenshake)]
			PlayRandomSound("TargetScreenshakeSound", TargetCentre, nil, AttackInfo)
			for _,Model in pairs(workspace:GetChildren()) do
				if Model:FindFirstChildOfClass("Humanoid") ~= nil then
					local ModelCentre = Model:FindFirstChild("HumanoidRootPart") or Model:FindFirstChild("Torso")
					if ModelCentre and (ModelCentre.Position - TargetCentre.Position).magnitude <= PTargetScreenshake.ScreenshakeRadius then
						local PPlayer = Players:GetPlayerFromCharacter(Model)
						if PPlayer ~= nil then
							local AIAttackCharge = FindMiscEffects("AttackCharge", AttackInfo)
							if AIAttackCharge ~= nil then
								AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
								SE:FireClient(PPlayer, AlterStatAfterCharge( FMKGF:AddressTableValue(PTargetScreenshake.ScreenshakeLongevity) , FMKGF:AddressTableValue(FindMiscEffects("AttackCharge",AttackInfo)[Random.new():NextInteger(1, #AIAttackCharge)].ChargeAlterTable.ScreenshakeLongevityMultiplier or 1),AttackInfo ), AlterStatAfterCharge( FMKGF:AddressTableValue(PTargetScreenshake.ScreenshakeIntensity) , FMKGF:AddressTableValue(FindMiscEffects("AttackCharge",AttackInfo)[Random.new():NextInteger(1, #AIAttackCharge)].ChargeAlterTable.ScreenshakeIntensityMultiplier or 1),AttackInfo ), PTargetScreenshake.ScreenshakeVariant)
							else
								SE:FireClient(PPlayer, AlterStatAfterCharge( FMKGF:AddressTableValue(PTargetScreenshake.ScreenshakeLongevity) , FMKGF:AddressTableValue({1}),AttackInfo ), AlterStatAfterCharge( FMKGF:AddressTableValue(PTargetScreenshake.ScreenshakeIntensity) , FMKGF:AddressTableValue({1}),AttackInfo ), PTargetScreenshake.ScreenshakeVariant)
							end
						end
					end
				end
			end
		end
		
		local PAttackKnockback = FindMiscEffects("AttackKnockback", AttackInfo)
		if PAttackKnockback ~= nil then -- Knockback
			PAttackKnockback = PAttackKnockback[Random.new():NextInteger(1, #PAttackKnockback)]
			local Knockback = FMKGF:AddressTableValue(PAttackKnockback.KnockbackForce)
			local Centre = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Torso")
			local PlayerCentre = PlayerCharacter:FindFirstChild("HumanoidRootPart") or PlayerCharacter:FindFirstChild("Torso")
			if Centre and PlayerCentre and Knockback ~= nil then
				local Direction = CFrame.new(Centre.Position, Vector3.new(PlayerCentre.CFrame.p.X, Centre.Position.Y ,PlayerCentre.CFrame.p.Z))
				local KnockbackPowerBonus = 1
				local KnockbackDurationBonus = 1
				
				local AIAttackCharge = FindMiscEffects("AttackCharge", AttackInfo)
				if AIAttackCharge ~= nil then
					AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
					KnockbackPowerBonus = AlterStatAfterCharge(KnockbackPowerBonus,FMKGF:AddressTableValue(FindMiscEffects("AttackCharge",AttackInfo)[Random.new():NextInteger(1, #AIAttackCharge)].ChargeAlterTable.KnockbackForceMultiplier or 1),AttackInfo)
					KnockbackDurationBonus = AlterStatAfterCharge(KnockbackDurationBonus,FMKGF:AddressTableValue(FindMiscEffects("AttackCharge",AttackInfo)[Random.new():NextInteger(1, #AIAttackCharge)].ChargeAlterTable.KnockbackDurationMultiplier or 1),AttackInfo)
				end
				
				local KnockbackBooster = Instance.new("BodyVelocity", Centre)
				KnockbackBooster.Velocity = -Direction.lookVector * ( FMKGF:AddressTableValue(PAttackKnockback.KnockbackForce) * KnockbackPowerBonus)
				KnockbackBooster.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
				KnockbackBooster.P = math.huge
				delay(FMKGF:AddressTableValue(PAttackKnockback.KnockbackDuration) * KnockbackDurationBonus,function()
					KnockbackBooster:Destroy()
				end)
			end	
		end
		
		local CritChance = FindMiscEffects("AttackCriticalChance", AttackInfo)
		if CritChance ~= nil then -- Critical Chance
			local CChance = AssertCriticalChance(CritChance[1], BaseDamage)
			if CChance[1] == true and CChance[2] ~= nil then
				BaseDamage = CChance[2]
				table.insert(BonusTable,"CriticalChance")
			end
		end
		
		if WeaponTags.BackstabEnabled then -- Backstab
			local TargetHum = Target:FindFirstChildOfClass("Humanoid")
			local TargetCentre = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Torso")
			local PlayerCentre = PlayerCharacter:FindFirstChild("HumanoidRootPart") or PlayerCharacter:FindFirstChild("Torso")
--			logprint( (Target.Torso.Position - Target.Torso.CFrame.lookVector * 2) - Tool[Handle].Position)
			if TargetHum and TargetCentre and PlayerCentre and TargetHum.Health > 0 and ( (TargetCentre.Position - TargetCentre.CFrame.lookVector * 2) - ATHandle.Position).magnitude < WeaponTags.BackstabRange and (TargetCentre.CFrame.lookVector - PlayerCentre.CFrame.lookVector).magnitude <= WeaponTags.BackstabRange then
				BaseDamage = BaseDamage * WeaponTags.BackstabDamageMultiplier
				table.insert(BonusTable,"Backstab")
			end
		end
		
		if WeaponTags.TotalWeaponDurability then
			local DL = 0.5 
			local Durability = (script.CDR.Value - script.TDR.Value) / script.TDR.Value
			local ATKDurability = FindMiscEffects("AttackDurability", AttackInfo)
			local DamageLimit = 1
			if ATKDurability ~= nil then
				ATKDurability = ATKDurability[Random.new():NextInteger(1, #ATKDurability)]
				DamageLimit = ATKDurability.DUDamageLimit
			end
			BaseDamage = BaseDamage + (BaseDamage *  (DamageLimit) * Durability)
		end
		local AIAttackCharge = FindMiscEffects("AttackCharge", AttackInfo)
		if AIAttackCharge ~= nil then
			AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
			BaseDamage = AlterStatAfterCharge(BaseDamage,FMKGF:AddressTableValue(AIAttackCharge.ChargeAlterTable.DamageMultiplier or 1),AttackInfo)
		end
		if AdditionalTable ~= nil then
			for _,Commands in pairs(AdditionalTable) do
				
				
				if Commands ~= true and Commands[1] == "ReduceDamage" then -- Check for command called
					if Commands[2] ~= nil then -- Check for needed arguments
						if tonumber(Commands[2]) ~= nil then -- Code
							BaseDamage = BaseDamage * Commands[2]
						end
					end 
				end
				
--				if Commands[1] == "Test" then
--					if Commands[2] ~= nil then
--						
--						logprint ("Nice! This works!")
--						
--					end
--				end
				
			end
		end
		DealDamage(Target,BaseDamage,BonusTable,AttackInfo)
	end
end

--

local AnimationsPlaying = {}

function PlayRandomAnimation(AType, AttackFrame)
	warn("PLAYRANDOMANIMATION : "..AType)
	local returning
	if AType ~= nil then
		local TableRandom = {}
		--
		for _,Animation in pairs(AttackFrame ~= nil and AttackFrame.AnimationTable or require(Tool.MainModule[CurrentAttackFrame]).AnimationTable) do
			if Animation.animationType == AType then
				table.insert(TableRandom,{Animation.ID,FMKGF:AddressTableValue(Animation.speed),Animation.animationType,Animation.hitboxTimes})
			end
		end
		--
		if TableRandom ~= nil then
			local Animation = TableRandom[Random.new():NextInteger(1,#TableRandom)]
			if Animation ~= nil and PlayerCharacter ~= nil then
				local PAnimation
				if IsNPC and IsNPC == true then
					local IAnimation = Instance.new("Animation",Tool.Handle)
					IAnimation.AnimationId = Animation[1]
					PAnimation = PlayerCharacter:FindFirstChildOfClass("Humanoid"):LoadAnimation(IAnimation)
					--logprint(Animation[2])
					PAnimation:Play(nil,nil,Animation[2])
					IAnimation:Destroy()
				else
					warn("Chainsaw play anim")
					VEFireFunc(1, Animation)
				end
				function PAnimStop()
					if PAnimation then PAnimation:Stop() end
				end
				table.insert(AnimationsPlaying,{Type = Animation[3], AnimInstance = PAnimation})
				if Animation[4] ~= nil then
					returning = Animation[4]
				end
			else
				logwarn("No animation found for type : "..AType)
			end
		end
	end
	return returning
end

function StopAnimation(AType, MoreInfo)
	local Select = 0
	for _, Animation in pairs(AnimationsPlaying) do
		Select = Select + 1
		--print(Animation)
		if Animation.Type == AType then
			if IsNPC and IsNPC == true then
				--print(Animation.AnimInstance)
				PAnimStop()
				--warn("aniamtion stopped 2222222222")
			else
				VEFireFunc(2, AType, MoreInfo)
			end
			table.remove(AnimationsPlaying,Select)
		end
	end
end

--

local ChargeTries = 0

function StartChargeF(Player,AttackFrame)
	Tick = os.clock()
	PlayRandomAnimation("Charging", AttackFrame)
	local ChargingSound = FindRandomSound("Charging", AttackFrame)
	PlayRandomSound("ChargingSingle")
	local AIAttackCharge = FindMiscEffects("AttackCharge", AttackFrame)
	--
	if AIAttackCharge ~= nil then
		AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
		if ChargingSound ~= nil then
			ChargingSoundS = Instance.new("Sound",Tool.Handle)
			ChargingSoundS.SoundId = ChargingSound[1]
			ChargingSoundS.PlaybackSpeed = FMKGF:AddressTableValue(ChargingSound[2])
			ChargingSoundS.Volume = FMKGF:AddressTableValue(ChargingSound[3])
			ChargingSoundS.Looped = true
			ChargingSoundS:Play()
		end
		--
		coroutine.wrap(function()
			local OGCT = ChargeTries
			wait(AIAttackCharge.ChargeLength)
			if ChargeTries == OGCT then
				StopAnimation("Charging")
				PlayRandomAnimation("MaxCharging", AttackFrame)
			end
		end)()
		--
		if ChargingSound and AIAttackCharge.ChargingSound_IncreasePitch == true then
			local ChargeTween = game:GetService("TweenService"):Create(ChargingSoundS,TweenInfo.new(AIAttackCharge.ChargeLength,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0),{PlaybackSpeed = (ChargingSoundS.PlaybackSpeed * FMKGF:AddressTableValue(AIAttackCharge.ChargingSound_MaxPitchMultiplier) ) } )
			ChargeTween:Play()
		end
	end
	
end

function EndChargeF()
	ChargeTries = ChargeTries + 1
	StopAnimation("Charging")
	StopAnimation("MaxCharging")
	Tick = math.abs(Tick - os.clock())
	if ChargingSoundS ~= nil then
		ChargingSoundS:Destroy()
	end
end

--
StartCharge.OnServerEvent:Connect(StartChargeF)
StartChargeBE.Event:Connect(StartChargeF)

EndCharge.OnServerEvent:Connect(EndChargeF)
EndChargeBE.Event:Connect(EndChargeF)
--

--

local HitboxEnabled = false
local Hitbox

local ChainsawOn = false -- exclusive for ChainsawAttack

function StartChainsawF()
	if PlayerCharacter ~= nil and Enabled ~= false and ServerDelay.Value == false then
		local Player = Players:GetPlayerFromCharacter(PlayerCharacter)
		if Player ~= nil then
			warn("Chainsaw started")
			logprint"Chainsaw initiated SERVER"
			ServerDelay.Value = true
			ChainsawOn = true
			PlayRandomAnimation("ChainsawStart")
			PlayRandomSound("ChainsawStart")
			wait(WeaponTags.ChainsawAttackBeginDelay)
			if ChainsawOn == true then
				logprint("Chainsaw began SERVER")
				AttackFrameWaitingFor = CurrentAttackFrame
				--
				StopAnimation("ChainsawStart")
				PlayRandomSound("ChainsawLoop")
				PlayRandomAnimation("ChainsawLoop")
				--
				HitboxEnabled = true
				ServerImpactTableHandle1 = {}
				ServerImpactTableHandle2 = {}
				--
				coroutine.wrap(function()
					while wait(WeaponTags.ChainsawTargetAttackCooldown) do
						ServerImpactTableHandle1 = {}
						ServerImpactTableHandle2 = {}
					end
				end)()
				--
			end
			
		end
	end
end

function EndChainsawF()
	if WeaponTags.ChainsawAttack and PlayerCharacter ~= nil and ServerDelay.Value == true then
		warn("Chainsaw ended")
		logprint"Chainsaw ended."
		ChainsawOn = false
		StopAnimation("ChainsawLoop")
		StopAnimation("ChainsawStart")
		StopSound()
		PlayRandomSound("ChainsawEnd")
		PlayRandomAnimation("ChainsawEnd")
		HitboxEnabled = false
		coroutine.wrap(function()
			wait(require(Tool.MainModule[CurrentAttackFrame]).AttackDelay)
			ServerDelay.Value = false
		end)()
	end
end

--
StartChainsaw.OnServerEvent:Connect(StartChainsawF)

EndChainsaw.OnServerEvent:Connect(EndChainsawF)
Tool.Unequipped:Connect(EndChainsawF)
--

local SCRaycastInitiate = EFAttack:WaitForChild("SCRaycastInitiate")

local RaycastHitbox = require(game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("RaycastHitbox"))

function FindTarget(Player, CAttackFrame, hitboxTimes)
	if PlayerCharacter ~= nil and Tool ~= nil then
		local AF = CAttackFrame
		if AF == nil then
			AF = require(Tool.MainModule[CurrentAttackFrame])
		end
		if AF ~= nil then
			Hitbox = RaycastHitbox:Deinitialize(Tool)
			Hitbox = RaycastHitbox:Initialize(Tool, {PlayerCharacter})
			Hitbox:HitStart()
			if HBConnect ~= nil then
				HBConnect:Disconnect()
			end
			--HBConnect = Hitbox.OnHit:Connect(function(hit, point, hum)
			--	if hit and point and hum then
			--		local SetHandle
			--		if point.Attachment.Parent.Name == "Handle2" and AF.Handle2Hitbox == true then
			--			SetHandle = Tool:WaitForChild("Handle2")
			--		elseif AF.Handle1Hitbox == true then
			--			SetHandle = Tool:WaitForChild("Handle")
			--		end
			--		Attack_Server(Player, hum.Parent, SetHandle, nil, AF, CurrentAttackFrame)
			--	elseif hit and point and hum == nil then
			--		HandleClangF(Player, hit, point, hum, AF)
			--	end
			--end)
			local AttackClangBool = false
			HBConnect = Hitbox.OnHit:Connect(function(hit, point, hum)
				--warn("hit ", hit, " point ", point, " hum ", hum)
				warn(WeaponTags.AttackBlock, hit , point , hum , hum ~= ("AttackClang") , (AF.Handle1Hitbox == true or AF.Handle2Hitbox == true) , AttackClangBool == false)
				if hit and hum ~= ("AttackClang")
				and (AF.Handle1Hitbox == true or AF.Handle2Hitbox == true) 
				and hit.Parent:IsA("Tool") 
				and hit.Parent:FindFirstChild("ServerScript")
				and hit.Parent.ServerScript:FindFirstChild("Block")
				and hit.Parent.ServerScript.Block.Value == true and point and (WeaponTags.PassiveBlocking or WeaponTags.AttackBlock) then
					local SetHandle
					if point.Attachment.Parent.Name == "Handle2" and AF.Handle2Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle2")
					elseif AF.Handle1Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle")
					end
					PlayRandomSound("AttackClang", nil, nil, AF)
					--warn("Clang 2!")
					--FindClangData(AF, hit)
					--warn("Clang 3!")
					HandleClangF(Player, hit, point, hum, AF, CurrentAttackFrame)
					--warn("Clang 4!")
				elseif hit and point and hum and hum ~= ("AttackClang") and (AF.Handle1Hitbox == true or AF.Handle2Hitbox == true) and AttackClangBool == false then
					local SetHandle
					if point.Attachment.Parent.Name == "Handle2" and AF.Handle2Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle2")
					elseif AF.Handle1Hitbox == true then
						SetHandle = Tool:WaitForChild("Handle")
					end
					Attack_Server(Player, hum.Parent, SetHandle, nil, AF, CurrentAttackFrame)
				elseif AttackClangBool == false then
					local AttackClangE = FindMiscEffects("AttackClang", AF)
					if AttackClangE and hit and point and hum == ("AttackClang") then
						AttackClangBool = true
						Hitbox:HitStop()
						HandleClangF(Player, hit, point, hum, AF, CurrentAttackFrame)
					end
				end
			end)
			coroutine.wrap(function()
				wait(math.clamp(hitboxTimes[2], hitboxTimes[1], AF.AttackDelay) or AF.AttackDelay)
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

function InitiateWeapon(Player,MouseCFrame,SelectedAttackFrame,PlayerBE, NPCTag)
	local CSTReturning = FMKGF:FindDisableWeapon(Tool)
	if CSTReturning == true then return end
	--
	local Valid = true
	local ActivateRaycastInClient = false
	if SelectedAttackFrame ~= nil then
		if Player ~= nil then
			Valid = false -- player cannot set the selected attack frame.
		else
			ActivateRaycastInClient = true
		end
	end
	if Player == nil and PlayerBE ~= nil then
		Player = PlayerBE
	end
	--
	if WeaponTags.AttackBlock and WeaponTags.AttackBlockDisableAttacks then
		if EndBlock ~= nil then
			EndBlock(true) -- Ends a currently running block if there is one (if ABDA is set to true)
		end
	end
	--
	if Enabled == true and ServerDelay.Value == false and Valid == true then
		--
		local AttackFrame
		if SelectedAttackFrame ~= nil then
			AttackFrame = require(Tool.MainModule[SelectedAttackFrame])
		else
			AttackFrame = require(Tool.MainModule[CurrentAttackFrame])
		end
		--
		if ActivateRaycastInClient == true then
			if Player ~= nil then
				SCRaycastInitiate:FireClient(Player, SelectedAttackFrame, SelectedAttackFrame)
				AttackFrameWaitingFor = SelectedAttackFrame
				logprint(AttackFrameWaitingFor.." = AttackFrameWaitingFor")
			else
				logwarn("No player is present! Cannot run AttackFrame properly.")
			end
		elseif ActivateRaycastInClient == false then
			AttackFrameWaitingFor = CurrentAttackFrame
			logprint(AttackFrameWaitingFor.." = AttackFrameWaitingFor")
		end
		ServerDelay.Value = true
		StopAttackPreMature = false
		local ATKDelay = AttackFrame.AttackDelay
		logprint("ATKDelay : "..ATKDelay)
		if SelectedAttackFrame ~= nil then
			EnableChargeBar:FireClient(Player, ATKDelay)
		end
		if WeaponTags.TotalWeaponDurability then
			local ATKDurability = FindMiscEffects("AttackDurability", AttackFrame)
			if ATKDurability ~= nil then
				ATKDurability = ATKDurability[Random.new():NextInteger(1, #ATKDurability)]
				local HD = HandleDurability(FMKGF:AddressTableValue(ATKDurability.AttackInitiateDU))
				if HD == true then
					return
				end
			end
		end
		local hitboxTimes
		local AIAttackCharge = FindMiscEffects("AttackCharge", AttackFrame)
		if AIAttackCharge ~= nil then
			AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
			if Tick/AIAttackCharge.ChargeLength >= 1 then
				hitboxTimes = PlayRandomAnimation("AttackMaxCharge", AttackFrame)
			else
				hitboxTimes = PlayRandomAnimation("AttackCharge", AttackFrame)
			end
		end
		if hitboxTimes == nil then
			hitboxTimes = PlayRandomAnimation("Attack", AttackFrame)
		end
		local AIAFWS = FindMiscEffects("AttackFrameWalkSpeed", AttackFrame)
		if AIAFWS ~= nil then
			AIAFWS = AIAFWS[Random.new():NextInteger(1, #AIAFWS)]
			if PlayerCharacter ~= nil and PlayerCharacter:FindFirstChildOfClass("Humanoid") ~= nil then
				-- DelayTable[1] = AttackDelay, DelayTable[2] = WalkSpeedChange --
				for _, DelayTable in pairs(AIAFWS.SpeedTable) do
					delay(DelayTable[1], function()
						PlayerCharacter:FindFirstChildOfClass("Humanoid").WalkSpeed = DelayTable[2]
					end)
				end
			end
		end
		--
		coroutine.wrap(function()
			wait(hitboxTimes[1] or 0)
			HitboxEnabled = true
			if NPCTag ~= nil then
				logprint("Initiate raycast here!")
				FindTarget(Player, AttackFrame, hitboxTimes)
			end
		end)()
		coroutine.wrap(function()
			wait(math.clamp(hitboxTimes[2], hitboxTimes[1], AttackFrame.AttackDelay) or AttackFrame.AttackDelay)
			HitboxEnabled = false
		end)()
		--
		local FRHT = FindMiscEffects("ResetHitboxTimes", AttackFrame)
		if FRHT ~= nil then
			FRHT = FRHT[Random.new():NextInteger(1, #FRHT)]
			for i, v in pairs(FRHT.HitboxTable) do
				delay(v, function()
					ServerImpactTableHandle1 = {}
					ServerImpactTableHandle2 = {}
				end)
			end
		end
		--
		if VisualSettings.VisibleTrail and FindMiscEffects("ThrowingAttack", AttackFrame) == nil then
			for i = 1, 2 do
				local HandleT = {AttackFrame["Handle"..(i).."Hitbox"]; "Handle"..(i)}
				if HandleT[1] == true then
					local HandleL
					if HandleT[2] == "Handle1" and Tool:FindFirstChild("Handle") ~= nil then HandleL = Tool:FindFirstChild("Handle") 
					elseif HandleT[2] == "Handle2" and Tool:FindFirstChild("Handle2") ~= nil then HandleL = Tool:FindFirstChild("Handle2") end
					if HandleL:FindFirstChild("MeleeTrail") ~= nil
					and HandleL:FindFirstChild("AttachmentBottom") ~= nil
					and HandleL:FindFirstChild("AttachmentTop") ~= nil
					and HandleL:FindFirstChild("MeleeTrail") then
						HandleL.MeleeTrail.Enabled = true
						if HandleL:FindFirstChild("MeleeTrail2")
						and HandleL:FindFirstChild("AttachmentMiddle") then
							HandleL.MeleeTrail2.Enabled = true
						end						
					end
				end
			end
		end
		local AIAttackCharge = FindMiscEffects("AttackCharge", AttackFrame)
		if AIAttackCharge ~= nil then
			AIAttackCharge = AIAttackCharge[Random.new():NextInteger(1, #AIAttackCharge)]
			GetChargeAmount(AIAttackCharge)
			if ChargeAmount == 1 then
				PlayRandomSound("MaxChargeSwing", nil, nil, AttackFrame)
			else
				PlayRandomSound("ChargeSwing", nil, nil, AttackFrame)
			end
			if AIAttackCharge.ChargeAlterTable ~= {} then -- Gradual Increase
				-- logprint'Server Yes'
				ATKDelay = ATKDelay + (ATKDelay * (AttackFrame.AttackDelay)*ChargeAmount)
			end
		elseif AIAttackCharge == nil then
			PlayRandomSound("Swing", nil, nil, AttackFrame)
		end
		
		-- logprint("ATKDelay for Server : "..ATKDelay)
		local PAttackScreenshake = FindMiscEffects("AttackScreenshake", AttackFrame)
		if PAttackScreenshake ~= nil then
			for _, pAS in pairs(PAttackScreenshake) do
				coroutine.wrap(function()
					wait(FMKGF:AddressTableValue(pAS.Delay))
					PlayRandomSound("AttackScreenshakeSound", nil, nil, AttackFrame)
					SE:FireClient(Player, FMKGF:AddressTableValue(pAS.ScreenshakeLongevity), FMKGF:AddressTableValue(pAS.ScreenshakeIntensity), pAS.ScreenshakeVariant)
				end)()
			end
		end
		
		local PHeal = FindMiscEffects("Heal", AttackFrame)
		if PHeal ~= nil then
			for _, hE in pairs(PHeal) do
				coroutine.wrap(function()
					wait(hE.Delay)
					if PlayerCharacter ~= nil and PlayerCharacter:FindFirstChildOfClass("Humanoid") ~= nil then
						PlayerCharacter:FindFirstChildOfClass("Humanoid").Health = PlayerCharacter:FindFirstChildOfClass("Humanoid").Health + FMKGF:AddressTableValue(hE.HealAmount)
					end
				end)()
			end
		end
		
		local PAttackCharge2 = FindMiscEffects("AttackCharge2", AttackFrame)
		if PAttackCharge2 ~= nil then
			for _, pAC2 in pairs(PAttackCharge2) do
				coroutine.wrap(function()
					wait(tonumber(pAC2.Delay))
					local PlayerCentre = PlayerCharacter:FindFirstChild("HumanoidRootPart") or PlayerCharacter:FindFirstChild("Torso")
					if PlayerCentre then
						local ChargeSPSMultiplier = 1
						local AAC = FindMiscEffects("AttackCharge", AttackFrame)
						if AAC ~= nil then
							AAC = AAC[Random.new():NextInteger(1, #AAC)]
							ChargeSPSMultiplier = AlterStatAfterCharge(ChargeSPSMultiplier,FMKGF:AddressTableValue(AAC.ChargeAlterTable.AttackCharge2SPSMultiplier),AttackFrame)
						end
						
						local CFrame2
						if pAC2.Charge2Type == 1 then
							CFrame2 = Vector3.new(MouseCFrame.p.X, PlayerCentre.Position.Y, MouseCFrame.p.Z)
						elseif pAC2.Charge2Type == 2 then
							CFrame2 = PlayerCentre.CFrame.lookVector
						end
						
						local Direction = CFrame.new(PlayerCentre.Position, CFrame2)
						local Charge2Gyro = Instance.new("BodyGyro", PlayerCentre)
						Charge2Gyro.MaxTorque = Vector3.new(1000000,1000000,1000000)
						Charge2Gyro.D = 100
						Charge2Gyro.P = 10000
						Charge2Gyro.CFrame = Direction
						local Charge2Booster = Instance.new("BodyVelocity", PlayerCentre)
						Charge2Booster.Velocity = Direction.lookVector * (FMKGF:AddressTableValue(pAC2.Charge2SPS) * ChargeSPSMultiplier)
						Charge2Booster.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
						Charge2Booster.P = math.huge
						game:GetService("Debris"):AddItem(Charge2Booster,tonumber(pAC2.Charge2Length))
						game:GetService("Debris"):AddItem(Charge2Gyro,tonumber(pAC2.Charge2Length))
					end
				end)()
			end
		end
		
		local FThrowingAttack = FindMiscEffects("ThrowingAttack", AttackFrame)
		if FThrowingAttack ~= nil then
			FThrowingAttack = FThrowingAttack[Random.new():NextInteger(1, #FThrowingAttack)]
			coroutine.wrap(function()
				wait(tonumber(FThrowingAttack.ThrowDelay))
				--
				Handle.Transparency = 1
				if Tool:FindFirstChild("Handle2") ~= nil then
					Tool.Handle2.Transparency = 1
				end
				
				local Handles = 0
				if AttackFrame.Handle1Hitbox == true then
					Handles = Handles + 1
				end
				if AttackFrame.Handle2Hitbox == true then
					Handles = Handles + 1
				end
				
				if PlayerCharacter ~= nil and PlayerCharacter:FindFirstChildOfClass("Humanoid").Health > 0 then
					for i = 1, Handles do
						
						local HandleN
						local ThrowingVelocity = FMKGF:AddressTableValue(FThrowingAttack.ThrowingVelocity)
						
						if i == 2 then HandleN = Tool:WaitForChild"Handle2":Clone() else HandleN = Tool:WaitForChild"Handle":Clone() end
						
						local StartPos = HandleN.CFrame
						local Direction = CFrame.new(StartPos.p, MouseCFrame.p)
						
						
						local P = HandleN:Clone()
						P.Velocity = (Direction.lookVector * ThrowingVelocity)
						P.CanCollide = true
						P.Anchored = false
						P.CFrame = (Direction + Direction.lookVector * 4.5)
						P.Transparency = 0
						
						if FThrowingAttack.ThrowingType == 2 then
	
							local BVelocity = Instance.new("BodyVelocity")
							BVelocity.Velocity = P.CFrame.lookVector * ThrowingVelocity
							BVelocity.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
							BVelocity.Parent = P
							
						end
						
						P.Orientation = P.Orientation + FThrowingAttack.ProjectileThrowingRotation
						
						local Values = { -- TESTING
							{Name = "Creator", Class = "ObjectValue", Value = Player},
							{Name = "Origin", Class = "Vector3Value", Value = StartPos.p},
							{Name = "Damage", Class = "NumberValue", Value = FMKGF:AddressTableValue(AttackFrame.BaseDamage)},
							{Name = "BaseProjectile", Class = "ObjectValue", Value = HandleN},
							{Name = "Lifetime", Class = "NumberValue", Value = FMKGF:AddressTableValue(FThrowingAttack.ProjectileLifetime)},
							{Name = "ProjectileLand", Class = "BoolValue", Value = FThrowingAttack.ProjectileLand},
							{Name = "ProjectileLandRotation", Class = "Vector3Value", Value = FThrowingAttack.ProjectileLandRotation},
						}
						
						local PScript = Tool.ServerScript:FindFirstChild("ProjectileScript"):Clone()
						PScript.Parent = P
						PScript.Disabled = false
						
						for i, v in pairs(Values) do
							local Value = Instance.new(v.Class)
							Value.Name = v.Name
							Value.Value = v.Value
	--						logprint(v.Value)
							Value.Parent = PScript
						end
						
						local HitEvent = PScript.HitE
						HitEvent.Event:Connect(function(Hit)
							if Hit.Parent:FindFirstChildOfClass("Humanoid") ~= nil then
								AttackTarget(Player,Hit.Parent,(SelectedAttackFrame == nil and CurrentAttackFrame or SelectedAttackFrame),AttackFrame,Handle)
							end
						end)
						P.Parent = workspace
						
					end
				end
				--
			end)()
		end
		--
		coroutine.wrap(function()
			wait(ATKDelay)
			Tick = 0
			ServerDelay.Value = false
			
			if SelectedAttackFrame == nil then
				CurrentAttackFrame = CurrentAttackFrame + 1
			
				if CurrentAttackFrame > TotalAttackFrames then
					CurrentAttackFrame = 1
				end
			end
			
			ServerImpactTableHandle1 = {}
			ServerImpactTableHandle2 = {}
			AttackFrameWaitingFor = nil
			
			if Tool:FindFirstChild("Handle") ~= nil then if FindMiscEffects("ThrowingAttack", AttackFrame) ~= nil then Tool.Handle.Transparency = 0 end if Tool.Handle:FindFirstChild("MeleeTrail") ~= nil then Tool.Handle.MeleeTrail.Enabled = false end if Tool.Handle:FindFirstChild("MeleeTrail2") ~= nil then Tool.Handle.MeleeTrail2.Enabled = false end end
			if Tool:FindFirstChild("Handle2") ~= nil then if FindMiscEffects("ThrowingAttack", AttackFrame) ~= nil then Tool.Handle2.Transparency = 0 end if Tool.Handle:FindFirstChild("MeleeTrail") ~= nil then Tool.Handle.MeleeTrail.Enabled = false end if Tool.Handle:FindFirstChild("MeleeTrail2") ~= nil then Tool.Handle.MeleeTrail2.Enabled = false end end
		end)()
	end
end

--
Initiate_Server.OnServerEvent:Connect(InitiateWeapon)
Initiate_ServerBE.Event:Connect(InitiateWeapon)
--

function Attack_Server(Player, Target, ATHandle, AddT, SelectedAttackFrame, SAFName)
	--warn("Attack_Server ", Player, Target, ATHandle, AddT, SelectedAttackFrame, SAFName)
	if (Player:IsA("Player") and Player.Character or Player) == PlayerCharacter and PlayerCharacter:FindFirstChild("Humanoid") and PlayerCharacter.Humanoid.Health > 0 
	and Target and Target ~= PlayerCharacter and Target:FindFirstChildOfClass("Humanoid") ~= nil and Target:FindFirstChildOfClass("Humanoid").Health > 0 
	and ATHandle and ServerDelay.Value == true and StopAttackPreMature == false and HitboxEnabled == true or (AddT ~= nil and AddT["AttackServerPass"] ~= nil) then
		--
		local AttackServerBasicPass = false
		if AttackFrameWaitingFor ~= nil then
			if SAFName ~= nil then
				if SAFName == AttackFrameWaitingFor then
					AttackServerBasicPass = true
				else
					logwarn("POTENTIAL EXPLOITER BYPASS [Case 1]")
				end
			else
				logwarn("POTENTIAL EXPLOITER BYPASS [Case 2]")
			end
		end
		--
		local MaxDistance
		local DistanceFromTarget
		local TargetCentre = Target:FindFirstChild("Torso") or Target:FindFirstChild("HumanoidRootPart")
		if WeaponTags.SafeHitbox and TargetCentre then
			local TargetTorsoPos = TargetCentre.Position
			local PlayerCharTorsoPos = (Tool:FindFirstChild("Handle2") and ATHandle == "Handle2") and Tool.Handle2:FindFirstChild("AttachmentTop").WorldPosition or Handle:FindFirstChild("AttachmentTop").WorldPosition
			local AttachmentTopPos = (Tool:FindFirstChild("Handle2") and ATHandle == "Handle2") and Tool.Handle2:FindFirstChild("AttachmentTop").WorldPosition or Handle:FindFirstChild("AttachmentTop").WorldPosition
			local AttachmentBottomPos = (Tool:FindFirstChild("Handle2") and ATHandle == "Handle2") and Tool.Handle2:FindFirstChild("AttachmentBottom").WorldPosition or Handle:FindFirstChild("AttachmentBottom").WorldPosition
			--
			local TargetRay = Ray.new(PlayerCharTorsoPos, (TargetCentre.Position - PlayerCharTorsoPos).unit * 300)
			local PartHit, PartPos = workspace:FindPartOnRay(TargetRay, PlayerCharacter)
			--
			if PartHit and PartHit.Parent:FindFirstChildOfClass("Humanoid") == nil then return end
			--
			local Allow = true
			local Allow2 = true
			--
--			if VisualSettings.DebuggingInstances == true then
--				local function NewPart(position) local Part = Instance.new("Part") Part.Anchored = true; Part.Size = Vector3.new(0.5,0.5,0.5) Part.CanCollide = false Part.Position = position Part.Parent = workspace end
--				NewPart(PlayerCharTorsoPos); NewPart(PartPos)
--			end
			--
			DistanceFromTarget = (PlayerCharTorsoPos - PartPos).magnitude
			MaxDistance = (AttachmentBottomPos - AttachmentTopPos).magnitude
			logwarn((MaxDistance + 1 + WeaponTags.SafeHitRange).." // "..DistanceFromTarget)
		end
		--
		if WeaponTags.SafeHitbox and (MaxDistance + 1 + WeaponTags.SafeHitRange) < DistanceFromTarget then AttackServerBasicPass = false; return end
		--
		if TargetCentre and AttackServerBasicPass == true and ATHandle then
			logprint("Attack Server : Basic Pass Certificate!")
			logprint(SelectedAttackFrame.AttackDelay)
			local Allow = true
			local Allow2 = true
	
			if ATHandle.Name == "Handle" then
				for _,PTarget in pairs(ServerImpactTableHandle1) do
					if PTarget == Target then
						Allow = false
					end
				end
				if Allow == true then table.insert(ServerImpactTableHandle1,Target) end
			elseif ATHandle.Name == "Handle2" then
				for _,PTarget in pairs(ServerImpactTableHandle2) do
					if PTarget == Target then
						Allow = false
					end
				end
				if Allow == true then table.insert(ServerImpactTableHandle2,Target) end
			end
			
			if WeaponTags.TEAMEnabled then
				if PlayerCharacter ~= nil and PlayerCharacter:FindFirstChild("TEAM") then
					if Target ~= nil and Target:FindFirstChild("TEAM") then
						if PlayerCharacter.TEAM.Value ~= Target.TEAM.Value then
							-- Allowed
						else
							Allow2 = false
						end
					else
						Allow2 = false
					end
				else
					logwarn("WARNING : Player does not have TEAM value upon hitting target!")
					Allow2 = false
				end
			else
				-- Allowed
			end
			
			if Allow == true and Allow2 == true then
				local AttackFrame
				if SelectedAttackFrame == nil then
					AttackFrame = require(Tool.MainModule[CurrentAttackFrame])
				else
					AttackFrame = SelectedAttackFrame
				end
				if AttackFrame ~= nil then
					
					local AdditionalTable = AddT or {}
					
					local PAOE = FindMiscEffects("AOE", AttackFrame)
					if PAOE ~= nil then
						PAOE = PAOE[1]
						for _, T in pairs(workspace:GetChildren()) do
							if T:IsA("Model") and T:FindFirstChildOfClass("Humanoid") and T ~= Target and T ~= PlayerCharacter then
								local TCentre = T:FindFirstChild("HumanoidRootPart") or T:FindFirstChild("Torso")
								local TargetCentre = Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Torso")
								if TCentre and TargetCentre and (TargetCentre.Position - TCentre.Position).magnitude < PAOE.AOERange then
									local Access = false
									if WeaponTags.TEAMEnabled and Target:FindFirstChild("TEAM") ~= nil and T:FindFirstChild("TEAM") ~= nil then
										if Target.TEAM.Value ~= T.TEAM.Value then
											Access = true
										end
									else
										Access = true
									end
									if Access == true then
										local ATAOE = AddT or {}
										table.insert(ATAOE, {"ReduceDamage", 0.75})
										AttackTarget(Player,T,(SelectedAttackFrame == nil and CurrentAttackFrame or SelectedAttackFrame),AttackFrame,ATHandle,ATAOE)
									end
								end
							end
						end
					end
					
					AttackTarget(Player,Target,(SelectedAttackFrame == nil and CurrentAttackFrame or SelectedAttackFrame),AttackFrame,ATHandle, AdditionalTable)
				end
			end
		end
	end
end

Attack_ServerRE.OnServerEvent:Connect(function(Player, Target, ATHandle, AddT, SelectedAttackFrame, SAFName)
	--warn("AttackServerRE Function")
	Attack_Server(Player, Target, ATHandle, nil, SelectedAttackFrame, SAFName)
end)