local HttpService = game:GetService("HttpService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Miscs = ReplicatedStorage:WaitForChild("Miscs")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local Tool = script.Parent
local Handle
local AnimationFolder = Tool:WaitForChild("AnimationFolder")
local ValueFolder = Tool:WaitForChild("ValueFolder")
local Player = Players.LocalPlayer
local Character = Workspace:WaitForChild(Player.Name)
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Torso = Character:FindFirstChild("Torso") or Character:FindFirstChild("UpperTorso")
local PlayerGui = Player:WaitForChild("PlayerGui")
local Mouse = Player:GetMouse()
local Camera = Workspace.CurrentCamera
local GunServer = Tool:WaitForChild("GunServer")

local GUI = script:WaitForChild("GunGUI")
local MobileButtons = {
	AimButton = GUI.MobileButtons.AimButton,
	FireButton = GUI.MobileButtons.FireButton,
	HoldDownButton = GUI.MobileButtons.HoldDownButton,
	InspectButton = GUI.MobileButtons.InspectButton,
	ReloadButton = GUI.MobileButtons.ReloadButton,
	SwitchButton = GUI.MobileButtons.SwitchButton,
	MeleeButton = GUI.MobileButtons.MeleeButton,
	AltButton = GUI.MobileButtons.AltButton
}
local CrossFrame = GUI.Crosshair.Main
local CrossParts = {CrossFrame:WaitForChild("HR"), CrossFrame:WaitForChild("HL"), CrossFrame:WaitForChild("VD"), CrossFrame:WaitForChild("VU")}

local TouchGui
local TouchControlFrame
local JumpButton
if UserInputService.TouchEnabled then
	TouchGui = PlayerGui:WaitForChild("TouchGui")
	TouchControlFrame = TouchGui:WaitForChild("TouchControlFrame")
	JumpButton = TouchControlFrame:WaitForChild("JumpButton")
end

local MarkerEvent = script:WaitForChild("MarkerEvent")
local ChangeMagAndAmmo = GunServer:WaitForChild("ChangeMagAndAmmo")

local GunVisualEffects = Miscs.GunVisualEffects

local WeaponSettings = Modules.WeaponSettings
local Gun = WeaponSettings.Gun
local Setting = Gun[Tool.Name].Setting
local Module = require(Setting)
local SmokeTrail = require(Modules.SmokeTrail)
local DamageModule = require(Modules.DamageModule)
local Utilities = require(Modules.Utilities)
local Thread = Utilities.Thread
local ProjectileMotion = Utilities.ProjectileMotion
local Math = Utilities.Math

local gunEvent = Events.gunEvent
local gunFunction = Events.gunFunction

local InflictTarget = Remotes.InflictTarget
local ShatterGlass = Remotes.ShatterGlass
local VisualizeBeam = Remotes.VisualizeBeam
local VisibleMuzzle = Remotes.VisibleMuzzle

Handle = Tool:WaitForChild(Module.PrimaryHandle)

local GUID = HttpService:GenerateGUID()
local BindToStepName = "UpdateGun_"..GUID

local VisualEffects = Module.UseCommonVisualEffects and GunVisualEffects.Common or GunVisualEffects[Tool.Name]

local Grip2
local Handle2
local HandleToFire = Handle
local Beam, Attach0, Attach1
local Misc
local LaserTrail
local BoltSegments = {}
local Animations = {}
local SettingModules = {}
local Variables = {}
local Keyframes = {}
local KeyframeConnections = {}
local TwoDeeShells = {}
local HitHumanoids = {}

if Module.DualWeldEnabled then
	Handle2 = Tool:WaitForChild(Module.SecondaryHandle, 2)
	if Handle2 == nil and Module.DualWeldEnabled then error("\"Dual\" setting is enabled but \"Handle2\" is missing!") end
end

local TopbarOffset = (GUI.IgnoreGuiInset and GuiService:GetGuiInset()) or Vector2.new(0, 0)
local Killzone = GUI.AbsoluteSize.Y + TopbarOffset.Y + 100

local TargetMarker = script:WaitForChild("TargetMarker")
local LockedEntity

local CommonVariables = {
	Equipped = false;
	ActuallyEquipped = false;
	Enabled = true;
	Down = false;
	HoldDown = false;
	IsFiring = false;
	Reloading = false;
	CanCancelReload = false;
	AimDown = false;
	Scoping = false;
	Inspecting = false;
	Charging = false;
	Charged = false;
	Overheated = false;
	CanBeCooledDown = true;
	Switching = false;
	Alting = false;
	CurrentRate = 0;
	LastRate = 0;
	ElapsedTime = 0;
	TwoDeeShellCount = 0;
	LastUpdate = nil;
 	LastUpdate2 = nil;
	InitialSensitivity = UserInputService.MouseDeltaSensitivity;
}

local RegionParams = OverlapParams.new()
RegionParams.FilterType = Enum.RaycastFilterType.Blacklist
RegionParams.FilterDescendantsInstances = {Camera, Tool, Character}
RegionParams.MaxParts = 0
RegionParams.CollisionGroup = "Default"

for i, v in ipairs(Setting:GetChildren()) do
	table.insert(SettingModules, require(v))
	table.insert(Variables, {		
		Mag = ValueFolder[i].Mag.Value;
		Ammo = ValueFolder[i].Ammo.Value;
		Heat = ValueFolder[i].Heat.Value;
		MaxAmmo = SettingModules[i].MaxAmmo;
		ElapsedCooldownTime = 0;
		ChargeLevel = 0;
		FireModes = SettingModules[i].FireModes;
		FireMode = 1;
		ShotsForDepletion = 0;
		ShotID = 0;
	})
end

for i, v in ipairs(AnimationFolder:GetChildren()) do
	local AnimTable = {}
	if SettingModules[i].EquippedAnimationID ~= nil then
		AnimTable.EquippedAnim = v:WaitForChild("EquippedAnim")
		AnimTable.EquippedAnim = Humanoid:LoadAnimation(AnimTable.EquippedAnim)
	end
	if SettingModules[i].IdleAnimationID ~= nil then
		AnimTable.IdleAnim = v:WaitForChild("IdleAnim")
		AnimTable.IdleAnim = Humanoid:LoadAnimation(AnimTable.IdleAnim)
	end
	if SettingModules[i].FireAnimationID ~= nil then
		AnimTable.FireAnim = v:WaitForChild("FireAnim")
		AnimTable.FireAnim = Humanoid:LoadAnimation(AnimTable.FireAnim)
	end
	if SettingModules[i].ShotgunPumpinAnimationID ~= nil then
		AnimTable.ShotgunPumpinAnim = v:WaitForChild("ShotgunPumpinAnim")
		AnimTable.ShotgunPumpinAnim = Humanoid:LoadAnimation(AnimTable.ShotgunPumpinAnim)
	end
	if SettingModules[i].ShotgunClipinAnimationID ~= nil then		
		AnimTable.ShotgunClipinAnim = v:WaitForChild("ShotgunClipinAnim")
		AnimTable.ShotgunClipinAnim = Humanoid:LoadAnimation(AnimTable.ShotgunClipinAnim)
	end
	if SettingModules[i].ReloadAnimationID ~= nil then	
		AnimTable.ReloadAnim = v:WaitForChild("ReloadAnim")
		AnimTable.ReloadAnim = Humanoid:LoadAnimation(AnimTable.ReloadAnim)
	end
	if SettingModules[i].HoldDownAnimationID ~= nil then		
		AnimTable.HoldDownAnim = v:WaitForChild("HoldDownAnim")
		AnimTable.HoldDownAnim = Humanoid:LoadAnimation(AnimTable.HoldDownAnim)
	end
	if SettingModules[i].SecondaryFireAnimationEnabled and SettingModules[i].SecondaryFireAnimationID ~= nil then
		AnimTable.SecondaryFireAnim = v:WaitForChild("SecondaryFireAnim")
		AnimTable.SecondaryFireAnim = Humanoid:LoadAnimation(AnimTable.SecondaryFireAnim)
	end
	if SettingModules[i].SecondaryShotgunPump and SettingModules[i].SecondaryShotgunPumpinAnimationID ~= nil then		
		AnimTable.SecondaryShotgunPumpinAnim = v:WaitForChild("SecondaryShotgunPumpinAnim")
		AnimTable.SecondaryShotgunPumpinAnim = Humanoid:LoadAnimation(AnimTable.SecondaryShotgunPumpinAnim)
	end
	if SettingModules[i].AimAnimationsEnabled and SettingModules[i].AimIdleAnimationID ~= nil then		
		AnimTable.AimIdleAnim = v:WaitForChild("AimIdleAnim")
		AnimTable.AimIdleAnim = Humanoid:LoadAnimation(AnimTable.AimIdleAnim)
	end
	if SettingModules[i].AimAnimationsEnabled and SettingModules[i].AimFireAnimationID ~= nil then
		AnimTable.AimFireAnim = v:WaitForChild("AimFireAnim")
		AnimTable.AimFireAnim = Humanoid:LoadAnimation(AnimTable.AimFireAnim)
	end
	if SettingModules[i].AimAnimationsEnabled and SettingModules[i].AimSecondaryFireAnimationID ~= nil then		
		AnimTable.AimSecondaryFireAnim = v:WaitForChild("AimSecondaryFireAnim")
		AnimTable.AimSecondaryFireAnim = Humanoid:LoadAnimation(AnimTable.AimSecondaryFireAnim)
	end
	if SettingModules[i].AimAnimationsEnabled and SettingModules[i].AimChargingAnimationID ~= nil then		
		AnimTable.AimChargingAnim = v:WaitForChild("AimChargingAnim")
		AnimTable.AimChargingAnim = Humanoid:LoadAnimation(AnimTable.AimChargingAnim)
	end
	if SettingModules[i].TacticalReloadAnimationEnabled and SettingModules[i].TacticalReloadAnimationID ~= nil then
		AnimTable.TacticalReloadAnim = v:WaitForChild("TacticalReloadAnim")
		AnimTable.TacticalReloadAnim = Humanoid:LoadAnimation(AnimTable.TacticalReloadAnim)
	end
	if SettingModules[i].InspectAnimationEnabled and SettingModules[i].InspectAnimationID ~= nil then		
		AnimTable.InspectAnim = v:WaitForChild("InspectAnim")
		AnimTable.InspectAnim = Humanoid:LoadAnimation(AnimTable.InspectAnim)
	end
	if SettingModules[i].ShotgunReload and SettingModules[i].PreShotgunReload and SettingModules[i].PreShotgunReloadAnimationID ~= nil then
		AnimTable.PreShotgunReloadAnim = v:WaitForChild("PreShotgunReloadAnim")
		AnimTable.PreShotgunReloadAnim = Humanoid:LoadAnimation(AnimTable.PreShotgunReloadAnim)
	end
	if SettingModules[i].MinigunRevUpAnimationID ~= nil then
		AnimTable.MinigunRevUpAnim = v:WaitForChild("MinigunRevUpAnim")
		AnimTable.MinigunRevUpAnim = Humanoid:LoadAnimation(AnimTable.MinigunRevUpAnim)
	end
	if SettingModules[i].MinigunRevDownAnimationID ~= nil then
		AnimTable.MinigunRevDownAnim = v:WaitForChild("MinigunRevDownAnim")
		AnimTable.MinigunRevDownAnim = Humanoid:LoadAnimation(AnimTable.MinigunRevDownAnim)
	end
	if SettingModules[i].ChargingAnimationEnabled and SettingModules[i].ChargingAnimationID ~= nil then
		AnimTable.ChargingAnim = v:WaitForChild("ChargingAnim")
		AnimTable.ChargingAnim = Humanoid:LoadAnimation(AnimTable.ChargingAnim)
	end
	if SettingModules[i].SelectiveFireEnabled and SettingModules[i].SwitchAnimationID ~= nil then		
		AnimTable.SwitchAnim = v:WaitForChild("SwitchAnim")
		AnimTable.SwitchAnim = Humanoid:LoadAnimation(AnimTable.SwitchAnim)
	end
	if SettingModules[i].BatteryEnabled and SettingModules[i].OverheatAnimationID ~= nil then
		AnimTable.OverheatAnim = v:WaitForChild("OverheatAnim")
		AnimTable.OverheatAnim = Humanoid:LoadAnimation(AnimTable.OverheatAnim)
	end
	if SettingModules[i].MeleeAttackEnabled and SettingModules[i].MeleeAttackAnimationID ~= nil then
		AnimTable.MeleeAttackAnim = v:WaitForChild("MeleeAttackAnim")
		AnimTable.MeleeAttackAnim = Humanoid:LoadAnimation(AnimTable.MeleeAttackAnim)
	end
	if Module.AltFire and SettingModules[i].AltAnimationID ~= nil then
		AnimTable.AltAnim = v:WaitForChild("AltAnim")
		AnimTable.AltAnim = Humanoid:LoadAnimation(AnimTable.AltAnim)
	end
	if SettingModules[i].LaserBeamStartupAnimationID ~= nil then		
		AnimTable.LaserBeamStartupAnim = v:WaitForChild("LaserBeamStartupAnim")
		AnimTable.LaserBeamStartupAnim = Humanoid:LoadAnimation(AnimTable.LaserBeamStartupAnim)
	end
	if SettingModules[i].LaserBeamLoopAnimationID ~= nil then		
		AnimTable.LaserBeamLoopAnim = v:WaitForChild("LaserBeamLoopAnim")
		AnimTable.LaserBeamLoopAnim = Humanoid:LoadAnimation(AnimTable.LaserBeamLoopAnim)
	end
	if SettingModules[i].LaserBeamStopAnimationID ~= nil then		
		AnimTable.LaserBeamStopAnim = v:WaitForChild("LaserBeamStopAnim")
		AnimTable.LaserBeamStopAnim = Humanoid:LoadAnimation(AnimTable.LaserBeamStopAnim)
	end
	table.insert(Animations, AnimTable)
end

local CurrentFireMode = 1
local CurrentModule = SettingModules[CurrentFireMode]
local CurrentVariables = Variables[CurrentFireMode]
local CurrentAnimTable = Animations[CurrentFireMode]

local CurrentAimFireAnim
local CurrentAimFireAnimationSpeed
if CurrentModule.AimAnimationsEnabled then
	CurrentAimFireAnim = CurrentAnimTable.AimFireAnim
	CurrentAimFireAnimationSpeed = CurrentModule.AimFireAnimationSpeed
end
local CurrentFireAnim = CurrentAnimTable.FireAnim
local CurrentFireAnimationSpeed = CurrentModule.FireAnimationSpeed
local CurrentShotgunPumpinAnim = CurrentAnimTable.ShotgunPumpinAnim
local CurrentShotgunPumpinAnimationSpeed = CurrentModule.ShotgunPumpinSpeed

local BeamTable = {}
local CrosshairPointAttachment = Instance.new("Attachment")
CrosshairPointAttachment.Name = "CrosshairPointAttachment"
local VE = VisualEffects
if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
	VE = VisualEffects[CurrentModule]
end
for i, v in pairs(VE.LaserBeamEffect.HitEffect:GetChildren()) do
	if v.ClassName == "ParticleEmitter" then
		local particle = v:Clone()
		particle.Enabled = true
		particle.Parent = CrosshairPointAttachment
	end
end
for i, v in pairs(VE.LaserBeamEffect.LaserBeams:GetChildren()) do
	if v.ClassName == "Beam" then
		local beam = v:Clone()
		table.insert(BeamTable, beam)
	end
end	

local function FindAnimationNameForKeyframe(AnimObject)
	if CurrentModule.AnimationKeyframes[AnimObject.Name] then
		table.insert(Keyframes, {AnimObject, CurrentModule.AnimationKeyframes[AnimObject.Name]})
	end
end

for _, a in pairs(CurrentAnimTable) do
	if a then
		FindAnimationNameForKeyframe(a)
	end 
end

if Module.MagCartridge and not CurrentModule.BatteryEnabled and CurrentModule.AmmoPerMag ~= math.huge then
	for i = 1, CurrentModule.AmmoPerMag do
		local Bullet = GUI.MagCartridge.UIGridLayout.Template:Clone()
		Bullet.Name = i
		Bullet.LayoutOrder = i
		Bullet.Parent = GUI.MagCartridge
	end
end

GUI.Scanner.Size = UDim2.fromScale(CurrentModule.ScanFrameWidth * 1.25, CurrentModule.ScanFrameHeight * 1.25)
GUI.Scanner.UIStroke.Transparency = 1
GUI.Scanner.Message.TextStrokeTransparency = 1
GUI.Scanner.Message.TextTransparency = 1

local Spring = Utilities.Spring
local OldPosition = Vector2.new()

--scope

--for the scope wiggle
local Scope = Spring.spring.new(Vector3.new(0, 200, 0))
Scope.s = CurrentModule.ScopeSwaySpeed
Scope.d = CurrentModule.ScopeSwayDamper
--for the knockback wiggle
local Knockback = Spring.spring.new(Vector3.new())
Knockback.s = CurrentModule.ScopeKnockbackSpeed
Knockback.d = CurrentModule.ScopeKnockbackDamper

--camera

local CameraSpring = Spring.spring.new(Vector3.new())
CameraSpring.s	= CurrentModule.RecoilSpeed
CameraSpring.d	= CurrentModule.RecoilDamper

--crosshair

local CrossScale = Spring.spring.new(0)	
CrossScale.s = 10	
CrossScale.d = 0.8
CrossScale.t = 1
local CrossSpring = Spring.spring.new(0)
CrossSpring.s = 12
CrossSpring.d = 0.65

local function SetCrossScale(Scale)
	CrossScale.t = Scale
end	

local function SetCrossSize(Size)
	CrossSpring.t = Size
end

local function SetCrossSettings(Size, Speed, Damper)
	CrossSpring.t = Size
	CrossSpring.s = Speed
	CrossSpring.d = Damper
end

local function Random2DDirection(Velocity, X, Y)
	return Vector2.new(X, Y) * (Velocity or 1)
end

local function AddressTableValue(V1, V2)
	if V1 ~= nil and CurrentModule.ChargedShotAdvanceEnabled then
		return ((CurrentVariables.ChargeLevel == 1 and V1.Level1) or (CurrentVariables.ChargeLevel == 2 and V1.Level2) or (CurrentVariables.ChargeLevel == 3 and V1.Level3) or V2)
	else
		return V2
	end
end

local function PopulateHumanoids(mdl)
	if mdl.ClassName == "Humanoid" then
		if DamageModule.CanDamage(mdl.Parent, Character, CurrentModule.FriendlyFire) then
			table.insert(Humanoids, mdl)
		end
	end
	for i2, mdl2 in ipairs(mdl:GetChildren()) do
		PopulateHumanoids(mdl2)
	end
end

local function CastRay(Type, StartPos, Direction, Length, Blacklist, IgnoreWater)
	if Type == "Tip" then
		local Hit, EndPos, Normal, Material = Workspace:FindPartOnRayWithIgnoreList(Ray.new(StartPos, Direction * Length), Blacklist, false, IgnoreWater)
		if Hit then
			local FirePointObject = HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode)
			if FirePointObject ~= nil then
				local TipCFrame = FirePointObject.WorldCFrame
				local TipPos = TipCFrame.Position
				local TipDir = TipCFrame.LookVector
				local AmountToCheatBack = math.abs((HumanoidRootPart.Position - TipPos):Dot(TipDir)) + 1
				local GunRay = Ray.new(TipPos - TipDir.Unit * AmountToCheatBack, TipDir.Unit * AmountToCheatBack)
				local HitPart, HitPoint = Workspace:FindPartOnRayWithIgnoreList(GunRay, Blacklist, false, IgnoreWater)
				if HitPart and math.abs((TipPos - HitPoint).Magnitude) > 0 then
					return CastRay(Type, EndPos + (Direction * 0.01), Direction, Length - ((StartPos - EndPos).Magnitude), Blacklist, IgnoreWater)
				end
			end	
		end
		return Hit, EndPos, Normal, Material
	else
		local HitPart, HitPoint, HitNormal, HitMaterial = nil, StartPos + (Direction * Length), Vector3.new(0, 1, 0), Enum.Material.Air
		local Success = false	
		repeat
			HitPart, HitPoint, HitNormal, HitMaterial = Workspace:FindPartOnRayWithIgnoreList(Ray.new(StartPos, Direction * Length), Blacklist, false, IgnoreWater)
			if HitPart then
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
					or (TargetHumanoid and (TargetHumanoid.Health <= 0 or not DamageModule.CanDamage(Target, Character, CurrentModule.FriendlyFire) or CurrentModule.IgnoreHumanoids))
					or TargetTool) then
					table.insert(Blacklist, HitPart)
					Success	= false
				else
					Success	= true
				end
			else
				Success	= true
			end
		until Success
		return HitPart, HitPoint, HitNormal, HitMaterial		
	end
