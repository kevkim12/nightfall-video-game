local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Miscs = ReplicatedStorage:WaitForChild("Miscs")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local WeaponSettings = Modules.WeaponSettings
local Gun = WeaponSettings.Gun
local GlassShattering = require(Modules.GlassShattering)
local DamageModule = require(Modules.DamageModule)
local Utilities = require(Modules.Utilities)
local Math = Utilities.Math
local CompareTables = Utilities.CompareTables

local PlayAudio = Remotes.PlayAudio
local VisualizeHitEffect = Remotes.VisualizeHitEffect
local VisualizeBullet = Remotes.VisualizeBullet
local VisualizeBeam = Remotes.VisualizeBeam
local VisibleMuzzle = Remotes.VisibleMuzzle
local VisualizeGore = Remotes.VisualizeGore
local ShatterGlass = Remotes.ShatterGlass
local InflictTarget = Remotes.InflictTarget

_G.TempBannedPlayers = {}

local KickPlayer = false -- I recommend to keep this false to avoid false positive
local PhysicEffect = true -- For base parts (blocks) only (Glass shattering)

local function SecureSettings(Player, Tool, Module)
	if Player and Tool then
		local Folder = Gun:FindFirstChild(Tool.Name)
		if Folder then
			local PreNewModule = Folder:FindFirstChild("Setting")
			if PreNewModule then
				local NewModule = require(PreNewModule:FindFirstChild(Module.ModuleName))
				if (CompareTables(Module, NewModule) == false) then
					if KickPlayer then
						Player:Kick("You have been kicked and blocked from rejoining this specific server for exploiting tool stats.")
						warn(Player.Name.." has been kicked for exploiting tool stats.")
						table.insert(_G.TempBannedPlayers, Player)
					else
						warn(Player.Name.." - Potential Exploiter Bypass! Case 2: Changed Tool Stats From Client")	
					end
					return false
				end
			else
				--[[if KickPlayer then
					Player:Kick("Module is not found. Kicked!")
					warn(Player.Name.." - Module is missing from "..Folder.Name.." folder.")
				else
					warn(Player.Name.." - Potential Exploiter Bypass! Case 1: Missing Module")	
				end]]
				warn(Player.Name.." - Potential Exploiter Bypass! Case 1: Missing Module")
				return false
			end
		else
			warn("There's no existing setting folder.")
			return false	
		end
	else
		warn("Player or tool don't exist.")
		return false
	end
	return true
end

local function AddressTableValue(Enabled, Level, V1, V2)
	if V1 ~= nil and Enabled then
		return ((Level == 1 and V1.Level1) or (Level == 2 and V1.Level2) or (Level == 3 and V1.Level3) or V2)
	else
		return V2
	end
end

local function CalculateDamage(Damage, TravelDistance, ZeroDamageDistance, FullDamageDistance)
	local ZeroDamageDistance = ZeroDamageDistance or 10000
	local FullDamageDistance = FullDamageDistance or 1000
	local DistRange = ZeroDamageDistance - FullDamageDistance
	local FallOff = math.clamp(1 - (math.max(0, TravelDistance - FullDamageDistance) / math.max(1, DistRange)), 0, 1)
	return math.max(Damage * FallOff, 0)
end

PlayAudio.OnServerEvent:Connect(function(Player, Audio, LowAmmoAudio, Replicate)
	for _, plr in next, Players:GetPlayers() do
		if plr ~= Player then
			PlayAudio:FireClient(plr, Audio, LowAmmoAudio, Replicate)
		end
	end
end)

VisualizeHitEffect.OnServerEvent:Connect(function(Player, Type, Hit, Position, Normal, Material, ClientModule, Misc, Replicate)
	for _, plr in next, Players:GetPlayers() do
		if plr ~= Player then
			VisualizeHitEffect:FireClient(plr, Type, Hit, Position, Normal, Material, ClientModule, Misc, Replicate)
		end
	end
end)

