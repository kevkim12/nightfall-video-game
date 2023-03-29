-- If you pay someone to script you a grenade because you don't have time and they scam you, you program it yourself.
-- Based on Aurified's experiences (5/22/2020)
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local M67Position
local M67PullPinAnimation
local M67PullPinTrack
local M67ThrowAnimation
local M67ThrowTrack
local Hum

local function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

local function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end


ReplicatedStorage.Events.GrenadeTriggered.OnServerEvent:Connect(function(player, PlayerUsername)
	Hum = player.Character:WaitForChild("Humanoid")
	M67PullPinAnimation = player.Character["M67"].Animations.PullPin
	M67PullPinTrack = Hum:LoadAnimation(M67PullPinAnimation)
	if player.Name == PlayerUsername then
		M67PullPinTrack:Play()
		M67PullPinTrack:GetMarkerReachedSignal("PinPull"):Connect(function(value)
			if player.Character:FindFirstChild("M67") ~= nil then
				player.Character["M67"].Handle.Click:Play()
				player.Character["M67"].Pin.Transparency = 1
			end
		end)
	end
end)

ReplicatedStorage.Events.GrenadeThrow.OnServerEvent:Connect(function(player, PlayerUsername, Power, Status)
	if player.Name == PlayerUsername and Status == "Success" then
		M67ThrowAnimation = player.Character["M67"].Animations.Throw
		M67ThrowTrack = Hum:LoadAnimation(M67ThrowAnimation)
		M67ThrowTrack:Play()
		local GrenadeClone = ReplicatedStorage.Assets.M67Used:Clone()
		GrenadeClone.User.Value = player.Name
		GrenadeClone.CanCollide = true
		GrenadeClone.Parent = game.Workspace
		GrenadeClone.CFrame = player.Character["M67"].Handle.CFrame
		GrenadeClone.Velocity = player.Character.HumanoidRootPart.CFrame.lookVector * (Power * 12) + Vector3.new(0, Power * 12, 0)
		player.Character["M67"]:Remove()
		
		wait(3)
		
		M67Position = GrenadeClone.Position
		
		local Team = player.TeamColor
		local NewExplosion = Instance.new("Explosion")
		NewExplosion.BlastPressure = 0
		NewExplosion.BlastRadius = 20
		NewExplosion.ExplosionType = "NoCraters"
		NewExplosion.Position = M67Position
		
		NewExplosion.Hit:Connect(function(HitPart, PartDistance)
			if HitPart.Parent:FindFirstChild("Humanoid") ~= nil then
				local HumanoidValue = HitPart.Parent:FindFirstChild('Humanoid')
				if game.Players:GetPlayerFromCharacter(HitPart.Parent) ~= nil then
					local PlayerValue = game.Players:GetPlayerFromCharacter(HitPart.Parent)
					if (PlayerValue.TeamColor ~= player.TeamColor or PlayerValue == player) then
						UntagHumanoid(HumanoidValue)
						if PlayerValue ~= player then
							TagHumanoid(HumanoidValue, player)
						end
						HumanoidValue:TakeDamage(50)
					end
				else
					if HitPart.Parent:FindFirstChild('TEAM').Value == "Infected" then
						UntagHumanoid(HumanoidValue)
						TagHumanoid(HumanoidValue, player)
						HumanoidValue:TakeDamage(50)
					end
				end
			end
		end)
		
		local Mark = ReplicatedStorage.Assets.FragBlastMark
		local MarkClone
		
		
		if Mark then
			GrenadeClone:Destroy()
			MarkClone = Mark:Clone()
			MarkClone.ExplosionSound:Play()
			MarkClone.FragEffect.Enabled = true
			MarkClone.FragLight.Enabled = true
			MarkClone.Parent = game.Workspace
			MarkClone.CFrame = CFrame.new(M67Position) * CFrame.new(0, -.45, 0)
			
		end
		NewExplosion.Parent = game.Workspace
		wait(.5)
		MarkClone.FragEffect.Enabled = false
		MarkClone.FragLight.Enabled = false
		wait(10)
		MarkClone:Destroy()
	elseif player.Name == PlayerUsername and Status == "Fail" then
		local GrenadeClone = ReplicatedStorage.Assets.M67Used:Clone()
		GrenadeClone.CanCollide = true
		GrenadeClone.Parent = game.Workspace
		GrenadeClone.CFrame = player.Character["Torso"].CFrame
		player.Backpack["M67"]:Remove()
		
		M67Position = GrenadeClone.Position
		
		local Team = player.TeamColor
		local NewExplosion = Instance.new("Explosion")
		NewExplosion.BlastPressure = 0
		NewExplosion.BlastRadius = 20
		NewExplosion.ExplosionType = "NoCraters"
		NewExplosion.Position = M67Position

		NewExplosion.Hit:Connect(function(HitPart, PartDistance)
			if HitPart.Parent:FindFirstChild("Humanoid") ~= nil then
				local HumanoidValue = HitPart.Parent:FindFirstChild('Humanoid')
				if game.Players:GetPlayerFromCharacter(HitPart.Parent) ~= nil then
					local PlayerValue = game.Players:GetPlayerFromCharacter(HitPart.Parent)
					if (PlayerValue.TeamColor ~= player.TeamColor or PlayerValue == player) then
						UntagHumanoid(HumanoidValue)
						if PlayerValue ~= player then
							TagHumanoid(HumanoidValue, player)
						end
						HumanoidValue:TakeDamage(50)
					end
				else
					if HitPart.Parent:FindFirstChild('TEAM').Value == "Infected" then
						UntagHumanoid(HumanoidValue)
						TagHumanoid(HumanoidValue, player)
						HumanoidValue:TakeDamage(50)
					end
				end
			end
		end)

		local Mark = ReplicatedStorage.Assets.FragBlastMark
		local MarkClone


		if Mark then
			GrenadeClone:Destroy()
			MarkClone = Mark:Clone()
			MarkClone.Decal.Texture = ""
			MarkClone.ExplosionSound:Play()
			MarkClone.FragEffect.Enabled = true
			MarkClone.FragLight.Enabled = true
			MarkClone.Parent = game.Workspace
			MarkClone.CFrame = CFrame.new(M67Position) * CFrame.new(0, -.45, 0)

		end
		NewExplosion.Parent = game.Workspace
		wait(.5)
		MarkClone.FragEffect.Enabled = false
		MarkClone.FragLight.Enabled = false
		wait(10)
		MarkClone:Destroy()
	end
end)