end

local function Get3DPosition(Type, CurrentPosOnScreen)
	local InputRay = Camera:ScreenPointToRay(CurrentPosOnScreen.X, CurrentPosOnScreen.Y)
	local EndPos = InputRay.Origin + InputRay.Direction
	local HitPart, HitPoint, HitNormal, HitMaterial = CastRay(Type, Camera.CFrame.p, (EndPos - Camera.CFrame.p).Unit, 5000, {Camera, Tool, Character}, true)
	return HitPoint
end

local function Get3DPosition2()
	local Type = CurrentModule.LaserBeam and "Beam" or "Tip"
	if Module.DirectShootingAt == "None" then
		return Get3DPosition(Type, GUI.Crosshair.AbsolutePosition)
	else
		local FirePointObject = HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode)
		if FirePointObject ~= nil then
			local Direction = ((FirePointObject.WorldCFrame * CFrame.new(0, 0, -5000)).p - FirePointObject.WorldPosition).Unit		
			local HitPart, HitPoint, HitNormal, HitMaterial = CastRay("Direct", FirePointObject.WorldPosition, Direction, 5000, {Camera, Tool, Character}, true)
			if Module.DirectShootingAt == "Both" then
				return HitPoint
			else
				if Module.DirectShootingAt == "FirstPerson" then
					if (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude <= 2 then
						return HitPoint
					else
						return Get3DPosition(Type, GUI.Crosshair.AbsolutePosition)
					end
				elseif Module.DirectShootingAt == "ThirdPerson" then
					if (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude > 2 then
						return HitPoint
					else
						return Get3DPosition(Type, GUI.Crosshair.AbsolutePosition)
					end
				end
			end			
		else
			return Get3DPosition(Type, GUI.Crosshair.AbsolutePosition)
		end
	end
end

local function CheckPartInScanner(part)
	if part then
		local PartPos, OnScreen = Camera:WorldToScreenPoint(part.Position)
		if OnScreen then
			local FrameSize = GUI.Scanner.AbsoluteSize
			local FramePos = GUI.Scanner.AbsolutePosition	
			return PartPos.X > FramePos.X and PartPos.Y > FramePos.Y and PartPos.X < FramePos.X + FrameSize.X and PartPos.Y < FramePos.Y + FrameSize.Y
		end			
	end
	return false
end

local function FindNearestEntity()
	Humanoids = {}
	PopulateHumanoids(Workspace)
	local MinOffset
	local TargetModel = nil
	local TargetHumanoid = nil
	local TargetTorso = nil
	for i, v in ipairs(Humanoids) do
		local torso = v.Parent:FindFirstChild("HumanoidRootPart") or v.Parent:FindFirstChild("Torso") or v.Parent:FindFirstChild("UpperTorso")
		if v and torso then
			local Dist = (Character.Head.Position - torso.Position).Magnitude
			local MousePos = Get3DPosition("Tip", GUI.Crosshair.AbsolutePosition)
			local MouseDirection = (MousePos - Character.Head.Position).Unit
			local Offset = (((MouseDirection * Dist) + Character.Head.Position) - torso.Position).Magnitude
			local CanFind = Dist < (CurrentModule.LockOnDistance + (torso.Size.Magnitude / 2.5)) and Offset < CurrentModule.LockOnRadius and (not MinOffset or Offset < MinOffset) and v.Health > 0
			if CurrentModule.HoldAndReleaseEnabled and not CurrentModule.SelectiveFireEnabled and CurrentModule.LockOnScan then
				CanFind = Dist < (CurrentModule.LockOnDistance + (torso.Size.Magnitude / 2.5)) and CheckPartInScanner(torso) and v.Health > 0
			end
			if CanFind then
				if DamageModule.CanDamage(v.Parent, Character, CurrentModule.FriendlyFire) then
					TargetModel = v.Parent
					TargetHumanoid = v
					TargetTorso = torso
				end
			end
		end	
	end
	return TargetModel, TargetHumanoid, TargetTorso
end

local function UpdateGUI()
	GUI.Frame.GunName.Title.Text = script.Parent.Name
	GUI.Frame.Mode.Main.Text = CurrentModule.FireModeTexts[CurrentVariables.FireMode]
	GUI.Frame.Ammo.Current.Text = CurrentVariables.Mag
	GUI.Frame.Ammo.Max.Text = CurrentVariables.Ammo

	GUI.MagCartridge.Visible = Module.MagCartridge

	GUI.MobileButtons.Visible = UserInputService.TouchEnabled --For mobile version	
	MobileButtons.AimButton.Visible = CurrentModule.SniperEnabled or CurrentModule.IronsightEnabled
	MobileButtons.HoldDownButton.Visible = CurrentModule.HoldDownEnabled
	MobileButtons.InspectButton.Visible = CurrentModule.InspectAnimationEnabled
	MobileButtons.SwitchButton.Visible = CurrentModule.SelectiveFireEnabled
	MobileButtons.ReloadButton.Visible = not CurrentModule.BatteryEnabled
	MobileButtons.MeleeButton.Visible = CurrentModule.MeleeAttackEnabled
	MobileButtons.AltButton.Visible = Module.AltFire 
end

local function UpdateCrosshair()
	if UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
		GUI.Crosshair.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)    
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude > 2 then --For mobile version, but in third-person view
		GUI.Crosshair.Position = UDim2.new(0.5, 0, 0.4, -50)
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude <= 2 then --For mobile version, but in first-person view
		GUI.Crosshair.Position = UDim2.new(0.5, -1, 0.5, -19)
	end
end

local function RenderScope()	
	Knockback.t = Knockback.t:Lerp(Vector3.new(), 0.2)
end

local function RenderMouse()
	local Delta = UserInputService:GetMouseDelta() / CurrentModule.ScopeSensitive
	local Offset = GUI.Scope.AbsoluteSize.X * 0.5

	if CommonVariables.Scoping and UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
		GUI.Scope.Position = UDim2.new(0, Scope.p.X + (Knockback.p.Y * 1000), 0, Scope.p.Y + (Knockback.p.X * 200))
		Scope.t = Vector3.new(Mouse.X - Offset - Delta.X, Mouse.Y - Offset - Delta.Y, 0)
		OldPosition = Vector2.new(Mouse.X, Mouse.Y)
	elseif CommonVariables.Scoping and UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then --For mobile version, but in first-person view
		GUI.Scope.Position = UDim2.new(0, Scope.p.X + (Knockback.p.Y * 1000), 0, Scope.p.Y + (Knockback.p.X * 200))
		Scope.t = Vector3.new(GUI.Crosshair.AbsolutePosition.X - Offset - Delta.X, GUI.Crosshair.AbsolutePosition.Y - Offset - Delta.Y, 0)
		OldPosition = Vector2.new(GUI.Crosshair.AbsolutePosition.X, GUI.Crosshair.AbsolutePosition.Y)
	end

	GUI.Scope.Visible = CommonVariables.Scoping
	if not CommonVariables.Scoping then
		GUI.Crosshair.Main.Visible = true
		Scope.t = Vector3.new(600, 200, 0)
	else
		GUI.Crosshair.Main.Visible = false
	end
	
	if Module.DirectShootingAt == "None" then
		UpdateCrosshair()
	else
		local FirePointObject = HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode)
		if FirePointObject ~= nil then
			local Position, _ = Camera:WorldToScreenPoint((FirePointObject.WorldCFrame * CFrame.new(0, 0, -5000)).p)
			if Module.DirectShootingAt == "Both" then
				GUI.Crosshair.Position = UDim2.fromOffset(Position.X, Position.Y)
			else
				if Module.DirectShootingAt == "FirstPerson" then
					if (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude <= 2 then
						GUI.Crosshair.Position = UDim2.fromOffset(Position.X, Position.Y)
					else
						UpdateCrosshair()
					end
				elseif Module.DirectShootingAt == "ThirdPerson" then
					if (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude > 2 then
						GUI.Crosshair.Position = UDim2.fromOffset(Position.X, Position.Y)
					else
						UpdateCrosshair()
					end
				end
			end			
		else
			UpdateCrosshair()
		end
	end
	
	GUI.Scanner.Position = UDim2.fromOffset(GUI.Crosshair.AbsolutePosition.X, GUI.Crosshair.AbsolutePosition.Y)
	
	if AddressTableValue(CurrentModule.ChargeAlterTable.Homing, CurrentModule.Homing) and CurrentModule.LockOnOnHovering and not CurrentModule.HitscanMode and not CurrentModule.LockOnScan then
		local TargetEntity, TargetHumanoid, TargetTorso = FindNearestEntity()
		if TargetEntity and TargetHumanoid and TargetTorso then
			LockedEntity = TargetEntity
			TargetMarker.Parent = GUI
			TargetMarker.Adornee = TargetTorso
			TargetMarker.Enabled = true
		else
			LockedEntity = nil
			TargetMarker.Enabled = false
			TargetMarker.Parent = script
			TargetMarker.Adornee = nil
		end
	end
end

local function RenderCam()			
	Camera.CoordinateFrame = Camera.CoordinateFrame * CFrame.Angles(CameraSpring.p.X, CameraSpring.p.Y, CameraSpring.p.Z)
end

local function RenderCrosshair()
	local Size = CrossSpring.p * 4 * CrossScale.p
	for i = 1, 4 do
		CrossParts[i].BackgroundTransparency = 1 - Size / 20
	end
	CrossParts[1].Position = UDim2.new(0, Size, 0, 0)
	CrossParts[2].Position = UDim2.new(0, -Size - 7, 0, 0)
	CrossParts[3].Position = UDim2.new(0, 0, 0, Size)
	CrossParts[4].Position = UDim2.new(0, 0, 0, -Size - 7)
end

local function RenderRate(dt)
	CommonVariables.ElapsedTime = CommonVariables.ElapsedTime + dt
	if CommonVariables.ElapsedTime >= 1 then
		CommonVariables.ElapsedTime = 0
		CommonVariables.CurrentRate = CommonVariables.CurrentRate - CommonVariables.LastRate
		CommonVariables.LastRate = CommonVariables.CurrentRate
	end
end

local function RenderMotion()
	if Beam and Attach0 and Attach1 then
		local Position = Get3DPosition2()
		local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode).WorldPosition, Position)
		local direction	= cframe.LookVector

		if direction then
			ProjectileMotion.UpdateProjectilePath(Beam, Attach0, Attach1, HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode).WorldPosition, direction * AddressTableValue(CurrentModule.ChargeAlterTable.BulletSpeed, CurrentModule.BulletSpeed), 3, AddressTableValue(CurrentModule.ChargeAlterTable.Acceleration, CurrentModule.Acceleration))
		end		
	end
end

local function RenderCooldown(dt)
	CurrentVariables.ElapsedCooldownTime = CurrentVariables.ElapsedCooldownTime + dt
	if CurrentVariables.ElapsedCooldownTime >= CurrentModule.CooldownTime then
		CurrentVariables.ElapsedCooldownTime = 0
		if not CommonVariables.Down then
			if not CommonVariables.Overheated then
				if CommonVariables.CanBeCooledDown then
					if CurrentVariables.Heat > 0 then
						CurrentVariables.Heat = math.clamp(CurrentVariables.Heat - CurrentModule.CooldownRate, 0, CurrentModule.MaxHeat)
						UpdateGUI()
					end						
				end			
			end
		end
	end
end

local function RenderTwoDeeShell(dt)
	local Drag = Module.Drag ^ dt
	for twoDeeShell, data in pairs(TwoDeeShells) do
		if twoDeeShell.Parent then
			data.Vel = (data.Vel * Drag) + Module.Gravity * dt
			data.Pos = data.Pos + data.Vel * dt
			data.RotVel = data.RotVel * Drag
			data.Rot = data.Rot + data.RotVel * dt
			twoDeeShell.Position = UDim2.new(0, data.Pos.X, 0, data.Pos.Y)
			twoDeeShell.Rotation = data.Rot
			if twoDeeShell.AbsolutePosition.Y > Killzone then
				twoDeeShell:Destroy()
				CommonVariables.TwoDeeShellCount = CommonVariables.TwoDeeShellCount - 1
				TwoDeeShells[twoDeeShell] = nil
			end
		else
			CommonVariables.TwoDeeShellCount = CommonVariables.TwoDeeShellCount - 1
			TwoDeeShells[twoDeeShell] = nil
		end
	end
end

--[[local function RenderMouseOLD(dt)	
	if CommonVariables.Scoping and UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
		GUI.Scope.Size = UDim2.new(Math.Lerp(GUI.Scope.Size.X.Scale, 1.2, math.min(dt * 5, 1)), 36, Math.Lerp(GUI.Scope.Size.Y.Scale, 1.2, math.min(dt * 5, 1)), 36)
		GUI.Scope.Position = UDim2.new(0, Mouse.X - GUI.Scope.AbsoluteSize.X / 2, 0, Mouse.Y - GUI.Scope.AbsoluteSize.Y / 2)
	elseif CommonVariables.Scoping and UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled then --For mobile version, but in first-person view
		GUI.Scope.Size = UDim2.new(Math.Lerp(GUI.Scope.Size.X.Scale, 1.2, math.min(dt * 5, 1)), 36, Math.Lerp(GUI.Scope.Size.Y.Scale, 1.2, math.min(dt * 5, 1)), 36)
	    GUI.Scope.Position = UDim2.new(0, GUI.Crosshair.AbsolutePosition.X - GUI.Scope.AbsoluteSize.X / 2, 0, GUI.Crosshair.AbsolutePosition.Y - GUI.Scope.AbsoluteSize.Y / 2)
	else
		GUI.Scope.Size = UDim2.new(0.6, 36, 0.6, 36)
		GUI.Scope.Position = UDim2.new(0, 0, 0, 0)
	end
	
	GUI.Scope.Visible = CommonVariables.Scoping
	
    if UserInputService.MouseEnabled and UserInputService.KeyboardEnabled then --For pc version
	    GUI.Crosshair.Position = UDim2.new(0, Mouse.X, 0, Mouse.Y)    
    elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude > 2 then --For mobile version, but in third-person view
	    GUI.Crosshair.Position = UDim2.new(0.5, 0, 0.4, -50)
    elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled and not UserInputService.KeyboardEnabled and (Character.Head.Position - Camera.CoordinateFrame.p).Magnitude <= 2 then --For mobile version, but in first-person view
	    GUI.Crosshair.Position = UDim2.new(0.5, -1, 0.5, -19)
    end
    
    GUI.Scanner.Position = UDim2.fromOffset(GUI.Crosshair.AbsolutePosition.X, GUI.Crosshair.AbsolutePosition.Y)
    
	if AddressTableValue(CurrentModule.ChargeAlterTable.Homing, CurrentModule.Homing) and CurrentModule.LockOnOnHovering and not CurrentModule.HitscanMode and not CurrentModule.LockOnScan then
		local TargetEntity, TargetHumanoid, TargetTorso = FindNearestEntity()
		if TargetEntity and TargetHumanoid and TargetTorso then
			LockedEntity = TargetEntity
			TargetMarker.Parent = GUI
			TargetMarker.Adornee = TargetTorso
			TargetMarker.Enabled = true
		else
			LockedEntity = nil
			TargetMarker.Enabled = false
			TargetMarker.Parent = script
			TargetMarker.Adornee = nil
		end
	end
end]]

local function VisibleMuzz(MuzzlePointObject, Enabled)
	for i, v in pairs(MuzzlePointObject:GetChildren()) do
		if v.ClassName == "ParticleEmitter" then
			if v:FindFirstChild("EmitCount") then
				if Enabled then
					Thread:Delay(0.01, function()
						v:Emit(v.EmitCount.Value)
					end)					
				end
			else
				v.Enabled = Enabled
			end	
		end
	end	
end