VisualizeBullet.OnServerEvent:Connect(function(Player, Tool, Handle, ClientModule, Directions, FirePointObject, MuzzlePointObject, Misc, Replicate)
	local IsValid = SecureSettings(Player, Tool, ClientModule)
	if not IsValid then
		return
	end
	for _, plr in next, Players:GetPlayers() do
		if plr ~= Player then
			VisualizeBullet:FireClient(plr, Tool, Handle, ClientModule, Directions, FirePointObject, MuzzlePointObject, Misc, Replicate)
		end
	end
end)

VisualizeBeam.OnServerEvent:Connect(function(Player, Enabled, Dictionary)
	for _, plr in next, Players:GetPlayers() do
		if plr ~= Player then
			VisualizeBeam:FireClient(plr, Enabled, Dictionary)
		end
	end
end)

VisibleMuzzle.OnServerEvent:Connect(function(Player, MuzzlePointObject, Enabled)
	for _, plr in next, Players:GetPlayers() do
		if plr ~= Player then
			VisibleMuzzle:FireClient(plr, MuzzlePointObject, Enabled)
		end
	end
end)

ShatterGlass.OnServerEvent:Connect(function(Player, Hit, Pos, Dir)
	if Hit then
		if Hit.Name == "_glass" then
			if Hit.Transparency ~= 1 then
				if PhysicEffect then
					local Sound = Instance.new("Sound")
					Sound.SoundId = "http://roblox.com/asset/?id=2978605361"
					Sound.TimePosition = .1
					Sound.Volume = 1
					Sound.Parent = Hit
					Sound:Play()
					Sound.Ended:Connect(function()
						Sound:Destroy()
					end)
					GlassShattering:Shatter(Hit, Pos, Dir + Vector3.new(math.random(-25, 25), math.random(-25, 25), math.random(-25, 25)))
					--[[local LifeTime = 5
					local FadeTime = 1
					local SX, SY, SZ = Hit.Size.X, Hit.Size.Y, Hit.Size.Z
					for X = 1, 4 do
						for Y = 1, 4 do
							local Part = Hit:Clone()
							local position = Vector3.new(X - 2.1, Y - 2.1, 0) * Vector3.new(SX / 4, SY / 4, SZ)
							local currentTransparency = Part.Transparency
							Part.Name = "_shatter"
							Part.Size = Vector3.new(SX / 4, SY / 4, SZ)
							Part.CFrame = Hit.CFrame * (CFrame.new(Part.Size / 8) - Hit.Size / 8 + position)			
							Part.Velocity = Vector3.new(math.random(-10, 10), math.random(-10, 10), math.random(-10, 10))
							Part.Parent = workspace
							--Debris:AddItem(Part, 10)
							task.delay(LifeTime, function()
								if Part.Parent ~= nil then
									if LifeTime > 0 then
										local t0 = os.clock()
										while true do
											local Alpha = math.min((os.clock() - t0) / FadeTime, 1)
											Part.Transparency = Math.Lerp(currentTransparency, 1, Alpha)
							    			if Alpha == 1 then break end
						      				task.wait()
										end
										Part:Destroy()
									else
										Part:Destroy()
					    			end
								end
							end)
							Part.Anchored = false
						end
					end]]
				else
					local Sound = Instance.new("Sound")
					Sound.SoundId = "http://roblox.com/asset/?id=2978605361"
					Sound.TimePosition = .1
					Sound.Volume = 1
					Sound.Parent = Hit
					Sound:Play()
					Sound.Ended:Connect(function()
						Sound:Destroy()
					end)
					local Particle = script.Shatter:Clone()
					Particle.Color = ColorSequence.new(Hit.Color)
					Particle.Transparency = NumberSequence.new{
						NumberSequenceKeypoint.new(0, Hit.Transparency), --(time, value)
						NumberSequenceKeypoint.new(1, 1)
					}
					Particle.Parent = Hit
					task.delay(0.01, function()
						Particle:Emit(10 * math.abs(Hit.Size.magnitude))
						Debris:AddItem(Particle, Particle.Lifetime.Max)
					end)
					Hit.CanCollide = false
					Hit.Transparency = 1
				end
			end
		else
			error("Hit part's name must be '_glass'.")
		end
	else
		error("Hit part doesn't exist.")
	end
end)

