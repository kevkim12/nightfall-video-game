local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local WeaponSettings = Modules.WeaponSettings
local Gun = WeaponSettings.Gun

local Tool = script.Parent
local Handle
local Player
local Character
local Humanoid
local LeftArm
local RightArm
local Grip2
local Handle2
local GripId = 0

local Setting = Gun[Tool.Name].Setting
local Module = require(Setting)
local Module2

local ChangeMagAndAmmo = script:WaitForChild("ChangeMagAndAmmo")

Handle = Tool:WaitForChild(Module.PrimaryHandle)

if Module.DualWeldEnabled then
	Handle2 = Tool:WaitForChild(Module.SecondaryHandle, 1)
	if Handle2 == nil and Module.DualWeldEnabled then error("\"Dual\" setting is enabled but \"Handle2\" is missing!") end
end

local AnimationFolder = Instance.new("Folder")
AnimationFolder.Name = "AnimationFolder"
AnimationFolder.Parent = Tool

local ValueFolder = Instance.new("Folder")
ValueFolder.Name = "ValueFolder"
ValueFolder.Parent = Tool

for i, v in ipairs(Setting:GetChildren()) do
	Module2 = require(v)
	
	local ValFolder = Instance.new("Folder")
	ValFolder.Name = i
	ValFolder.Parent = ValueFolder
	local MagValue = script:FindFirstChild("Mag") or Instance.new("NumberValue")
	MagValue.Name = "Mag"
	MagValue.Value = Module2.AmmoPerMag
	MagValue.Parent = ValFolder
	local AmmoValue = script:FindFirstChild("Ammo") or Instance.new("NumberValue")
	AmmoValue.Name = "Ammo"
	AmmoValue.Value = Module2.LimitedAmmoEnabled and Module2.Ammo or 0
	AmmoValue.Parent = ValFolder
	local HeatValue = script:FindFirstChild("Heat") or Instance.new("NumberValue")
	HeatValue.Name = "Heat"
	HeatValue.Value = 0
	HeatValue.Parent = ValFolder
	
	local AnimFolder = Instance.new("Folder")
	AnimFolder.Name = i
	AnimFolder.Parent = AnimationFolder
	if Module2.IdleAnimationID ~= nil then
		local IdleAnim = Instance.new("Animation")
		IdleAnim.Name = "IdleAnim"
		IdleAnim.AnimationId = "rbxassetid://"..Module2.IdleAnimationID
		IdleAnim.Parent = AnimFolder
	end
	if Module2.FireAnimationID ~= nil then
		local FireAnim = Instance.new("Animation")
		FireAnim.Name = "FireAnim"
		FireAnim.AnimationId = "rbxassetid://"..Module2.FireAnimationID
		FireAnim.Parent = AnimFolder
	end
	if Module2.ReloadAnimationID ~= nil then
		local ReloadAnim = Instance.new("Animation")
		ReloadAnim.Name = "ReloadAnim"
		ReloadAnim.AnimationId = "rbxassetid://"..Module2.ReloadAnimationID
		ReloadAnim.Parent = AnimFolder
	end
	if Module2.ShotgunClipinAnimationID ~= nil then
		local ShotgunClipinAnim = Instance.new("Animation")
		ShotgunClipinAnim.Name = "ShotgunClipinAnim"
		ShotgunClipinAnim.AnimationId = "rbxassetid://"..Module2.ShotgunClipinAnimationID
		ShotgunClipinAnim.Parent = AnimFolder
	end
	if Module2.ShotgunPumpinAnimationID ~= nil then
		local ShotgunPumpinAnim = Instance.new("Animation")
		ShotgunPumpinAnim.Name = "ShotgunPumpinAnim"
		ShotgunPumpinAnim.AnimationId = "rbxassetid://"..Module2.ShotgunPumpinAnimationID
		ShotgunPumpinAnim.Parent = AnimFolder
	end
	if Module2.HoldDownAnimationID ~= nil then
		local HoldDownAnim = Instance.new("Animation")
		HoldDownAnim.Name = "HoldDownAnim"
		HoldDownAnim.AnimationId = "rbxassetid://"..Module2.HoldDownAnimationID
		HoldDownAnim.Parent = AnimFolder
	end
	if Module2.EquippedAnimationID ~= nil then
		local EquippedAnim = Instance.new("Animation")
		EquippedAnim.Name = "EquippedAnim"
		EquippedAnim.AnimationId = "rbxassetid://"..Module2.EquippedAnimationID
		EquippedAnim.Parent = AnimFolder
	end
	if Module2.SecondaryFireAnimationEnabled and Module2.SecondaryFireAnimationID ~= nil then
		local SecondaryFireAnim = Instance.new("Animation")
		SecondaryFireAnim.Name = "SecondaryFireAnim"
		SecondaryFireAnim.AnimationId = "rbxassetid://"..Module2.SecondaryFireAnimationID
		SecondaryFireAnim.Parent = AnimFolder
	end
	if Module2.SecondaryShotgunPump and Module2.SecondaryShotgunPumpinAnimationID ~= nil then
		local SecondaryShotgunPumpinAnim = Instance.new("Animation")
		SecondaryShotgunPumpinAnim.Name = "SecondaryShotgunPumpinAnim"
		SecondaryShotgunPumpinAnim.AnimationId = "rbxassetid://"..Module2.SecondaryShotgunPumpinAnimationID
		SecondaryShotgunPumpinAnim.Parent = AnimFolder
	end
	if Module2.AimAnimationsEnabled and Module2.AimIdleAnimationID ~= nil then
		local AimIdleAnim = Instance.new("Animation")
		AimIdleAnim.Name = "AimIdleAnim"
		AimIdleAnim.AnimationId = "rbxassetid://"..Module2.AimIdleAnimationID
		AimIdleAnim.Parent = AnimFolder
	end
	if Module2.AimAnimationsEnabled and Module2.AimFireAnimationID ~= nil then
		local AimFireAnim = Instance.new("Animation")
		AimFireAnim.Name = "AimFireAnim"
		AimFireAnim.AnimationId = "rbxassetid://"..Module2.AimFireAnimationID
		AimFireAnim.Parent = AnimFolder
	end
	if Module2.AimAnimationsEnabled and Module2.AimSecondaryFireAnimationID ~= nil then
		local AimSecondaryFireAnim = Instance.new("Animation")
		AimSecondaryFireAnim.Name = "AimSecondaryFireAnim"
		AimSecondaryFireAnim.AnimationId = "rbxassetid://"..Module2.AimSecondaryFireAnimationID
		AimSecondaryFireAnim.Parent = AnimFolder
	end
	if Module2.AimAnimationsEnabled and Module2.AimChargingAnimationID ~= nil then
		local AimChargingAnim = Instance.new("Animation")
		AimChargingAnim.Name = "AimChargingAnim"
		AimChargingAnim.AnimationId = "rbxassetid://"..Module2.AimChargingAnimationID
		AimChargingAnim.Parent = AnimFolder
	end
	if Module2.TacticalReloadAnimationEnabled and Module2.TacticalReloadAnimationID ~= nil then
		local TacticalReloadAnim = Instance.new("Animation")
		TacticalReloadAnim.Name = "TacticalReloadAnim"
		TacticalReloadAnim.AnimationId = "rbxassetid://"..Module2.TacticalReloadAnimationID
		TacticalReloadAnim.Parent = AnimFolder
	end
	if Module2.InspectAnimationEnabled and Module2.InspectAnimationID ~= nil then
		local InspectAnim = Instance.new("Animation")
		InspectAnim.Name = "InspectAnim"
		InspectAnim.AnimationId = "rbxassetid://"..Module2.InspectAnimationID
		InspectAnim.Parent = AnimFolder
	end
	if Module2.ShotgunReload and Module2.PreShotgunReload and Module2.PreShotgunReloadAnimationID ~= nil then
		local PreShotgunReloadAnim = Instance.new("Animation")
		PreShotgunReloadAnim.Name = "PreShotgunReloadAnim"
		PreShotgunReloadAnim.AnimationId = "rbxassetid://"..Module2.PreShotgunReloadAnimationID
		PreShotgunReloadAnim.Parent = AnimFolder
	end
	if Module2.MinigunRevUpAnimationID ~= nil then
		local MinigunRevUpAnim = Instance.new("Animation")
		MinigunRevUpAnim.Name = "MinigunRevUpAnim"
		MinigunRevUpAnim.AnimationId = "rbxassetid://"..Module2.MinigunRevUpAnimationID
		MinigunRevUpAnim.Parent = AnimFolder
	end
	if Module2.MinigunRevDownAnimationID ~= nil then
		local MinigunRevDownAnim = Instance.new("Animation")
		MinigunRevDownAnim.Name = "MinigunRevDownAnim"
		MinigunRevDownAnim.AnimationId = "rbxassetid://"..Module2.MinigunRevDownAnimationID
		MinigunRevDownAnim.Parent = AnimFolder
	end
	if Module2.ChargingAnimationEnabled and Module2.ChargingAnimationID ~= nil then
		local ChargingAnim = Instance.new("Animation")
		ChargingAnim.Name = "ChargingAnim"
		ChargingAnim.AnimationId = "rbxassetid://"..Module2.ChargingAnimationID
		ChargingAnim.Parent = AnimFolder
	end
	if Module2.SelectiveFireEnabled and Module2.SwitchAnimationID ~= nil then
		local SwitchAnim = Instance.new("Animation")
		SwitchAnim.Name = "SwitchAnim"
		SwitchAnim.AnimationId = "rbxassetid://"..Module2.SwitchAnimationID
		SwitchAnim.Parent = AnimFolder
	end
	if Module2.BatteryEnabled and Module2.OverheatAnimationID ~= nil then
		local OverheatAnim = Instance.new("Animation")
		OverheatAnim.Name = "OverheatAnim"
		OverheatAnim.AnimationId = "rbxassetid://"..Module2.OverheatAnimationID
		OverheatAnim.Parent = AnimFolder
	end
	if Module2.MeleeAttackEnabled and Module2.MeleeAttackAnimationID ~= nil then
		local MeleeAttackAnim = Instance.new("Animation")
		MeleeAttackAnim.Name = "MeleeAttackAnim"
		MeleeAttackAnim.AnimationId = "rbxassetid://"..Module2.MeleeAttackAnimationID
		MeleeAttackAnim.Parent = AnimFolder
	end
	if Module.AltFire and Module2.AltAnimationID ~= nil then
		local AltAnim = Instance.new("Animation")
		AltAnim.Name = "AltAnim"
		AltAnim.AnimationId = "rbxassetid://"..Module2.AltAnimationID
		AltAnim.Parent = AnimFolder
	end
	if Module2.LaserBeamStartupAnimationID ~= nil then
		local LaserBeamStartupAnim = Instance.new("Animation")
		LaserBeamStartupAnim.Name = "LaserBeamStartupAnim"
		LaserBeamStartupAnim.AnimationId = "rbxassetid://"..Module2.LaserBeamStartupAnimationID
		LaserBeamStartupAnim.Parent = AnimFolder
	end
	if Module2.LaserBeamLoopAnimationID ~= nil then
		local LaserBeamLoopAnim = Instance.new("Animation")
		LaserBeamLoopAnim.Name = "LaserBeamLoopAnim"
		LaserBeamLoopAnim.AnimationId = "rbxassetid://"..Module2.LaserBeamLoopAnimationID
		LaserBeamLoopAnim.Parent = AnimFolder
	end
	if Module2.LaserBeamStopAnimationID ~= nil then
		local LaserBeamStopAnim = Instance.new("Animation")
		LaserBeamStopAnim.Name = "LaserBeamStopAnim"
		LaserBeamStopAnim.AnimationId = "rbxassetid://"..Module2.LaserBeamStopAnimationID
		LaserBeamStopAnim.Parent = AnimFolder
	end
