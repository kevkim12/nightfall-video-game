-- a modified version of nocollider's gore system
local RenderDistance = 400

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local Miscs = ReplicatedStorage:WaitForChild("Miscs")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Events = ReplicatedStorage:WaitForChild("Events")
local Modules = ReplicatedStorage:WaitForChild("Modules")

local Utilities = require(Modules.Utilities)
local Thread = Utilities.Thread

local Gibs = Miscs.Gibs
local GibsR15 = Miscs.GibsR15
local Skeleton = Miscs.Skeleton
local SkeletonR15 = Miscs.SkeletonR15

local Camera = Workspace.CurrentCamera
local Gib = Events.gib
local VisualizeGore = Remotes.VisualizeGore

local Joints = {}

local DamagedHeadParts = {"damaged.head.1", "damaged.head.2", "damaged.head.3"}

local Gore = {
	["Head"] = {"damaged.head.bone.1", "damaged.head.bone.2"},
	["Right Arm"] = {"damaged.right.arm.1", "damaged.right.arm.2", "damaged.right.arm.flesh.1", "damaged.right.arm.flesh.2"},
	["Left Arm"] = {"damaged.left.arm.1", "damaged.left.arm.2", "damaged.left.arm.flesh.1", "damaged.left.arm.flesh.2"},
	["Right Leg"] = {"damaged.right.leg.1", "damaged.right.leg.2", "damaged.right.leg.flesh.1", "damaged.right.leg.flesh.2"},
	["Left Leg"] = {"damaged.left.leg.1", "damaged.left.leg.2", "damaged.left.leg.flesh.1", "damaged.left.leg.flesh.2"},
	["Torso"] = {"damaged.torso", "damaged.torso.flesh", "damaged.torso.bone"},
}

local GoreR15 = {
	["Head"] = {"damaged.head.bone.1", "damaged.head.bone.2"},
	["RightUpperArm"] = {"damaged.right.upper.arm", "damaged.right.upper.arm.bone"},
	["RightLowerArm"] = {"damaged.right.lower.arm", "damaged.right.lower.arm.flesh"},
	["RightHand"] = {"damaged.right.hand"},
	["LeftUpperArm"] = {"damaged.left.upper.arm", "damaged.left.upper.arm.bone"},
	["LeftLowerArm"] = {"damaged.left.lower.arm", "damaged.left.lower.arm.flesh"},
	["LeftHand"] = {"damaged.left.hand"},
	["RightUpperLeg"] = {"damaged.right.upper.leg", "damaged.right.upper.leg.flesh"},
	["RightLowerLeg"] = {"damaged.right.lower.leg", "damaged.right.lower.leg.flesh"},
	["RightFoot"] = {"damaged.right.foot"},
	["LeftUpperLeg"] = {"damaged.left.upper.leg", "damaged.left.upper.leg.flesh"},
	["LeftLowerLeg"] = {"damaged.left.lower.leg", "damaged.left.lower.leg.flesh"},
	["LeftFoot"] = {"damaged.left.foot"},
	["UpperTorso"] = {"damaged.upper.torso", "damaged.upper.torso.bone"},
	["LowerTorso"] = {"damaged.lower.torso", "damaged.lower.torso.flesh"},
}

local Bones = {
	["Head"] = {"head"},
	["Right Arm"] = {"right.arm"},
	["Left Arm"] = {"left.arm"},
	["Right Leg"] = {"right.leg"},
	["Left Leg"] = {"left.leg"},
	["Torso"] = {"torso"},
}

local BonesR15 = {
	["Head"] = {"head"},
	["RightUpperArm"] = {"right.upper.arm"},
	["RightLowerArm"] = {"right.lower.arm"},
	["RightHand"] = {"right.hand"},
	["LeftUpperArm"] = {"left.upper.arm"},
	["LeftLowerArm"] = {"left.lower.arm"},
	["LeftHand"] = {"left.hand"},
	["RightUpperLeg"] = {"right.upper.leg"},
	["RightLowerLeg"] = {"right.lower.leg"},
	["RightFoot"] = {"right.foot"},
	["LeftUpperLeg"] = {"left.upper.leg"},
	["LeftLowerLeg"] = {"left.lower.leg"},
	["LeftFoot"] = {"left.foot"},
	["UpperTorso"] = {"upper.torso"},
	["LowerTorso"] = {"lower.torso"},
}