local function InflictGun(Player, Tool, ClientModule, TargetHumanoid, TargetTorso, Hit, ClientHitSize, Misc, HitDist)
	local IsValid = SecureSettings(Player, Tool, ClientModule)
	if not IsValid and (ClientHitSize and Hit.Size ~= ClientHitSize) then
		return
	end
	local ModifiedSetting = {
		ExplosiveEnabled = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ExplosiveEnabled, ClientModule.ExplosiveEnabled),
		ExplosionRadius = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ExplosionRadius, ClientModule.ExplosionRadius),
		SelfDamage = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.SelfDamage, ClientModule.SelfDamage),
		SelfDamageRedution = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.SelfDamageRedution, ClientModule.SelfDamageRedution),
		ReduceSelfDamageOnAirOnly = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ReduceSelfDamageOnAirOnly, ClientModule.ReduceSelfDamageOnAirOnly),
		BaseDamage = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BaseDamage, ClientModule.BaseDamage),
		DamageMultipliers = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DamageMultipliers, ClientModule.DamageMultipliers),
		ZeroDamageDistance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ZeroDamageDistance, ClientModule.ZeroDamageDistance),
		FullDamageDistance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.FullDamageDistance, ClientModule.FullDamageDistance),
		CriticalBaseChance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.CriticalBaseChance, ClientModule.CriticalBaseChance),
		CriticalDamageMultiplier = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.CriticalDamageMultiplier, ClientModule.CriticalDamageMultiplier),
		Knockback = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.Knockback, ClientModule.Knockback),
		Lifesteal = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.Lifesteal, ClientModule.Lifesteal),
		DebuffName = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DebuffName, ClientModule.DebuffName),
		DebuffChance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DebuffChance, ClientModule.DebuffChance),
		ApplyDebuffOnCritical = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ApplyDebuffOnCritical, ClientModule.ApplyDebuffOnCritical)	
	}
	local Character = Player.Character
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local TrueDamage
	if HitDist and ModifiedSetting.ExplosiveEnabled then
		local DamageMultiplier = (1 - math.clamp((HitDist / ModifiedSetting.ExplosionRadius), 0, 1))		
		TrueDamage = ClientModule.DamageBasedOnDistance and (ModifiedSetting.BaseDamage * (ModifiedSetting.DamageMultipliers[Hit.Name] or 1)) * DamageMultiplier or ModifiedSetting.BaseDamage * (ModifiedSetting.DamageMultipliers[Hit.Name] or 1)
	else
		TrueDamage = ClientModule.DamageDropOffEnabled and CalculateDamage(ModifiedSetting.BaseDamage * (ModifiedSetting.DamageMultipliers[Hit.Name] or 1), HitDist, ModifiedSetting.ZeroDamageDistance, ModifiedSetting.FullDamageDistance) or ModifiedSetting.BaseDamage * (ModifiedSetting.DamageMultipliers[Hit.Name] or 1)
	end
	if Player and Character and Humanoid then
		local GuaranteedDebuff = false
		local CanDamage = DamageModule.CanDamage(TargetHumanoid.Parent, Character, ClientModule.FriendlyFire)
		if ModifiedSetting.ExplosiveEnabled and ModifiedSetting.SelfDamage then
			if TargetHumanoid.Parent.Name == Player.Name then
				CanDamage = (TargetHumanoid.Parent.Name == Player.Name)
				if ModifiedSetting.ReduceSelfDamageOnAirOnly then
					TrueDamage = TargetHumanoid:GetState() ~= Enum.HumanoidStateType.Freefall and TrueDamage or (TrueDamage * (1 - ModifiedSetting.SelfDamageRedution))
				else
					TrueDamage = TrueDamage * (1 - ModifiedSetting.SelfDamageRedution)
				end
			end
		end
		if TargetHumanoid and TargetHumanoid.Health ~= 0 and TargetTorso and CanDamage then
			while TargetHumanoid:FindFirstChild("creator") do
				TargetHumanoid.creator:Destroy()
			end
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "creator"
			Creator.Value = Player
			Creator.Parent = TargetHumanoid
			Debris:AddItem(Creator, 5)
			if ClientModule.CriticalDamageEnabled then
				local CriticalChanceRandom = Random.new():NextInteger(0, 100)
				if CriticalChanceRandom <= ModifiedSetting.CriticalBaseChance then
					TargetHumanoid:TakeDamage(TrueDamage * ModifiedSetting.CriticalDamageMultiplier)
					GuaranteedDebuff = ModifiedSetting.ApplyDebuffOnCritical
				else
					TargetHumanoid:TakeDamage(TrueDamage)
				end			
			else
				TargetHumanoid:TakeDamage(TrueDamage)
			end
			if ModifiedSetting.Knockback > 0 then
				if not (ModifiedSetting.ExplosiveEnabled and ClientModule.ExplosionKnockback) then
					local Shover = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
					local Duration = 0.1
					local Speed = ModifiedSetting.Knockback / Duration
					local Velocity = (TargetTorso.Position - Shover.Position).Unit * Speed
					local ShoveForce = Instance.new("BodyVelocity")
					ShoveForce.MaxForce = Vector3.new(1e9, 1e9, 1e9)
					ShoveForce.Velocity = Velocity
					ShoveForce.Parent = TargetTorso
					Debris:AddItem(ShoveForce, Duration)					
				end
			end
			if ModifiedSetting.Lifesteal > 0 and Humanoid.Health ~= 0 then
				local HealAmount = TrueDamage * ModifiedSetting.Lifesteal
				Humanoid.Health = Humanoid.Health + HealAmount
			end
			if ClientModule.Debuff then
				if ModifiedSetting.DebuffName ~= "" then
					local Roll = Random.new():NextInteger(0, 100)
					if Roll <= ModifiedSetting.DebuffChance or GuaranteedDebuff then
						if not TargetHumanoid.Parent:FindFirstChild(ModifiedSetting.DebuffName) then
							local Debuff = Miscs.Debuffs[ModifiedSetting.DebuffName]:Clone()
							Debuff.creator.Value = Creator.Value
							Debuff.Parent = TargetHumanoid.Parent
							Debuff.Disabled = false
						end
					end					
				end
			end
			--GORE
			if TargetHumanoid.Health - TrueDamage <= 0 and not TargetHumanoid.Parent:FindFirstChild("gibbed") then
				if Hit then
					if Hit.Name == "Head" or Hit.Name == "Torso" or Hit.Name == "Left Arm" or Hit.Name == "Right Arm" or Hit.Name == "Right Leg" or Hit.Name == "Left Leg" or Hit.Name == "UpperTorso" or Hit.Name == "LowerTorso" or Hit.Name == "LeftUpperArm" or Hit.Name == "LeftLowerArm" or Hit.Name == "LeftHand" or Hit.Name == "RightUpperArm" or Hit.Name == "RightLowerArm" or Hit.Name == "RightHand" or Hit.Name == "RightUpperLeg" or Hit.Name == "RightLowerLeg" or Hit.Name == "RightFoot" or Hit.Name == "LeftUpperLeg" or Hit.Name == "LeftLowerLeg" or Hit.Name == "LeftFoot" then
						VisualizeGore:FireAllClients(Hit, TargetHumanoid.Parent, ClientModule, Misc.GoreEffect)
					end
				end
			end
		end
	else
		warn("Unable to register damage because player is no longer existing here")
	end