end

local function GetInstanceFromAncestor(Table)
	if Table[1] == "Tool" then
		return Tool:FindFirstChild(Table[2], true)
	end
	if Table[1] ~= "Character" then
		return
	end
	return Character:FindFirstChild(Table[2], true)
end

local Motor6DInstance

local function SetCustomGrip(Enabled, AlignFromDefaultGrip)
	if Enabled then
		GripId += 1
		local LastGripId = GripId
		if not Motor6DInstance then
			local Part0 = GetInstanceFromAncestor(Module.CustomGripPart0)
			local Part1 = GetInstanceFromAncestor(Module.CustomGripPart1)
			if Part0 and Part1 then
				Motor6DInstance = Instance.new("Motor6D")
				Motor6DInstance.Name = Module.CustomGripName
				Motor6DInstance.Part0 = Part0
				Motor6DInstance.Part1 = Part1
				if Handle.Name == "Handle" then
					repeat task.wait() if LastGripId ~= GripId then break end until RightArm:FindFirstChild("RightGrip")
					if LastGripId == GripId then
						local RightGrip = RightArm:FindFirstChild("RightGrip")
						if RightGrip then
							if AlignFromDefaultGrip then
								local DefaultC0 = RightGrip.C0
								local DefaultC1 = RightGrip.C1
								if DefaultC0 and DefaultC1 then
									Motor6DInstance.C0 = DefaultC0
									Motor6DInstance.C1 = DefaultC1						
								end
							end
							RightGrip.Enabled = false
							RightGrip:Destroy()
							if Module.CustomGripCFrame then
								Motor6DInstance.C0 *= Module.CustomGripC0
								Motor6DInstance.C1 *= Module.CustomGripC1
							end
							Motor6DInstance.Parent = Part0
						end
					end
				else
					if Module.CustomGripCFrame then
						Motor6DInstance.C0 *= Module.CustomGripC0
						Motor6DInstance.C1 *= Module.CustomGripC1
					end
					Motor6DInstance.Parent = Part0
				end
			end	
		end
	elseif not Enabled then
		GripId += 1
		if Motor6DInstance then
			Motor6DInstance:Destroy()
			Motor6DInstance = nil
		end
	end