function DoOdds(Chances)
	if Random.new():NextInteger(0, 100) <= Chances then
		return true
	end
	return false
end

local function FullR6Gib(Joint, Ragdoll, ClientModule, GoreEffect)
	if Ragdoll:FindFirstChild("Torso") and Joint.Transparency ~= 1 and not Ragdoll:FindFirstChild("gibbed") and (Joint.Position - Camera.CFrame.p).Magnitude <= RenderDistance then	
	    Joint.Transparency = 1
	    local Tag = Instance.new("StringValue", Ragdoll)
	    Tag.Name = "gibbed"
				
	    local Decal = Joint:FindFirstChildOfClass("Decal") 
	    if Decal then
		    Decal:Destroy()
	    end

		if Joint.Name == "Head" then
			local parts = Ragdoll:GetChildren()
			for i = 1, #parts do
				if parts[i]:IsA("Hat") or parts[i]:IsA("Accessory") then
					local handle = parts[i].Handle:Clone()
					local children = handle:GetChildren()
					for i = 1, #children do
						if children[i]:IsA("Weld") then
							children[i]:Destroy()
						end
					end
					handle.CFrame = parts[i].Handle.CFrame
					handle.CanCollide = true
				    handle.RotVelocity = Vector3.new((math.random() - 0.5) * 25, (math.random() - 0.5) * 25, (math.random() - 0.5) * 25)
					handle.Velocity = Vector3.new(
						(math.random() - 0.5) * 25,
						math.random(25, 50),
						(math.random() - 0.5) * 25
					)
					handle.Parent = Ragdoll
					parts[i].Handle.Transparency = 1
				end
			end
		end

		for _, Limb in pairs(Bones[Joint.Name]) do
			local limb = Skeleton[Limb]:Clone()
		    limb.Anchored = true
		    limb.CanCollide = false
		    limb.Parent = Ragdoll
		    local offset = Skeleton.rig[Joint.Name].CFrame:ToObjectSpace(limb.CFrame)
		    Joints[limb] = function() return Joint.CFrame * offset end
		end
				
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = Joint.CFrame
		Attachment.Parent = workspace.Terrain
		local Sound = Instance.new("Sound",Attachment)
		Sound.SoundId = "rbxassetid://"..ClientModule.GoreSoundIDs[math.random(1, #ClientModule.GoreSoundIDs)]
		Sound.PlaybackSpeed = Random.new():NextNumber(ClientModule.GoreSoundPitchMin, ClientModule.GoreSoundPitchMax)
		Sound.Volume = ClientModule.GoreSoundVolume
					
		local function spawner()
		    local C = GoreEffect:GetChildren()
		    for i = 1, #C do
		        if C[i].className == "ParticleEmitter" then
		            local count = 1
		            local Particle = C[i]:Clone()
		            Particle.Parent = Attachment
		            if Particle:FindFirstChild("EmitCount") then
		                count = Particle.EmitCount.Value
		            end
		            Thread:Delay(0.01, function()
		                Particle:Emit(count)
		               	Debris:AddItem(Particle, Particle.Lifetime.Max)
		            end)
		        end
		    end
		    Sound:Play()
		end
				
		Thread:Spawn(spawner)
		Debris:AddItem(Attachment, 10)	
	end
end

local function R6Gib(Joint, Ragdoll, ClientModule, GoreEffect)
	if Ragdoll:FindFirstChild("Torso") and Joint.Transparency ~= 1 and not Ragdoll:FindFirstChild("gibbed") and (Joint.Position - Camera.CFrame.p).Magnitude <= RenderDistance then	
	    Joint.Transparency = 1
	    local Tag = Instance.new("StringValue", Ragdoll)
	    Tag.Name = "gibbed"
				
	    local Decal = Joint:FindFirstChildOfClass("Decal") 
	    if Decal then
		    Decal:Destroy()
	    end

		if Joint.Name == "Head" then
			local parts = Ragdoll:GetChildren()
			for i = 1, #parts do
				if parts[i]:IsA("Hat") or parts[i]:IsA("Accessory") then
					local handle = parts[i].Handle:Clone()
					local children = handle:GetChildren()
					for i = 1, #children do
						if children[i]:IsA("Weld") then
							children[i]:Destroy()
						end
					end
					handle.CFrame = parts[i].Handle.CFrame
					handle.CanCollide = true
				    handle.RotVelocity = Vector3.new((math.random() - 0.5) * 25, (math.random() - 0.5) * 25, (math.random() - 0.5) * 25)
					handle.Velocity = Vector3.new(
						(math.random() - 0.5) * 25,
						math.random(25, 50),
						(math.random() - 0.5) * 25
					)
					handle.Parent = Ragdoll
					parts[i].Handle.Transparency = 1
				end
			end
			for _, headPart in pairs(DamagedHeadParts) do
			    local part = Gibs[headPart]:Clone()
				part.Color = Joint.Color
			    part.CFrame = Joint.CFrame
			    part.RotVelocity = Vector3.new((math.random() - 0.5) * 25, (math.random() - 0.5) * 25, (math.random() - 0.5) * 25)
				part.Velocity = Vector3.new(
					(math.random() - 0.5) * 25,
					math.random(50, 100),
					(math.random() - 0.5) * 25
				)
			    part.Parent = Ragdoll
			end
		end

		for _, Limb in pairs(Gore[Joint.Name]) do
			local limb = Gibs[Limb]:Clone()
		    limb.Anchored = true
		    limb.CanCollide = false
		    if not (limb.Name:match("flesh") or limb.Name:match("bone")) then
				limb.Color = Joint.Color
				if not limb.Name:match("head") then
					if limb.Name:match("leg") or limb.Name:match("foot") then
						if Ragdoll:FindFirstChildOfClass("Pants") then
							limb.TextureID = Ragdoll:FindFirstChildOfClass("Pants").PantsTemplate
						end
					else
						if limb.Name:match("torso") then
							if Ragdoll:FindFirstChildOfClass("Shirt") then
								limb.TextureID = Ragdoll:FindFirstChildOfClass("Shirt").ShirtTemplate
							else
								if Ragdoll:FindFirstChildOfClass("Pants") then
									limb.TextureID = Ragdoll:FindFirstChildOfClass("Pants").PantsTemplate
								end
							end
						else
							if Ragdoll:FindFirstChildOfClass("Shirt") then
								limb.TextureID = Ragdoll:FindFirstChildOfClass("Shirt").ShirtTemplate
							end
						end
					end
				end
		    end
		    limb.Parent = Ragdoll
		    local offset = Gibs.rig[Joint.Name].CFrame:ToObjectSpace(limb.CFrame)
		    Joints[limb] = function() return Joint.CFrame * offset end
		end
				
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = Joint.CFrame
		Attachment.Parent = workspace.Terrain
		local Sound = Instance.new("Sound",Attachment)
		Sound.SoundId = "rbxassetid://"..ClientModule.GoreSoundIDs[math.random(1, #ClientModule.GoreSoundIDs)]
		Sound.PlaybackSpeed = Random.new():NextNumber(ClientModule.GoreSoundPitchMin, ClientModule.GoreSoundPitchMax)
		Sound.Volume = ClientModule.GoreSoundVolume
					
		local function spawner()
		    local C = GoreEffect:GetChildren()
		    for i = 1, #C do
		        if C[i].className == "ParticleEmitter" then
		            local count = 1
		            local Particle = C[i]:Clone()
		            Particle.Parent = Attachment
		            if Particle:FindFirstChild("EmitCount") then
		                count = Particle.EmitCount.Value
		            end
		            Thread:Delay(0.01, function()
		                Particle:Emit(count)
		               	Debris:AddItem(Particle, Particle.Lifetime.Max)
		            end)
		        end
		    end
		    Sound:Play()
		end
				
		Thread:Spawn(spawner)
		Debris:AddItem(Attachment, 10)	
	end
end

local function FullR15Gib(Joint, Ragdoll, ClientModule, GoreEffect)
	if Ragdoll:FindFirstChild("UpperTorso") and Joint.Transparency ~= 1 and not Ragdoll:FindFirstChild("gibbed") and (Joint.Position - Camera.CFrame.p).Magnitude <= RenderDistance then	
	    Joint.Transparency = 1
	    local Tag = Instance.new("StringValue", Ragdoll)
	    Tag.Name = "gibbed"
				
	    local Decal = Joint:FindFirstChildOfClass("Decal") 
	    if Decal then
		    Decal:Destroy()
	    end

		if Joint.Name == "Head" then
			local parts = Ragdoll:GetChildren()
			for i = 1, #parts do
				if parts[i]:IsA("Hat") or parts[i]:IsA("Accessory") then
					local handle = parts[i].Handle:Clone()
					local children = handle:GetChildren()
					for i = 1, #children do
						if children[i]:IsA("Weld") then
							children[i]:Destroy()
						end
					end
					handle.CFrame = parts[i].Handle.CFrame
					handle.CanCollide = true
				    handle.RotVelocity = Vector3.new((math.random() - 0.5) * 25, (math.random() - 0.5) * 25, (math.random() - 0.5) * 25)
					handle.Velocity = Vector3.new(
						(math.random() - 0.5) * 25,
						math.random(25, 50),
						(math.random() - 0.5) * 25
					)
					handle.Parent = Ragdoll
					parts[i].Handle.Transparency = 1
				end
			end
		end

		for _, Limb in pairs(BonesR15[Joint.Name]) do
			local limb = SkeletonR15[Limb]:Clone()
		    limb.Anchored = true
		    limb.CanCollide = false
		    limb.Parent = Ragdoll
		    local offset = SkeletonR15.rig[Joint.Name].CFrame:ToObjectSpace(limb.CFrame)
		    Joints[limb] = function() return Joint.CFrame * offset end
		end
				
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = Joint.CFrame
		Attachment.Parent = workspace.Terrain
		local Sound = Instance.new("Sound",Attachment)
		Sound.SoundId = "rbxassetid://"..ClientModule.GoreSoundIDs[math.random(1, #ClientModule.GoreSoundIDs)]
		Sound.PlaybackSpeed = Random.new():NextNumber(ClientModule.GoreSoundPitchMin, ClientModule.GoreSoundPitchMax)
		Sound.Volume = ClientModule.GoreSoundVolume
					
		local function spawner()
		    local C = GoreEffect:GetChildren()
		    for i = 1, #C do
		        if C[i].className == "ParticleEmitter" then
		            local count = 1
		            local Particle = C[i]:Clone()
		            Particle.Parent = Attachment
		            if Particle:FindFirstChild("EmitCount") then
		                count = Particle.EmitCount.Value
		            end
		            Thread:Delay(0.01, function()
		                Particle:Emit(count)
		               	Debris:AddItem(Particle, Particle.Lifetime.Max)
		            end)
		        end
		    end
		    Sound:Play()
		end
				
		Thread:Spawn(spawner)
		Debris:AddItem(Attachment, 10)	
	end
end

local function R15Gib(Joint, Ragdoll, ClientModule, GoreEffect)
	if Ragdoll:FindFirstChild("UpperTorso") and Joint.Transparency ~= 1 and not Ragdoll:FindFirstChild("gibbed") and (Joint.Position - Camera.CFrame.p).Magnitude <= RenderDistance then	
	    Joint.Transparency = 1
	    local Tag = Instance.new("StringValue", Ragdoll)
	    Tag.Name = "gibbed"
				
	    local Decal = Joint:FindFirstChildOfClass("Decal") 
	    if Decal then
		    Decal:Destroy()
	    end

		if Joint.Name == "Head" then
			local parts = Ragdoll:GetChildren()
			for i = 1, #parts do
				if parts[i]:IsA("Hat") or parts[i]:IsA("Accessory") then
					local handle = parts[i].Handle:Clone()
					local children = handle:GetChildren()
					for i = 1, #children do
						if children[i]:IsA("Weld") then
							children[i]:Destroy()
						end
					end
					handle.CFrame = parts[i].Handle.CFrame
					handle.CanCollide = true
				    handle.RotVelocity = Vector3.new((math.random() - 0.5) * 25, (math.random() - 0.5) * 25, (math.random() - 0.5) * 25)
					handle.Velocity = Vector3.new(
						(math.random() - 0.5) * 25,
						math.random(25, 50),
						(math.random() - 0.5) * 25
					)
					handle.Parent = Ragdoll
					parts[i].Handle.Transparency = 1
				end
			end
			for _, headPart in pairs(DamagedHeadParts) do
			    local part = Gibs[headPart]:Clone()
				part.Color = Joint.Color
			    part.CFrame = Joint.CFrame
			    part.RotVelocity = Vector3.new((math.random() - 0.5) * 25, (math.random() - 0.5) * 25, (math.random() - 0.5) * 25)
				part.Velocity = Vector3.new(
					(math.random() - 0.5) * 25,
					math.random(50, 100),
					(math.random() - 0.5) * 25
				)
			    part.Parent = Ragdoll
			end
		end

		for _, Limb in pairs(GoreR15[Joint.Name]) do
			local limb = GibsR15[Limb]:Clone()
		    limb.Anchored = true
		    limb.CanCollide = false
		    if not (limb.Name:match("flesh") or limb.Name:match("bone")) then
				limb.Color = Joint.Color
				if not limb.Name:match("head") then
					if limb.Name:match("leg") or limb.Name:match("foot") then
						if Ragdoll:FindFirstChildOfClass("Pants") then
							limb.TextureID = Ragdoll:FindFirstChildOfClass("Pants").PantsTemplate
						end
					else
						if limb.Name:match("torso") then
							if Ragdoll:FindFirstChildOfClass("Shirt") then
								limb.TextureID = Ragdoll:FindFirstChildOfClass("Shirt").ShirtTemplate
							else
								if Ragdoll:FindFirstChildOfClass("Pants") then
									limb.TextureID = Ragdoll:FindFirstChildOfClass("Pants").PantsTemplate
								end
							end
						else
							if Ragdoll:FindFirstChildOfClass("Shirt") then
								limb.TextureID = Ragdoll:FindFirstChildOfClass("Shirt").ShirtTemplate
							end
						end
					end
				end
		    end
		    limb.Parent = Ragdoll
		    local offset = GibsR15.rig[Joint.Name].CFrame:ToObjectSpace(limb.CFrame)
		    Joints[limb] = function() return Joint.CFrame * offset end
		end
				
		local Attachment = Instance.new("Attachment")
		Attachment.CFrame = Joint.CFrame
		Attachment.Parent = workspace.Terrain
		local Sound = Instance.new("Sound",Attachment)
		Sound.SoundId = "rbxassetid://"..ClientModule.GoreSoundIDs[math.random(1, #ClientModule.GoreSoundIDs)]
		Sound.PlaybackSpeed = Random.new():NextNumber(ClientModule.GoreSoundPitchMin, ClientModule.GoreSoundPitchMax)
		Sound.Volume = ClientModule.GoreSoundVolume
					
		local function spawner()
			local C = GoreEffect:GetChildren()
		    for i = 1, #C do
		        if C[i].className == "ParticleEmitter" then
		            local count = 1
		            local Particle = C[i]:Clone()
		            Particle.Parent = Attachment
		            if Particle:FindFirstChild("EmitCount") then
		                count = Particle.EmitCount.Value
		            end
		            Thread:Delay(0.01, function()
		                Particle:Emit(count)
		               	Debris:AddItem(Particle, Particle.Lifetime.Max)
		            end)
		        end
		    end
		    Sound:Play()
		end
				
		Thread:Spawn(spawner)
		Debris:AddItem(Attachment, 10)	
	end
end

local function GibJoint(Joint, Ragdoll, ClientModule, GoreEffect)
	if ClientModule.GoreEffectEnabled then
		if Ragdoll:FindFirstChildOfClass("Humanoid") then
			if Ragdoll:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
				if DoOdds(ClientModule.FullyGibbedLimbChance) then
					FullR6Gib(Joint, Ragdoll, ClientModule, GoreEffect)
				else
					R6Gib(Joint, Ragdoll, ClientModule, GoreEffect)
				end
			else
				if DoOdds(ClientModule.FullyGibbedLimbChance) then
					FullR15Gib(Joint, Ragdoll, ClientModule, GoreEffect)
				else
					R15Gib(Joint, Ragdoll, ClientModule, GoreEffect)
				end
			end
		end
	end
end

Gib.Event:Connect(GibJoint)
VisualizeGore.OnClientEvent:Connect(GibJoint)

RunService.RenderStepped:Connect(function(dt)
	for part, cframe in next, Joints do
		part.CFrame = cframe()
	end
end)