local function MarkHit(ClientModule, IsHeadshot)
	--pcall(function()
		if ClientModule.HitmarkerEnabled then
			if IsHeadshot then
				GUI.Crosshair.Hitmarker.ImageColor3 = ClientModule.HitmarkerColorHS
				GUI.Crosshair.Hitmarker.ImageTransparency = 0
				TweenService:Create(GUI.Crosshair.Hitmarker, TweenInfo.new(ClientModule.HitmarkerFadeTimeHS, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()

			else
				GUI.Crosshair.Hitmarker.ImageColor3 = ClientModule.HitmarkerColor
				GUI.Crosshair.Hitmarker.ImageTransparency = 0
				TweenService:Create(GUI.Crosshair.Hitmarker, TweenInfo.new(ClientModule.HitmarkerFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {ImageTransparency = 1}):Play()
			end
			local MarkerSound = GUI.Crosshair.MarkerSound:Clone()
			MarkerSound.SoundId = "rbxassetid://"..ClientModule.HitmarkerSoundIDs[math.random(1, #ClientModule.HitmarkerSoundIDs)]
			MarkerSound.PlaybackSpeed = IsHeadshot and ClientModule.HitmarkerSoundPitchHS or ClientModule.HitmarkerSoundPitch
			MarkerSound.Parent = Player.PlayerGui
			MarkerSound:Play()
			MarkerSound.Ended:Connect(function()
				MarkerSound:Destroy()
			end)
		end
	--end)
end

local function EjectShell(ShootingHandle)
	if AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellEnabled, CurrentModule.BulletShellEnabled) then
		if AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellParticles, CurrentModule.BulletShellParticles) then
			local function Spawner()	
				local VisualEffects2 = VisualEffects
				if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
					VisualEffects2 = VisualEffects[CurrentModule]
				end
				local ShellEjectEffect = VisualEffects2.ShellEjectEffect
				if CurrentModule.ChargedShotAdvanceEnabled then	
					if CurrentVariables.ChargeLevel == 1 then
						if VisualEffects2:FindFirstChild("ShellEjectEffectLvl1") then
							ShellEjectEffect = VisualEffects2.ShellEjectEffectLvl1
						end
					elseif CurrentVariables.ChargeLevel == 2 then
						if VisualEffects2:FindFirstChild("ShellEjectEffectLvl2") then
							ShellEjectEffect = VisualEffects2.ShellEjectEffectLvl2
						end
					elseif CurrentVariables.ChargeLevel == 3 then
						if VisualEffects2:FindFirstChild("ShellEjectEffectLvl3") then
							ShellEjectEffect = VisualEffects2.ShellEjectEffectLvl3
						end
					end
				end	
				for i, v in pairs(ShellEjectEffect:GetChildren()) do
					if v.ClassName == "ParticleEmitter" then
						local Count = 1
						local Particle = v:Clone()
						Particle.Parent = ShootingHandle["ShellEjectParticlePoint"..CurrentFireMode]
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
			Thread:Spawn(Spawner)
		end
		local RadomizeRotVelocity = AddressTableValue(CurrentModule.ChargeAlterTable.RadomizeRotVelocity, CurrentModule.RadomizeRotVelocity)
		local EjectPoint = ShootingHandle["ShellEjectPoint"..CurrentFireMode]
		local Shell = Miscs.BulletShells[AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellType, CurrentModule.BulletShellType)]:Clone()
		Shell.CFrame = EjectPoint.WorldCFrame
		Shell.CanCollide = AddressTableValue(CurrentModule.ChargeAlterTable.AllowCollide, CurrentModule.AllowCollide)
		Shell.Velocity = EjectPoint.WorldCFrame.LookVector * AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellVelocity, CurrentModule.BulletShellVelocity)
		Shell.RotVelocity = (RadomizeRotVelocity and EjectPoint.WorldCFrame.XVector or EjectPoint.WorldCFrame.LookVector) * AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellRotVelocity, CurrentModule.BulletShellRotVelocity)
		Shell.Parent = Camera
		if AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellHitSoundEnabled, CurrentModule.BulletShellHitSoundEnabled) then
			local BulletShellHitSoundIDs = AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellHitSoundIDs, CurrentModule.BulletShellHitSoundIDs)
			local BulletShellHitSoundVolume = AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellHitSoundVolume, CurrentModule.BulletShellHitSoundVolume)
			local BulletShellHitSoundPitchMin = AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellHitSoundPitchMin, CurrentModule.BulletShellHitSoundPitchMin)
			local BulletShellHitSoundPitchMax = AddressTableValue(CurrentModule.ChargeAlterTable.BulletShellHitSoundPitchMax, CurrentModule.BulletShellHitSoundPitchMax)
			local TouchedConnection = nil
			TouchedConnection = Shell.Touched:Connect(function(Hit)
				if not Hit:IsDescendantOf(Character) then
					local Sound = Instance.new("Sound")
					Sound.SoundId = "rbxassetid://"..BulletShellHitSoundIDs[math.random(1, #BulletShellHitSoundIDs)]
					Sound.PlaybackSpeed = Random.new():NextNumber(BulletShellHitSoundPitchMin, BulletShellHitSoundPitchMax)
					Sound.Volume = BulletShellHitSoundVolume
					Sound.Parent = Shell
					Sound:Play()					
					TouchedConnection:Disconnect()
					TouchedConnection = nil
				end
			end)
		end
		Debris:AddItem(Shell, AddressTableValue(CurrentModule.ChargeAlterTable.DisappearTime, CurrentModule.DisappearTime))
	end
end

local function RecoilCamera()
	if CurrentModule.CameraRecoilingEnabled then
		local Recoil = AddressTableValue(CurrentModule.ChargeAlterTable.Recoil, CurrentModule.Recoil)
		local CurrentRecoil = Recoil * (CommonVariables.AimDown and 1 - CurrentModule.RecoilRedution or 1)
		local RecoilX = math.rad(CurrentRecoil * Math.Randomize2(CurrentModule.AngleX_Min, CurrentModule.AngleX_Max, CurrentModule.Accuracy))
		local RecoilY = math.rad(CurrentRecoil * Math.Randomize2(CurrentModule.AngleY_Min, CurrentModule.AngleY_Max, CurrentModule.Accuracy))
		local RecoilZ = math.rad(CurrentRecoil * Math.Randomize2(CurrentModule.AngleZ_Min, CurrentModule.AngleZ_Max, CurrentModule.Accuracy))
		Knockback:Accelerate(Vector3.new(-RecoilX * CurrentModule.ScopeKnockbackMultiplier, -RecoilY * CurrentModule.ScopeKnockbackMultiplier, 0))
		CameraSpring:Accelerate(Vector3.new(RecoilX, RecoilY, RecoilZ))
		Thread:Wait(0.03)
		CameraSpring:Accelerate(Vector3.new(-RecoilX, -RecoilY, 0))
	end
end

local function SelfKnockback(p1, p2)
	local SelfKnockbackPower = AddressTableValue(CurrentModule.ChargeAlterTable.SelfKnockbackPower, CurrentModule.SelfKnockbackPower)
	local SelfKnockbackMultiplier = AddressTableValue(CurrentModule.ChargeAlterTable.SelfKnockbackMultiplier, CurrentModule.SelfKnockbackMultiplier)
	local SelfKnockbackRedution = AddressTableValue(CurrentModule.ChargeAlterTable.SelfKnockbackRedution, CurrentModule.SelfKnockbackRedution)
	local Power = Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall and SelfKnockbackPower * SelfKnockbackMultiplier * (1 - SelfKnockbackRedution) or SelfKnockbackPower * SelfKnockbackMultiplier
	local VelocityMod = (p1 - p2).Unit
	local AirVelocity = Torso.Velocity - Vector3.new(0, Torso.Velocity.Y, 0) + Vector3.new(VelocityMod.X, 0, VelocityMod.Z) * -Power
	local TorsoFly = Instance.new("BodyVelocity")
	TorsoFly.MaxForce = Vector3.new(math.huge, 0, math.huge)
	TorsoFly.Velocity = AirVelocity
	TorsoFly.Parent = Torso
	Torso.Velocity = Torso.Velocity + Vector3.new(0, VelocityMod.Y * 2, 0) * -Power
	Debris:AddItem(TorsoFly, 0.25)			
end

local function CreateTwoDeeShell(ObjRot, Pos, Size, Vel, type, shockwave)
	local MaxedOut = CommonVariables.TwoDeeShellCount >= Module.MaxCount
	if MaxedOut and Module.RemoveOldAtMax and math.random() then
		-- This is the best method I can figure for removing a random item from a dictionary of known length
		local RemoveCoutndown = math.random(1, Module.MaxCount)
		for twoDeeShell, _ in pairs(TwoDeeShells) do
			RemoveCoutndown = RemoveCoutndown - 1
			if RemoveCoutndown <= 0 then
				twoDeeShell:Destroy()
				CommonVariables.TwoDeeShellCount = CommonVariables.TwoDeeShellCount - 1
				TwoDeeShells[twoDeeShell] = nil
				MaxedOut = CommonVariables.TwoDeeShellCount >= Module.MaxCount
				break
			end
		end
	end
	if not MaxedOut then
		CommonVariables.TwoDeeShellCount = CommonVariables.TwoDeeShellCount + 1
		local Rot = ObjRot --math.random() * 360
		local XCenter = Pos.X + (Size.X / 2)
		local YCenter = Pos.Y + (Size.Y / 2)
		local Data = {
			RotVel = (math.random() * 2 - 1) * Module.MaxRotationSpeed,
			Rot = Rot,
			Pos = (Pos and Vector2.new(XCenter, YCenter) or Vector2.new(0, 0)) + TopbarOffset,
			Vel = Vel or Vector2.new(0, 0),
		}
		local TwoDeeShell = GUI.MagCartridge.UIGridLayout.Shell
		if type == "bullet" then
			TwoDeeShell = GUI.MagCartridge.UIGridLayout.Template
		end
		local Clone = TwoDeeShell:Clone()
		Clone.Rotation = Rot
		TwoDeeShells[Clone] = Data
		Clone.Parent = GUI
		if shockwave then
			Thread:Spawn(function()
				local ShockwaveClone = GUI.MagCartridge.UIGridLayout.Shockwave:Clone()
				local Degree = math.rad(math.random(360))
				ShockwaveClone.Position = UDim2.new(0, XCenter, 0, YCenter)
				ShockwaveClone.Rotation = math.deg(Degree)
				ShockwaveClone.Parent = GUI
				local Tween = TweenService:Create(ShockwaveClone, TweenInfo.new(0.25, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(0, 50, 0, 50), ImageTransparency = 1})
				Tween:Play()
				Tween.Completed:Wait()
				ShockwaveClone:Destroy()				
			end)
		end
	end
end

local function Fire(ShootingHandle, FireDirections, Target)	
	if CurrentModule.AimAnimationsEnabled and CommonVariables.AimDown == true then
		if CurrentAimFireAnim then
			CurrentAimFireAnim:Play(nil, nil, CurrentAimFireAnimationSpeed)
		end
	else
		if CurrentFireAnim then
			CurrentFireAnim:Play(nil, nil, CurrentFireAnimationSpeed)
		end
	end
	if CurrentAnimTable.MinigunRevUpAnim and CurrentAnimTable.MinigunRevUpAnim.IsPlaying then
		CurrentAnimTable.MinigunRevUpAnim:Stop()
	end
	--[[if CurrentAnimTable.FireAnim then
		CurrentAnimTable.FireAnim:Play(nil, nil, CurrentModule.FireAnimationSpeed)
	end]]
	--[[if not ShootingHandle[CurrentFireMode].FireSound.Playing or not ShootingHandle[CurrentFireMode].FireSound.Looped then
		ShootingHandle[CurrentFireMode].FireSound:Play()
	end]]
	local FireSounds = ShootingHandle[CurrentFireMode].FireSounds
	local VisualEffects2 = VisualEffects
	if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
		VisualEffects2 = VisualEffects[CurrentModule]
	end
	local MuzzleFolder = VisualEffects2.MuzzleEffect
	local HitEffectFolder = VisualEffects2.HitEffect
	local BloodEffectFolder = VisualEffects2.BloodEffect
	local ExplosionEffectFolder = VisualEffects2.ExplosionEffect
	local GoreEffectFolder = VisualEffects2.GoreEffect
	if CurrentModule.ChargedShotAdvanceEnabled then	
		if CurrentVariables.ChargeLevel == 1 then
			if ShootingHandle[CurrentFireMode]:FindFirstChild("FireSoundsLvl1") then
				FireSounds = ShootingHandle[CurrentFireMode].FireSoundsLvl1
			end
			if VisualEffects2:FindFirstChild("MuzzleEffectLvl1") then
				MuzzleFolder = VisualEffects2.MuzzleEffectLvl1
			end
			if VisualEffects2:FindFirstChild("HitEffectLvl1") then
				HitEffectFolder = VisualEffects2.HitEffectLvl1
			end
			if VisualEffects2:FindFirstChild("BloodEffectLvl1") then
				BloodEffectFolder = VisualEffects2.BloodEffectLvl1
			end
			if VisualEffects2:FindFirstChild("ExplosionEffectLvl1") then
				ExplosionEffectFolder = VisualEffects2.ExplosionEffectLvl1
			end
			if VisualEffects2:FindFirstChild("GoreEffectLvl1") then
				GoreEffectFolder = VisualEffects2.GoreEffectLvl1
			end
		elseif CurrentVariables.ChargeLevel == 2 then
			if ShootingHandle[CurrentFireMode]:FindFirstChild("FireSoundsLvl2") then
				FireSounds = ShootingHandle[CurrentFireMode].FireSoundsLvl2
			end
			if VisualEffects2:FindFirstChild("MuzzleEffectLvl2") then
				MuzzleFolder = VisualEffects2.MuzzleEffectLvl2
			end
			if VisualEffects2:FindFirstChild("HitEffectLvl2") then
				HitEffectFolder = VisualEffects2.HitEffectLvl2
			end
			if VisualEffects2:FindFirstChild("BloodEffectLvl2") then
				BloodEffectFolder = VisualEffects2.BloodEffectLvl2
			end
			if VisualEffects2:FindFirstChild("ExplosionEffectLvl2") then
				ExplosionEffectFolder = VisualEffects2.ExplosionEffectLvl2
			end
			if VisualEffects2:FindFirstChild("GoreEffectLvl2") then
				GoreEffectFolder = VisualEffects2.GoreEffectLvl2
			end
		elseif CurrentVariables.ChargeLevel == 3 then
			if ShootingHandle[CurrentFireMode]:FindFirstChild("FireSoundsLvl3") then
				FireSounds = ShootingHandle[CurrentFireMode].FireSoundsLvl3
			end
			if VisualEffects2:FindFirstChild("MuzzleEffectLvl3") then
				MuzzleFolder = VisualEffects2.MuzzleEffectLvl3
			end
			if VisualEffects2:FindFirstChild("HitEffectLvl3") then
				HitEffectFolder = VisualEffects2.HitEffectLvl3
			end
			if VisualEffects2:FindFirstChild("BloodEffectLvl3") then
				BloodEffectFolder = VisualEffects2.BloodEffectLvl3
			end
			if VisualEffects2:FindFirstChild("ExplosionEffectLvl3") then
				ExplosionEffectFolder = VisualEffects2.ExplosionEffectLvl3
			end
			if VisualEffects2:FindFirstChild("GoreEffectLvl3") then
				GoreEffectFolder = VisualEffects2.GoreEffectLvl3
			end
		end
	end	
	local Tracks = FireSounds:GetChildren()
	local Chosen = math.random(1, #Tracks)
	local Track = Tracks[Chosen]
	if Track ~= nil then
		gunEvent:Fire("PlayAudio",
		{
			SoundId = Track.SoundId,
			EmitterSize = Track.EmitterSize,
			MaxDistance = Track.MaxDistance,
			Volume = Track.Volume,
			Pitch = Track.PlaybackSpeed,
			Origin = ShootingHandle:FindFirstChild("GunMuzzlePoint"..CurrentFireMode),
			Echo = CurrentModule.EchoEffect,
			Silenced = CurrentModule.SilenceEffect,
			DistantSoundIds = AddressTableValue(CurrentModule.ChargeAlterTable.DistantSoundIds, CurrentModule.DistantSoundIds),
			DistantSoundVolume = AddressTableValue(CurrentModule.ChargeAlterTable.DistantSoundVolume, CurrentModule.DistantSoundVolume)
		},
		{
			Enabled = CurrentModule.LowAmmo,
			CurrentAmmo = CurrentVariables.Mag,
			AmmoPerMag = CurrentModule.AmmoPerMag,
			SoundId = ShootingHandle[CurrentFireMode].LowAmmoSound.SoundId,
			EmitterSize = ShootingHandle[CurrentFireMode].LowAmmoSound.EmitterSize,
			MaxDistance = ShootingHandle[CurrentFireMode].LowAmmoSound.MaxDistance,
			Volume = ShootingHandle[CurrentFireMode].LowAmmoSound.Volume,
			Pitch = CurrentModule.RaisePitch and (math.max(math.abs(CurrentVariables.Mag / 10 - 1), 0.4)) or ShootingHandle[CurrentFireMode].LowAmmoSound.PlaybackSpeed,
			Origin = ShootingHandle:FindFirstChild("GunMuzzlePoint"..CurrentFireMode)
		}, true)
	end
	gunEvent:Fire("VisualizeBullet", Tool, Handle, CurrentModule, FireDirections, ShootingHandle:FindFirstChild("GunFirePoint"..CurrentFireMode), ShootingHandle:FindFirstChild("GunMuzzlePoint"..CurrentFireMode),
		{
			MuzzleFolder = MuzzleFolder,
			HitEffectFolder = HitEffectFolder,
			BloodEffectFolder = BloodEffectFolder,
			ExplosionEffectFolder = ExplosionEffectFolder,
			GoreEffect = GoreEffectFolder,
			ChargeLevel = CurrentVariables.ChargeLevel,
			LockedEntity = Target or LockedEntity
		},
		true)
	CommonVariables.IsFiring = true
	Thread:Spawn(RecoilCamera)
	CrossSpring:Accelerate(AddressTableValue(CurrentModule.ChargeAlterTable.CrossExpansion, CurrentModule.CrossExpansion))
end

CurrentFireAnim:GetMarkerReachedSignal("Unlock"):Connect(function(value)
	CommonVariables.IsFiring = false
end)

local function Overheat()
	if CommonVariables.ActuallyEquipped and CommonVariables.Enabled and not CommonVariables.Overheated and (CurrentVariables.Ammo > 0 or not CurrentModule.LimitedAmmoEnabled) and CurrentVariables.Heat >= CurrentModule.MaxHeat then
		CommonVariables.Overheated = true
		if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
			CurrentAnimTable.InspectAnim:Stop()
		end
		if CommonVariables.AimDown then
			TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLengthNAD, CurrentModule.EasingStyleNAD, CurrentModule.EasingDirectionNAD), {FieldOfView = 70}):Play()
			SetCrossScale(1)
			if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.AimIdleAnim and CurrentAnimTable.AimIdleAnim.IsPlaying then
				CurrentAnimTable.AimIdleAnim:Stop()
				if CurrentAnimTable.IdleAnim then
					CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
				end
			end
			CommonVariables.Scoping = false
			Player.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity
			CommonVariables.AimDown = false
		end
		UpdateGUI()
		if CommonVariables.ActuallyEquipped then
			if CurrentAnimTable.OverheatAnim then
				CurrentAnimTable.OverheatAnim:Play(nil, nil, CurrentModule.OverheatAnimationSpeed)
			end
			Handle[CurrentFireMode].OverheatSound:Play()
		end
		--Thread:Wait(CurrentModule.OverheatTime)
		for i = 1, CurrentModule.MaxHeat do
			Thread:Wait(CurrentModule.OverheatTime / CurrentModule.MaxHeat)
			CurrentVariables.Heat = CurrentVariables.Heat - 1
			UpdateGUI()
			if CurrentVariables.Heat == 0 then
				CommonVariables.Overheated = false
				break
			end
		end
		CommonVariables.Overheated = false
		UpdateGUI()
	end
end

local function Reload()
	if CommonVariables.ActuallyEquipped and CommonVariables.Enabled and not CommonVariables.Reloading and (CurrentVariables.Ammo > 0 or not CurrentModule.LimitedAmmoEnabled) and CurrentVariables.Mag < CurrentModule.AmmoPerMag then
		CommonVariables.Reloading = true
		if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
			CurrentAnimTable.InspectAnim:Stop()
		end
		if CommonVariables.AimDown then
			TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLengthNAD, CurrentModule.EasingStyleNAD, CurrentModule.EasingDirectionNAD), {FieldOfView = 70}):Play()
			SetCrossScale(1)
			if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.AimIdleAnim and CurrentAnimTable.AimIdleAnim.IsPlaying then
				CurrentAnimTable.AimIdleAnim:Stop()
				if CurrentAnimTable.IdleAnim then
					CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
				end
			end
			CommonVariables.Scoping = false
			Player.CameraMode = Enum.CameraMode.Classic
			UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity
			CommonVariables.AimDown = false
		end
		UpdateGUI()
		if CurrentModule.ShotgunReload then
			if CurrentModule.PreShotgunReload then
				if CommonVariables.ActuallyEquipped then
					if CurrentAnimTable.PreShotgunReloadAnim then
						CurrentAnimTable.PreShotgunReloadAnim:Play(nil, nil, CurrentModule.PreShotgunReloadAnimationSpeed)
					end
					Handle[CurrentFireMode].PreReloadSound:Play()					
				end
				local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped or CommonVariables.CanCancelReload then
						if CommonVariables.ActuallyEquipped and CommonVariables.CanCancelReload then
							if CurrentAnimTable.PreShotgunReloadAnim and CurrentAnimTable.PreShotgunReloadAnim.IsPlaying then
								CurrentAnimTable.PreShotgunReloadAnim:Stop()
							end
							if Handle[CurrentFireMode].PreReloadSound.Playing then
								Handle[CurrentFireMode].PreReloadSound:Stop()
							end
						end
						break
					end
				until (os.clock() - StartTime) >= CurrentModule.PreShotgunReloadSpeed
				--Thread:Wait(CurrentModule.PreShotgunReloadSpeed)
			end
			for i = 1, (CurrentModule.AmmoPerMag - CurrentVariables.Mag) do
				if CommonVariables.ActuallyEquipped then
					if CurrentAnimTable.ShotgunClipinAnim then
						CurrentAnimTable.ShotgunClipinAnim:Play(nil, nil, CurrentModule.ShotgunClipinAnimationSpeed)
					end
					Handle[CurrentFireMode].ShotgunClipin:Play()					
				end
				local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped or CommonVariables.CanCancelReload then
						if CommonVariables.ActuallyEquipped and CommonVariables.CanCancelReload then
							if CurrentAnimTable.ShotgunClipinAnim and CurrentAnimTable.ShotgunClipinAnim.IsPlaying then
								CurrentAnimTable.ShotgunClipinAnim:Stop()
							end
							if Handle[CurrentFireMode].ShotgunClipin.Playing then
								Handle[CurrentFireMode].ShotgunClipin:Stop()
							end
						end
						break
					end
				until (os.clock() - StartTime) >= CurrentModule.ShellClipinSpeed
				--Thread:Wait(CurrentModule.ShellClipinSpeed)
				if CommonVariables.CanCancelReload then
					break
				end
				if CurrentVariables.Mag < CurrentModule.AmmoPerMag then
					if CommonVariables.ActuallyEquipped then
						if CurrentModule.LimitedAmmoEnabled then
							if CurrentVariables.Ammo > 0 then
								CurrentVariables.Mag = CurrentVariables.Mag + 1
								CurrentVariables.Ammo = CurrentVariables.Ammo - 1
								ChangeMagAndAmmo:FireServer(CurrentFireMode, CurrentVariables.Mag, CurrentVariables.Ammo, CurrentVariables.Heat)
								if Module.MagCartridge and not CurrentModule.BatteryEnabled then
									for i = 1, CurrentVariables.Mag do
										GUI.MagCartridge[i].Visible = true
									end		
								end
								UpdateGUI()                        
							end
						else
							CurrentVariables.Mag = CurrentVariables.Mag + 1
							CurrentVariables.Ammo = CurrentVariables.Ammo - 1
							ChangeMagAndAmmo:FireServer(CurrentFireMode, CurrentVariables.Mag, CurrentVariables.Ammo, CurrentVariables.Heat)
							if Module.MagCartridge and not CurrentModule.BatteryEnabled then
								for i = 1, CurrentVariables.Mag do
									GUI.MagCartridge[i].Visible = true
								end		
							end
							UpdateGUI()    
						end
					end
				else
					break
				end
				if CurrentModule.LimitedAmmoEnabled then
					if not CommonVariables.ActuallyEquipped or CurrentVariables.Ammo <= 0 then
						break
					end
				else
					if not CommonVariables.ActuallyEquipped then
						break
					end
				end
			end
		end
		if CommonVariables.ActuallyEquipped and not CommonVariables.CanCancelReload then
			if CurrentModule.TacticalReloadAnimationEnabled then
				if CurrentVariables.Mag > 0 then
					if CurrentAnimTable.TacticalReloadAnim then
						CurrentAnimTable.TacticalReloadAnim:Play(nil, nil, CurrentModule.TacticalReloadAnimationSpeed)
					end 
					Handle[CurrentFireMode].TacticalReloadSound:Play()
				else
					if CurrentAnimTable.ReloadAnim then
						CurrentAnimTable.ReloadAnim:Play(nil, nil, CurrentModule.ReloadAnimationSpeed)
					end
					Handle[CurrentFireMode].ReloadSound:Play()
				end
			else
				if CurrentAnimTable.ReloadAnim then
					CurrentAnimTable.ReloadAnim:Play(nil, nil, CurrentModule.ReloadAnimationSpeed)
				end
				Handle[CurrentFireMode].ReloadSound:Play()
			end
		end
		local ReloadTime = (CurrentVariables.Mag > 0 and CurrentModule.TacticalReloadAnimationEnabled) and CurrentModule.TacticalReloadTime or CurrentModule.ReloadTime
		local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped or CommonVariables.CanCancelReload then
				if CommonVariables.ActuallyEquipped and CommonVariables.CanCancelReload then
					if CurrentAnimTable.TacticalReloadAnim and CurrentAnimTable.TacticalReloadAnim.IsPlaying then
						CurrentAnimTable.TacticalReloadAnim:Stop()
					end
					if Handle[CurrentFireMode].TacticalReloadSound.Playing then
						Handle[CurrentFireMode].TacticalReloadSound:Stop()
					end
					if CurrentAnimTable.ReloadAnim and CurrentAnimTable.ReloadAnim.IsPlaying then
						CurrentAnimTable.ReloadAnim:Stop()
					end
					if Handle[CurrentFireMode].ReloadSound.Playing then
						Handle[CurrentFireMode].ReloadSound:Stop()
					end					
				end
				break
			end
		until (os.clock() - StartTime) >= ReloadTime
		--Thread:Wait((CurrentVariables.Mag > 0 and CurrentModule.TacticalReloadAnimationEnabled) and CurrentModule.TacticalReloadTime or CurrentModule.ReloadTime)
		if CommonVariables.ActuallyEquipped and not CommonVariables.CanCancelReload then
			if not CurrentModule.ShotgunReload then
				if Module.MagCartridge and Module.DropAllRemainingBullets and not CurrentModule.BatteryEnabled then
					for i = 1, CurrentVariables.Mag do
						local Bullet = GUI.MagCartridge:FindFirstChild(i)
						local Vel = Random2DDirection(Module.DropVelocity, math.random(Module.DropXMin, Module.DropXMax), math.random(Module.DropYMin, Module.DropYMax)) * (math.random() ^ 0.5)
						CreateTwoDeeShell(Bullet.Rotation, Bullet.AbsolutePosition, Bullet.AbsoluteSize, Vel, "bullet")	
					end	
				end
				if CurrentModule.LimitedAmmoEnabled then
					local ammoToUse = math.min(CurrentModule.AmmoPerMag - CurrentVariables.Mag, CurrentVariables.Ammo)
					CurrentVariables.Mag = CurrentVariables.Mag + ammoToUse
					CurrentVariables.Ammo = CurrentVariables.Ammo - ammoToUse
				else
					CurrentVariables.Mag = CurrentModule.AmmoPerMag
				end
				ChangeMagAndAmmo:FireServer(CurrentFireMode, CurrentVariables.Mag, CurrentVariables.Ammo, CurrentVariables.Heat)
			end
		end
		CommonVariables.Reloading = false
		CommonVariables.CanCancelReload = false
		if Module.MagCartridge and not CurrentModule.BatteryEnabled then
			for i = 1, CurrentVariables.Mag do
				GUI.MagCartridge[i].Visible = true
			end		
		end
		UpdateGUI()
	end
