local ProjectileHandler = {}

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local Modules = ReplicatedStorage:WaitForChild("Modules")
local Miscs = ReplicatedStorage:WaitForChild("Miscs")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local FastCast = require(Modules.FastCastRedux)
local DamageModule = require(Modules.DamageModule)
local PartCache = require(Modules.PartCache)
local Utilities = require(Modules.Utilities)
local Thread = Utilities.Thread
local Math = Utilities.Math
local DirectionPredictor = Utilities.DirectionPredictor

local Bullets = Miscs.Bullets
local Projectiles = Miscs.Projectiles

local InflictTarget = Remotes.InflictTarget
local VisualizeBullet = Remotes.VisualizeBullet
local VisualizeHitEffect = Remotes.VisualizeHitEffect
local ShatterGlass = Remotes.ShatterGlass

-- Properties
local OptimalEffects = false -- Adjust details of effects by client quality level
local RenderDistance = 400 -- Maximum camera distance to render visual effects
local ScreenCullingEnabled = true -- Show visual effects when their positions are on screen
local MaxDebrisCounts = 100 -- Maximum number of debris objects (mostly decayed projectiles) to exist
local RayExit = true -- Only for Wall Penetration
FastCast.DebugLogging = false
FastCast.VisualizeCasts = false

local Beam = Instance.new("Beam")
Beam.TextureSpeed = 0
Beam.LightEmission = 0
Beam.LightInfluence = 1
Beam.Transparency = NumberSequence.new(0)

local BlockSegContainer = Instance.new("Folder")
BlockSegContainer.Name = "BlockSegContainer"
BlockSegContainer.Parent = Camera

local CylinderSegContainer = Instance.new("Folder")
CylinderSegContainer.Name = "CylinderSegContainer"
CylinderSegContainer.Parent = Camera

local ConeSegContainer = Instance.new("Folder")
ConeSegContainer.Name = "ConeSegContainer"
ConeSegContainer.Parent = Camera

local Caster = FastCast.new()

local BlockSegCache = PartCache.new(Miscs.BlockSegment, 500)
BlockSegCache:SetCacheParent(BlockSegContainer)

local CylinderSegCache = PartCache.new(Miscs.CylinderSegment, 500)
CylinderSegCache:SetCacheParent(CylinderSegContainer)

local ConeSegCache = PartCache.new(Miscs.ConeSegment, 500)
ConeSegCache:SetCacheParent(ConeSegContainer)

local ShootId = 0
local DebrisCounts = 0
local PartCacheStorage = {}

local function CastWithBlacklist(Cast, Origin, Direction, Blacklist, IgnoreWater)
	local CastRay = Ray.new(Origin, Direction)
	local HitPart, HitPoint, HitNormal, HitMaterial = nil, Origin + Direction, Vector3.new(0, 1, 0), Enum.Material.Air
	local Success = false	
	repeat
		HitPart, HitPoint, HitNormal, HitMaterial = Workspace:FindPartOnRayWithIgnoreList(CastRay, Blacklist, false, IgnoreWater)
		if HitPart then
			--if Cast.UserData.ClientModule.IgnoreBlacklistedParts and Cast.UserData.ClientModule.BlacklistParts[HitPart.Name] then
			--	table.insert(Blacklist, HitPart)
			--	Success	= false
			--else
				local Target = HitPart:FindFirstAncestorOfClass("Model")
				local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
				local TargetTool = HitPart:FindFirstAncestorOfClass("Tool")
				if (HitPart.Transparency > 0.75
					or HitPart.Name == "Missile"
					or HitPart.Name == "Handle"
					or HitPart.Name == "Effect"
					or HitPart.Name == "Bullet"
					or HitPart.Name == "Laser"
					or string.lower(HitPart.Name) == "water"
					or HitPart.Name == "Rail"
					or HitPart.Name == "Arrow"
					or (TargetHumanoid and (TargetHumanoid.Health <= 0 or not DamageModule.CanDamage(Target, Cast.UserData.Character, Cast.UserData.ClientModule.FriendlyFire) or (Cast.UserData.BounceData and table.find(Cast.UserData.BounceData.BouncedHumanoids, TargetHumanoid))))
					or TargetTool) then
					table.insert(Blacklist, HitPart)
					Success	= false
				else
					Success	= true
				end				
			--end
		else
			Success	= true
		end
	until Success
	return HitPart, HitPoint, HitNormal, HitMaterial
end

local function AddressTableValue(Enabled, Level, V1, V2)
	if V1 ~= nil and Enabled and Level then
		return ((Level == 1 and V1.Level1) or (Level == 2 and V1.Level2) or (Level == 3 and V1.Level3) or V2)
	else
		return V2
	end
end

local function CanShowEffects(Position)
	if ScreenCullingEnabled then
		local _, OnScreen = Camera:WorldToScreenPoint(Position)
		return OnScreen and (Position - Camera.CFrame.p).Magnitude <= RenderDistance
	end
	return (Position - Camera.CFrame.p).Magnitude <= RenderDistance
end

local function PopulateHumanoids(Cast, Model)
	if Model.ClassName == "Humanoid" then
		if DamageModule.CanDamage(Model.Parent, Cast.UserData.Character, Cast.UserData.ClientModule.FriendlyFire) then
			table.insert(Humanoids, Model)
		end
	end
	for i, mdl in ipairs(Model:GetChildren()) do
		PopulateHumanoids(Cast, mdl)
	end
end

local function FindNearestEntity(Cast, Position)
	Humanoids = {}
	PopulateHumanoids(Cast, Workspace)
	local Dist = Cast.UserData.HomeData.HomingDistance
	local TargetModel = nil
	local TargetHumanoid = nil
	local TargetTorso = nil
	for i, v in ipairs(Humanoids) do
		local torso = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Torso") or v.Parent:FindFirstChild("UpperTorso")
		if v and torso then
			if (torso.Position - Position).Magnitude < (Dist + (torso.Size.Magnitude / 2.5)) and v.Health > 0 then
				if not Cast.UserData.HomeData.HomeThroughWall then
					local hit, pos, normal, material = CastWithBlacklist(Cast, Position, (torso.CFrame.p - Position).Unit * 999, Cast.UserData.IgnoreList, true)
					if hit then
						if hit:IsDescendantOf(v.Parent) then
							if DamageModule.CanDamage(v.Parent, Cast.UserData.Character, Cast.UserData.ClientModule.FriendlyFire) then
								TargetModel = v.Parent
								TargetHumanoid = v
								TargetTorso = torso
								Dist = (Position - torso.Position).Magnitude
							end
						end
					end
				else
					if DamageModule.CanDamage(v.Parent, Cast.UserData.Character, Cast.UserData.ClientModule.FriendlyFire) then
						TargetModel = v.Parent
						TargetHumanoid = v
						TargetTorso = torso
						Dist = (Position - torso.Position).Magnitude
					end
				end						
			end
		end	
	end
	return TargetModel, TargetHumanoid, TargetTorso
end

local function EmitParticle(Particle, Count)
	if OptimalEffects then
		local QualityLevel = UserSettings().GameSettings.SavedQualityLevel
		if QualityLevel == Enum.SavedQualitySetting.Automatic then
			local Compressor = 1 / 2
			Particle:Emit(Count * Compressor)
		else
			local Compressor = QualityLevel.Value / 21
			Particle:Emit(Count * Compressor)
		end
	else
		Particle:Emit(Count)
	end
end

local function FadeBeam(A0, A1, Beam, Hole, FadeTime, Replicate)
	if FadeTime > 0 then
		if OptimalEffects then
			if Replicate then
				local t0 = os.clock()
				while Hole ~= nil do
					local Alpha = math.min((os.clock() - t0) / FadeTime, 1)
					if Beam then Beam.Transparency = NumberSequence.new(Math.Lerp(0, 1, Alpha)) end
					if Alpha == 1 then break end
					Thread:Wait()
				end
				if A0 then A0:Destroy() end
				if A1 then A1:Destroy() end
				if Beam then Beam:Destroy() end
				if Hole then Hole:Destroy() end
			else
				if A0 then A0:Destroy() end
				if A1 then A1:Destroy() end
				if Beam then Beam:Destroy() end
				if Hole then Hole:Destroy() end
			end
		else
			local t0 = os.clock()
			while Hole ~= nil do
				local Alpha = math.min((os.clock() - t0) / FadeTime, 1)
				if Beam then Beam.Transparency = NumberSequence.new(Math.Lerp(0, 1, Alpha)) end
				if Alpha == 1 then break end
				Thread:Wait()
			end
			if A0 then A0:Destroy() end
			if A1 then A1:Destroy() end
			if Beam then Beam:Destroy() end
			if Hole then Hole:Destroy() end
		end
	else
		if A0 then A0:Destroy() end
		if A1 then A1:Destroy() end
		if Beam then Beam:Destroy() end
		if Hole then Hole:Destroy() end
	end
end