end

ChangeMagAndAmmo.OnServerEvent:Connect(function(Player, Id, Mag, Ammo, Heat)
	ValueFolder[Id].Mag.Value = Mag
	ValueFolder[Id].Ammo.Value = Ammo
	ValueFolder[Id].Heat.Value = Heat
end)

Tool.Equipped:Connect(function()
	Player = Players:GetPlayerFromCharacter(Tool.Parent)
	Character = Tool.Parent
	Humanoid = Character:FindFirstChildOfClass("Humanoid")
	LeftArm = Character:FindFirstChild("Left Arm") or Character:FindFirstChild("LeftHand")
	RightArm = Character:FindFirstChild("Right Arm") or Character:FindFirstChild("RightHand")
	if Module.CustomGripEnabled and not Tool.RequiresHandle then
		if not Motor6DInstance then
			SetCustomGrip(true, Module.AlignC0AndC1FromDefaultGrip)
		end		
	end
	if Module.DualWeldEnabled and not Module.CustomGripEnabled and Tool.RequiresHandle then
		Handle2.CanCollide = false
		if RightArm then
			local Grip = RightArm:WaitForChild("RightGrip", 0.01)
			if Grip then
				Grip2 = Grip:Clone()
				Grip2.Name = "LeftGrip"
				Grip2.Part0 = LeftArm
				Grip2.Part1 = Handle2
				--Grip2.C1 = Grip2.C1:inverse()
				Grip2.Parent = LeftArm
			end
		end
	end
end)

Tool.Unequipped:Connect(function()
	if Module.CustomGripEnabled and not Tool.RequiresHandle then
		if Motor6DInstance then
			SetCustomGrip(false)
		end		
	end
	if Module.DualWeldEnabled and not Module.CustomGripEnabled and Tool.RequiresHandle then
		Handle2.CanCollide = true
		if Grip2 then
			Grip2:Destroy()
		end
	end
end)

Tool.AncestryChanged:Connect(function()
	if not Tool:IsDescendantOf(game) then
		if Module.CustomGripEnabled and not Tool.RequiresHandle then
			if Motor6DInstance then
				SetCustomGrip(false)
			end		
		end
		if Module.DualWeldEnabled and not Module.CustomGripEnabled and Tool.RequiresHandle then
			Handle2.CanCollide = true
			if Grip2 then
				Grip2:Destroy()
			end
		end
	end
end)