end

local function OnTooglingAiming()
	if not CommonVariables.Reloading and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Alting and not CommonVariables.AimDown and CommonVariables.ActuallyEquipped and CurrentModule.IronsightEnabled and (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
		TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLength, CurrentModule.EasingStyle, CurrentModule.EasingDirection), {FieldOfView = CurrentModule.FieldOfViewIS}):Play()
		SetCrossScale(CurrentModule.CrossScaleIS)
		if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
			CurrentAnimTable.InspectAnim:Stop()
		end
		if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.IdleAnim and CurrentAnimTable.IdleAnim.IsPlaying then
			CurrentAnimTable.IdleAnim:Stop()
			if CurrentAnimTable.AimIdleAnim then
				CurrentAnimTable.AimIdleAnim:Play(nil, nil, CurrentModule.AimIdleAnimationSpeed)
			end
		end
		Player.CameraMode = Enum.CameraMode.LockFirstPerson
		UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity * CurrentModule.MouseSensitiveIS
		CommonVariables.AimDown = true
	elseif not CommonVariables.Reloading and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Alting and CommonVariables.AimDown and CommonVariables.ActuallyEquipped and CurrentModule.SniperEnabled and (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
		TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLength, CurrentModule.EasingStyle, CurrentModule.EasingDirection), {FieldOfView = CurrentModule.FieldOfViewS}):Play()
		SetCrossScale(CurrentModule.CrossScaleS)
		if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
			CurrentAnimTable.InspectAnim:Stop()
		end
		if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.IdleAnim and CurrentAnimTable.IdleAnim.IsPlaying then
			CurrentAnimTable.IdleAnim:Stop()
			if CurrentAnimTable.AimIdleAnim then
				CurrentAnimTable.AimIdleAnim:Play(nil, nil, CurrentModule.AimIdleAnimationSpeed)
			end
		end
		CommonVariables.AimDown = true
		local StartTime = os.clock() repeat Thread:Wait() if not (CommonVariables.ActuallyEquipped or CommonVariables.AimDown) then break end until (os.clock() - StartTime) >= CurrentModule.ScopeDelay
		if CommonVariables.ActuallyEquipped and CommonVariables.AimDown then
			local ZoomSound = GUI.Scope.ZoomSound:Clone()
			ZoomSound.Parent = Player.PlayerGui
			ZoomSound:Play()
			ZoomSound.Ended:Connect(function()
				ZoomSound:Destroy()
			end)
			Player.CameraMode = Enum.CameraMode.LockFirstPerson
			UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity * CurrentModule.MouseSensitiveS
			CommonVariables.Scoping = true
		end
	else
		TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLengthNAD, CurrentModule.EasingStyleNAD, CurrentModule.EasingDirectionNAD), {FieldOfView = 70}):Play()
		SetCrossScale(1)
		if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.AimIdleAnim and CurrentAnimTable.AimIdleAnim.IsPlaying then
			CurrentAnimTable.AimIdleAnim:Stop()
			if CurrentAnimTable.IdleAnim then
				CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
			end
		end
		CommonVariables.Scoping = false
		Player.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity
		CommonVariables.AimDown = false
	end
end

local function OnHoldingDown()
	if CurrentModule.HoldDownEnabled then
		if not CommonVariables.Reloading and not CommonVariables.Overheated and CommonVariables.ActuallyEquipped and CommonVariables.Enabled then
			if not CommonVariables.HoldDown then
				CommonVariables.HoldDown = true
				if CurrentAnimTable.AimIdleAnim and CurrentAnimTable.AimIdleAnim.IsPlaying then
					CurrentAnimTable.AimIdleAnim:Stop()
				end
				if CurrentAnimTable.IdleAnim and CurrentAnimTable.IdleAnim.IsPlaying then
					CurrentAnimTable.IdleAnim:Stop()
				end
				if CurrentAnimTable.HoldDownAnim then
					CurrentAnimTable.HoldDownAnim:Play(nil, nil, CurrentModule.HoldDownAnimationSpeed)
				end
				if CommonVariables.AimDown then
					TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLengthNAD, CurrentModule.EasingStyleNAD, CurrentModule.EasingDirectionNAD), {FieldOfView = 70}):Play()
					SetCrossScale(1)
					CommonVariables.Scoping = false
					Player.CameraMode = Enum.CameraMode.Classic
					UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity
					CommonVariables.AimDown = false
				end
			else
				CommonVariables.HoldDown = false
				if CurrentAnimTable.IdleAnim then
					CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
				end
				if CurrentAnimTable.HoldDownAnim and CurrentAnimTable.HoldDownAnim.IsPlaying then
					CurrentAnimTable.HoldDownAnim:Stop()
				end
			end
		end
	end
end

local function OnInspecting()
	if not CommonVariables.Reloading and not CommonVariables.Overheated and CommonVariables.ActuallyEquipped and CommonVariables.Enabled and not CommonVariables.AimDown and not CommonVariables.Inspecting and not CommonVariables.Switching and not CommonVariables.Alting and CurrentModule.InspectAnimationEnabled then
		CommonVariables.Inspecting = true
		if CurrentAnimTable.InspectAnim then
			CurrentAnimTable.InspectAnim:Play(nil, nil, CurrentModule.InspectAnimationSpeed)
		end
		local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped or CommonVariables.Reloading or CommonVariables.Overheated or not CommonVariables.Enabled or CommonVariables.AimDown or CommonVariables.Switching then break end until (os.clock() - StartTime) >= CurrentAnimTable.InspectAnim.Length / CurrentAnimTable.InspectAnim.Speed
		CommonVariables.Inspecting = false	
	end
end

local function OnSwitching()
	if not CommonVariables.Reloading and not CommonVariables.Overheated and CommonVariables.ActuallyEquipped and CommonVariables.Enabled and not CommonVariables.Inspecting and not CommonVariables.Switching and not CommonVariables.Alting and CurrentModule.SelectiveFireEnabled then
		CommonVariables.Switching = true
		if CurrentAnimTable.SwitchAnim then
			CurrentAnimTable.SwitchAnim:Play(nil, nil, CurrentModule.SwitchAnimationSpeed)
		end
		local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped or CommonVariables.Reloading or CommonVariables.Overheated or not CommonVariables.Enabled or CommonVariables.Inspecting then break end until (os.clock() - StartTime) >= CurrentModule.SwitchTime
		CommonVariables.Switching = false
		if CommonVariables.ActuallyEquipped and not CommonVariables.Reloading and not CommonVariables.Overheated and CommonVariables.Enabled and not CommonVariables.Inspecting then
			Handle[CurrentFireMode].SwitchSound:Play()	
			CurrentVariables.FireMode = CurrentVariables.FireMode % #CurrentVariables.FireModes + 1
			UpdateGUI()
		end	
	end
end

local function OnAlting()
	if Module.AltFire and #Setting:GetChildren() > 1 then
		if not CommonVariables.Reloading and not CommonVariables.Overheated and CommonVariables.ActuallyEquipped and CommonVariables.Enabled and not CommonVariables.Inspecting and not CommonVariables.Alting and not CommonVariables.Switching then
			CommonVariables.Alting = true
			if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
				CurrentAnimTable.InspectAnim:Stop()
			end
			if CommonVariables.AimDown then
				TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLengthNAD, CurrentModule.EasingStyleNAD, CurrentModule.EasingDirectionNAD), {FieldOfView = 70}):Play()
				SetCrossScale(1)
				if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.AimIdleAnim and CurrentAnimTable.AimIdleAnim.IsPlaying then
					CurrentAnimTable.AimIdleAnim:Stop()
					if CurrentAnimTable.IdleAnim then
						CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
					end
				end
				CommonVariables.Scoping = false
				Player.CameraMode = Enum.CameraMode.Classic
				UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity
				CommonVariables.AimDown = false
			end
			if CurrentAnimTable.AltAnim then
				CurrentAnimTable.AltAnim:Play(nil, nil, CurrentModule.AltAnimationSpeed)
			end
			Handle[CurrentFireMode].AltSound:Play()
			local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped or CommonVariables.Reloading or CommonVariables.Overheated or not CommonVariables.Enabled or CommonVariables.Inspecting then break end until (os.clock() - StartTime) >= CurrentModule.AltTime
			CommonVariables.Alting = false
			if CommonVariables.ActuallyEquipped and not CommonVariables.Reloading and not CommonVariables.Overheated and CommonVariables.Enabled and not CommonVariables.Inspecting then
				LockedEntity = nil
				TargetMarker.Enabled = false
				TargetMarker.Parent = script
				TargetMarker.Adornee = nil
				if Beam then
					Beam:Destroy()
					Beam = nil
				end
				if Attach0 then
					Attach0:Destroy()
					Attach0 = nil
				end
				if Attach1 then
					Attach1:Destroy()
					Attach1 = nil
				end
				for _, a in pairs(CurrentAnimTable) do
					if a --[[and not a.Animation.Name == "AltAnim"]] then
						if a.IsPlaying then
							a:Stop()
						end
					end 
				end
				
				HandleToFire = Handle
				
				CommonVariables.CurrentRate = 0
				CommonVariables.LastRate = 0
				CommonVariables.ElapsedTime = 0

				CurrentFireMode = CurrentFireMode % #Setting:GetChildren() + 1
				CurrentModule = SettingModules[CurrentFireMode]
				CurrentVariables = Variables[CurrentFireMode]
				CurrentAnimTable = Animations[CurrentFireMode]
				
				if CurrentModule.AimAnimationsEnabled then
					CurrentAimFireAnim = CurrentAnimTable.AimFireAnim
					CurrentAimFireAnimationSpeed = CurrentModule.AimFireAnimationSpeed
				end
				CurrentFireAnim = CurrentAnimTable.FireAnim
				CurrentFireAnimationSpeed = CurrentModule.FireAnimationSpeed
				CurrentShotgunPumpinAnim = CurrentAnimTable.ShotgunPumpinAnim
				CurrentShotgunPumpinAnimationSpeed = CurrentModule.ShotgunPumpinSpeed
				
				Scope.s = CurrentModule.ScopeSwaySpeed
				Scope.d = CurrentModule.ScopeSwayDamper
				
				Knockback.s = CurrentModule.ScopeKnockbackSpeed
				Knockback.d = CurrentModule.ScopeKnockbackDamper

				CameraSpring.s	= CurrentModule.RecoilSpeed
				CameraSpring.d	= CurrentModule.RecoilDamper
				
				for i, v in pairs(BeamTable) do
					if v then
						v:Destroy()
					end
					table.remove(BeamTable, i)
				end
				CrosshairPointAttachment:ClearAllChildren()
				local VE2 = VisualEffects
				if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
					VE2 = VisualEffects[CurrentModule]
				end
				for i, v in pairs(VE2.LaserBeamEffect.HitEffect:GetChildren()) do
					if v.ClassName == "ParticleEmitter" then
						local particle = v:Clone()
						particle.Enabled = true
						particle.Parent = CrosshairPointAttachment
					end
				end
				for i, v in pairs(VE2.LaserBeamEffect.LaserBeams:GetChildren()) do
					if v.ClassName == "Beam" then
						local beam = v:Clone()
						table.insert(BeamTable, beam)
					end
				end	
				
				table.clear(Keyframes)
				for _, a in pairs(CurrentAnimTable) do
					if a then
						FindAnimationNameForKeyframe(a)
					end 
				end
				for i, v in pairs(KeyframeConnections) do
					v:Disconnect()
					table.remove(KeyframeConnections, i)
				end
				for _, v in pairs(Keyframes) do
					table.insert(KeyframeConnections, v[1]:GetMarkerReachedSignal("AnimationEvents"):Connect(function(keyframeName)
						if v[2][keyframeName] then
							v[2][keyframeName](keyframeName, Tool)
						end
					end))
				end
				
				if Module.MagCartridge and not CurrentModule.BatteryEnabled and CurrentModule.AmmoPerMag ~= math.huge then
					for _, v in pairs(GUI.MagCartridge:GetChildren()) do
						if not v:IsA("UIGridLayout") then
							v:Destroy()
						end
					end
					for i = 1, CurrentModule.AmmoPerMag do
						local Bullet = GUI.MagCartridge.UIGridLayout.Template:Clone()
						Bullet.Name = i
						Bullet.LayoutOrder = i
						if i > CurrentVariables.Mag then
							Bullet.Visible = false
						end
						Bullet.Parent = GUI.MagCartridge
					end
				end
				
				GUI.Scanner.Size = UDim2.fromScale(CurrentModule.ScanFrameWidth * 1.25, CurrentModule.ScanFrameHeight * 1.25)
				GUI.Scanner.UIStroke.Transparency = 1
				GUI.Scanner.Message.TextStrokeTransparency = 1
				GUI.Scanner.Message.TextTransparency = 1
				
				SmokeTrail:StopEmission()

				if CurrentModule.ProjectileMotion then
					local VisualEffects2 = VisualEffects
					if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
						VisualEffects2 = VisualEffects[CurrentModule]
					end
					Beam, Attach0, Attach1 = ProjectileMotion.ShowProjectilePath(VisualEffects2.MotionBeam, HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode).WorldPosition, Vector3.new(), 3, AddressTableValue(CurrentModule.ChargeAlterTable.Acceleration, CurrentModule.Acceleration))
				end

				if CurrentAnimTable.IdleAnim then
					CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
				end
				
				if CurrentModule.AmmoPerMag ~= math.huge and CurrentModule.MaxHeat ~= math.huge then
					GUI.Frame.Visible = true
				end
				
				UpdateGUI()
				
				SetCrossSettings(CurrentModule.CrossSize, CurrentModule.CrossSpeed, CurrentModule.CrossDamper)
				
				if CommonVariables.ActuallyEquipped and Module.AutoReload and not CommonVariables.Reloading and (CurrentVariables.Ammo > 0 or not CurrentModule.LimitedAmmoEnabled) and CurrentVariables.Mag <= 0 then
					Reload()
				end			
			end	
		end
	end
end