local function MakeImpactFX(Hit, Position, Normal, Material, ParentToPart, ClientModule, Misc, Replicate, IsMelee)
	local SurfaceCF = CFrame.new(Position, Position + Normal)
	
	local HitEffectEnabled = ClientModule.HitEffectEnabled
	local HitSoundIDs = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitSoundIDs, ClientModule.HitSoundIDs)
	local HitSoundPitchMin = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitSoundPitchMin, ClientModule.HitSoundPitchMin)
	local HitSoundPitchMax = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitSoundPitchMax, ClientModule.HitSoundPitchMax)
	local HitSoundVolume = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitSoundVolume, ClientModule.HitSoundVolume)
	local CustomHitEffect = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.CustomHitEffect, ClientModule.CustomHitEffect)
	
	local BulletHoleEnabled = ClientModule.BulletHoleEnabled
	local BulletHoleSize = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletHoleSize, ClientModule.BulletHoleSize)
	local BulletHoleTexture = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletHoleTexture, ClientModule.BulletHoleTexture)
	local PartColor = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.PartColor, ClientModule.PartColor)
	local BulletHoleVisibleTime = ClientModule.BulletHoleVisibleTime
	local BulletHoleFadeTime = ClientModule.BulletHoleFadeTime
	
	if IsMelee then
		HitEffectEnabled = ClientModule.MeleeHitEffectEnabled
		HitSoundIDs = ClientModule.MeleeHitSoundIDs
		HitSoundPitchMin = ClientModule.MeleeHitSoundPitchMin
		HitSoundPitchMax = ClientModule.MeleeHitSoundPitchMax
		HitSoundVolume = ClientModule.MeleeHitSoundVolume
		CustomHitEffect = ClientModule.CustomMeleeHitEffect
		
		BulletHoleEnabled = ClientModule.MarkerEffectEnabled
		BulletHoleSize = ClientModule.MarkerEffectSize
		BulletHoleTexture = ClientModule.MarkerEffectTexture
		BulletHoleVisibleTime = ClientModule.MarkerEffectVisibleTime
		BulletHoleFadeTime = ClientModule.MarkerEffectFadeTime
		PartColor = ClientModule.MarkerPartColor
	end
	
	if HitEffectEnabled then
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = SurfaceCF
		Attachment.Parent = Workspace.Terrain
		local Sound
		
		local function Spawner(material)
			if Misc.HitEffectFolder[material.Name]:FindFirstChild("MaterialSounds") then
				local tracks = Misc.HitEffectFolder[material.Name].MaterialSounds:GetChildren()
				local rn = math.random(1, #tracks)
				local track = tracks[rn]
				if track ~= nil then
					Sound = track:Clone()
					if track:FindFirstChild("Pitch") then
						Sound.PlaybackSpeed = Random.new():NextNumber(track.Pitch.Min.Value, track.Pitch.Max.Value)
					else
						Sound.PlaybackSpeed = Random.new():NextNumber(HitSoundPitchMin, HitSoundPitchMax)
					end
					if track:FindFirstChild("Volume") then
						Sound.Volume = Random.new():NextNumber(track.Volume.Min.Value, track.Volume.Max.Value)
					else
						Sound.Volume = HitSoundVolume
					end
					Sound.Parent = Attachment
				end
			else
				Sound = Instance.new("Sound")
				Sound.SoundId = "rbxassetid://"..HitSoundIDs[math.random(1, #HitSoundIDs)]
				Sound.PlaybackSpeed = Random.new():NextNumber(HitSoundPitchMin, HitSoundPitchMax)
				Sound.Volume = HitSoundVolume
				Sound.Parent = Attachment
			end
			for i, v in pairs(Misc.HitEffectFolder[material.Name]:GetChildren()) do
				if v.ClassName == "ParticleEmitter" then
					local Count = 1
					local Particle = v:Clone()
					Particle.Parent = Attachment
					if Particle:FindFirstChild("EmitCount") then
						Count = Particle.EmitCount.Value
					end
					if Particle.PartColor.Value then
						local HitPartColor = Hit and Hit.Color or Color3.fromRGB(255, 255, 255)
						if Hit and Hit:IsA("Terrain") then
							HitPartColor = Workspace.Terrain:GetMaterialColor(Material or Enum.Material.Sand)
						end
						Particle.Color = ColorSequence.new(HitPartColor, HitPartColor)
					end
					Thread:Delay(0.01, function()
						EmitParticle(Particle, Count)
						Debris:AddItem(Particle, Particle.Lifetime.Max)
					end)					
				end
			end
			Sound:Play()
			if BulletHoleEnabled then
				local Hole = Instance.new("Attachment")
				Hole.Parent = ParentToPart and Hit or Workspace.Terrain
				Hole.WorldCFrame = SurfaceCF * CFrame.Angles(math.rad(90), math.rad(180), 0)
				if ParentToPart then
					local Scale = BulletHoleSize
					if Misc.HitEffectFolder[material.Name]:FindFirstChild("MaterialHoleSize") then
						Scale = Misc.HitEffectFolder[material.Name].MaterialHoleSize.Value
					end
					local A0 = Instance.new("Attachment")
					local A1 = Instance.new("Attachment")
					local BeamClone = Beam:Clone()
					BeamClone.Width0 = Scale
					BeamClone.Width1 = Scale
					if Misc.HitEffectFolder[material.Name]:FindFirstChild("MaterialDecals") then
						local Decals = Misc.HitEffectFolder[material.Name].MaterialDecals:GetChildren()
						local Chosen = math.random(1, #Decals)
						local Decal = Decals[Chosen]
						if Decal ~= nil then
							BeamClone.Texture = "rbxassetid://"..Decal.Value
							if Decal.PartColor.Value then
								local HitPartColor = Hit and Hit.Color or Color3.fromRGB(255, 255, 255)
								if Hit and Hit:IsA("Terrain") then
									HitPartColor = Workspace.Terrain:GetMaterialColor(Material or Enum.Material.Sand)
								end
								BeamClone.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, HitPartColor), ColorSequenceKeypoint.new(1, HitPartColor)})
							end
						end
					else
						BeamClone.Texture = "rbxassetid://"..BulletHoleTexture[math.random(1, #BulletHoleTexture)]
						if PartColor then
							local HitPartColor = Hit and Hit.Color or Color3.fromRGB(255, 255, 255)
							if Hit and Hit:IsA("Terrain") then
								HitPartColor = Workspace.Terrain:GetMaterialColor(Material or Enum.Material.Sand)
							end
							BeamClone.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, HitPartColor), ColorSequenceKeypoint.new(1, HitPartColor)})
						end
					end
					BeamClone.Attachment0 = A0
					BeamClone.Attachment1 = A1
					A0.Parent = Hit
					A1.Parent = Hit
					A0.WorldCFrame = Hole.WorldCFrame * CFrame.new(Scale / 2, -0.01, 0) * CFrame.Angles(math.rad(90), 0, 0)
					A1.WorldCFrame = Hole.WorldCFrame * CFrame.new(-Scale / 2, -0.01, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0)
					BeamClone.Parent = Workspace.Terrain
					Thread:Delay(BulletHoleVisibleTime, function()
						FadeBeam(A0, A1, BeamClone, Hole, BulletHoleFadeTime, Replicate)
					end)
				else
					Debris:AddItem(Hole, 5)
				end
			end
		end
		
		if not CustomHitEffect then
			if Misc.HitEffectFolder:FindFirstChild(Hit.Material) then
				Spawner(Hit.Material)
			else
				Spawner(Misc.HitEffectFolder.Custom)
			end
		else
			Spawner(Misc.HitEffectFolder.Custom)
		end
		
		Debris:AddItem(Attachment, 10)				
	end
end

local function MakeBloodFX(Hit, Position, Normal, Material, ParentToPart, ClientModule, Misc, Replicate, IsMelee)
	local SurfaceCF = CFrame.new(Position, Position + Normal)
	
	local BloodEnabled = ClientModule.BloodEnabled
	local HitCharSndIDs = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitCharSndIDs, ClientModule.HitCharSndIDs)
	local HitCharSndPitchMin = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitCharSndPitchMin, ClientModule.HitCharSndPitchMin)
	local HitCharSndPitchMax = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitCharSndPitchMax, ClientModule.HitCharSndPitchMax)
	local HitCharSndVolume = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitCharSndVolume, ClientModule.HitCharSndVolume)
	
	local BloodWoundEnabled = ClientModule.BloodWoundEnabled
	local BloodWoundTexture = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BloodWoundTexture, ClientModule.BloodWoundTexture)
	local BloodWoundSize = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BloodWoundSize, ClientModule.BloodWoundSize)
	local BloodWoundTextureColor = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BloodWoundTextureColor, ClientModule.BloodWoundTextureColor)
	local BloodWoundPartColor = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BloodWoundPartColor, ClientModule.BloodWoundPartColor)
	local BloodWoundVisibleTime = ClientModule.BloodWoundVisibleTime
	local BloodWoundFadeTime = ClientModule.BloodWoundFadeTime
	
	if IsMelee then
		BloodEnabled = ClientModule.MeleeBloodEnabled
		HitCharSndIDs = ClientModule.MeleeHitCharSndIDs
		HitCharSndPitchMin = ClientModule.MeleeHitCharSndPitchMin
		HitCharSndPitchMax = ClientModule.MeleeHitCharSndPitchMax
		HitCharSndVolume = ClientModule.MeleeHitCharSndVolume

		BloodWoundEnabled = ClientModule.MeleeBloodWoundEnabled
		BloodWoundTexture = ClientModule.MeleeBloodWoundTexture
		BloodWoundSize = ClientModule.MeleeBloodWoundSize
		BloodWoundTextureColor = ClientModule.MeleeBloodWoundTextureColor
		BloodWoundPartColor = ClientModule.MeleeBloodWoundVisibleTime
		BloodWoundVisibleTime = ClientModule.MeleeBloodWoundFadeTime
		BloodWoundFadeTime = ClientModule.MeleeBloodWoundPartColor
	end
	
	if BloodEnabled then
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = SurfaceCF
		Attachment.Parent = Workspace.Terrain
		local Sound = Instance.new("Sound")
		Sound.SoundId = "rbxassetid://"..HitCharSndIDs[math.random(1, #HitCharSndIDs)]
		Sound.PlaybackSpeed = Random.new():NextNumber(HitCharSndPitchMin, HitCharSndPitchMax)
		Sound.Volume = HitCharSndVolume
		Sound.Parent = Attachment
		for i, v in pairs(Misc.BloodEffectFolder:GetChildren()) do
			if v.ClassName == "ParticleEmitter" then
				local Count = 1
				local Particle = v:Clone()
				Particle.Parent = Attachment
				if Particle:FindFirstChild("EmitCount") then
					Count = Particle.EmitCount.Value
				end
				Thread:Delay(0.01, function()
					EmitParticle(Particle, Count)
					Debris:AddItem(Particle, Particle.Lifetime.Max)
				end)
			end
		end
		Sound:Play()
		Debris:AddItem(Attachment, 10)
		
		if BloodWoundEnabled then
			local Hole = Instance.new("Attachment")
			Hole.Parent = ParentToPart and Hit or Workspace.Terrain
			Hole.WorldCFrame = SurfaceCF * CFrame.Angles(math.rad(90), math.rad(180), 0)
			if ParentToPart then
				local A0 = Instance.new("Attachment")
				local A1 = Instance.new("Attachment")
				local BeamClone = Beam:Clone()
				BeamClone.Width0 = BloodWoundSize
				BeamClone.Width1 = BloodWoundSize
				BeamClone.Texture = "rbxassetid://"..BloodWoundTexture[math.random(1, #BloodWoundTexture)]
				BeamClone.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, BloodWoundTextureColor), ColorSequenceKeypoint.new(1, BloodWoundTextureColor)})
				if BloodWoundPartColor then
					local HitPartColor = Hit and Hit.Color or Color3.fromRGB(255, 255, 255)
					if Hit and Hit:IsA("Terrain") then
						HitPartColor = Workspace.Terrain:GetMaterialColor(Material or Enum.Material.Sand)
					end
					BeamClone.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, HitPartColor), ColorSequenceKeypoint.new(1, HitPartColor)})
				end				
				BeamClone.Attachment0 = A0
				BeamClone.Attachment1 = A1
				A0.Parent = Hit
				A1.Parent = Hit
				A0.WorldCFrame = Hole.WorldCFrame * CFrame.new(BloodWoundSize / 2, -0.01, 0) * CFrame.Angles(math.rad(90), 0, 0)
				A1.WorldCFrame = Hole.WorldCFrame * CFrame.new(-BloodWoundSize / 2, -0.01, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0)
				BeamClone.Parent = Workspace.Terrain
				Thread:Delay(BloodWoundVisibleTime, function()
					FadeBeam(A0, A1, BeamClone, Hole, BloodWoundFadeTime, Replicate)
				end)
			else
				Debris:AddItem(Hole, 5)
			end
		end
	end
end