end

local function InflictGunMelee(Player, Tool, ClientModule, TargetHumanoid, TargetTorso, Hit, ClientHitSize)
	local IsValid = SecureSettings(Player, Tool, ClientModule)
	if not IsValid and (ClientHitSize and Hit.Size ~= ClientHitSize) then
		return
	end
	local Character = Player.Character
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local TrueDamage = ClientModule.MeleeDamage * (ClientModule.MeleeDamageMultipliers[Hit.Name] or 1)
	if Player and Character and Humanoid then
		local GuaranteedDebuff = false
		if TargetHumanoid and TargetHumanoid.Health ~= 0 and TargetTorso and DamageModule.CanDamage(TargetHumanoid.Parent, Character, ClientModule.FriendlyFire) then
			while TargetHumanoid:FindFirstChild("creator") do
				TargetHumanoid.creator:Destroy()
			end
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "creator"
			Creator.Value = Player
			Creator.Parent = TargetHumanoid
			Debris:AddItem(Creator, 5)
			if ClientModule.MeleeCriticalDamageEnabled then
				local CriticalChanceRandom = Random.new():NextInteger(0, 100)
				if CriticalChanceRandom <= ClientModule.MeleeCriticalBaseChance then
					TargetHumanoid:TakeDamage(TrueDamage * ClientModule.MeleeCriticalDamageMultiplier)
					GuaranteedDebuff = ClientModule.ApplyMeleeDebuffOnCritical
				else
					TargetHumanoid:TakeDamage(TrueDamage)
				end			
			else
				TargetHumanoid:TakeDamage(TrueDamage)
			end
			if ClientModule.MeleeKnockback > 0 then
				local Shover = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
				local Duration = 0.1
				local Speed = ClientModule.MeleeKnockback / Duration
				local Velocity = (TargetTorso.Position - Shover.Position).Unit * Speed
				local ShoveForce = Instance.new("BodyVelocity")
				ShoveForce.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				ShoveForce.Velocity = Velocity
				ShoveForce.Parent = TargetTorso
				Debris:AddItem(ShoveForce, Duration)
			end
			if ClientModule.MeleeLifesteal > 0 and Humanoid.Health ~= 0 then
				local HealAmount = TrueDamage * ClientModule.MeleeLifesteal
				Humanoid.Health = Humanoid.Health + HealAmount
			end
			if ClientModule.MeleeDebuff then
				if ClientModule.MeleeDebuffName ~= "" then
					local Roll = Random.new():NextInteger(0, 100)
					if Roll <= ClientModule.MeleeDebuffChance or GuaranteedDebuff then
						if not TargetHumanoid.Parent:FindFirstChild(ClientModule.MeleeDebuffName) then
							local Debuff = Miscs.Debuffs[ClientModule.MeleeDebuffName]:Clone()
							Debuff.creator.Value = Creator.Value
							Debuff.Parent = TargetHumanoid.Parent
							Debuff.Disabled = false
						end
					end					
				end
			end
		end
	else
		warn("Unable to register damage because player/character is no longer existing here")
	end