local function OnFiring()
	if CurrentModule.LaserBeam then
		CommonVariables.Down = true
		if CommonVariables.ActuallyEquipped and CommonVariables.Enabled and CommonVariables.Down and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 then
			if Module.CancelReload then
				if CommonVariables.Reloading and not CommonVariables.CanCancelReload then
					CommonVariables.CanCancelReload = true
				end
			else
				if CommonVariables.Reloading then
					return
				end
			end
			CommonVariables.CanBeCooledDown = false	
			CommonVariables.Enabled = false
			if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
				CurrentAnimTable.InspectAnim:Stop()
			end			
			if CurrentModule.LaserBeamStartupDelay > 0 then
				if CurrentAnimTable.LaserBeamStartupAnim and not CurrentAnimTable.LaserBeamStartupAnim.IsPlaying then
					CurrentAnimTable.LaserBeamStartupAnim:Play(nil, nil, CurrentModule.LaserBeamStartupAnimationSpeed)
				end
				if CommonVariables.ActuallyEquipped and HandleToFire[CurrentFireMode]:FindFirstChild("BeamStartupSound") then
					HandleToFire[CurrentFireMode].BeamStartupSound:Play()
				end
				Thread:Wait(CurrentModule.LaserBeamStartupDelay)
			end
			local Start = false
			local MuzzlePoint = HandleToFire:FindFirstChild("GunMuzzlePoint"..CurrentFireMode)
			local FirePoint = HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode)
			while CommonVariables.ActuallyEquipped and not CommonVariables.Reloading and not CommonVariables.Overheated and not CommonVariables.HoldDown and CommonVariables.Down and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 do
				if CurrentAnimTable.LaserBeamLoopAnim and not CurrentAnimTable.LaserBeamLoopAnim.IsPlaying then
					CurrentAnimTable.LaserBeamLoopAnim:Play(nil, nil, CurrentModule.LaserBeamLoopAnimationSpeed)
				end
				if not HandleToFire[CurrentFireMode].BeamLoopSound.Playing or not HandleToFire[CurrentFireMode].BeamLoopSound.Looped then
					HandleToFire[CurrentFireMode].BeamLoopSound:Play()
				end
				local FireDirection = (Get3DPosition2() - FirePoint.WorldPosition).Unit
				local Hit, Pos, Normal, Material = CastRay("Beam", FirePoint.WorldPosition, FireDirection, CurrentModule.LaserBeamRange, {Tool, Character, Camera}, true)
				if not Start then
					Start = true
					HandleToFire[CurrentFireMode].BeamFireSound:Play()
					VisibleMuzz(MuzzlePoint, true)
					VisibleMuzzle:FireServer(MuzzlePoint, true)
					for i, v in pairs(BeamTable) do
						if v then
							v.Parent = Handle
							v.Attachment0 = FirePoint
							v.Attachment1 = CrosshairPointAttachment
						end
					end
					if CurrentModule.LaserTrailEnabled then
						LaserTrail = Miscs[CurrentModule.LaserTrailShape.."Segment"]:Clone()
						if CurrentModule.RandomizeLaserColorIn == "None" then
							LaserTrail.Color = CurrentModule.LaserTrailColor
						end
						LaserTrail.Material = CurrentModule.LaserTrailMaterial
						LaserTrail.Reflectance = CurrentModule.LaserTrailReflectance
						LaserTrail.Transparency = CurrentModule.LaserTrailTransparency
						LaserTrail.Size = CurrentModule.LaserTrailShape == "Cone" and Vector3.new(CurrentModule.LaserTrailWidth, (FirePoint.WorldPosition - Pos).Magnitude, CurrentModule.LaserTrailHeight) or Vector3.new((FirePoint.WorldPosition - Pos).Magnitude, CurrentModule.LaserTrailHeight, CurrentModule.LaserTrailWidth)
						LaserTrail.CFrame = CFrame.new((FirePoint.WorldPosition + Pos) * 0.5, Pos) * (CurrentModule.LaserTrailShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
						LaserTrail.Parent = Camera
					end
				end
				if LaserTrail then
					if CurrentModule.RandomizeLaserColorIn ~= "None" then
						local Hue = os.clock() % CurrentModule.LaserColorCycleTime / CurrentModule.LaserColorCycleTime
						local Color = Color3.fromHSV(Hue, 1, 1)
						LaserTrail.Color = Color
					end
					LaserTrail.Size = CurrentModule.LaserTrailShape == "Cone" and Vector3.new(CurrentModule.LaserTrailWidth, (FirePoint.WorldPosition - Pos).Magnitude, CurrentModule.LaserTrailHeight) or Vector3.new((FirePoint.WorldPosition - Pos).Magnitude, CurrentModule.LaserTrailHeight, CurrentModule.LaserTrailWidth)
					LaserTrail.CFrame = CFrame.new((FirePoint.WorldPosition + Pos) * 0.5, Pos) * (CurrentModule.LaserTrailShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
				end
				if CurrentModule.LightningBoltEnabled then
					local BoltCFrameTable = {}
					local BoltRadius = CurrentModule.BoltRadius
					for i = 1, CurrentModule.BoltCount do
						if i == 1 then
							table.insert(BoltCFrameTable, CFrame.new(0, 0, 0))
						else
							table.insert(BoltCFrameTable, CFrame.new(math.random(-BoltRadius, BoltRadius), math.random(-BoltRadius, BoltRadius), 0))
						end
					end
					for _, v in ipairs(BoltCFrameTable) do
						local Start = (CFrame.new(FirePoint.WorldPosition, FirePoint.WorldPosition + FireDirection) * v).p
						local End = (CFrame.new(Pos, Pos + FireDirection) * v).p
						local Distance = (End - Start).Magnitude
						local LastPos = Start
						local RandomBoltColor = Color3.new(math.random(), math.random(), math.random())
						for i = 0, Distance, 10 do
							local FakeDistance = CFrame.new(Start, End) * CFrame.new(0, 0, -i - 10) * CFrame.new(-2 + (math.random() * CurrentModule.BoltWideness), -2 + (math.random() * CurrentModule.BoltWideness), -2 + (math.random() * CurrentModule.BoltWideness))
							local BoltSegment = Miscs[CurrentModule.BoltShape.."Segment"]:Clone()
							if CurrentModule.RandomizeBoltColorIn ~= "None" then
								if CurrentModule.RandomizeBoltColorIn == "Whole" then
									BoltSegment.Color = RandomBoltColor
								elseif CurrentModule.RandomizeBoltColorIn == "Segment" then
									BoltSegment.Color = Color3.new(math.random(), math.random(), math.random())
								end
							else
								BoltSegment.Color = CurrentModule.BoltColor
							end
							BoltSegment.Material = CurrentModule.BoltMaterial
							BoltSegment.Reflectance = CurrentModule.BoltReflectance
							BoltSegment.Transparency = CurrentModule.BoltTransparency
							if i + 10 > Distance then
								BoltSegment.CFrame = CFrame.new(LastPos, End) * CFrame.new(0, 0, -(LastPos - End).Magnitude / 2) * (CurrentModule.BoltShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
							else
								BoltSegment.CFrame = CFrame.new(LastPos, FakeDistance.p) * CFrame.new(0, 0, -(LastPos - FakeDistance.p).Magnitude / 2) * (CurrentModule.BoltShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
							end
							if i + 10 > Distance then
								BoltSegment.Size = CurrentModule.BoltShape == "Cone" and Vector3.new(CurrentModule.BoltWidth, (LastPos - End).Magnitude, CurrentModule.BoltHeight) or Vector3.new((LastPos - End).Magnitude, CurrentModule.BoltHeight, CurrentModule.BoltWidth)
							else
								BoltSegment.Size = CurrentModule.BoltShape == "Cone" and Vector3.new(CurrentModule.BoltWidth, (LastPos - FakeDistance.p).Magnitude, CurrentModule.BoltHeight) or Vector3.new((LastPos - FakeDistance.p).Magnitude, CurrentModule.BoltHeight, CurrentModule.BoltWidth)
							end
							BoltSegment.Parent = Camera
							table.insert(BoltSegments, BoltSegment)
							Thread:Delay(CurrentModule.BoltVisibleTime, function()
								if CurrentModule.BoltFadeTime > 0 then
									local DesiredSize = BoltSegment.Size * (CurrentModule.ScaleBolt and Vector3.new(1, CurrentModule.BoltScaleMultiplier, CurrentModule.BoltScaleMultiplier) or Vector3.new(1, 1, 1))
									local Tween = TweenService:Create(BoltSegment, TweenInfo.new(CurrentModule.BoltFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
									Tween:Play()
									Tween.Completed:Wait()
									local Index = table.find(BoltSegments, BoltSegment)
									if Index then
										table.remove(BoltSegments, Index)
									end
									BoltSegment:Destroy()
								else
									local Index = table.find(BoltSegments, BoltSegment)
									if Index then
										table.remove(BoltSegments, Index)
									end
									BoltSegment:Destroy()							
								end
							end)
							LastPos = FakeDistance.p
						end
					end
				end
				
				CrosshairPointAttachment.Parent = Workspace.Terrain
				CrosshairPointAttachment.WorldCFrame = CFrame.new(Pos)
				if CurrentModule.LookAtInput then
					MuzzlePoint.CFrame = MuzzlePoint.Parent.CFrame:toObjectSpace(CFrame.lookAt(MuzzlePoint.WorldPosition, Pos))
					CrosshairPointAttachment.WorldCFrame = CFrame.new(Pos, FireDirection)
				end
				
				Misc = {ChargeLevel = CurrentVariables.ChargeLevel}
				
				local lastUpdate = CommonVariables.LastUpdate or 0
				local now = os.clock()
				if (now - lastUpdate) > 0.1 then
					CommonVariables.LastUpdate = now
					--Replicate Beam or something
					local VE3 = VisualEffects
					if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
						VE3 = VisualEffects[CurrentModule]
					end
					VisualizeBeam:FireServer(true, {
						Id = GUID,
						ClientModule = CurrentModule,
						LaserBeams = VE3.LaserBeamEffect.LaserBeams,
						HitEffect = VE3.LaserBeamEffect.HitEffect,
						CrosshairPosition = Pos,
						Handle = HandleToFire,
						MuzzlePoint = MuzzlePoint,
						FirePoint = FirePoint,
					})
				end
				
				local lastUpdate2 = CommonVariables.LastUpdate2 or 0
				local now2 = os.clock()
				if (now2 - lastUpdate2) > CurrentModule.LaserTrailDamageRate then
					CommonVariables.LastUpdate2 = now2
					--Damage hum or something
					if Hit then
						if Hit.Name == "_glass" and CurrentModule.CanBreakGlass then
							ShatterGlass:FireServer(Hit, Pos, FireDirection)
						else
							local Target = Hit:FindFirstAncestorOfClass("Model")
							local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
							local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
							local VisualEffects2 = VisualEffects
							if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
								VisualEffects2 = VisualEffects[CurrentModule]
							end
							if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
								if TargetHumanoid.Health > 0 then
									Thread:Spawn(function()
										InflictTarget:InvokeServer("GunLaser", Tool, CurrentModule, TargetHumanoid, TargetTorso, Hit, Hit.Size, Misc)
									end)
									MarkHit(CurrentModule, false)
								end
							end							
						end
					end
					if CurrentModule.BatteryEnabled then
						CurrentVariables.ShotsForDepletion = CurrentVariables.ShotsForDepletion + 1
						if CurrentVariables.ShotsForDepletion >= CurrentModule.ShotsForDepletion then
							CurrentVariables.ShotsForDepletion = 0
							CurrentVariables.Ammo = CurrentVariables.Ammo - Random.new():NextInteger(CurrentModule.MinDepletion, CurrentModule.MaxDepletion)
						end	
						CurrentVariables.Heat = CurrentVariables.Heat + Random.new():NextInteger(CurrentModule.HeatPerFireMin, CurrentModule.HeatPerFireMax)
					else
						if Module.MagCartridge and not CurrentModule.BatteryEnabled and CurrentModule.AmmoPerMag ~= math.huge then
							local Bullet = GUI.MagCartridge:FindFirstChild(CurrentVariables.Mag)
							if Module.Ejection then
								local Vel = Random2DDirection(Module.Velocity, math.random(Module.XMin, Module.XMax), math.random(Module.YMin, Module.YMax)) * (math.random() ^ 0.5)
								CreateTwoDeeShell(Bullet.Rotation, Bullet.AbsolutePosition, Bullet.AbsoluteSize, Vel, "shell", Module.Shockwave)								
							end
							Bullet.Visible = false	
						end
						CurrentVariables.Mag = CurrentVariables.Mag - 1
					end
					ChangeMagAndAmmo:FireServer(CurrentFireMode, CurrentVariables.Mag, CurrentVariables.Ammo, CurrentVariables.Heat)
					Thread:Spawn(function()
						CurrentVariables.ShotID = CurrentVariables.ShotID + 1
						local LastShotID = CurrentVariables.ShotID
						local Interrupted = false
						local CooldownTime = CurrentModule.TimeBeforeCooldown
						local StartTime = os.clock() repeat Thread:Wait() if LastShotID ~= CurrentVariables.ShotID then break end until (os.clock() - StartTime) >= CooldownTime		
						if LastShotID ~= CurrentVariables.ShotID then Interrupted = true end				
						if not Interrupted then
							CommonVariables.CanBeCooledDown = true
						end
					end)
					UpdateGUI()
				end
				
				if LaserTrail and CurrentModule.DamageableLaserTrail then
					local TouchingParts = Workspace:GetPartsInPart(LaserTrail, RegionParams)
					for _, part in pairs(TouchingParts) do
						if part and part.Parent then
							local Target = part:FindFirstAncestorOfClass("Model")
							local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
							local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or part.Parent:FindFirstChild("Head"))
							if TargetHumanoid and TargetHumanoid.Parent ~= Character and TargetTorso then
								if TargetHumanoid.Health > 0 then														
									if not table.find(HitHumanoids, TargetHumanoid) then
										table.insert(HitHumanoids, TargetHumanoid)
										Thread:Spawn(function()
											InflictTarget:InvokeServer("GunLaser", Tool, CurrentModule, TargetHumanoid, TargetTorso, part, part.Size, Misc)
										end)
										MarkHit(CurrentModule, false)
										if CurrentModule.LaserTrailConstantDamage then
											Thread:Delay(CurrentModule.LaserTrailDamageRate, function()
												local Index = table.find(HitHumanoids, TargetHumanoid)
												if Index then
													table.remove(HitHumanoids, Index)
												end
											end)
										end
									end	
								end
							end	
						end
					end
				end				
				
				CommonVariables.CurrentRate = CommonVariables.CurrentRate + CurrentModule.SmokeTrailRateIncrement
				
				Thread:Wait()
			end
			if Misc then
				VisualizeBeam:FireServer(false, {
					Id = GUID,
					ClientModule = CurrentModule,
				})
				Misc = nil				
			end
			for i, v in pairs(BeamTable) do
				if v then
					v.Attachment0 = nil
					v.Attachment1 = nil
					v.Parent = nil
				end
			end
			if LaserTrail then
				Thread:Spawn(function()
					local LastLaserTrail = LaserTrail
					if CurrentModule.LaserTrailFadeTime > 0 then
						local DesiredSize = LastLaserTrail.Size * (CurrentModule.ScaleLaserTrail and Vector3.new(1, CurrentModule.LaserTrailScaleMultiplier, CurrentModule.LaserTrailScaleMultiplier) or Vector3.new(1, 1, 1))
						local Tween = TweenService:Create(LastLaserTrail, TweenInfo.new(CurrentModule.LaserTrailFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
						Tween:Play()
						Tween.Completed:Wait()
						LastLaserTrail:Destroy()
					else
						LastLaserTrail:Destroy()
					end	
				end)
				LaserTrail = nil
			end
			if CrosshairPointAttachment then
				CrosshairPointAttachment.Parent = nil
			end
			VisibleMuzz(MuzzlePoint, false)
			VisibleMuzzle:FireServer(MuzzlePoint, false)
			if (CurrentModule.BatteryEnabled and CurrentVariables.Heat >= CurrentModule.MaxHeat or CurrentVariables.Mag <= 0) then
				if CommonVariables.CurrentRate >= CurrentModule.MaximumRate and CurrentModule.SmokeTrailEnabled then
					Thread:Spawn(function()
						SmokeTrail:StopEmission()
						SmokeTrail:EmitSmokeTrail(HandleToFire["SmokeTrail"..CurrentFireMode], CurrentModule.MaximumTime)
					end)
				end				
			end
			if HandleToFire[CurrentFireMode].BeamLoopSound.Playing and HandleToFire[CurrentFireMode].BeamLoopSound.Looped then
				HandleToFire[CurrentFireMode].BeamLoopSound:Stop()
			end
			if CurrentAnimTable.LaserBeamLoopAnim and CurrentAnimTable.LaserBeamLoopAnim.IsPlaying then
				CurrentAnimTable.LaserBeamLoopAnim:Stop()
			end
			if CurrentAnimTable.LaserBeamStartupAnim and CurrentAnimTable.LaserBeamStartupAnim.IsPlaying then
				CurrentAnimTable.LaserBeamStartupAnim:Stop()
			end
			if HandleToFire[CurrentFireMode].BeamFireSound.Playing then
				HandleToFire[CurrentFireMode].BeamFireSound:Stop()
			end
			if CommonVariables.ActuallyEquipped and HandleToFire[CurrentFireMode]:FindFirstChild("BeamEndSound") then
				HandleToFire[CurrentFireMode].BeamEndSound:Play()
			end
			local Overheated = false
			if CommonVariables.ActuallyEquipped then
				if CurrentModule.BatteryEnabled then
					if CurrentVariables.Heat >= CurrentModule.MaxHeat then
						Overheated = true
						CommonVariables.Enabled = true
						Thread:Spawn(Overheat)
					end
				end
			end
			if not Overheated then
				if CommonVariables.ActuallyEquipped and CurrentAnimTable.LaserBeamStopAnim and not CurrentAnimTable.LaserBeamStopAnim.IsPlaying then
					CurrentAnimTable.LaserBeamStopAnim:Play(nil, nil, CurrentModule.LaserBeamStopAnimationSpeed)
				end
				Thread:Wait(CurrentModule.LaserBeamStopDelay)
				CommonVariables.Enabled = true
				if CommonVariables.ActuallyEquipped then
					if Module.AutoReload then
						if CurrentVariables.Mag <= 0 then
							Reload()
						end
					end
				end				
			end
		end
	else
		if CurrentModule.ChargedShotAdvanceEnabled and not CurrentModule.SelectiveFireEnabled then
			CommonVariables.Charging = true
			if CommonVariables.ActuallyEquipped and CommonVariables.Enabled and CommonVariables.Charging and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 then
				if Module.CancelReload then
					if CommonVariables.Reloading and not CommonVariables.CanCancelReload then
						CommonVariables.CanCancelReload = true
					end
				else
					if CommonVariables.Reloading then
						return
					end
				end
				CommonVariables.CanBeCooledDown = false	
				CommonVariables.Enabled = false
				if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
					CurrentAnimTable.InspectAnim:Stop()
				end
				if CurrentModule.AimAnimationsEnabled and CommonVariables.AimDown then
					if CurrentAnimTable.AimChargingAnim and not CurrentAnimTable.AimChargingAnim.IsPlaying then
						CurrentAnimTable.AimChargingAnim:Play(nil, nil, CurrentModule.AimChargingAnimationSpeed)
					end
				else
					if CurrentAnimTable.ChargingAnim and not CurrentAnimTable.ChargingAnim.IsPlaying then
						CurrentAnimTable.ChargingAnim:Play(nil, nil, CurrentModule.ChargingAnimationSpeed)
					end
				end
				local ChargingSound = HandleToFire[CurrentFireMode]:FindFirstChild("ChargingSound")
				local StartTime = os.clock()
				while true do
					local DeltaTime = os.clock() - StartTime
					if CurrentVariables.ChargeLevel == 0 and DeltaTime >= CurrentModule.Level1ChargingTime then
						CurrentVariables.ChargeLevel = 1
						GUI.ChargeBar.ChargeLevel1:Play()
					elseif CurrentVariables.ChargeLevel == 1 and DeltaTime >= CurrentModule.Level2ChargingTime then
						CurrentVariables.ChargeLevel = 2
						GUI.ChargeBar.ChargeLevel2:Play()
					elseif CurrentVariables.ChargeLevel == 2 and DeltaTime >= CurrentModule.AdvancedChargingTime then
						CurrentVariables.ChargeLevel = 3
						GUI.ChargeBar.ChargeLevel3:Play()
						GUI.ChargeBar.Shine.UIGradient.Offset = Vector2.new(-1, 0)
						TweenService:Create(GUI.ChargeBar.Shine.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Offset = Vector2.new(1, 0)}):Play()
					end
					local ChargePercent = math.min(DeltaTime / CurrentModule.AdvancedChargingTime, 1)
					if ChargePercent < 0.5 then --Fade from red to yellow then to green
						GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1, ChargePercent * 2, 0)
					else
						GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1 - ((ChargePercent - 0.5) / 0.5), 1, 0)
					end
					GUI.ChargeBar.Fill.Size = UDim2.new(ChargePercent, 0, 1, 0)
					if ChargingSound then
						if not ChargingSound.Playing then
							ChargingSound:Play()
						end
						if CurrentModule.ChargingSoundIncreasePitch then
							ChargingSound.PlaybackSpeed = CurrentModule.ChargingSoundPitchRange[1] + (ChargePercent * (CurrentModule.ChargingSoundPitchRange[2] - CurrentModule.ChargingSoundPitchRange[1]))
						end
					end
					Thread:Wait()
					if not CommonVariables.ActuallyEquipped or not CommonVariables.Charging then
						break
					end
				end
				if CurrentAnimTable.AimChargingAnim and CurrentAnimTable.AimChargingAnim.IsPlaying then
					CurrentAnimTable.AimChargingAnim:Stop(0)
				end
				if CurrentAnimTable.ChargingAnim and CurrentAnimTable.ChargingAnim.IsPlaying then
					CurrentAnimTable.ChargingAnim:Stop(0)
				end
				GUI.ChargeBar.Fill.Size = UDim2.new(0, 0, 1, 0)
				if ChargingSound then
					if ChargingSound.Playing then
						ChargingSound:Stop()
					end
					if CurrentModule.ChargingSoundIncreasePitch then
						ChargingSound.PlaybackSpeed = CurrentModule.ChargingSoundPitchRange[1]
					end
				end
				if not CommonVariables.ActuallyEquipped then
					CurrentVariables.ChargeLevel = 0
					CommonVariables.Enabled = true
				end
				if CommonVariables.ActuallyEquipped and not CommonVariables.Enabled and not CommonVariables.Charging and not CommonVariables.Reloading and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 then
					for i = 1, (CurrentModule.BurstFireEnabled and (AddressTableValue(CurrentModule.ChargeAlterTable.BulletPerBurst, CurrentModule.BulletPerBurst)) or 1) do
						if not CommonVariables.ActuallyEquipped then
							break
						end
						local Directions = {}
						if not CurrentModule.ShotgunPump then
							Thread:Spawn(function()
								local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BulletShellDelay
								if CommonVariables.ActuallyEquipped then
									EjectShell(HandleToFire)
								end
							end)
						end
						CommonVariables.CurrentRate = CommonVariables.CurrentRate + CurrentModule.SmokeTrailRateIncrement
						local Position = Get3DPosition2()
						for ii = 1, (CurrentModule.ShotgunEnabled and (AddressTableValue(CurrentModule.ChargeAlterTable.BulletPerShot, CurrentModule.BulletPerShot)) or 1) do
							local Spread = AddressTableValue(CurrentModule.ChargeAlterTable.Spread, CurrentModule.Spread)
							local CurrentSpread = Spread * 10 * (CommonVariables.AimDown and 1 - CurrentModule.SpreadRedutionIS and 1 - CurrentModule.SpreadRedutionS or 1)
							local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode).WorldPosition, Position)
							
							local SpreadPattern = AddressTableValue(CurrentModule.ChargeAlterTable.SpreadPattern, CurrentModule.SpreadPattern)
							if AddressTableValue(CurrentModule.ChargeAlterTable.ShotgunPattern, CurrentModule.ShotgunPattern) and #SpreadPattern > 0 then
								local X, Y = SpreadPattern[ii][1], SpreadPattern[ii][2]
								cframe = cframe * CFrame.Angles(math.rad(CurrentSpread * Y / 50), math.rad(CurrentSpread * X / 50), 0)
							else
								cframe = cframe * CFrame.Angles(math.rad(math.random(-CurrentSpread, CurrentSpread) / 50), math.rad(math.random(-CurrentSpread, CurrentSpread) / 50), 0)
							end

							local Direction	= cframe.LookVector
							table.insert(Directions, Direction)
						end
						if AddressTableValue(CurrentModule.ChargeAlterTable.SelfKnockback, CurrentModule.SelfKnockback) then
							SelfKnockback(Position, Torso.Position)
						end
						Fire(HandleToFire, Directions)
						if CurrentModule.BatteryEnabled then
							CurrentVariables.ShotsForDepletion = CurrentVariables.ShotsForDepletion + 1
							if CurrentVariables.ShotsForDepletion >= CurrentModule.ShotsForDepletion then
								CurrentVariables.ShotsForDepletion = 0
								CurrentVariables.Ammo = CurrentVariables.Ammo - Random.new():NextInteger(AddressTableValue(CurrentModule.ChargeAlterTable.MinDepletion, CurrentModule.MinDepletion), AddressTableValue(CurrentModule.ChargeAlterTable.MaxDepletion, CurrentModule.MaxDepletion))
							end	
							CurrentVariables.Heat = CurrentVariables.Heat + Random.new():NextInteger(AddressTableValue(CurrentModule.ChargeAlterTable.HeatPerFireMin, CurrentModule.HeatPerFireMin), AddressTableValue(CurrentModule.ChargeAlterTable.HeatPerFireMax, CurrentModule.HeatPerFireMax))
						else
							if Module.MagCartridge and not CurrentModule.BatteryEnabled and CurrentModule.AmmoPerMag ~= math.huge then
								local Bullet = GUI.MagCartridge:FindFirstChild(CurrentVariables.Mag)
								if Module.Ejection then
									local Vel = Random2DDirection(Module.Velocity, math.random(Module.XMin, Module.XMax), math.random(Module.YMin, Module.YMax)) * (math.random() ^ 0.5)
									CreateTwoDeeShell(Bullet.Rotation, Bullet.AbsolutePosition, Bullet.AbsoluteSize, Vel, "shell", Module.Shockwave)								
								end
								Bullet.Visible = false						
							end
							CurrentVariables.Mag = CurrentVariables.Mag - 1
						end
						ChangeMagAndAmmo:FireServer(CurrentFireMode, CurrentVariables.Mag, CurrentVariables.Ammo, CurrentVariables.Heat)
						Thread:Spawn(function()
							CurrentVariables.ShotID = CurrentVariables.ShotID + 1
							local LastShotID = CurrentVariables.ShotID
							local Interrupted = false
							local CooldownTime = CurrentModule.TimeBeforeCooldown
							local StartTime = os.clock() repeat Thread:Wait() if LastShotID ~= CurrentVariables.ShotID then break end until (os.clock() - StartTime) >= CooldownTime		
							if LastShotID ~= CurrentVariables.ShotID then Interrupted = true end				
							if not Interrupted then
								CommonVariables.CanBeCooledDown = true
							end
						end)
						UpdateGUI()
						if CurrentModule.BurstFireEnabled then
							local BurstRate = AddressTableValue(CurrentModule.ChargeAlterTable.BurstRate, CurrentModule.BurstRate)
							local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= BurstRate
							--Thread:Wait(BurstRate)
						end
						--[[if not CommonVariables.ActuallyEquipped then
							break
						end]]
						if CurrentModule.BatteryEnabled then
							if CurrentVariables.Heat >= CurrentModule.MaxHeat then
								break
							end
						else
							if CurrentVariables.Mag <= 0 then
								break
							end
						end
					end
					if not CurrentModule.ShotgunPump then
						HandleToFire = (HandleToFire == Handle and CurrentModule.DualFireEnabled) and Handle2 or Handle

						if CurrentModule.AimAnimationsEnabled then
							CurrentAimFireAnim = (CurrentAimFireAnim == CurrentAnimTable.AimFireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.AimSecondaryFireAnim or CurrentAnimTable.AimFireAnim
							CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == CurrentModule.AimFireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.AimSecondaryFireAnimationSpeed or CurrentModule.AimFireAnimationSpeed
						end

						CurrentFireAnim = (CurrentFireAnim == CurrentAnimTable.FireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.SecondaryFireAnim or CurrentAnimTable.FireAnim
						CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == CurrentModule.FireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.SecondaryFireAnimationSpeed or CurrentModule.FireAnimationSpeed	
					end
					if (CurrentModule.BatteryEnabled and CurrentVariables.Heat >= CurrentModule.MaxHeat or CurrentVariables.Mag <= 0) then
						if CommonVariables.CurrentRate >= CurrentModule.MaximumRate and CurrentModule.SmokeTrailEnabled then
							Thread:Spawn(function()
								SmokeTrail:StopEmission()
								SmokeTrail:EmitSmokeTrail(HandleToFire["SmokeTrail"..CurrentFireMode], CurrentModule.MaximumTime)
							end)
						end				
					end
					local Overheated = false
					if CommonVariables.ActuallyEquipped then
						if CurrentModule.BatteryEnabled then
							if CurrentVariables.Heat >= CurrentModule.MaxHeat then
								Overheated = true
								CurrentVariables.ChargeLevel = 0
								CommonVariables.Enabled = true
								Thread:Spawn(Overheat)
							end
						end
					end
					if not Overheated then
						Thread:Wait(AddressTableValue(CurrentModule.ChargeAlterTable.FireRate, CurrentModule.FireRate))
						if CurrentModule.ShotgunPump then
							if CommonVariables.ActuallyEquipped then
								if CurrentShotgunPumpinAnim then
									CurrentShotgunPumpinAnim:Play(nil, nil, CurrentShotgunPumpinAnimationSpeed)
								end
								if HandleToFire[CurrentFireMode]:FindFirstChild("PumpSound") then
									HandleToFire[CurrentFireMode].PumpSound:Play()
								end
								Thread:Spawn(function()
									local StartTime = os.clock() repeat Thread:Wait() if not CurrentVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BulletShellDelay
									if CurrentVariables.ActuallyEquipped then
										EjectShell(HandleToFire)
									end
								end)
							end
							HandleToFire = (HandleToFire == Handle and CurrentModule.DualFireEnabled) and Handle2 or Handle

							if CurrentModule.AimAnimationsEnabled then
								CurrentAimFireAnim = (CurrentAimFireAnim == CurrentAnimTable.AimFireAnim and Module.SecondaryFireAnimationEnabled) and CurrentAnimTable.AimSecondaryFireAnim or CurrentAnimTable.AimFireAnim
								CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == Module.AimFireAnimationSpeed and Module.SecondaryFireAnimationEnabled) and Module.AimSecondaryFireAnimationSpeed or Module.AimFireAnimationSpeed
							end

							CurrentFireAnim = (CurrentFireAnim == CurrentAnimTable.FireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.SecondaryFireAnim or CurrentAnimTable.FireAnim
							CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == CurrentModule.FireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.SecondaryFireAnimationSpeed or CurrentModule.FireAnimationSpeed

							CurrentShotgunPumpinAnim = (CurrentShotgunPumpinAnim == CurrentAnimTable.ShotgunPumpinAnim and CurrentModule.SecondaryShotgunPump) and CurrentAnimTable.SecondaryShotgunPumpinAnim or CurrentAnimTable.ShotgunPumpinAnim
							CurrentShotgunPumpinAnimationSpeed = (CurrentShotgunPumpinAnimationSpeed == CurrentModule.ShotgunPumpinAnimationSpeed and CurrentModule.SecondaryShotgunPump) and CurrentModule.SecondaryShotgunPumpinAnimationSpeed or CurrentModule.ShotgunPumpinAnimationSpeed
							Thread:Wait(CurrentModule.ShotgunPumpinSpeed)
						end
						CurrentVariables.ChargeLevel = 0
						CommonVariables.Enabled = true
						if CommonVariables.ActuallyEquipped then
							if Module.AutoReload then
								if CurrentVariables.Mag <= 0 then
									Reload()
								end
							end
						end
					end
				end
			end
		elseif CurrentModule.HoldAndReleaseEnabled and not CurrentModule.SelectiveFireEnabled then
			CommonVariables.Charging = true
			if CommonVariables.ActuallyEquipped and CommonVariables.Enabled and CommonVariables.Charging and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 then
				if Module.CancelReload then
					if CommonVariables.Reloading and not CommonVariables.CanCancelReload then
						CommonVariables.CanCancelReload = true
					end
				else
					if CommonVariables.Reloading then
						return
					end
				end
				CommonVariables.CanBeCooledDown = false
				CommonVariables.Enabled = false
				if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
					CurrentAnimTable.InspectAnim:Stop()
				end
				if CurrentModule.AimAnimationsEnabled and CommonVariables.AimDown then
					if CurrentAnimTable.AimChargingAnim and not CurrentAnimTable.AimChargingAnim.IsPlaying then
						CurrentAnimTable.AimChargingAnim:Play(nil, nil, CurrentModule.AimChargingAnimationSpeed)
					end
				else
					if CurrentAnimTable.ChargingAnim and not CurrentAnimTable.ChargingAnim.IsPlaying then
						CurrentAnimTable.ChargingAnim:Play(nil, nil, CurrentModule.ChargingAnimationSpeed)
					end
				end
				local ChargingSound = HandleToFire[CurrentFireMode]:FindFirstChild("ChargingSound")
				local StartTime = os.clock()
				local StartTime2 = os.clock()
				local Start = false
				local LockedOnTargets = {}
				local TargetCounts = 0
				while true do
					if not CurrentModule.LockOnScan then
						local DeltaTime = os.clock() - StartTime
						if not CommonVariables.Charged and DeltaTime >= CurrentModule.HoldingTime then
							CommonVariables.Charged = true
							GUI.ChargeBar.ChargeLevel3:Play()
							GUI.ChargeBar.Shine.UIGradient.Offset = Vector2.new(-1, 0)
							TweenService:Create(GUI.ChargeBar.Shine.UIGradient, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Offset = Vector2.new(1, 0)}):Play()
						end
						local ChargePercent = math.min(DeltaTime / CurrentModule.HoldingTime, 1)
						if ChargePercent < 0.5 then --Fade from red to yellow then to green
							GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1, ChargePercent * 2, 0)
						else
							GUI.ChargeBar.Fill.BackgroundColor3 = Color3.new(1 - ((ChargePercent - 0.5) / 0.5), 1, 0)
						end
						GUI.ChargeBar.Fill.Size = UDim2.new(ChargePercent, 0, 1, 0)
						if ChargingSound then
							if not ChargingSound.Playing then
								ChargingSound:Play()
							end
							if CurrentModule.ChargingSoundIncreasePitch then
								ChargingSound.PlaybackSpeed = CurrentModule.ChargingSoundPitchRange[1] + (ChargePercent * (CurrentModule.ChargingSoundPitchRange[2] - CurrentModule.ChargingSoundPitchRange[1]))
							end
						end
					else
						CommonVariables.Charged = true
						local DeltaTime = os.clock() - StartTime
						if DeltaTime >= CurrentModule.TimeBeforeScan then
							if not Start then
								Start = true
								StartTime2 = os.clock()
								GUI.Scanner.Scan:Play()
								GUI.Scanner.Message.Text = "Searching targets... (0/"..CurrentModule.MaximumTargets..")"
								TweenService:Create(GUI.Scanner, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(CurrentModule.ScanFrameWidth, CurrentModule.ScanFrameHeight)}):Play()
								TweenService:Create(GUI.Scanner.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 0}):Play()
								TweenService:Create(GUI.Scanner.Message, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextStrokeTransparency = 0.75, TextTransparency = 0}):Play()
							end
							local DeltaTime2 = os.clock() - StartTime2
							if DeltaTime2 >= CurrentModule.ScanRate then
								StartTime2 = os.clock()
								local TargetEntity, TargetHumanoid, TargetTorso = FindNearestEntity()
								if TargetEntity and TargetHumanoid and TargetTorso then
									if TargetCounts < CurrentModule.MaximumTargets then
										TargetCounts = TargetCounts + 1
										if TargetCounts < CurrentModule.MaximumTargets then
											GUI.Scanner.LockOn:Play()
											GUI.Scanner.Message.Text = "Searching targets... ("..TargetCounts.."/"..CurrentModule.MaximumTargets..")"
										else
											GUI.Scanner.LockOnFull:Play()
											GUI.Scanner.Message.Text = "Ready! ("..TargetCounts.."/"..CurrentModule.MaximumTargets..")"
										end
										local TargetMarkerClone = TargetMarker:Clone()
										TargetMarkerClone.Parent = GUI
										TargetMarkerClone.Adornee = TargetTorso
										TargetMarkerClone.Enabled = true
										table.insert(LockedOnTargets, {TargetEntity = TargetEntity, TargetTorso = TargetTorso, TargetMarker = TargetMarkerClone})										
									end
								end
							end
							for i, v in pairs(LockedOnTargets) do
								if v.TargetEntity and v.TargetTorso then
									if not CheckPartInScanner(v.TargetTorso) then
										TargetCounts = TargetCounts - 1
										GUI.Scanner.Message.Text = "Searching targets... ("..TargetCounts.."/"..CurrentModule.MaximumTargets..")"
										if v.TargetMarker then
											v.TargetMarker:Destroy()
										end
										table.remove(LockedOnTargets, i)	
									end
								else
									TargetCounts = TargetCounts - 1
									GUI.Scanner.Message.Text = "Searching targets... ("..TargetCounts.."/"..CurrentModule.MaximumTargets..")"
									if v.TargetMarker then
										v.TargetMarker:Destroy()
									end
									table.remove(LockedOnTargets, i)	
								end
							end
						end
					end
					Thread:Wait()
					if not CommonVariables.ActuallyEquipped or not CommonVariables.Charging then
						break
					end
				end
				if CurrentAnimTable.AimChargingAnim and CurrentAnimTable.AimChargingAnim.IsPlaying then
					CurrentAnimTable.AimChargingAnim:Stop(0)
				end
				if CurrentAnimTable.ChargingAnim and CurrentAnimTable.ChargingAnim.IsPlaying then
					CurrentAnimTable.ChargingAnim:Stop(0)
				end
				if not CurrentModule.LockOnScan then
					GUI.ChargeBar.Fill.Size = UDim2.new(0, 0, 1, 0)
					if ChargingSound then
						if ChargingSound.Playing then
							ChargingSound:Stop()
						end
						if CurrentModule.ChargingSoundIncreasePitch then
							ChargingSound.PlaybackSpeed = CurrentModule.ChargingSoundPitchRange[1]
						end
					end					
				else
					GUI.Scanner.Message.Text = ""
					TweenService:Create(GUI.Scanner, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.fromScale(CurrentModule.ScanFrameWidth * 1.25, CurrentModule.ScanFrameHeight * 1.25)}):Play()
					TweenService:Create(GUI.Scanner.UIStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Transparency = 1}):Play()
					TweenService:Create(GUI.Scanner.Message, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextStrokeTransparency = 1, TextTransparency = 1}):Play()
					for i, v in pairs(LockedOnTargets) do
						if v.TargetMarker then
							v.TargetMarker:Destroy()
						end
					end	
				end
				if not CommonVariables.ActuallyEquipped then
					CommonVariables.Charged = false
					CommonVariables.Enabled = true
				end
				if CommonVariables.ActuallyEquipped and not CommonVariables.Enabled and not CommonVariables.Charging and CommonVariables.Charged and not CommonVariables.Reloading and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 then
					CommonVariables.Charged = false
					for i = 1, CurrentModule.LockOnScan and (TargetCounts > 0 and TargetCounts or 1) or (CurrentModule.BurstFireEnabled and CurrentModule.BulletPerBurst or 1) do
						if not CommonVariables.ActuallyEquipped then
							break
						end
						local Directions = {}
						if not CurrentModule.ShotgunPump then
							Thread:Spawn(function()
								local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BulletShellDelay
								if CommonVariables.ActuallyEquipped then
									EjectShell(HandleToFire)
								end
							end)
						end
						CommonVariables.CurrentRate = CommonVariables.CurrentRate + CurrentModule.SmokeTrailRateIncrement
						local Position = (CurrentModule.LockOnScan and #LockedOnTargets > 0) and (LockedOnTargets[i].TargetTorso and LockedOnTargets[i].TargetTorso.Position or Get3DPosition2()) or Get3DPosition2()
						for ii = 1, (CurrentModule.ShotgunEnabled and CurrentModule.BulletPerShot or 1) do
							local Spread = CurrentModule.Spread * 10 * (CommonVariables.AimDown and 1 - CurrentModule.SpreadRedutionIS and 1 - CurrentModule.SpreadRedutionS or 1)						
							local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode).WorldPosition, Position)

							local SpreadPattern = AddressTableValue(CurrentModule.ChargeAlterTable.SpreadPattern, CurrentModule.SpreadPattern)
							if AddressTableValue(CurrentModule.ChargeAlterTable.ShotgunPattern, CurrentModule.ShotgunPattern) and #SpreadPattern > 0 then
								local X, Y = SpreadPattern[ii][1], SpreadPattern[ii][2]
								cframe = cframe * CFrame.Angles(math.rad(Spread * Y / 50), math.rad(Spread * X / 50), 0)
							else
								cframe = cframe * CFrame.Angles(math.rad(math.random(-Spread, Spread) / 50), math.rad(math.random(-Spread, Spread) / 50), 0)
							end

							local Direction	= cframe.LookVector
							table.insert(Directions, Direction)
						end
						if CurrentModule.SelfKnockback then
							SelfKnockback(Position, Torso.Position)
						end
						Fire(HandleToFire, Directions, (CurrentModule.LockOnScan and #LockedOnTargets > 0) and (LockedOnTargets[i].TargetEntity or nil) or nil)
						if CurrentModule.BatteryEnabled then
							CurrentVariables.ShotsForDepletion = CurrentVariables.ShotsForDepletion + 1
							if CurrentVariables.ShotsForDepletion >= CurrentModule.ShotsForDepletion then
								CurrentVariables.ShotsForDepletion = 0
								CurrentVariables.Ammo = CurrentVariables.Ammo - Random.new():NextInteger(CurrentModule.MinDepletion, CurrentModule.MaxDepletion)
							end	
							CurrentVariables.Heat = CurrentVariables.Heat + Random.new():NextInteger(CurrentModule.HeatPerFireMin, CurrentModule.HeatPerFireMax)
						else
							if Module.MagCartridge and not CurrentModule.BatteryEnabled and CurrentModule.AmmoPerMag ~= math.huge then
								local Bullet = GUI.MagCartridge:FindFirstChild(CurrentVariables.Mag)
								if Module.Ejection then
									local vel = Random2DDirection(Module.Velocity, math.random(Module.XMin, Module.XMax), math.random(Module.YMin, Module.YMax)) * (math.random() ^ 0.5)
									CreateTwoDeeShell(Bullet.Rotation, Bullet.AbsolutePosition, Bullet.AbsoluteSize, vel, "shell", Module.Shockwave)								
								end
								Bullet.Visible = false						
							end
							CurrentVariables.Mag = CurrentVariables.Mag - 1
						end
						ChangeMagAndAmmo:FireServer(CurrentFireMode, CurrentVariables.Mag, CurrentVariables.Ammo, CurrentVariables.Heat)
						Thread:Spawn(function()
							CurrentVariables.ShotID = CurrentVariables.ShotID + 1
							local LastShotID = CurrentVariables.ShotID
							local Interrupted = false
							local CooldownTime = CurrentModule.TimeBeforeCooldown
							local StartTime = os.clock() repeat Thread:Wait() if LastShotID ~= CurrentVariables.ShotID then break end until (os.clock() - StartTime) >= CooldownTime		
							if LastShotID ~= CurrentVariables.ShotID then Interrupted = true end				
							if not Interrupted then
								CommonVariables.CanBeCooledDown = true
							end
						end)
						UpdateGUI()
						if CurrentModule.LockOnScan then
							local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.LockOnScanBurstRate
							--Thread:Wait(CurrentModule.LockOnScanBurstRate)
						else
							if CurrentModule.BurstFireEnabled then
								local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BurstRate
								--Thread:Wait(CurrentModule.BurstRate)
							end							
						end
						--[[if not CommonVariables.ActuallyEquipped then
							break
						end]]
						if CurrentModule.BatteryEnabled then
							if CurrentVariables.Heat >= CurrentModule.MaxHeat then
								break
							end
						else
							if CurrentVariables.Mag <= 0 then
								break
							end
						end
					end
					if not CurrentModule.ShotgunPump then
						HandleToFire = (HandleToFire == Handle and CurrentModule.DualFireEnabled) and Handle2 or Handle

						if CurrentModule.AimAnimationsEnabled then
							CurrentAimFireAnim = (CurrentAimFireAnim == CurrentAnimTable.AimFireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.AimSecondaryFireAnim or CurrentAnimTable.AimFireAnim
							CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == CurrentModule.AimFireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.AimSecondaryFireAnimationSpeed or CurrentModule.AimFireAnimationSpeed
						end

						CurrentFireAnim = (CurrentFireAnim == CurrentAnimTable.FireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.SecondaryFireAnim or CurrentAnimTable.FireAnim
						CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == CurrentModule.FireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.SecondaryFireAnimationSpeed or CurrentModule.FireAnimationSpeed	
					end
					if (CurrentModule.BatteryEnabled and CurrentVariables.Heat >= CurrentModule.MaxHeat or CurrentVariables.Mag <= 0) then
						if CommonVariables.CurrentRate >= CurrentModule.MaximumRate and CurrentModule.SmokeTrailEnabled then
							Thread:Spawn(function()
								SmokeTrail:StopEmission()
								SmokeTrail:EmitSmokeTrail(HandleToFire["SmokeTrail"..CurrentFireMode], CurrentModule.MaximumTime)
							end)
						end				
					end
					local Overheated = false
					if CommonVariables.ActuallyEquipped then
						if CurrentModule.BatteryEnabled then
							if CurrentVariables.Heat >= CurrentModule.MaxHeat then
								Overheated = true
								CommonVariables.Enabled = true
								Thread:Spawn(Overheat)
							end
						end
					end
					if not Overheated then
						Thread:Wait(CurrentModule.FireRate)
						if CurrentModule.ShotgunPump then
							if CommonVariables.ActuallyEquipped then
								if CurrentShotgunPumpinAnim then
									CurrentShotgunPumpinAnim:Play(nil, nil, CurrentShotgunPumpinAnimationSpeed)
								end
								if HandleToFire[CurrentFireMode]:FindFirstChild("PumpSound") then
									HandleToFire[CurrentFireMode].PumpSound:Play()
								end
								Thread:Spawn(function()
									local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BulletShellDelay
									if CommonVariables.ActuallyEquipped then
										EjectShell(HandleToFire)
									end
								end)
							end
							HandleToFire = (HandleToFire == Handle and CurrentModule.DualFireEnabled) and Handle2 or Handle

							if CurrentModule.AimAnimationsEnabled then
								CurrentAimFireAnim = (CurrentAimFireAnim == CurrentAnimTable.AimFireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.AimSecondaryFireAnim or CurrentAnimTable.AimFireAnim
								CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == CurrentModule.AimFireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.AimSecondaryFireAnimationSpeed or CurrentModule.AimFireAnimationSpeed
							end

							CurrentFireAnim = (CurrentFireAnim == CurrentAnimTable.FireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.SecondaryFireAnim or CurrentAnimTable.FireAnim
							CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == CurrentModule.FireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.SecondaryFireAnimationSpeed or CurrentModule.FireAnimationSpeed

							CurrentShotgunPumpinAnim = (CurrentShotgunPumpinAnim == CurrentAnimTable.ShotgunPumpinAnim and CurrentModule.SecondaryShotgunPump) and CurrentAnimTable.SecondaryShotgunPumpinAnim or CurrentAnimTable.ShotgunPumpinAnim
							CurrentShotgunPumpinAnimationSpeed = (CurrentShotgunPumpinAnimationSpeed == CurrentModule.ShotgunPumpinAnimationSpeed and CurrentModule.SecondaryShotgunPump) and CurrentModule.SecondaryShotgunPumpinAnimationSpeed or CurrentModule.ShotgunPumpinAnimationSpeed
							Thread:Wait(CurrentModule.ShotgunPumpinSpeed)
						end
						CommonVariables.Enabled = true
						if CommonVariables.ActuallyEquipped then
							if Module.AutoReload then
								if CurrentVariables.Mag <= 0 then
									Reload()
								end
							end
						end
					end
				end
			end	
		else
			CommonVariables.Down = true
			local IsChargedShot = false
			if CommonVariables.ActuallyEquipped and CommonVariables.Enabled and CommonVariables.Down and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 then
				if Module.CancelReload then
					if CommonVariables.Reloading and not CommonVariables.CanCancelReload then
						CommonVariables.CanCancelReload = true
					end
				else
					if CommonVariables.Reloading then
						return
					end
				end
				CommonVariables.CanBeCooledDown = false	
				CommonVariables.Enabled = false
				if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
					CurrentAnimTable.InspectAnim:Stop()
				end			
				if CurrentModule.ChargedShotEnabled then
					if CommonVariables.ActuallyEquipped and HandleToFire[CurrentFireMode]:FindFirstChild("ChargeSound") then
						HandleToFire[CurrentFireMode].ChargeSound:Play()
					end
					Thread:Wait(CurrentModule.ChargingTime)
					IsChargedShot = true
				end
				if CurrentModule.MinigunEnabled then
					if CurrentAnimTable.MinigunRevUpAnim and not CurrentAnimTable.MinigunRevUpAnim.IsPlaying then
						CurrentAnimTable.MinigunRevUpAnim:Play(nil, nil, CurrentModule.MinigunRevUpAnimationSpeed)
					end
					if CommonVariables.ActuallyEquipped and HandleToFire[CurrentFireMode]:FindFirstChild("WindUp") then
						HandleToFire[CurrentFireMode].WindUp:Play()
					end
					Thread:Wait(CurrentModule.DelayBeforeFiring)
				end
				while CommonVariables.ActuallyEquipped and not CommonVariables.Overheated and not CommonVariables.HoldDown and (CommonVariables.Down or IsChargedShot) and not CommonVariables.Switching and not CommonVariables.Alting and CurrentVariables.Mag > 0 and CurrentVariables.Heat < CurrentModule.MaxHeat and Humanoid.Health > 0 do
					IsChargedShot = false	
					for i = 1, ((CurrentModule.SelectiveFireEnabled and (CurrentVariables.FireModes[CurrentVariables.FireMode] ~= true and CurrentVariables.FireModes[CurrentVariables.FireMode] or 1)) or (CurrentModule.BurstFireEnabled and CurrentModule.BulletPerBurst) or 1) do
						if not CommonVariables.ActuallyEquipped then
							break
						end
						local Directions = {}
						if not CurrentModule.ShotgunPump then
							Thread:Spawn(function()
								local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BulletShellDelay
								if CommonVariables.ActuallyEquipped then EjectShell(HandleToFire) end
							end)
						end
						CommonVariables.CurrentRate = CommonVariables.CurrentRate + CurrentModule.SmokeTrailRateIncrement
						local Position = Get3DPosition2()
						for ii = 1, (CurrentModule.ShotgunEnabled and CurrentModule.BulletPerShot or 1) do
							local Spread = CurrentModule.Spread * 10 * (CommonVariables.AimDown and 1 - CurrentModule.SpreadRedutionIS and 1 - CurrentModule.SpreadRedutionS or 1)
							local cframe = CFrame.new(HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode).WorldPosition, Position)

							local SpreadPattern = AddressTableValue(CurrentModule.ChargeAlterTable.SpreadPattern, CurrentModule.SpreadPattern)
							if AddressTableValue(CurrentModule.ChargeAlterTable.ShotgunPattern, CurrentModule.ShotgunPattern) and #SpreadPattern > 0 then
								local X, Y = SpreadPattern[ii][1], SpreadPattern[ii][2]
								cframe = cframe * CFrame.Angles(math.rad(Spread * Y / 50), math.rad(Spread * X / 50), 0)
							else
								cframe = cframe * CFrame.Angles(math.rad(math.random(-Spread, Spread) / 50), math.rad(math.random(-Spread, Spread) / 50), 0)
							end

							local Direction	= cframe.LookVector
							table.insert(Directions, Direction)
						end
						if CurrentModule.SelfKnockback then
							SelfKnockback(Position, Torso.Position)
						end
						Fire(HandleToFire, Directions)
						if CurrentModule.BatteryEnabled then
							CurrentVariables.ShotsForDepletion = CurrentVariables.ShotsForDepletion + 1
							if CurrentVariables.ShotsForDepletion >= CurrentModule.ShotsForDepletion then
								CurrentVariables.ShotsForDepletion = 0
								CurrentVariables.Ammo = CurrentVariables.Ammo - Random.new():NextInteger(CurrentModule.MinDepletion, CurrentModule.MaxDepletion)
							end	
							CurrentVariables.Heat = CurrentVariables.Heat + Random.new():NextInteger(CurrentModule.HeatPerFireMin, CurrentModule.HeatPerFireMax)
						else
							if Module.MagCartridge and not CurrentModule.BatteryEnabled and CurrentModule.AmmoPerMag ~= math.huge then
								local Bullet = GUI.MagCartridge:FindFirstChild(CurrentVariables.Mag)
								if Module.Ejection then
									local Vel = Random2DDirection(Module.Velocity, math.random(Module.XMin, Module.XMax), math.random(Module.YMin, Module.YMax)) * (math.random() ^ 0.5)
									CreateTwoDeeShell(Bullet.Rotation, Bullet.AbsolutePosition, Bullet.AbsoluteSize, Vel, "shell", Module.Shockwave)								
								end
								Bullet.Visible = false	
							end
							CurrentVariables.Mag = CurrentVariables.Mag - 1
						end
						ChangeMagAndAmmo:FireServer(CurrentFireMode, CurrentVariables.Mag, CurrentVariables.Ammo, CurrentVariables.Heat)
						Thread:Spawn(function()
							CurrentVariables.ShotID = CurrentVariables.ShotID + 1
							local LastShotID = CurrentVariables.ShotID
							local Interrupted = false
							local CooldownTime = CurrentModule.TimeBeforeCooldown
							local StartTime = os.clock() repeat Thread:Wait() if LastShotID ~= CurrentVariables.ShotID then break end until (os.clock() - StartTime) >= CooldownTime		
							if LastShotID ~= CurrentVariables.ShotID then Interrupted = true end				
							if not Interrupted then
								CommonVariables.CanBeCooledDown = true
							end
						end)
						UpdateGUI()
						if CurrentModule.BurstFireEnabled and not CurrentModule.SelectiveFireEnabled then
							local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BurstRate
							--Thread:Wait(CurrentModule.BurstRate)
						end
						if CurrentModule.SelectiveFireEnabled then
							local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BurstRates[CurrentVariables.FireMode]
							--Thread:Wait(CurrentModule.BurstRates[CurrentVariables.FireMode])
						end
						--[[if not CommonVariables.ActuallyEquipped then
							break
						end]]
						if CurrentModule.BatteryEnabled then
							if CurrentVariables.Heat >= CurrentModule.MaxHeat then
								break
							end
						else
							if CurrentVariables.Mag <= 0 then
								break
							end
						end
					end
					if not CurrentModule.ShotgunPump then
						HandleToFire = (HandleToFire == Handle and CurrentModule.DualFireEnabled) and Handle2 or Handle

						if CurrentModule.AimAnimationsEnabled then
							CurrentAimFireAnim = (CurrentAimFireAnim == CurrentAnimTable.AimFireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.AimSecondaryFireAnim or CurrentAnimTable.AimFireAnim
							CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == CurrentModule.AimFireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.AimSecondaryFireAnimationSpeed or CurrentModule.AimFireAnimationSpeed
						end

						CurrentFireAnim = (CurrentFireAnim == CurrentAnimTable.FireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.SecondaryFireAnim or CurrentAnimTable.FireAnim
						CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == CurrentModule.FireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.SecondaryFireAnimationSpeed or CurrentModule.FireAnimationSpeed				
					end
					if (CurrentModule.BatteryEnabled and CurrentVariables.Heat >= CurrentModule.MaxHeat or CurrentVariables.Mag <= 0) then
						if CommonVariables.CurrentRate >= CurrentModule.MaximumRate and CurrentModule.SmokeTrailEnabled then
							Thread:Spawn(function()
								SmokeTrail:StopEmission()
								SmokeTrail:EmitSmokeTrail(HandleToFire["SmokeTrail"..CurrentFireMode], CurrentModule.MaximumTime)
							end)
						end				
					end
					if CurrentModule.BatteryEnabled then
						if CurrentVariables.Heat >= CurrentModule.MaxHeat then
							break
						end
					end
					Thread:Wait(CurrentModule.SelectiveFireEnabled and CurrentModule.FireRates[CurrentVariables.FireMode] or CurrentModule.FireRate)
					if CurrentModule.SelectiveFireEnabled then
						if CurrentVariables.FireModes[CurrentVariables.FireMode] ~= true then
							break
						end
					else
						if not CurrentModule.Auto then
							break
						end
					end
				end
				--[[if HandleToFire[CurrentFireMode].FireSound.Playing and HandleToFire[CurrentFireMode].FireSound.Looped then
					HandleToFire[CurrentFireMode].FireSound:Stop()
				end]]
				if CurrentModule.MinigunEnabled and CommonVariables.ActuallyEquipped and HandleToFire[CurrentFireMode]:FindFirstChild("WindDown") then
					HandleToFire[CurrentFireMode].WindDown:Play()
				end
				local Overheated = false
				if CommonVariables.ActuallyEquipped then
					if CurrentModule.BatteryEnabled then
						if CurrentVariables.Heat >= CurrentModule.MaxHeat then
							Overheated = true
							CommonVariables.Enabled = true
							Thread:Spawn(Overheat)
						end
					end
				end
				if not Overheated then
					if CurrentModule.MinigunEnabled then
						if CommonVariables.ActuallyEquipped and CurrentAnimTable.MinigunRevDownAnim and not CurrentAnimTable.MinigunRevDownAnim.IsPlaying then
							CurrentAnimTable.MinigunRevDownAnim:Play(nil, nil, CurrentModule.MinigunRevDownAnimationSpeed)
						end
						if CurrentAnimTable.MinigunRevUpAnim and CurrentAnimTable.MinigunRevUpAnim.IsPlaying then
							CurrentAnimTable.MinigunRevUpAnim:Stop()
						end
						Thread:Wait(CurrentModule.DelayAfterFiring)
					end
					if CurrentModule.ShotgunPump then
						if CommonVariables.ActuallyEquipped then
							if CurrentShotgunPumpinAnim then
								CurrentShotgunPumpinAnim:Play(nil, nil, CurrentShotgunPumpinAnimationSpeed)
							end
							if HandleToFire[CurrentFireMode]:FindFirstChild("PumpSound") then
								HandleToFire[CurrentFireMode].PumpSound:Play()
							end
							Thread:Spawn(function()
								local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.ActuallyEquipped then break end until (os.clock() - StartTime) >= CurrentModule.BulletShellDelay
								if CommonVariables.ActuallyEquipped then
									EjectShell(HandleToFire)
								end
							end)
						end
						HandleToFire = (HandleToFire == Handle and CurrentModule.DualFireEnabled) and Handle2 or Handle

						if CurrentModule.AimAnimationsEnabled then
							CurrentAimFireAnim = (CurrentAimFireAnim == CurrentAnimTable.AimFireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.AimSecondaryFireAnim or CurrentAnimTable.AimFireAnim
							CurrentAimFireAnimationSpeed = (CurrentAimFireAnimationSpeed == CurrentModule.AimFireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.AimSecondaryFireAnimationSpeed or CurrentModule.AimFireAnimationSpeed
						end

						CurrentFireAnim = (CurrentFireAnim == CurrentAnimTable.FireAnim and CurrentModule.SecondaryFireAnimationEnabled) and CurrentAnimTable.SecondaryFireAnim or CurrentAnimTable.FireAnim
						CurrentFireAnimationSpeed = (CurrentFireAnimationSpeed == CurrentModule.FireAnimationSpeed and CurrentModule.SecondaryFireAnimationEnabled) and CurrentModule.SecondaryFireAnimationSpeed or CurrentModule.FireAnimationSpeed

						CurrentShotgunPumpinAnim = (CurrentShotgunPumpinAnim == CurrentAnimTable.ShotgunPumpinAnim and CurrentModule.SecondaryShotgunPump) and CurrentAnimTable.SecondaryShotgunPumpinAnim or CurrentAnimTable.ShotgunPumpinAnim
						CurrentShotgunPumpinAnimationSpeed = (CurrentShotgunPumpinAnimationSpeed == CurrentModule.ShotgunPumpinAnimationSpeed and CurrentModule.SecondaryShotgunPump) and CurrentModule.SecondaryShotgunPumpinAnimationSpeed or CurrentModule.ShotgunPumpinAnimationSpeed
						Thread:Wait(CurrentModule.ShotgunPumpinSpeed)
					end
					CommonVariables.Enabled = true
					if CommonVariables.ActuallyEquipped then
						if Module.AutoReload then
							if CurrentVariables.Mag <= 0 then
								Reload()
							end
						end
					end
				end
			end
		end		
	end
end

local function OnStoppingFiring()
	CommonVariables.Down = false
	if CurrentModule.ChargedShotAdvanceEnabled or CurrentModule.HoldAndReleaseEnabled then
		CommonVariables.Charging = false
	end
	if CurrentModule.HoldAndReleaseEnabled and not CommonVariables.Charged then
		CommonVariables.Enabled = true
	end
	if CommonVariables.CurrentRate >= CurrentModule.MaximumRate and CurrentModule.SmokeTrailEnabled then
		Thread:Spawn(function()
			SmokeTrail:StopEmission()
			SmokeTrail:EmitSmokeTrail(HandleToFire["SmokeTrail"..CurrentFireMode], CurrentModule.MaximumTime)
		end)
	end	
end

local function OnMeleeAttacking()
	if CurrentModule.MeleeAttackEnabled then
		if CurrentAnimTable.MeleeAttackAnim and CurrentAnimTable.MeleeAttackAnim.Length > 0 then
			local Connection
			if CommonVariables.ActuallyEquipped and CommonVariables.Enabled and not CommonVariables.Overheated and not CommonVariables.Switching and not CommonVariables.Alting and not CommonVariables.AimDown and Humanoid.Health > 0 then
				if Module.CancelReload then
					if CommonVariables.Reloading and not CommonVariables.CanCancelReload then
						CommonVariables.CanCancelReload = true
					end
				else
					if CommonVariables.Reloading then
						return
					end
				end
				CommonVariables.Enabled = false
				if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
					CurrentAnimTable.InspectAnim:Stop()
				end
				CurrentAnimTable.MeleeAttackAnim:Play(nil, nil, CurrentModule.MeleeAttackAnimationSpeed)
				if CommonVariables.ActuallyEquipped and HandleToFire[CurrentFireMode]:FindFirstChild("MeleeSwingSound") then
					HandleToFire[CurrentFireMode].MeleeSwingSound:Play()
				end
				Connection = CurrentAnimTable.MeleeAttackAnim:GetMarkerReachedSignal("MeleeDamageSequence"):Connect(function(ParamString)
					--print(ParamString)
					local Direction = ((Handle["MeleeHitPoint"..CurrentFireMode].WorldCFrame * CFrame.new(0, 0, -CurrentModule.MeleeAttackRange)).p - Handle["MeleeHitPoint"..CurrentFireMode].WorldPosition).Unit
					local MeleeRay = Ray.new(Handle["MeleeHitPoint"..CurrentFireMode].WorldPosition, Direction * CurrentModule.MeleeAttackRange)
					local Hit, Pos, Norm, Material = Workspace:FindPartOnRayWithIgnoreList(MeleeRay, {Camera, Tool.Parent})
					if Hit then
						if Hit.Name == "_glass" and CurrentModule.MeleeCanBreakGlass then
							ShatterGlass:FireServer(Hit, Pos, Direction)
						else
							local Target = Hit:FindFirstAncestorOfClass("Model")
							local TargetHumanoid = Target and Target:FindFirstChildOfClass("Humanoid")
							local TargetTorso = Target and (Target:FindFirstChild("HumanoidRootPart") or Target:FindFirstChild("Head"))
							local VisualEffects2 = VisualEffects
							if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
								VisualEffects2 = VisualEffects[CurrentModule]
							end
							if TargetHumanoid and TargetHumanoid.Health > 0 and TargetTorso then
								gunEvent:Fire("VisualizeHitEffect", "Blood", Hit, Pos, Norm, Material, CurrentModule, {BloodEffectFolder = VisualEffects2.MeleeBloodEffect}, true)
								if TargetHumanoid.Health > 0 then
									Thread:Spawn(function()
										InflictTarget:InvokeServer("GunMelee", Tool, CurrentModule, TargetHumanoid, TargetTorso, Hit, Hit.Size)
									end)
									MarkHit(CurrentModule, Hit.Name == "Head" and CurrentModule.HeadshotHitmarker)
								end
							else
								gunEvent:Fire("VisualizeHitEffect", "Normal", Hit, Pos, Norm, Material, CurrentModule, {HitEffectFolder = VisualEffects2.MeleeHitEffect}, true)
							end							
						end
					end

					if Connection then
						--print("Disconnected")
						Connection:Disconnect()
						Connection = nil
					end
				end)
				CurrentAnimTable.MeleeAttackAnim.Stopped:Wait()
				CommonVariables.Enabled = true
			end				
		end	
	end
end

local function OnUnequipping(Remove)
	CommonVariables.IsFiring = false
	if CurrentModule.ChargedShotAdvanceEnabled then
		CommonVariables.Charging = false
	end
	if CurrentModule.HoldAndReleaseEnabled then
		CommonVariables.Charged = false
	end
	CommonVariables.Equipped = false
	CommonVariables.ActuallyEquipped = false
	if JumpButton then
		MobileButtons.AimButton.Parent = GUI.MobileButtons
		MobileButtons.FireButton.Parent = GUI.MobileButtons
		MobileButtons.HoldDownButton.Parent = GUI.MobileButtons
		MobileButtons.InspectButton.Parent = GUI.MobileButtons
		MobileButtons.ReloadButton.Parent = GUI.MobileButtons
		MobileButtons.SwitchButton.Parent = GUI.MobileButtons
		MobileButtons.AltButton.Parent = GUI.MobileButtons
	end
	GUI.Parent = script
	GUI.Frame.Visible = false
	if Module.WalkSpeedRedutionEnabled then
		Humanoid.WalkSpeed = Humanoid.WalkSpeed + Module.WalkSpeedRedution
	else
		Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	UserInputService.MouseIconEnabled = true
	RunService:UnbindFromRenderStep(BindToStepName)
	for i, v in pairs(KeyframeConnections) do
		v:Disconnect()
		table.remove(KeyframeConnections, i)
	end
	LockedEntity = nil
	TargetMarker.Enabled = false
	TargetMarker.Parent = script
	TargetMarker.Adornee = nil
	if Beam then
		Beam:Destroy()
		Beam = nil
	end
	if Attach0 then
		Attach0:Destroy()
		Attach0 = nil
	end
	if Attach1 then
		Attach1:Destroy()
		Attach1 = nil
	end
	for _, a in pairs(CurrentAnimTable) do
		if a and a.IsPlaying then
			a:Stop()
		end 
	end
	for _, s in pairs(Handle[CurrentFireMode]:GetChildren()) do
		if s:IsA("Sound") and s.IsPlaying then
			s:Stop()
		end 
	end
	if Handle2 then
		for _, s in pairs(Handle2[CurrentFireMode]:GetChildren()) do
			if s:IsA("Sound") and s.IsPlaying then
				s:Stop()
			end 
		end
	end
	if Remove then
		if CurrentModule.LaserBeam then
			VisibleMuzz(HandleToFire:FindFirstChild("GunMuzzlePoint"..CurrentFireMode), false)
			VisibleMuzzle:FireServer(HandleToFire:FindFirstChild("GunMuzzlePoint"..CurrentFireMode), false)
			gunEvent:Fire("RemoveBeam", GUID, CurrentModule, BeamTable, LaserTrail, BoltSegments, CrosshairPointAttachment)			
		end
	end
	if CommonVariables.AimDown then
		TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLengthNAD, CurrentModule.EasingStyleNAD, CurrentModule.EasingDirectionNAD), {FieldOfView = 70}):Play()
		SetCrossScale(1)
		CommonVariables.Scoping = false
		Player.CameraMode = Enum.CameraMode.Classic
		UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity
		CommonVariables.AimDown = false
	end
end

--aiming

MobileButtons.AimButton.MouseButton1Click:Connect(function()
	OnTooglingAiming()
end)

MobileButtons.HoldDownButton.MouseButton1Click:Connect(function()
	OnHoldingDown()
end)

MobileButtons.InspectButton.MouseButton1Click:Connect(function()
	OnInspecting()
end)

MobileButtons.SwitchButton.MouseButton1Click:Connect(function()
	OnSwitching()
end)

MobileButtons.ReloadButton.MouseButton1Click:Connect(function()
	Reload()
end)

MobileButtons.FireButton.MouseButton1Down:Connect(function()
	OnFiring()
end)

MobileButtons.FireButton.MouseButton1Up:Connect(function()
	OnStoppingFiring()
end)

MobileButtons.MeleeButton.MouseButton1Click:Connect(function()
	OnMeleeAttacking()
end)

MobileButtons.AltButton.MouseButton1Click:Connect(function()
	OnAlting()
end)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
	if GameProcessed then
		return
	end
	if not UserInputService.TouchEnabled then		
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.KeyCode == Module.Controller.Fire then
			OnFiring()
		elseif Input.KeyCode == Module.Keyboard.Reload or Input.KeyCode == Module.Controller.Reload then
			Reload()
		elseif Input.KeyCode == Module.Keyboard.HoldDown or Input.KeyCode == Module.Controller.HoldDown then
			OnHoldingDown()
		elseif Input.KeyCode == Module.Keyboard.Inspect or Input.KeyCode == Module.Controller.Inspect then
			OnInspecting()
		elseif Input.KeyCode == Module.Keyboard.Switch or Input.KeyCode == Module.Controller.Switch then
			OnSwitching()
		elseif Input.KeyCode == Module.Keyboard.ToogleAim or Input.KeyCode == Module.Controller.ToogleAim then
			OnTooglingAiming()
		elseif Input.KeyCode == Module.Keyboard.Melee or Input.KeyCode == Module.Controller.Melee then
			OnMeleeAttacking()
		elseif Input.KeyCode == Module.Keyboard.AltFire or Input.KeyCode == Module.Controller.AltFire then
			OnAlting()
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
			if not CommonVariables.Reloading and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Alting and not CommonVariables.AimDown and CommonVariables.ActuallyEquipped and CurrentModule.IronsightEnabled and (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
				TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLength, CurrentModule.EasingStyle, CurrentModule.EasingDirection), {FieldOfView = CurrentModule.FieldOfViewIS}):Play()
				SetCrossScale(CurrentModule.CrossScaleIS)
				if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
					CurrentAnimTable.InspectAnim:Stop()
				end
				if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.IdleAnim and CurrentAnimTable.IdleAnim.IsPlaying then
					CurrentAnimTable.IdleAnim:Stop()
					if CurrentAnimTable.AimIdleAnim then
						CurrentAnimTable.AimIdleAnim:Play(nil, nil, CurrentModule.AimIdleAnimationSpeed)
					end
				end
				Player.CameraMode = Enum.CameraMode.LockFirstPerson
				UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity * CurrentModule.MouseSensitiveIS
				CommonVariables.AimDown = true
			elseif not CommonVariables.Reloading and not CommonVariables.Overheated and not CommonVariables.HoldDown and not CommonVariables.Alting and not CommonVariables.AimDown and CommonVariables.ActuallyEquipped and CurrentModule.SniperEnabled and (Camera.Focus.p - Camera.CoordinateFrame.p).Magnitude <= 1 then
				TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLength, CurrentModule.EasingStyle, CurrentModule.EasingDirection), {FieldOfView = CurrentModule.FieldOfViewS}):Play()
				SetCrossScale(CurrentModule.CrossScaleS)
				if CurrentAnimTable.InspectAnim and CurrentAnimTable.InspectAnim.IsPlaying then
					CurrentAnimTable.InspectAnim:Stop()
				end
				if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.IdleAnim and CurrentAnimTable.IdleAnim.IsPlaying then
					CurrentAnimTable.IdleAnim:Stop()
					if CurrentAnimTable.AimIdleAnim then
						CurrentAnimTable.AimIdleAnim:Play(nil, nil, CurrentModule.AimIdleAnimationSpeed)
					end
				end
				CommonVariables.AimDown = true
				local StartTime = os.clock() repeat Thread:Wait() if not (CommonVariables.ActuallyEquipped or CommonVariables.AimDown) then break end until (os.clock() - StartTime) >= CurrentModule.ScopeDelay
				if CommonVariables.ActuallyEquipped and CommonVariables.AimDown then
					local ZoomSound = GUI.Scope.ZoomSound:Clone()
					ZoomSound.Parent = Player.PlayerGui
					ZoomSound:Play()
					ZoomSound.Ended:Connect(function()
						ZoomSound:Destroy()
					end)
					Player.CameraMode = Enum.CameraMode.LockFirstPerson
					UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity * CurrentModule.MouseSensitiveS
					CommonVariables.Scoping = true
				end
			end
		end
	end
end)

UserInputService.InputEnded:Connect(function(Input, GameProcessed)
	if GameProcessed then
		return
	end
	if not UserInputService.TouchEnabled then
		if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.KeyCode == Module.Controller.Fire then
			OnStoppingFiring()
		elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
			if CommonVariables.AimDown then
				TweenService:Create(Camera, TweenInfo.new(CurrentModule.TweenLengthNAD, CurrentModule.EasingStyleNAD, CurrentModule.EasingDirectionNAD), {FieldOfView = 70}):Play()
				SetCrossScale(1)
				if CurrentModule.AimAnimationsEnabled and CurrentAnimTable.AimIdleAnim and CurrentAnimTable.AimIdleAnim.IsPlaying then
					CurrentAnimTable.AimIdleAnim:Stop()
					if CurrentAnimTable.IdleAnim then
						CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
					end
				end
				CommonVariables.Scoping = false
				Player.CameraMode = Enum.CameraMode.Classic
				UserInputService.MouseDeltaSensitivity = CommonVariables.InitialSensitivity
				CommonVariables.AimDown = false
			end
		end
	end
end)

MarkerEvent.Event:Connect(MarkHit)

ChangeMagAndAmmo.OnClientEvent:Connect(function(Values)
	for i, v in ipairs(Values) do
		Variables[v.Id].Mag = v.Mag
		Variables[v.Id].Ammo = v.Ammo
		Variables[v.Id].Heat = v.Heat
	end
	UpdateGUI()
end)

local function RenderStepped(dt)
	if CommonVariables.Equipped then -- here
		if not UserInputService.TouchEnabled and CommonVariables.IsFiring == true then
			local pos = Mouse.Hit.p
			local lookToPosVector = Vector3.new(pos.X, HumanoidRootPart.Position.Y, pos.Z)

			HumanoidRootPart.CFrame = CFrame.lookAt(HumanoidRootPart.Position, lookToPosVector)
		end
	end
end

Tool.Equipped:Connect(function()
	CommonVariables.Equipped = true
	if JumpButton then
		MobileButtons.AimButton.Parent = JumpButton
		MobileButtons.FireButton.Parent = JumpButton
		MobileButtons.HoldDownButton.Parent = JumpButton
		MobileButtons.InspectButton.Parent = JumpButton
		MobileButtons.ReloadButton.Parent = JumpButton
		MobileButtons.SwitchButton.Parent = JumpButton
		MobileButtons.AltButton.Parent = JumpButton
	end
	if CurrentModule.AmmoPerMag ~= math.huge and CurrentModule.MaxHeat ~= math.huge then
		GUI.Frame.Visible = true
	end
	GUI.Parent = Player.PlayerGui
	UpdateGUI()
	Handle[CurrentFireMode].EquippedSound:Play()
	if Module.WalkSpeedRedutionEnabled then
		Humanoid.WalkSpeed = Humanoid.WalkSpeed - Module.WalkSpeedRedution
	else
		Humanoid.WalkSpeed = Humanoid.WalkSpeed
	end
	SetCrossSettings(CurrentModule.CrossSize, CurrentModule.CrossSpeed, CurrentModule.CrossDamper)
	UserInputService.MouseIconEnabled = false
	if CurrentModule.ProjectileMotion then
		local VisualEffects2 = VisualEffects
		if VisualEffects:FindFirstChild(CurrentModule.ModuleName) then
			VisualEffects2 = VisualEffects[CurrentModule]
		end
		Beam, Attach0, Attach1 = ProjectileMotion.ShowProjectilePath(VisualEffects2.MotionBeam, HandleToFire:FindFirstChild("GunFirePoint"..CurrentFireMode).WorldPosition, Vector3.new(), 3, AddressTableValue(CurrentModule.ChargeAlterTable.Acceleration, CurrentModule.Acceleration))
	end

	RunService:BindToRenderStep(BindToStepName, Enum.RenderPriority.Camera.Value, function(dt)
		--Update crosshair and scope
		RenderMouse()
		RenderScope()
		RenderCrosshair()
		--Update camera
		RenderCam()
		--Update rate
		RenderRate(dt)
		--Render motion
		if CurrentModule.ProjectileMotion then
			RenderMotion()
		end
		--Render cooldown
		if CurrentModule.BatteryEnabled then
			RenderCooldown(dt)
		end
		--Render 2D shell
		RenderTwoDeeShell(dt)
	end)
	
	for _, v in pairs(Keyframes) do
		table.insert(KeyframeConnections, v[1]:GetMarkerReachedSignal("AnimationEvents"):Connect(function(keyframeName)
			if v[2][keyframeName] then
				v[2][keyframeName](keyframeName, Tool)
			end
		end))
	end

	if CurrentAnimTable.EquippedAnim then
		CurrentAnimTable.EquippedAnim:Play(nil, nil, CurrentModule.EquippedAnimationSpeed)
	end
	if CurrentAnimTable.IdleAnim then
		CurrentAnimTable.IdleAnim:Play(nil, nil, CurrentModule.IdleAnimationSpeed)
	end
	
	local StartTime = os.clock() repeat Thread:Wait() if not CommonVariables.Equipped then break end until (os.clock() - StartTime) >= CurrentModule.EquipTime
	if CommonVariables.Equipped then
		CommonVariables.ActuallyEquipped = true
	end
	
	if CommonVariables.ActuallyEquipped and Module.AutoReload and not CommonVariables.Reloading and (CurrentVariables.Ammo > 0 or not CurrentModule.LimitedAmmoEnabled) and CurrentVariables.Mag <= 0 then
		Reload()
	end
end)

RunService.RenderStepped:Connect(RenderStepped)

Tool.Unequipped:Connect(function()
	OnUnequipping(Tool.Parent == Workspace)
end)

Humanoid.Died:Connect(function()
	OnUnequipping(true)
end)

Tool.AncestryChanged:Connect(function()
	if not Tool:IsDescendantOf(game) then
		OnUnequipping(true)
	end
end)