local function OnRayFinalHit(Cast, Origin, Direction, RaycastResult, SegmentVelocity, CosmeticBulletObject)
	local EndPos = RaycastResult and RaycastResult.Position or Cast.UserData.SegmentOrigin
	local ShowEffects = CanShowEffects(EndPos)
	if not AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosiveEnabled, Cast.UserData.ClientModule.ExplosiveEnabled) then
		if not RaycastResult then
			return
		end
		if RaycastResult.Instance and RaycastResult.Instance.Parent then
			if RaycastResult.Instance.Name == "_glass" and AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.CanBreakGlass, Cast.UserData.ClientModule.CanBreakGlass) then
				if Cast.UserData.Replicate then
					ShatterGlass:FireServer(RaycastResult.Instance, RaycastResult.Position, Direction)
				end
			else
				if Cast.UserData.ClientModule.BlacklistParts[RaycastResult.Instance.Name] then
					if ShowEffects then
						MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
					end
				else
					local Distance = (RaycastResult.Position - Origin).Magnitude
					local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
					local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
					local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
					if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
						if ShowEffects then
							MakeBloodFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
						end
						if Cast.UserData.Replicate then
							if TargetHumanoid.Health > 0 then
								Thread:Spawn(function()
									InflictTarget:InvokeServer("Gun", Cast.UserData.Tool, Cast.UserData.ClientModule, TargetHumanoid, TargetTorso, RaycastResult.Instance, RaycastResult.Instance.Size, Cast.UserData.Misc, Distance)
								end)
								if Cast.UserData.Tool and Cast.UserData.Tool.GunClient:FindFirstChild("MarkerEvent") then
									Cast.UserData.Tool.GunClient.MarkerEvent:Fire(Cast.UserData.ClientModule, RaycastResult.Instance.Name == "Head" and Cast.UserData.ClientModule.HeadshotHitmarker)
								end
							end
						end	
					else
						if ShowEffects then
							MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
						end
					end					
				end			
			end
		end
	else
		if Cast.UserData.ClientModule.ExplosionSoundEnabled then
			local SoundTable = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionSoundIDs, Cast.UserData.ClientModule.ExplosionSoundIDs)
			local Attachment = Instance.new("Attachment")
			Attachment.CFrame = CFrame.new(EndPos)
			Attachment.Parent = Workspace.Terrain
			local Sound = Instance.new("Sound")
			Sound.SoundId = "rbxassetid://"..SoundTable[math.random(1, #SoundTable)]
			Sound.PlaybackSpeed = Random.new():NextNumber(AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionSoundPitchMin, Cast.UserData.ClientModule.ExplosionSoundPitchMin), AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionSoundPitchMax, Cast.UserData.ClientModule.ExplosionSoundPitchMax))
			Sound.Volume = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionSoundVolume, Cast.UserData.ClientModule.ExplosionSoundVolume)
			Sound.Parent = Attachment
			Sound:Play()
			Debris:AddItem(Attachment, 10)		
		end

		local Explosion = Instance.new("Explosion")
		Explosion.BlastRadius = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionRadius, Cast.UserData.ClientModule.ExplosionRadius)
		Explosion.BlastPressure = 0
		Explosion.ExplosionType = Enum.ExplosionType.NoCraters
		Explosion.Position = EndPos
		Explosion.Parent = Camera

		local SurfaceCF = RaycastResult and CFrame.new(RaycastResult.Position, RaycastResult.Position + RaycastResult.Normal) or CFrame.new(Cast.UserData.SegmentOrigin, Cast.UserData.SegmentOrigin + Cast.UserData.SegmentDirection)
		
		if ShowEffects and RaycastResult then 
			if AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionCraterEnabled, Cast.UserData.ClientModule.ExplosionCraterEnabled) then
				if RaycastResult.Instance and RaycastResult.Instance.Parent then
					local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
					local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
					if not TargetHumanoid then
						local ParentToPart = true
						local Hole = Instance.new("Attachment")
						Hole.Parent = ParentToPart and RaycastResult.Instance or Workspace.Terrain
						Hole.WorldCFrame = SurfaceCF * CFrame.Angles(math.rad(90), math.rad(180), 0)
						if ParentToPart then
							local Scale = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionCraterSize, Cast.UserData.ClientModule.ExplosionCraterSize)
							local Texture = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionCraterTexture, Cast.UserData.ClientModule.ExplosionCraterTexture)
							local A0 = Instance.new("Attachment")
							local A1 = Instance.new("Attachment")
							local BeamClone = Beam:Clone()
							BeamClone.Width0 = Scale
							BeamClone.Width1 = Scale
							BeamClone.Texture = "rbxassetid://"..Texture[math.random(1,#Texture)]
							if AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionCraterPartColor, Cast.UserData.ClientModule.ExplosionCraterPartColor) then
								local HitPartColor = RaycastResult.Instance and RaycastResult.Instance.Color or Color3.fromRGB(255, 255, 255)
								if RaycastResult.Instance and RaycastResult.Instance:IsA("Terrain") then
									HitPartColor = Workspace.Terrain:GetMaterialColor(RaycastResult.Material or Enum.Material.Sand)
								end
								BeamClone.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, HitPartColor), ColorSequenceKeypoint.new(1, HitPartColor)})
							end			
							BeamClone.Attachment0 = A0
							BeamClone.Attachment1 = A1
							A0.Parent = RaycastResult.Instance
							A1.Parent = RaycastResult.Instance
							A0.WorldCFrame = Hole.WorldCFrame * CFrame.new(Scale / 2, -0.01, 0) * CFrame.Angles(math.rad(90), 0, 0)
							A1.WorldCFrame = Hole.WorldCFrame * CFrame.new(-Scale / 2, -0.01, 0) * CFrame.Angles(math.rad(90), math.rad(180), 0)
							BeamClone.Parent = Workspace.Terrain
							local VisibleTime = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionCraterVisibleTime, Cast.UserData.ClientModule.ExplosionCraterVisibleTime)
							local FadeTime = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionCraterFadeTime, Cast.UserData.ClientModule.ExplosionCraterFadeTime)
							Thread:Delay(VisibleTime, function()
								FadeBeam(A0, A1, BeamClone, Hole, FadeTime, Cast.UserData.Replicate)
							end)
						else
							Debris:AddItem(Hole, 5)
						end						
					end
				end
			end
		end
		
		if Cast.UserData.ClientModule.CustomExplosion then
			Explosion.Visible = false

			if ShowEffects then
				local Attachment = Instance.new("Attachment")
				Attachment.CFrame = SurfaceCF
				Attachment.Parent = Workspace.Terrain

				for i, v in pairs(Cast.UserData.Misc.ExplosionEffectFolder:GetChildren()) do
					if v.ClassName == "ParticleEmitter" then
						local Count = 1
						local Particle = v:Clone()
						Particle.Parent = Attachment
						if Particle:FindFirstChild("EmitCount") then
							Count = Particle.EmitCount.Value
						end
						Thread:Delay(0.01, function()
							EmitParticle(Particle, Count)
							Debris:AddItem(Particle, Particle.Lifetime.Max)
						end)
					end
				end
				
				Debris:AddItem(Attachment, 10)
			end
		end	

		local HitHumanoids = {}

		Explosion.Hit:Connect(function(HitPart, HitDist)
			if HitPart and Cast.UserData.Replicate then
				if HitPart.Parent and HitPart.Name == "HumanoidRootPart" or HitPart.Name == "Head" then
					local Target = HitPart:FindFirstAncestorOfClass("Model")
					local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
					local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
					if TargetHumanoid and TargetTorso then
						if TargetHumanoid.Health > 0 then
							if not HitHumanoids[TargetHumanoid] then
								if Cast.UserData.ClientModule.ExplosionKnockback then
									local Multipler = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionKnockbackMultiplierOnTarget, Cast.UserData.ClientModule.ExplosionKnockbackMultiplierOnTarget)
									local DistanceFactor = HitDist / AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionRadius, Cast.UserData.ClientModule.ExplosionRadius)
									DistanceFactor = 1 - DistanceFactor
									local VelocityMod = (TargetTorso.Position - Explosion.Position).Unit * AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionKnockbackPower, Cast.UserData.ClientModule.ExplosionKnockbackPower) --* DistanceFactor
									local AirVelocity = TargetTorso.Velocity - Vector3.new(0, TargetTorso.Velocity.y, 0) + Vector3.new(VelocityMod.X, 0, VelocityMod.Z)
									if DamageModule.CanDamage(Target, Cast.UserData.Character, Cast.UserData.ClientModule.FriendlyFire) then
										local TorsoFly = Instance.new("BodyVelocity")
										TorsoFly.MaxForce = Vector3.new(math.huge, 0, math.huge)
										TorsoFly.Velocity = AirVelocity
										TorsoFly.Parent = TargetTorso
										TargetTorso.Velocity = TargetTorso.Velocity + Vector3.new(0, VelocityMod.Y * Multipler, 0)
										Debris:AddItem(TorsoFly, 0.25)	
									else
										if TargetHumanoid.Parent.Name == Player.Name then
											Multipler = AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.ExplosionKnockbackMultiplierOnPlayer, Cast.UserData.ClientModule.ExplosionKnockbackMultiplierOnPlayer)
											local TorsoFly = Instance.new("BodyVelocity")
											TorsoFly.MaxForce = Vector3.new(math.huge, 0, math.huge)
											TorsoFly.Velocity = AirVelocity
											TorsoFly.Parent = TargetTorso
											TargetTorso.Velocity = TargetTorso.Velocity + Vector3.new(0, VelocityMod.Y * Multipler, 0)
											Debris:AddItem(TorsoFly, 0.25)
										end
									end							
								end
								local Part = RaycastResult and RaycastResult.Instance or HitPart
								Thread:Spawn(function()
									InflictTarget:InvokeServer("Gun", Cast.UserData.Tool, Cast.UserData.ClientModule, TargetHumanoid, TargetTorso, Part, Part.Size, Cast.UserData.Misc, HitDist)
								end)
								if Cast.UserData.Tool and Cast.UserData.Tool.GunClient:FindFirstChild("MarkerEvent") then
									Cast.UserData.Tool.GunClient.MarkerEvent:Fire(Cast.UserData.ClientModule, Part.Name == "Head" and Cast.UserData.ClientModule.HeadshotHitmarker)
								end
								HitHumanoids[TargetHumanoid] = true
							end   	
						end
					end
				elseif HitPart.Name == "_glass" and AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.CanBreakGlass, Cast.UserData.ClientModule.CanBreakGlass) then
					ShatterGlass:FireServer(HitPart, HitPart.Position, Direction)
				end
			end
		end)
	end
end