end

local function InflictGunLaser(Player, Tool, ClientModule, TargetHumanoid, TargetTorso, Hit, ClientHitSize, Misc)
	local IsValid = SecureSettings(Player, Tool, ClientModule)
	if not IsValid and (ClientHitSize and Hit.Size ~= ClientHitSize) then
		return
	end
	local ModifiedSetting = {
		LaserTrailDamage = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailDamage, ClientModule.LaserTrailDamage),	
		LaserTrailCriticalBaseChance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailCriticalBaseChance, ClientModule.LaserTrailCriticalBaseChance),
		LaserTrailCriticalDamageMultiplier = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailCriticalDamageMultiplier, ClientModule.LaserTrailCriticalDamageMultiplier),
		LaserTrailKnockback = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailKnockback, ClientModule.LaserTrailKnockback),
		LaserTrailLifesteal = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailLifesteal, ClientModule.LaserTrailLifesteal),
		LaserTrailDebuffName = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailDebuffName, ClientModule.LaserTrailDebuffName),
		LaserTrailDebuffChance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailDebuffChance, ClientModule.LaserTrailDebuffChance),
		ApplyLaserTrailDebuffOnCritical = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ApplyLaserTrailDebuffOnCritical, ClientModule.ApplyLaserTrailDebuffOnCritical)	
	}
	local Character = Player.Character
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")
	local TrueDamage = ModifiedSetting.LaserTrailDamage
	if Player and Character and Humanoid then
		local GuaranteedDebuff = false
		if TargetHumanoid and TargetHumanoid.Health ~= 0 and TargetTorso and DamageModule.CanDamage(TargetHumanoid.Parent, Character, ClientModule.FriendlyFire) then
			while TargetHumanoid:FindFirstChild("creator") do
				TargetHumanoid.creator:Destroy()
			end
			local Creator = Instance.new("ObjectValue")
			Creator.Name = "creator"
			Creator.Value = Player
			Creator.Parent = TargetHumanoid
			Debris:AddItem(Creator, 5)
			if ClientModule.LaserTrailCriticalDamageEnabled then
				local CriticalChanceRandom = Random.new():NextInteger(0, 100)
				if CriticalChanceRandom <= ModifiedSetting.LaserTrailCriticalBaseChance then
					TargetHumanoid:TakeDamage(TrueDamage * ModifiedSetting.LaserTrailCriticalDamageMultiplier)
					GuaranteedDebuff = ModifiedSetting.ApplyLaserTrailDebuffOnCritical
				else
					TargetHumanoid:TakeDamage(TrueDamage)
				end			
			else
				TargetHumanoid:TakeDamage(TrueDamage)
			end
			if ModifiedSetting.LaserTrailKnockback > 0 then
				local Shover = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Head")
				local Duration = 0.1
				local Speed = ModifiedSetting.LaserTrailKnockback / Duration
				local Velocity = (TargetTorso.Position - Shover.Position).Unit * Speed
				local ShoveForce = Instance.new("BodyVelocity")
				ShoveForce.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				ShoveForce.Velocity = Velocity
				ShoveForce.Parent = TargetTorso
				Debris:AddItem(ShoveForce, Duration)
			end
			if ModifiedSetting.LaserTrailLifesteal > 0 and Humanoid.Health ~= 0 then
				local HealAmount = TrueDamage * ModifiedSetting.LaserTrailLifesteal
				Humanoid.Health = Humanoid.Health + HealAmount
			end
			if ClientModule.LaserTrailDebuff then
				if ModifiedSetting.LaserTrailDebuffName ~= "" then
					local Roll = Random.new():NextInteger(0, 100)
					if Roll <= ModifiedSetting.LaserTrailDebuffChance or GuaranteedDebuff then
						if not TargetHumanoid.Parent:FindFirstChild(ModifiedSetting.LaserTrailDebuffName) then
							local Debuff = Miscs.Debuffs[ModifiedSetting.LaserTrailDebuffName]:Clone()
							Debuff.creator.Value = Creator.Value
							Debuff.Parent = TargetHumanoid.Parent
							Debuff.Disabled = false
						end
					end					
				end
			end
		end
	else
		warn("Unable to register damage because player is no longer existing here")
	end
end

InflictTarget.OnServerInvoke = function(Player, Type, ...)
	if Type == "Gun" then
		InflictGun(Player, ...)
	elseif Type == "GunMelee" then
		InflictGunMelee(Player, ...)
	elseif Type == "GunLaser" then
		InflictGunLaser(Player, ...)
	end
end

Players.PlayerAdded:Connect(function(player)
	for i, v in pairs(_G.TempBannedPlayers) do
		if v == player.Name then
			player:Kick("You cannot rejoin a server where you were kicked from.")
			warn(player.Name.." tried to rejoin a server where he/she was kicked from.")
			break
		end
	end
end)