local function OnRayHit(Cast, Origin, Direction, RaycastResult, SegmentVelocity, CosmeticBulletObject)
	local CanBounce = Cast.UserData.CastBehavior.Hitscan and true or false
	local CurrentPosition = Cast:GetPosition()
	local CurrentVelocity = Cast:GetVelocity()
	local Acceleration = Cast.UserData.CastBehavior.Acceleration
	if not Cast.UserData.CastBehavior.Hitscan then
		Cast.UserData.SpinData.InitalTick = os.clock()
		Cast.UserData.SpinData.InitalAngularVelocity = RaycastResult.Normal:Cross(CurrentVelocity) / 0.2
		Cast.UserData.SpinData.InitalRotation = (Cast.RayInfo.CurrentCFrame - Cast.RayInfo.CurrentCFrame.p)
		Cast.UserData.SpinData.ProjectileOffset = 0.2 * RaycastResult.Normal		
		if CurrentVelocity.Magnitude > 0 then
			local NormalizeBounce = false
			local Position = Cast.RayInfo.RaycastHitbox and CurrentPosition or RaycastResult.Position
			if Cast.UserData.BounceData.BounceBetweenHumanoids then
				local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
				local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
				local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
				if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
					if not table.find(Cast.UserData.BounceData.BouncedHumanoids, TargetHumanoid) then
						table.insert(Cast.UserData.BounceData.BouncedHumanoids, TargetHumanoid)
					end
				end
				local TrackedEntity, TrackedHumanoid, TrackedTorso = FindNearestEntity(Cast, Position)
				if TrackedEntity and TrackedHumanoid and TrackedTorso and TrackedHumanoid.Health > 0 then
					local DesiredVector = (TrackedTorso.Position - Position).Unit
					if Cast.UserData.BounceData.PredictDirection then
						local Pos, Vel = DirectionPredictor(Position, TrackedTorso.Position, Vector3.new(), TrackedTorso.Velocity, Acceleration, (2 * TrackedTorso.Velocity) / 3, SegmentVelocity.Magnitude)
						if Pos and Vel then
							DesiredVector = Vel.Unit
						end
					end
					Cast:SetVelocity(DesiredVector * SegmentVelocity.Magnitude)
					Cast:SetPosition(Position)
				else
					NormalizeBounce = true
				end
			else
				NormalizeBounce = true
			end
			if NormalizeBounce then
				local Delta = Position - CurrentPosition
				local Fix = 1 - 0.001 / Delta.Magnitude
				Fix = Fix < 0 and 0 or Fix
				Cast:AddPosition(Fix * Delta + 0.05 * RaycastResult.Normal)
				local NewNormal = RaycastResult.Normal
				local NewVelocity = CurrentVelocity
				if Cast.UserData.BounceData.IgnoreSlope and (Acceleration ~= Vector3.new(0, 0, 0) and Acceleration.Y < 0) then
					local NewPosition = Cast:GetPosition()
					NewVelocity = Vector3.new(CurrentVelocity.X, -Cast.UserData.BounceData.BounceHeight, CurrentVelocity.Z)
					local Instance2, Position2, Normal2, Material2 = CastWithBlacklist(Cast, NewPosition, Vector3.new(0, 1, 0), Cast.UserData.IgnoreList, true)
					if Instance2 then
						NewVelocity = Vector3.new(CurrentVelocity.X, Cast.UserData.BounceData.BounceHeight, CurrentVelocity.Z)
					end	
					local X = math.deg(math.asin(RaycastResult.Normal.X))
					local Z = math.deg(math.asin(RaycastResult.Normal.Z))
					local FloorAngle = math.floor(math.max(X == 0 and Z or X, X == 0 and -Z or -X))
					NewNormal = FloorAngle > 0 and (FloorAngle >= Cast.UserData.BounceData.SlopeAngle and RaycastResult.Normal or Vector3.new(0, RaycastResult.Normal.Y, 0)) or RaycastResult.Normal
				end
				local NormalVelocity = Vector3.new().Dot(NewNormal, NewVelocity) * NewNormal
				local TanVelocity = NewVelocity - NormalVelocity
				local GeometricDeceleration
				local D1 = -Vector3.new().Dot(NewNormal, Acceleration)
				local D2 = -(1 + Cast.UserData.BounceData.BounceElasticity) * Vector3.new().Dot(NewNormal, NewVelocity)
				GeometricDeceleration = 1 - Cast.UserData.BounceData.FrictionConstant * (10 * (D1 < 0 and 0 or D1) * Cast.StateInfo.Delta + (D2 < 0 and 0 or D2)) / TanVelocity.Magnitude
				Cast:SetVelocity((GeometricDeceleration < 0 and 0 or GeometricDeceleration) * TanVelocity - Cast.UserData.BounceData.BounceElasticity * NormalVelocity)				
			end
			CanBounce = true	
		end
	else
		local NormalizeBounce = false
		if Cast.UserData.BounceData.BounceBetweenHumanoids then
			local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
			local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
			local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
			if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
				if not table.find(Cast.UserData.BounceData.BouncedHumanoids, TargetHumanoid) then
					table.insert(Cast.UserData.BounceData.BouncedHumanoids, TargetHumanoid)
				end
			end
			local TrackedEntity, TrackedHumanoid, TrackedTorso = FindNearestEntity(Cast, RaycastResult.Position)
			if TrackedEntity and TrackedHumanoid and TrackedTorso and TrackedHumanoid.Health > 0 then
				local DesiredVector = (TrackedTorso.Position - RaycastResult.Position).Unit
				Cast.RayInfo.ModifiedDirection = DesiredVector
			else
				NormalizeBounce = true
			end
		else
			NormalizeBounce = true
		end
		if NormalizeBounce then			
			local CurrentDirection = Cast.RayInfo.ModifiedDirection
			local NewDirection = CurrentDirection - (2 * CurrentDirection:Dot(RaycastResult.Normal) * RaycastResult.Normal)
			Cast.RayInfo.ModifiedDirection = NewDirection
		end
	end
	if CanBounce then
		if Cast.UserData.BounceData.CurrentBounces > 0 then
			Cast.UserData.BounceData.CurrentBounces -= 1
			local ShowEffects = CanShowEffects(RaycastResult.Position)
			if Cast.UserData.BounceData.NoExplosionWhileBouncing then
				if RaycastResult.Instance.Name == "_glass" and AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.CanBreakGlass, Cast.UserData.ClientModule.CanBreakGlass) then
					if Cast.UserData.Replicate then
						ShatterGlass:FireServer(RaycastResult.Instance, RaycastResult.Position, SegmentVelocity.Unit)
					end
				else
					if Cast.UserData.ClientModule.BlacklistParts[RaycastResult.Instance.Name] then
						if ShowEffects then
							MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
						end
					else
						local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
						local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
						local Distance = (RaycastResult.Position - Origin).Magnitude
						local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
						if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
							if ShowEffects then
								MakeBloodFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
							end
							if Cast.UserData.Replicate then
								if TargetHumanoid.Health > 0 then							
									Thread:Spawn(function()
										InflictTarget:InvokeServer("Gun", Cast.UserData.Tool, Cast.UserData.ClientModule, TargetHumanoid, TargetTorso, RaycastResult.Instance, RaycastResult.Instance.Size, Cast.UserData.Misc, Distance)
									end)
									if Cast.UserData.Tool and Cast.UserData.Tool.GunClient:FindFirstChild("MarkerEvent") then
										Cast.UserData.Tool.GunClient.MarkerEvent:Fire(Cast.UserData.ClientModule, RaycastResult.Instance.Name == "Head" and Cast.UserData.ClientModule.HeadshotHitmarker)
									end						
								end
							end
						else
							if ShowEffects then
								MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
							end
						end						
					end
				end	
			else
				OnRayFinalHit(Cast, Origin, Direction, RaycastResult, SegmentVelocity, CosmeticBulletObject)
			end
		end		
	end
end

local function CanRayHit(Cast, Origin, Direction, RaycastResult, SegmentVelocity, CosmeticBulletObject)
	if Cast.UserData.ClientModule.BlacklistParts[RaycastResult.Instance.Name] then
		if Cast.UserData.BounceData.StopBouncingOn == "Object" then
			return false
		end
	else
		local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
		local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
		local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
		if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
			if Cast.UserData.BounceData.StopBouncingOn == "Humanoid" then
				return false
			end
		else
			if Cast.UserData.BounceData.StopBouncingOn == "Object" then
				return false
			end
		end		
	end
	if not Cast.UserData.CastBehavior.Hitscan and Cast.UserData.BounceData.SuperRicochet then
		return true
	else
		if Cast.UserData.BounceData.CurrentBounces > 0 then
			return true
		end		
	end
	return false
end

local function OnRayExited(Cast, Origin, Direction, RaycastResult, SegmentVelocity, CosmeticBulletObject)
	if not RayExit then
		return
	end
	if Cast.UserData.PenetrationData then
		if Cast.UserData.ClientModule.PenetrationType == "WallPenetration" then
			local ShowEffects = CanShowEffects(RaycastResult.Position)
			if RaycastResult.Instance and RaycastResult.Instance.Parent then
				if RaycastResult.Instance.Name == "_glass" and AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.CanBreakGlass, Cast.UserData.ClientModule.CanBreakGlass) then
					return
				else
					if Cast.UserData.ClientModule.BlacklistParts[RaycastResult.Instance.Name] then
						if ShowEffects then
							MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
						end
					else
						local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
						local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
						local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
						if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
							if ShowEffects then
								MakeBloodFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)						
							end	
						else
							if ShowEffects then
								MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
							end
						end						
					end			
				end	
			end		
		end		
	end
	if RaycastResult.Instance and RaycastResult.Instance.Parent then
		local vis = Cast:DbgVisualizeHit(CFrame.new(RaycastResult.Position), true)
		if (vis ~= nil) then vis.Color3 = Color3.fromRGB(13, 105, 172) end		
	end
end

local function CanRayPenetrate(Cast, Origin, Direction, RaycastResult, SegmentVelocity, CosmeticBulletObject)
	local ShowEffects = CanShowEffects(RaycastResult.Position)
	if RaycastResult.Instance and RaycastResult.Instance.Parent then
		if Cast.UserData.ClientModule.IgnoreBlacklistedParts and Cast.UserData.ClientModule.BlacklistParts[RaycastResult.Instance.Name] then
			return true
		else
			local Target = RaycastResult.Instance:FindFirstAncestorOfClass("Model")
			local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
			local TargetTool = RaycastResult.Instance:FindFirstAncestorOfClass("Tool")
			if (RaycastResult.Instance.Transparency > 0.75
				or RaycastResult.Instance.Name == "Missile"
				or RaycastResult.Instance.Name == "Handle"
				or RaycastResult.Instance.Name == "Effect"
				or RaycastResult.Instance.Name == "Bullet"
				or RaycastResult.Instance.Name == "Laser"
				or string.lower(RaycastResult.Instance.Name) == "water"
				or RaycastResult.Instance.Name == "Rail"
				or RaycastResult.Instance.Name == "Arrow"
				or (TargetHumanoid and (TargetHumanoid.Health <= 0 or not DamageModule.CanDamage(Target, Cast.UserData.Character, Cast.UserData.ClientModule.FriendlyFire) or (Cast.UserData.PenetrationData and table.find(Cast.UserData.PenetrationData.HitHumanoids, TargetHumanoid)) or (Cast.UserData.BounceData and table.find(Cast.UserData.BounceData.BouncedHumanoids, TargetHumanoid))))
				or TargetTool) then
				return true
			else
				if Cast.UserData.PenetrationData then
					if Cast.UserData.ClientModule.PenetrationType == "WallPenetration" then
						if Cast.UserData.PenetrationData.PenetrationDepth <= 0 then
							return false
						end
					elseif Cast.UserData.ClientModule.PenetrationType == "HumanoidPenetration" then
						if Cast.UserData.PenetrationData.PenetrationAmount <= 0 then
							return false
						end
					end
					local MaxExtent = RaycastResult.Instance.Size.Magnitude * Direction
					local ExitHit, ExitPoint, ExitNormal, ExitMaterial = Workspace:FindPartOnRayWithWhitelist(Ray.new(RaycastResult.Position + MaxExtent, -MaxExtent), {RaycastResult.Instance}, Cast.RayInfo.Parameters.IgnoreWater)
					local Dist = (ExitPoint - RaycastResult.Position).Magnitude
					if RaycastResult.Instance.Name == "_glass" and AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.CanBreakGlass, Cast.UserData.ClientModule.CanBreakGlass) then
						if Cast.UserData.Replicate then
							ShatterGlass:FireServer(RaycastResult.Instance, RaycastResult.Position, SegmentVelocity.Unit)
						end
						if Cast.UserData.ClientModule.PenetrationType == "WallPenetration" then
							local ToReduce = 1 - ((Dist / Cast.UserData.PenetrationData.PenetrationDepth / 1.1))
							Cast.UserData.PenetrationData.PenetrationDepth *= ToReduce
							return true
						end
					else
						if Cast.UserData.ClientModule.BlacklistParts[RaycastResult.Instance.Name] then
							if Cast.UserData.ClientModule.PenetrationType == "WallPenetration" then
								if ShowEffects then
									MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
								end
								local ToReduce = 1 - ((Dist / Cast.UserData.PenetrationData.PenetrationDepth / 1.1))
								Cast.UserData.PenetrationData.PenetrationDepth *= ToReduce
								if ExitHit then
									OnRayExited(Cast, RaycastResult.Position + MaxExtent, -MaxExtent, {Instance = ExitHit, Position = ExitPoint, Normal = ExitNormal, Material = ExitMaterial}, SegmentVelocity, CosmeticBulletObject)
								end
								return true							
							end
						else
							local Distance = (RaycastResult.Position - Origin).Magnitude
							local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
							if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
								if not table.find( Cast.UserData.PenetrationData.HitHumanoids, TargetHumanoid) then
									table.insert(Cast.UserData.PenetrationData.HitHumanoids, TargetHumanoid)
									if ShowEffects then
										MakeBloodFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
									end
									if Cast.UserData.Replicate then
										if TargetHumanoid.Health > 0 then							
											Thread:Spawn(function()
												InflictTarget:InvokeServer("Gun", Cast.UserData.Tool, Cast.UserData.ClientModule, TargetHumanoid, TargetTorso, RaycastResult.Instance, RaycastResult.Instance.Size, Cast.UserData.Misc, Distance)
											end)
											if Cast.UserData.Tool and Cast.UserData.Tool.GunClient:FindFirstChild("MarkerEvent") then
												Cast.UserData.Tool.GunClient.MarkerEvent:Fire(Cast.UserData.ClientModule, RaycastResult.Instance.Name == "Head" and Cast.UserData.ClientModule.HeadshotHitmarker)
											end						
										end
									end
									if Cast.UserData.ClientModule.PenetrationType == "WallPenetration" then
										local ToReduce = 1 - ((Dist / Cast.UserData.PenetrationData.PenetrationDepth / 1.1))
										Cast.UserData.PenetrationData.PenetrationDepth *= ToReduce
										if ExitHit then
											OnRayExited(Cast, RaycastResult.Position + MaxExtent, -MaxExtent, {Instance = ExitHit, Position = ExitPoint, Normal = ExitNormal, Material = ExitMaterial}, SegmentVelocity, CosmeticBulletObject)
										end
									elseif Cast.UserData.ClientModule.PenetrationType == "HumanoidPenetration" then
										Cast.UserData.PenetrationData.PenetrationAmount -= 1
									end
									if Cast.UserData.PenetrationData.PenetrationIgnoreDelay ~= math.huge then
										Thread:Delay(Cast.UserData.PenetrationData.PenetrationIgnoreDelay, function()
											local Index = table.find( Cast.UserData.PenetrationData.HitHumanoids, TargetHumanoid)
											if Index then
												table.remove(Cast.UserData.PenetrationData.HitHumanoids, Index)
											end	
										end)
									end
									return true
								end
							else
								if Cast.UserData.ClientModule.PenetrationType == "WallPenetration" then
									if ShowEffects then
										MakeImpactFX(RaycastResult.Instance, RaycastResult.Position, RaycastResult.Normal, RaycastResult.Material, true, Cast.UserData.ClientModule, Cast.UserData.Misc, Cast.UserData.Replicate)
									end
									local ToReduce = 1 - ((Dist / Cast.UserData.PenetrationData.PenetrationDepth / 1.1))
									Cast.UserData.PenetrationData.PenetrationDepth *= ToReduce
									if ExitHit then
										OnRayExited(Cast, RaycastResult.Position + MaxExtent, -MaxExtent, {Instance = ExitHit, Position = ExitPoint, Normal = ExitNormal, Material = ExitMaterial}, SegmentVelocity, CosmeticBulletObject)
									end
									return true							
								end
							end								
						end
					end				
				end
			end			
		end
	end
	return false
end

local function UpdateParticle(Cast, Position, LastPosition, W2)
	if Cast.UserData.BulletParticleData.MotionBlur then
		local T2 = os.clock()
		local P2 = CFrame.new().pointToObjectSpace(Camera.CFrame, W2)
		local V2
		if Cast.UserData.BulletParticleData.T0 then
			V2 = 2 / (T2 - Cast.UserData.BulletParticleData.T1) * (P2 - Cast.UserData.BulletParticleData.P1) - (P2 - Cast.UserData.BulletParticleData.P0) / (T2 - Cast.UserData.BulletParticleData.T0)
		else
			V2 = (P2 - Cast.UserData.BulletParticleData.P1) / (T2 - Cast.UserData.BulletParticleData.T1)
			Cast.UserData.BulletParticleData.V1 = V2
		end
		Cast.UserData.BulletParticleData.T0, Cast.UserData.BulletParticleData.V0, Cast.UserData.BulletParticleData.P0 = Cast.UserData.BulletParticleData.T1, Cast.UserData.BulletParticleData.V1, Cast.UserData.BulletParticleData.P1
		Cast.UserData.BulletParticleData.T1, Cast.UserData.BulletParticleData.V1, Cast.UserData.BulletParticleData.P1 = T2, V2, P2
		local Dt = Cast.UserData.BulletParticleData.T1 - Cast.UserData.BulletParticleData.T0
		local M0 = Cast.UserData.BulletParticleData.V0.Magnitude
		local M1 = Cast.UserData.BulletParticleData.V1.Magnitude
		Cast.UserData.BulletParticleData.Attachment0.Position = Camera.CFrame * Cast.UserData.BulletParticleData.P0
		Cast.UserData.BulletParticleData.Attachment1.Position = Camera.CFrame * Cast.UserData.BulletParticleData.P1
		if M0 > 1.0E-8 then
			Cast.UserData.BulletParticleData.Attachment0.Axis = CFrame.new().vectorToWorldSpace(Camera.CFrame, Cast.UserData.BulletParticleData.V0 / M0)
		end
		if M1 > 1.0E-8 then
			Cast.UserData.BulletParticleData.Attachment1.Axis = CFrame.new().vectorToWorldSpace(Camera.CFrame, Cast.UserData.BulletParticleData.V1 / M1)
		end
		local Dist0 = -Cast.UserData.BulletParticleData.P0.Z
		local Dist1 = -Cast.UserData.BulletParticleData.P1.Z
		if Dist0 < 0 then
			Dist0 = 0
		end
		if Dist1 < 0 then
			Dist1 = 0
		end
		local W0 = Cast.UserData.BulletParticleData.BulletSize + Cast.UserData.BulletParticleData.BulletBloom * Dist0
		local W1 = Cast.UserData.BulletParticleData.BulletSize + Cast.UserData.BulletParticleData.BulletBloom * Dist1
		local L = ((Cast.UserData.BulletParticleData.P1 - Cast.UserData.BulletParticleData.P0) * Vector3.new(1, 1, 0)).Magnitude
		local Tr = 1 - 4 * Cast.UserData.BulletParticleData.BulletSize * Cast.UserData.BulletParticleData.BulletSize / ((W0 + W1) * (2 * L + W0 + W1)) * Cast.UserData.BulletParticleData.BulletBrightness
		for _, effect in next, Cast.UserData.BulletParticleData.Effects do
			effect.CurveSize0 = Dt / 3 * M0
			effect.CurveSize1 = Dt / 3 * M1
			effect.Width0 = W0
			effect.Width1 = W1
			effect.Transparency = NumberSequence.new(Tr)
		end
	else
		if (Position - LastPosition).Magnitude > 0 then
			local Rotation = CFrame.new(LastPosition, Position) - LastPosition
			local Offset = CFrame.Angles(0, math.pi / 2, 0)
			Cast.UserData.BulletParticleData.Attachment0.CFrame = CFrame.new(Position) * Rotation * Offset
			Cast.UserData.BulletParticleData.Attachment1.CFrame = CFrame.new(LastPosition, Position) * Offset
		end					
	end
end

local function OnRayUpdated(Cast, LastSegmentOrigin, SegmentOrigin, SegmentDirection, Length, SegmentVelocity, CosmeticBulletObject)
	Cast.UserData.LastSegmentOrigin = LastSegmentOrigin
	Cast.UserData.SegmentOrigin = SegmentOrigin
	Cast.UserData.SegmentDirection = SegmentDirection
	Cast.UserData.SegmentVelocity = SegmentVelocity
	local Tick = os.clock() - Cast.UserData.SpinData.InitalTick
	if Cast.UserData.UpdateData.UpdateRayInExtra then
		if Cast.UserData.UpdateData.ExtraRayUpdater then
			Cast.UserData.UpdateData.ExtraRayUpdater(Cast, Cast.StateInfo.Delta)
		end
	end
	if not Cast.UserData.CastBehavior.Hitscan and Cast.UserData.HomeData.Homing then
		local CurrentPosition = Cast:GetPosition()
		local CurrentVelocity = Cast:GetVelocity()
		if Cast.UserData.HomeData.LockOnOnHovering then
			if Cast.UserData.HomeData.LockedEntity then
				local TargetHumanoid = Cast.UserData.HomeData.LockedEntity:FindFirstChildOfClass("Humanoid")
				if TargetHumanoid and TargetHumanoid.Health > 0 then
					local TargetTorso = Cast.UserData.HomeData.LockedEntity:FindFirstChild("HumanoidRootPart") or Cast.UserData.HomeData.LockedEntity:FindFirstChild("Torso") or Cast.UserData.HomeData.LockedEntity:FindFirstChild("UpperTorso")
					local DesiredVector = (TargetTorso.Position - CurrentPosition).Unit
					local CurrentVector = CurrentVelocity.Unit
					local AngularDifference = math.acos(DesiredVector:Dot(CurrentVector))
					if AngularDifference > 0 then
						local OrthoVector = CurrentVector:Cross(DesiredVector).Unit
						local AngularCorrection = math.min(AngularDifference, Cast.StateInfo.Delta * Cast.UserData.HomeData.TurnRatePerSecond)
						Cast:SetVelocity(CFrame.fromAxisAngle(OrthoVector, AngularCorrection):vectorToWorldSpace(CurrentVelocity))
					end
				end
			end
		else
			local TargetEntity, TargetHumanoid, TargetTorso = FindNearestEntity(Cast, CurrentPosition)
			if TargetEntity and TargetHumanoid and TargetTorso and TargetHumanoid.Health > 0 then
				local DesiredVector = (TargetTorso.Position - CurrentPosition).Unit
				local CurrentVector = CurrentVelocity.Unit
				local AngularDifference = math.acos(DesiredVector:Dot(CurrentVector))
				if AngularDifference > 0 then
					local OrthoVector = CurrentVector:Cross(DesiredVector).Unit
					local AngularCorrection = math.min(AngularDifference, Cast.StateInfo.Delta * Cast.UserData.HomeData.TurnRatePerSecond)
					Cast:SetVelocity(CFrame.fromAxisAngle(OrthoVector, AngularCorrection):vectorToWorldSpace(CurrentVelocity))
				end
			end
		end
	end
	local TravelCFrame
	if Cast.UserData.SpinData.CanSpinPart then
		if not Cast.UserData.CastBehavior.Hitscan then
			local Position = (SegmentOrigin + Cast.UserData.SpinData.ProjectileOffset)
			if Cast.UserData.BounceData.SuperRicochet then
				TravelCFrame = CFrame.new(Position, Position + SegmentVelocity) * Math.FromAxisAngle(Tick * Cast.UserData.SpinData.InitalAngularVelocity) * Cast.UserData.SpinData.InitalRotation
			else
				if Cast.UserData.BounceData.CurrentBounces > 0 then
					TravelCFrame = CFrame.new(Position, Position + SegmentVelocity) * Math.FromAxisAngle(Tick * Cast.UserData.SpinData.InitalAngularVelocity) * Cast.UserData.SpinData.InitalRotation
				else
					TravelCFrame = CFrame.new(SegmentOrigin, SegmentOrigin + SegmentVelocity) * CFrame.Angles(math.rad(-360 * ((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinX - math.floor((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinX))), math.rad(-360 * ((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinY - math.floor((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinY))), math.rad(-360 * ((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinZ - math.floor((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinZ))))
				end
			end
		else
			TravelCFrame = CFrame.new(SegmentOrigin, SegmentOrigin + SegmentVelocity) * CFrame.Angles(math.rad(-360 * ((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinX - math.floor((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinX))), math.rad(-360 * ((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinY - math.floor((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinY))), math.rad(-360 * ((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinZ - math.floor((os.clock() - Cast.UserData.ShootId / 4) * Cast.UserData.SpinData.SpinZ))))
		end
	else
		TravelCFrame = CFrame.new(SegmentOrigin, SegmentOrigin + SegmentVelocity)
	end
	Cast.RayInfo.CurrentCFrame = TravelCFrame
	if Cast.UserData.BulletParticleData then
		UpdateParticle(Cast, SegmentOrigin, Cast.UserData.LastPosition, SegmentOrigin)
	end
	if Cast.UserData.LaserData.LaserTrailEnabled then
		if Cast.StateInfo.Delta > 0 then
			local Width = Cast.UserData.LaserData.LaserTrailWidth
			local Height = Cast.UserData.LaserData.LaserTrailHeight
			local TrailSegment = Miscs[Cast.UserData.LaserData.LaserTrailShape.."Segment"]:Clone()
			if Cast.UserData.LaserData.RandomizeLaserColorIn ~= "None" then
				if Cast.UserData.LaserData.RandomizeLaserColorIn == "Whole" then
					TrailSegment.Color = Cast.UserData.LaserData.RandomLaserColor
				elseif Cast.UserData.LaserData.RandomizeLaserColorIn == "Segment" then
					TrailSegment.Color = Color3.new(math.random(), math.random(), math.random())
				end
			else
				TrailSegment.Color = Cast.UserData.LaserData.LaserTrailColor
			end
			TrailSegment.Material = Cast.UserData.LaserData.LaserTrailMaterial
			TrailSegment.Reflectance = Cast.UserData.LaserData.LaserTrailReflectance
			TrailSegment.Transparency = Cast.UserData.LaserData.LaserTrailTransparency
			TrailSegment.Size = Cast.UserData.LaserData.LaserTrailShape == "Cone" and Vector3.new(Width, (SegmentOrigin - LastSegmentOrigin).Magnitude, Height) or Vector3.new((SegmentOrigin - LastSegmentOrigin).Magnitude, Height, Width)
			TrailSegment.CFrame = CFrame.new((LastSegmentOrigin + SegmentOrigin) * 0.5, SegmentOrigin) * (Cast.UserData.LaserData.LaserTrailShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
			TrailSegment.Parent = Camera
			table.insert(Cast.UserData.LaserData.LaserTrailContainer, TrailSegment)
			if Cast.UserData.LaserData.UpdateLaserTrail then
				Cast.UserData.LaserData.UpdateLaserTrail:Fire(Cast.UserData.LaserData.LaserTrailId, Cast.UserData.LaserData.LaserTrailContainer)
			end
			Thread:Delay(Cast.UserData.LaserData.LaserTrailVisibleTime, function()
				if Cast.UserData.LaserData.LaserTrailFadeTime > 0 then
					local DesiredSize = TrailSegment.Size * (Cast.UserData.LaserData.ScaleLaserTrail and Vector3.new(1, Cast.UserData.LaserData.LaserTrailScaleMultiplier, Cast.UserData.LaserData.LaserTrailScaleMultiplier) or Vector3.new(1, 1, 1))
					local Tween = TweenService:Create(TrailSegment, TweenInfo.new(Cast.UserData.LaserData.LaserTrailFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
					Tween:Play()
					Tween.Completed:Wait()
					if TrailSegment then
						local Index = table.find(Cast.UserData.LaserData.LaserTrailContainer, TrailSegment)
						if Index then
							table.remove(Cast.UserData.LaserData.LaserTrailContainer, Index)
							if Cast.UserData.LaserData.UpdateLaserTrail then
								Cast.UserData.LaserData.UpdateLaserTrail:Fire(Cast.UserData.LaserData.LaserTrailId, Cast.UserData.LaserData.LaserTrailContainer)
							end
						end
						TrailSegment:Destroy()
					end
				else
					if TrailSegment then
						local Index = table.find(Cast.UserData.LaserData.LaserTrailContainer, TrailSegment)
						if Index then
							table.remove(Cast.UserData.LaserData.LaserTrailContainer, Index)
							if Cast.UserData.LaserData.UpdateLaserTrail then
								Cast.UserData.LaserData.UpdateLaserTrail:Fire(Cast.UserData.LaserData.LaserTrailId, Cast.UserData.LaserData.LaserTrailContainer)
							end
						end
						TrailSegment:Destroy()
					end
				end
			end)			
		end
	end
	if Cast.UserData.LightningData.LightningBoltEnabled then
		if Cast.StateInfo.Delta > 0 then
			local Wideness = Cast.UserData.LightningData.BoltWideness
			local Width = Cast.UserData.LightningData.BoltWidth
			local Height = Cast.UserData.LightningData.BoltHeight
			for _, v in ipairs(Cast.UserData.LightningData.BoltCFrameTable) do
				local Cache
				if Cast.UserData.LightningData.BoltShape == "Block" then
					Cache = BlockSegCache
				elseif Cast.UserData.LightningData.BoltShape == "Cylinder" then
					Cache = CylinderSegCache
				elseif Cast.UserData.LightningData.BoltShape == "Cone" then
					Cache = ConeSegCache
				end
				if Cache then
					local Start = (CFrame.new(SegmentOrigin, SegmentOrigin + SegmentDirection) * v).p
					local End = (CFrame.new(LastSegmentOrigin, LastSegmentOrigin + SegmentDirection) * v).p
					local Distance = (End - Start).Magnitude
					local Pos = Start
					for i = 0, Distance, 10 do
						local FakeDistance = CFrame.new(Start, End) * CFrame.new(0, 0, -i - 10) * CFrame.new(-2 + (math.random() * Wideness), -2 + (math.random() * Wideness), -2 + (math.random() * Wideness))
						local BoltSegment = Cache:GetPart()
						if Cast.UserData.LightningData.RandomizeBoltColorIn ~= "None" then
							if Cast.UserData.LightningData.RandomizeBoltColorIn == "Whole" then
								BoltSegment.Color = Cast.UserData.LightningData.RandomBoltColor
							elseif Cast.UserData.LightningData.RandomizeBoltColorIn == "Segment" then
								BoltSegment.Color = Color3.new(math.random(), math.random(), math.random())
							end
						else
							BoltSegment.Color = Cast.UserData.LightningData.BoltColor
						end
						BoltSegment.Material = Cast.UserData.LightningData.BoltMaterial
						BoltSegment.Reflectance = Cast.UserData.LightningData.BoltReflectance
						BoltSegment.Transparency = Cast.UserData.LightningData.BoltTransparency						
						if i + 10 > Distance then
							BoltSegment.CFrame = CFrame.new(Pos, End) * CFrame.new(0, 0, -(Pos - End).Magnitude / 2) * (Cast.UserData.LightningData.BoltShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
						else
							BoltSegment.CFrame = CFrame.new(Pos, FakeDistance.p) * CFrame.new(0, 0, -(Pos - FakeDistance.p).Magnitude / 2) * (Cast.UserData.LightningData.BoltShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
						end
						if i + 10 > Distance then
							BoltSegment.Size = Cast.UserData.LightningData.BoltShape == "Cone" and Vector3.new(Width, (Pos - End).Magnitude, Height) or Vector3.new((Pos - End).Magnitude, Height, Width)
						else
							BoltSegment.Size = Cast.UserData.LightningData.BoltShape == "Cone" and Vector3.new(Width, (Pos - FakeDistance.p).Magnitude, Height) or Vector3.new((Pos - FakeDistance.p).Magnitude, Height, Width)
						end
						Thread:Delay(Cast.UserData.LightningData.BoltVisibleTime, function()
							if Cast.UserData.LightningData.BoltFadeTime > 0 then
								local DesiredSize = BoltSegment.Size * (Cast.UserData.LightningData.ScaleBolt and Vector3.new(1, Cast.UserData.LightningData.BoltScaleMultiplier, Cast.UserData.LightningData.BoltScaleMultiplier) or Vector3.new(1, 1, 1))
								local Tween = TweenService:Create(BoltSegment, TweenInfo.new(Cast.UserData.LightningData.BoltFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
								Tween:Play()
								Tween.Completed:Wait()
								if BoltSegment ~= nil then
									Cache:ReturnPart(BoltSegment)
								end
							else
								if BoltSegment ~= nil then
									Cache:ReturnPart(BoltSegment)
								end								
							end
						end)
						Pos = FakeDistance.p
					end					
				end
			end
		end
	end
	if not Cast.UserData.Replicate and Cast.UserData.ClientModule.WhizSoundEnabled then
		if not Cast.UserData.Whizzed then	
			local Mag = (Camera.CFrame.p - SegmentOrigin).Magnitude --(Camera.CFrame.p - CosmeticBulletObject.Position).Magnitude		
			if Mag < Cast.UserData.ClientModule.WhizDistance then
				local WhizSound = Instance.new("Sound")
				WhizSound.SoundId = "rbxassetid://"..Cast.UserData.ClientModule.WhizSoundIDs[math.random(1, #Cast.UserData.ClientModule.WhizSoundIDs)]
				WhizSound.Volume = Cast.UserData.ClientModule.WhizSoundVolume
				WhizSound.PlaybackSpeed = Random.new():NextNumber(Cast.UserData.ClientModule.WhizSoundPitchMin, Cast.UserData.ClientModule.WhizSoundPitchMax)
				WhizSound.Name = "WhizSound"
				WhizSound.Parent = SoundService				
				WhizSound:Play()
				Debris:AddItem(WhizSound, WhizSound.TimeLength / WhizSound.PlaybackSpeed)
				Cast.UserData.Whizzed = true
			end
		end
	end
	Cast.UserData.LastPosition = SegmentOrigin
	if CosmeticBulletObject == nil then
		return
	end
	CosmeticBulletObject.CFrame = TravelCFrame
end

local function OnRayTerminated(Cast, RaycastResult, IsDecayed)
	if Cast.UserData.LaserData.UpdateLaserTrail then
		Cast.UserData.LaserData.UpdateLaserTrail:Fire(Cast.UserData.LaserData.LaserTrailId, Cast.UserData.LaserData.LaserTrailContainer, true)
	end
	if Cast.UserData.BulletParticleData then
		Cast.UserData.BulletParticleData.Attachment0:Destroy()
		Cast.UserData.BulletParticleData.Attachment1:Destroy()
		for _, effect in next, Cast.UserData.BulletParticleData.Effects do
			effect:Destroy()
		end
	end
	local CosmeticBulletObject = Cast.RayInfo.CosmeticBulletObject
	if CosmeticBulletObject ~= nil then	
		local CurrentPosition = Cast:GetPosition()
		local CurrentVelocity = Cast:GetVelocity()
		if IsDecayed then
			if Cast.UserData.DebrisData.DecayProjectile then
				if DebrisCounts <= MaxDebrisCounts then
					DebrisCounts += 1
					local DecayProjectile = CosmeticBulletObject:Clone()
					DecayProjectile.Name = "DecayProjectile"
					DecayProjectile.CFrame = CosmeticBulletObject.CFrame
					DecayProjectile.Anchored = Cast.UserData.DebrisData.AnchorDecay
					DecayProjectile.CanCollide = Cast.UserData.DebrisData.CollideDecay
					if not DecayProjectile.Anchored then
						if Cast.UserData.DebrisData.VelocityInfluence then
							DecayProjectile.Velocity = DecayProjectile.CFrame.LookVector * CurrentVelocity.Magnitude
						else
							DecayProjectile.Velocity = DecayProjectile.CFrame.LookVector * Cast.UserData.DebrisData.DecayVelocity
						end
					end
					for _, v in pairs(DecayProjectile:GetDescendants()) do
						if ((v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight")) and Cast.UserData.DebrisData.DisableDebrisContents.DisableTrail) then
							v.Enabled = false
						elseif (v:IsA("ParticleEmitter") and Cast.UserData.DebrisData.DisableDebrisContents.Particle) then
							v.Enabled = false
						elseif (v:IsA("Trail") and Cast.UserData.DebrisData.DisableDebrisContents.Trail) then
							v.Enabled = false
						elseif (v:IsA("Beam") and Cast.UserData.DebrisData.DisableDebrisContents.Beam) then
							v.Enabled = false
						elseif (v:IsA("Sound") and Cast.UserData.DebrisData.DisableDebrisContents.Sound) then
							v:Stop()
						end
					end
					DecayProjectile.Parent = Camera
					Thread:Delay(5, function() --10
						if DecayProjectile then
							DecayProjectile:Destroy()
						end
						DebrisCounts -= 1
					end)
				end
			end
		else
			if RaycastResult then
				local HitPointObjectSpace = RaycastResult.Instance.CFrame:pointToObjectSpace(RaycastResult.Position)
				if Cast.UserData.DebrisData.DebrisProjectile then
					if DebrisCounts <= MaxDebrisCounts then
						DebrisCounts += 1
						local DebrisProjectile = CosmeticBulletObject:Clone()
						DebrisProjectile.Name = "DebrisProjectile"
						DebrisProjectile.CFrame = Cast.UserData.DebrisData.NormalizeDebris and CFrame.new(RaycastResult.Position, RaycastResult.Position + RaycastResult.Normal) or (RaycastResult.Instance.CFrame * CFrame.new(HitPointObjectSpace, HitPointObjectSpace + RaycastResult.Instance.CFrame:vectorToObjectSpace(Cast.UserData.SegmentVelocity.Unit))) --CosmeticBulletObject.CFrame
						DebrisProjectile.Anchored = Cast.UserData.DebrisData.AnchorDebris
						DebrisProjectile.CanCollide = Cast.UserData.DebrisData.CollideDebris
						if not DebrisProjectile.Anchored and Cast.UserData.DebrisData.BounceDebris then
							local Direction = DebrisProjectile.CFrame.LookVector
							local Reflect = Direction - (2 * Direction:Dot(RaycastResult.Normal) * RaycastResult.Normal)
							DebrisProjectile.Velocity = Reflect * (Cast.UserData.DebrisData.BounceVelocity * (CurrentVelocity.Magnitude / AddressTableValue(Cast.UserData.ClientModule.ChargedShotAdvanceEnabled, Cast.UserData.Misc.ChargeLevel, Cast.UserData.ClientModule.ChargeAlterTable.BulletSpeed, Cast.UserData.ClientModule.BulletSpeed)))
							DebrisProjectile.CFrame = CFrame.new(DebrisProjectile.Position, DebrisProjectile.Position + DebrisProjectile.Velocity)	
						end
						for _, v in pairs(DebrisProjectile:GetDescendants()) do
							if ((v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight")) and Cast.UserData.DebrisData.DisableDebrisContents.DisableTrail) then
								v.Enabled = false
							elseif (v:IsA("ParticleEmitter") and Cast.UserData.DebrisData.DisableDebrisContents.Particle) then
								v.Enabled = false
							elseif (v:IsA("Trail") and Cast.UserData.DebrisData.DisableDebrisContents.Trail) then
								v.Enabled = false
							elseif (v:IsA("Beam") and Cast.UserData.DebrisData.DisableDebrisContents.Beam) then
								v.Enabled = false
							elseif (v:IsA("Sound") and Cast.UserData.DebrisData.DisableDebrisContents.Sound) then
								v:Stop()
							end
						end
						DebrisProjectile.Parent = Camera
						Thread:Delay(5, function() --10
							if DebrisProjectile then
								DebrisProjectile:Destroy()
							end
							DebrisCounts -= 1
						end)
					end
				end
			end
		end
		CosmeticBulletObject.Transparency = 1
		for _, v in pairs(CosmeticBulletObject:GetDescendants()) do
			if v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("SurfaceLight") or v:IsA("SpotLight") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("BillboardGui") or v:IsA("SurfaceGui") then
				v.Enabled = false
			elseif v:IsA("Sound") then
				v:Stop()
			elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("BasePart") then
				v.Transparency = 1
			end
		end
		if Cast.UserData.CastBehavior.CosmeticBulletProvider ~= nil then
			--Thread:Delay(5, function() -- 10
				if CosmeticBulletObject ~= nil then
					Cast.UserData.CastBehavior.CosmeticBulletProvider:ReturnPart(CosmeticBulletObject)
				end
			--end)
		else
			Debris:AddItem(CosmeticBulletObject, 5) -- 10
		end
	end
end

function ProjectileHandler:VisualizeHitEffect(Type, Hit, Position, Normal, Material, ClientModule, Misc, Replicate)
	if Replicate then 
		VisualizeHitEffect:FireServer(Type, Hit, Position, Normal, Material, ClientModule, Misc, nil)
	end
	local ShowEffects = CanShowEffects(Position)
	if ShowEffects then
		if Type == "Normal" then
			MakeImpactFX(Hit, Position, Normal, Material, true, ClientModule, Misc, Replicate, true)
		elseif Type == "Blood" then
			MakeBloodFX(Hit, Position, Normal, Material, true, ClientModule, Misc, Replicate, true)
		end
	end
end

function ProjectileHandler:SimulateProjectile(Tool, Handle, ClientModule, Directions, FirePointObject, MuzzlePointObject, Misc, Replicate)
	if ClientModule and Tool and Handle then
		if FirePointObject then
			if not FirePointObject:IsDescendantOf(Workspace) and not FirePointObject:IsDescendantOf(Tool) then
				return
			end
		else
			return
		end
						
		if Replicate then 
			VisualizeBullet:FireServer(Tool, Handle, ClientModule, Directions, FirePointObject, MuzzlePointObject, Misc, nil)
		end
		
		if MuzzlePointObject then
			if ClientModule.MuzzleFlashEnabled then		
				for i, v in pairs(Misc.MuzzleFolder:GetChildren()) do
					if v.ClassName == "ParticleEmitter" then
						local Count = 1
						local Particle = v:Clone()
						Particle.Parent = MuzzlePointObject
						if Particle:FindFirstChild("EmitCount") then
							Count = Particle.EmitCount.Value
						end
						Thread:Delay(0.01, function()
							Particle:Emit(Count)
							Debris:AddItem(Particle, Particle.Lifetime.Max)
						end)
					end
				end	
			end

			if ClientModule.MuzzleLightEnabled then
				local Light = Instance.new("PointLight")
				Light.Brightness = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LightBrightness, ClientModule.LightBrightness)
				Light.Color = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LightColor, ClientModule.LightColor)
				Light.Range = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LightRange, ClientModule.LightRange)
				Light.Shadows = ClientModule.LightShadows
				Light.Enabled = true
				Light.Parent = MuzzlePointObject
				Debris:AddItem(Light, ClientModule.VisibleTime)
			end			
		end
		
		local Character = Tool.Parent
		local IgnoreList = {Camera, Tool, Character}
		local CastParams = RaycastParams.new()
		CastParams.IgnoreWater = true
		CastParams.FilterType = Enum.RaycastFilterType.Blacklist
		CastParams.FilterDescendantsInstances = IgnoreList
		local RegionParams = OverlapParams.new()
		RegionParams.FilterType = Enum.RaycastFilterType.Blacklist
		RegionParams.FilterDescendantsInstances = IgnoreList
		RegionParams.MaxParts = 0
		RegionParams.CollisionGroup = "Default"
		
		ShootId += 1
		
		local LaserTrails = {}
		local UpdateLaserTrail
		local LaserTrailEnabled = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailEnabled, ClientModule.LaserTrailEnabled)		
		local DamageableLaserTrail = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DamageableLaserTrail, ClientModule.DamageableLaserTrail)
		if Replicate then
			if LaserTrailEnabled and DamageableLaserTrail then
				UpdateLaserTrail = Instance.new("BindableEvent")
				UpdateLaserTrail.Name = "UpdateLaserTrail_"..HttpService:GenerateGUID()
			end
		end
		
		for _, Direction in pairs(Directions) do
			if FirePointObject then
				if not FirePointObject:IsDescendantOf(Workspace) and not FirePointObject:IsDescendantOf(Tool) then
					return
				end
			else
				return
			end 
			
			local Origin, Dir = FirePointObject.WorldPosition, Direction

			local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart", 1)
			local TipCFrame = FirePointObject.WorldCFrame
			local TipPos = TipCFrame.Position
			local TipDir = TipCFrame.LookVector
			local AmountToCheatBack = math.abs((HumanoidRootPart.Position - TipPos):Dot(TipDir)) + 1
			local GunRay = Ray.new(TipPos - TipDir.Unit * AmountToCheatBack, TipDir.Unit * AmountToCheatBack)
			local HitPart, HitPoint = Workspace:FindPartOnRayWithIgnoreList(GunRay, IgnoreList, false, true)
			if HitPart and math.abs((TipPos - HitPoint).Magnitude) > 0 then
				Origin = HitPoint - TipDir.Unit * 0.1
				--Dir = TipDir.Unit
			end

			local MyMovementSpeed = HumanoidRootPart.Velocity
			local ModifiedBulletSpeed = (Dir * AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletSpeed, ClientModule.BulletSpeed)) -- + MyMovementSpeed

			local CosmeticPartProvider
			local ProjectileContainer
			local ProjectileType = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ProjectileType, ClientModule.ProjectileType)
			if ProjectileType ~= "None" then
				local Projectile = Projectiles:FindFirstChild(ProjectileType)
				if Projectile then
					local Exist2 = false
					for _, v in pairs(PartCacheStorage) do
						if v.ProjectileName == Projectile.Name then
							Exist2 = true
							ProjectileContainer = Camera:FindFirstChild("ProjectileContainer_("..Projectile.Name..")")
							CosmeticPartProvider = v.CosmeticPartProvider
							break
						end
					end
					if not Exist2 then
						ProjectileContainer = Instance.new("Folder")
						ProjectileContainer.Name = "ProjectileContainer_("..Projectile.Name..")"
						ProjectileContainer.Parent = Camera
						CosmeticPartProvider = PartCache.new(Projectile, 100, ProjectileContainer)
						table.insert(PartCacheStorage, {
							ProjectileName = Projectile.Name,
							CosmeticPartProvider = CosmeticPartProvider
						})
					end					
				end				
			end

			local PenetrationDepth = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.PenetrationDepth, ClientModule.PenetrationDepth)
			local PenetrationAmount = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.PenetrationAmount, ClientModule.PenetrationAmount)
			local PenetrationData
			if (PenetrationDepth > 0 or PenetrationAmount > 0) then
				PenetrationData = {
					PenetrationDepth = PenetrationDepth,
					PenetrationAmount = PenetrationAmount,
					PenetrationIgnoreDelay = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.PenetrationIgnoreDelay, ClientModule.PenetrationIgnoreDelay),
					HitHumanoids = {},
				}
			end

			local SpinX = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.SpinX, ClientModule.SpinX)
			local SpinY = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.SpinY, ClientModule.SpinY)
			local SpinZ = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.SpinZ, ClientModule.SpinZ)

			local BulletParticleData
			if AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletParticle, ClientModule.BulletParticle) then
				local BulletType = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletType, ClientModule.BulletType)
				if BulletType ~= "None" then
					local Attachment0 = Bullets[BulletType].Attachment0:Clone()
					local Attachment1 = Bullets[BulletType].Attachment1:Clone()
					local Effects = {}
					Attachment0.Parent = Workspace.Terrain
					Attachment1.Parent = Workspace.Terrain
					for _, effect in next, Bullets[BulletType]:GetChildren() do
						if effect:IsA("Beam") or effect:IsA("Trail") then
							local eff = effect:Clone()
							eff.Attachment0 = Attachment0 --Attachment1
							eff.Attachment1 = Attachment1 --Attachment0
							eff.Parent = Workspace.Terrain
							table.insert(Effects, eff)
						end
					end
					BulletParticleData = {
						T0 = nil,
						P0 = nil,
						V0 = nil,
						T1 = os.clock(),
						P1 = CFrame.new().pointToObjectSpace(Camera.CFrame, Origin),
						V1 = nil,
						Attachment0 = Attachment0,
						Attachment1 = Attachment1,
						Effects = Effects,
						MotionBlur = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.MotionBlur, ClientModule.MotionBlur),
						BulletSize = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletSize, ClientModule.BulletSize),
						BulletBloom = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletBloom, ClientModule.BulletBloom),
						BulletBrightness = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BulletBrightness, ClientModule.BulletBrightness),
					}
				end	
			end

			local CastBehavior = FastCast.newBehavior()
			CastBehavior.RaycastParams = CastParams
			CastBehavior.TravelType = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.TravelType, ClientModule.TravelType)
			CastBehavior.MaxDistance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.Range, ClientModule.Range)
			CastBehavior.Lifetime = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.Lifetime, ClientModule.Lifetime)
			CastBehavior.HighFidelityBehavior = FastCast.HighFidelityBehavior.Default

			--CastBehavior.CosmeticBulletTemplate = CosmeticBullet -- Uncomment if you just want a simple template part and aren't using PartCache
			CastBehavior.CosmeticBulletProvider = CosmeticPartProvider -- Comment out if you aren't using PartCache

			CastBehavior.CosmeticBulletContainer = ProjectileContainer
			CastBehavior.Acceleration = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.Acceleration, ClientModule.Acceleration)
			CastBehavior.AutoIgnoreContainer = false
			CastBehavior.HitEventOnTermination = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitEventOnTermination, ClientModule.HitEventOnTermination)
			CastBehavior.CanPenetrateFunction = CanRayPenetrate
			CastBehavior.CanHitFunction = CanRayHit

			local RaycastHitbox = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.RaycastHitbox, ClientModule.RaycastHitbox)
			local RaycastHitboxData = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.RaycastHitboxData, ClientModule.RaycastHitboxData)
			CastBehavior.RaycastHitbox = (RaycastHitbox and #RaycastHitboxData > 0) and RaycastHitboxData or nil
			CastBehavior.CurrentCFrame = CFrame.new(Origin, Origin + Dir)
			CastBehavior.ModifiedDirection = CFrame.new(Origin, Origin + Dir).LookVector

			CastBehavior.Hitscan = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HitscanMode, ClientModule.HitscanMode)
			
			local LaserTrailId = HttpService:GenerateGUID()
			if Replicate then
				if LaserTrailEnabled and DamageableLaserTrail then
					table.insert(LaserTrails, {
						Id = LaserTrailId,
						LaserContainer = {},
						HitHumanoids = {},
						Terminate = false,
					})
				end
			end
			
			local BoltCFrameTable = {}
			local LightningBoltEnabled = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LightningBoltEnabled, ClientModule.LightningBoltEnabled)
			if LightningBoltEnabled then
				local BoltRadius = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltRadius, ClientModule.BoltRadius)
				for i = 1, AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltCount, ClientModule.BoltCount) do
					if i == 1 then
						table.insert(BoltCFrameTable, CFrame.new(0, 0, 0))
					else
						table.insert(BoltCFrameTable, CFrame.new(math.random(-BoltRadius, BoltRadius), math.random(-BoltRadius, BoltRadius), 0))
					end
				end
			end
			
			CastBehavior.UserData = {
				ShootId = ShootId,
				Tool = Tool,
				Character = Character,
				ClientModule = ClientModule,
				Misc = Misc,
				Replicate = Replicate,
				PenetrationData = PenetrationData,
				BulletParticleData = BulletParticleData,
				LaserData = {
					LaserTrailEnabled = LaserTrailEnabled,					
					LaserTrailWidth = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailWidth, ClientModule.LaserTrailWidth),
					LaserTrailHeight = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailHeight, ClientModule.LaserTrailHeight),					
					LaserTrailColor = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailColor, ClientModule.LaserTrailColor),
					RandomizeLaserColorIn = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.RandomizeLaserColorIn, ClientModule.RandomizeLaserColorIn),
					LaserTrailMaterial = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailMaterial, ClientModule.LaserTrailMaterial),
					LaserTrailShape = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailShape, ClientModule.LaserTrailShape),
					LaserTrailReflectance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailReflectance, ClientModule.LaserTrailReflectance),
					LaserTrailTransparency = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailTransparency, ClientModule.LaserTrailTransparency),
					LaserTrailVisibleTime = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailVisibleTime, ClientModule.LaserTrailVisibleTime),
					LaserTrailFadeTime = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailFadeTime, ClientModule.LaserTrailFadeTime),
					ScaleLaserTrail = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ScaleLaserTrail, ClientModule.ScaleLaserTrail),
					LaserTrailScaleMultiplier = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailScaleMultiplier, ClientModule.LaserTrailScaleMultiplier),
					RandomLaserColor = Color3.new(math.random(), math.random(), math.random()),
					LaserTrailId = LaserTrailId,
					UpdateLaserTrail = UpdateLaserTrail,
					LaserTrailContainer = {},
				},
				LightningData = {
					LightningBoltEnabled = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LightningBoltEnabled, ClientModule.LightningBoltEnabled),
					BoltWideness = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltWideness, ClientModule.BoltWideness),
					BoltWidth = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltWidth, ClientModule.BoltWidth),
					BoltHeight = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltHeight, ClientModule.BoltHeight),
					BoltColor = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltColor, ClientModule.BoltColor),
					RandomizeBoltColorIn = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.RandomizeBoltColorIn, ClientModule.RandomizeBoltColorIn),
					BoltMaterial = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltMaterial, ClientModule.BoltMaterial),
					BoltShape = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltShape, ClientModule.BoltShape),
					BoltReflectance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltReflectance, ClientModule.BoltReflectance),
					BoltTransparency = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltTransparency, ClientModule.BoltTransparency),
					BoltVisibleTime = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltVisibleTime, ClientModule.BoltVisibleTime),
					BoltFadeTime = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltFadeTime, ClientModule.BoltFadeTime),
					ScaleBolt = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ScaleBolt, ClientModule.ScaleBolt),
					BoltScaleMultiplier = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BoltScaleMultiplier, ClientModule.BoltScaleMultiplier),
					RandomBoltColor = Color3.new(math.random(), math.random(), math.random()),
					BoltCFrameTable = BoltCFrameTable,
				},
				SpinData = {
					CanSpinPart = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.CanSpinPart, ClientModule.CanSpinPart),
					SpinX = SpinX,
					SpinY = SpinY,
					SpinZ = SpinZ,
					InitalTick = os.clock(),
					InitalAngularVelocity = Vector3.new(SpinX, SpinY, SpinZ),
					InitalRotation = (CastBehavior.CurrentCFrame - CastBehavior.CurrentCFrame.p),
					ProjectileOffset = Vector3.new(),
				},
				DebrisData = {
					DebrisProjectile = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DebrisProjectile, ClientModule.DebrisProjectile),
					AnchorDebris = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.AnchorDebris, ClientModule.AnchorDebris),
					CollideDebris = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.CollideDebris, ClientModule.CollideDebris),
					NormalizeDebris = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.NormalizeDebris, ClientModule.NormalizeDebris),
					BounceDebris = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BounceDebris, ClientModule.BounceDebris),
					BounceVelocity = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BounceVelocity, ClientModule.BounceVelocity),

					DecayProjectile = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DecayProjectile, ClientModule.DecayProjectile),
					AnchorDecay = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.AnchorDecay, ClientModule.AnchorDecay),
					CollideDecay = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.CollideDecay, ClientModule.CollideDecay),
					DecayVelocity = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DecayVelocity, ClientModule.DecayVelocity),
					VelocityInfluence = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.VelocityInfluence, ClientModule.VelocityInfluence),

					DisableDebrisContents = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.DisableDebrisContents, ClientModule.DisableDebrisContents),	
				},
				BounceData = {
					CurrentBounces = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.RicochetAmount, ClientModule.RicochetAmount),
					BounceElasticity = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BounceElasticity, ClientModule.BounceElasticity),
					FrictionConstant = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.FrictionConstant, ClientModule.FrictionConstant),
					IgnoreSlope = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.IgnoreSlope, ClientModule.IgnoreSlope),
					SlopeAngle = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.SlopeAngle, ClientModule.SlopeAngle),
					BounceHeight = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BounceHeight, ClientModule.BounceHeight),
					NoExplosionWhileBouncing = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.NoExplosionWhileBouncing, ClientModule.NoExplosionWhileBouncing),
					StopBouncingOn = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.StopBouncingOn, ClientModule.StopBouncingOn),
					SuperRicochet = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.SuperRicochet, ClientModule.SuperRicochet),
					BounceBetweenHumanoids = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.BounceBetweenHumanoids, ClientModule.BounceBetweenHumanoids),
					PredictDirection = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.PredictDirection, ClientModule.PredictDirection),					
					BouncedHumanoids = {},
				},
				HomeData = {
					Homing = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.Homing, ClientModule.Homing),
					HomingDistance = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HomingDistance, ClientModule.HomingDistance),
					TurnRatePerSecond = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.TurnRatePerSecond, ClientModule.TurnRatePerSecond),
					HomeThroughWall = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.HomeThroughWall, ClientModule.HomeThroughWall),
					LockOnOnHovering = ClientModule.LockOnOnHovering,
					LockedEntity = Misc.LockedEntity,
				},
				UpdateData = {
					UpdateRayInExtra = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.UpdateRayInExtra, ClientModule.UpdateRayInExtra),
					ExtraRayUpdater = AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.ExtraRayUpdater, ClientModule.ExtraRayUpdater),
				},
				IgnoreList = IgnoreList,
				LastSegmentOrigin = Vector3.new(),
				SegmentOrigin = Vector3.new(),
				SegmentDirection = Vector3.new(),
				SegmentVelocity = Vector3.new(),
				LastPosition = Origin,
				CastBehavior = CastBehavior,
				Whizzed = false,
			}

			local Simulate = Caster:Fire(Origin, Dir, ModifiedBulletSpeed, CastBehavior)
		end
		
		if Replicate then
			if LaserTrailEnabled and DamageableLaserTrail then
				if UpdateLaserTrail then
					UpdateLaserTrail.Event:Connect(function(Id, LaserContainer, Terminate)
						for _, v in pairs(LaserTrails) do
							if v.Id == Id then
								v.LaserContainer = LaserContainer
								if Terminate then
									v.Terminate = true
								end
								break
							end
						end
					end)
				end
				local Connection
				Connection = RunService.Heartbeat:Connect(function(dt)
					if #LaserTrails <= 0 then
						if UpdateLaserTrail then
							UpdateLaserTrail:Destroy()
						end
						if Connection then
							Connection:Disconnect()
							Connection = nil
						end
					else
						for i, v in next, LaserTrails, nil do
							local Terminated = false
							if v.Terminate then
								if #v.LaserContainer <= 0 then
									Terminated = true
									table.remove(LaserTrails, i)
								end
							end
							if not Terminated then
								for _, vv in pairs(v.LaserContainer) do
									if vv then
										local TouchingParts = Workspace:GetPartsInPart(vv, RegionParams)
										for _, part in pairs(TouchingParts) do
											if part and part.Parent then
												local Target = part:FindFirstAncestorOfClass("Model")
												local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
												local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or part.Parent:FindFirstChild("Head"))
												if TargetHumanoid and TargetHumanoid.Parent ~= Character and TargetTorso then
													if TargetHumanoid.Health > 0 then														
														if not table.find(v.HitHumanoids, TargetHumanoid) then
															table.insert(v.HitHumanoids, TargetHumanoid)
															Thread:Spawn(function()
																InflictTarget:InvokeServer("GunLaser", Tool, ClientModule, TargetHumanoid, TargetTorso, part, part.Size, Misc)
															end)
															if Tool and Tool.GunClient:FindFirstChild("MarkerEvent") then
																Tool.GunClient.MarkerEvent:Fire(ClientModule, false)
															end
															if AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailConstantDamage, ClientModule.LaserTrailConstantDamage) then
																Thread:Delay(AddressTableValue(ClientModule.ChargedShotAdvanceEnabled, Misc.ChargeLevel, ClientModule.ChargeAlterTable.LaserTrailDamageRate, ClientModule.LaserTrailDamageRate), function()
																	local Index = table.find(v.HitHumanoids, TargetHumanoid)
																	if Index then
																		table.remove(v.HitHumanoids, Index)
																	end
																end)
															end
														end	
													end
												end	
											end
										end
									end
								end								
							end
						end
					end
				end)				
			end			
		end
	end
end

Caster.RayFinalHit:Connect(OnRayFinalHit)
Caster.RayHit:Connect(OnRayHit)
Caster.LengthChanged:Connect(OnRayUpdated)
Caster.CastTerminating:Connect(OnRayTerminated)

return ProjectileHandler