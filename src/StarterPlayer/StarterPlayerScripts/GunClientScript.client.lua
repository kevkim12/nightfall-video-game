local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Camera = Workspace.CurrentCamera

local Events = ReplicatedStorage:WaitForChild("Events")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local Modules = ReplicatedStorage:WaitForChild("Modules")
local Miscs = ReplicatedStorage:WaitForChild("Miscs")

local gunEvent = Events.gunEvent
local gunFunction = Events.gunFunction

local PlayAudio = Remotes.PlayAudio
local VisualizeBullet = Remotes.VisualizeBullet
local VisualizeHitEffect = Remotes.VisualizeHitEffect
local VisualizeBeam = Remotes.VisualizeBeam
local VisibleMuzzle = Remotes.VisibleMuzzle

local AudioHandler = require(Modules.AudioHandler)
local ProjectileHandler = require(Modules.ProjectileHandler)
local Utilities = require(Modules.Utilities)
local Thread = Utilities.Thread

local Container = {}
local LaserTrailContainer = {}
local LightningBoltContainer = {}

local function FindExistingId(Dictionary)
	for _, v in pairs(Container) do
		if v.Main.Id == Dictionary.Id then
			return true
		end
	end
	return false
end

local function RemoveExistingBeam(Id, ClientModule, BeamTable, LaserTrail, BoltSegments, CrosshairPointAttachment)
	VisualizeBeam:FireServer(false, {
		Id = Id,
		ClientModule = ClientModule,
	})
	if BeamTable then
		for i, v in pairs(BeamTable) do
			if v then
				v:Destroy()
			end
			table.remove(BeamTable, i)
		end
	end
	if LaserTrail then
		Thread:Spawn(function()
			if ClientModule.LaserTrailFadeTime > 0 then
				local DesiredSize = LaserTrail.Size * (ClientModule.ScaleLaserTrail and Vector3.new(1, ClientModule.LaserTrailScaleMultiplier, ClientModule.LaserTrailScaleMultiplier) or Vector3.new(1, 1, 1))
				local Tween = TweenService:Create(LaserTrail, TweenInfo.new(ClientModule.LaserTrailFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
				Tween:Play()
				Tween.Completed:Wait()
				LaserTrail:Destroy()
			else
				LaserTrail:Destroy()
			end	
		end)
	end
	if BoltSegments then
		for i, v in pairs(BoltSegments) do
			Thread:Delay(ClientModule.BoltVisibleTime, function()
				if ClientModule.BoltFadeTime > 0 then
					local DesiredSize = v.Size * (ClientModule.ScaleBolt and Vector3.new(1, ClientModule.BoltScaleMultiplier, ClientModule.BoltScaleMultiplier) or Vector3.new(1, 1, 1))
					local Tween = TweenService:Create(v, TweenInfo.new(ClientModule.BoltFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
					Tween:Play()
					Tween.Completed:Wait()
					table.remove(BoltSegments, i)
					v:Destroy()
				else
					table.remove(BoltSegments, i)
					v:Destroy()							
				end
			end)			
		end
	end
	if CrosshairPointAttachment then
		CrosshairPointAttachment:Destroy()
	end
end

local function PlayReplicatedAudio(Audio, LowAmmoAudio, Replicate)
	AudioHandler:PlayAudio(Audio, LowAmmoAudio, Replicate)
end

local function SimulateReplicatedProjectile(Tool, Handle, ClientModule, Directions, FirePointObject, MuzzlePointObject, Misc, Replicate)
	ProjectileHandler:SimulateProjectile(Tool, Handle, ClientModule, Directions, FirePointObject, MuzzlePointObject, Misc, Replicate)
end

local function VisualizeReplicatedHitEffect(Type, Hit, Position, Normal, Material, ClientModule, Misc, Replicate)
	ProjectileHandler:VisualizeHitEffect(Type, Hit, Position, Normal, Material, ClientModule, Misc, Replicate)
end

local function VisualizeReplicatedBeam(Enabled, Dictionary)
	if Enabled then
		if not FindExistingId(Dictionary) then
			table.insert(Container, {Main = Dictionary})
		else
			local Main
			for _, v in pairs(Container) do
				if v.Main.Id == Dictionary.Id then
					Main = v.Main
					break
				end
			end
			if not Main.CrosshairPointAttachment then
				Main.CrosshairPointAttachment = Instance.new("Attachment")
				Main.CrosshairPointAttachment.Name = "CrosshairPointAttachment"
				for i, v in pairs(Main.HitEffect:GetChildren()) do
					if v.ClassName == "ParticleEmitter" then
						local particle = v:Clone()
						particle.Enabled = true
						particle.Parent = Main.CrosshairPointAttachment
					end
				end
			end
			if not Main.LaserBeamContainer then
				Main.LaserBeamContainer = {}
				for i, v in pairs(Main.LaserBeams:GetChildren()) do
					if v.ClassName == "Beam" then
						local beam = v:Clone()
						table.insert(Main.LaserBeamContainer, beam)
					end
				end
				for i, v in pairs(Main.LaserBeamContainer) do
					if v then
						v.Parent = Main.Handle
						v.Attachment0 = Main.FirePoint
						v.Attachment1 = Main.CrosshairPointAttachment
					end
				end
			end
			if Main.ClientModule.LaserTrailEnabled and not Main.LaserTrailData then
				Main.LaserTrailData = {}
				Main.LaserTrailData.Id = Main.Id
				Main.LaserTrailData.ClientModule = Main.ClientModule
				Main.LaserTrailData.FirePoint = Main.FirePoint
				Main.LaserTrailData.CrosshairPointAttachment = Main.CrosshairPointAttachment
				Main.LaserTrailData.LaserTrail = Miscs[Main.ClientModule.LaserTrailShape.."Segment"]:Clone()
				
				if Main.ClientModule.RandomizeLaserColorIn == "None" then
					Main.LaserTrailData.LaserTrail.Color = Main.ClientModule.LaserTrailColor
				end
				Main.LaserTrailData.LaserTrail.Material = Main.ClientModule.LaserTrailMaterial
				Main.LaserTrailData.LaserTrail.Reflectance = Main.ClientModule.LaserTrailReflectance
				Main.LaserTrailData.LaserTrail.Transparency = Main.ClientModule.LaserTrailTransparency
				Main.LaserTrailData.LaserTrail.Size = Main.ClientModule.LaserTrailShape == "Cone" and Vector3.new(Main.ClientModule.LaserTrailWidth, (Main.FirePoint.WorldPosition - Main.CrosshairPointAttachment.WorldPosition).Magnitude, Main.ClientModule.LaserTrailHeight) or Vector3.new((Main.FirePoint.WorldPosition - Main.CrosshairPointAttachment.WorldPosition).Magnitude, Main.ClientModule.LaserTrailHeight, Main.ClientModule.LaserTrailWidth)
				Main.LaserTrailData.LaserTrail.CFrame = CFrame.new((Main.FirePoint.WorldPosition + Main.CrosshairPointAttachment.WorldPosition) * 0.5, Main.CrosshairPointAttachment.WorldPosition) * (Main.ClientModule.LaserTrailShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
				Main.LaserTrailData.LaserTrail.Parent = Camera
				
				table.insert(LaserTrailContainer, Main.LaserTrailData)
			end
			if Main.ClientModule.LightningBoltEnabled and not Main.LightningBoltData then
				Main.LightningBoltData = {}
				Main.LightningBoltData.Id = Main.Id
				Main.LightningBoltData.ClientModule = Main.ClientModule
				Main.LightningBoltData.FirePoint = Main.FirePoint
				Main.LightningBoltData.CrosshairPointAttachment = Main.CrosshairPointAttachment
				table.insert(LightningBoltContainer, Main.LightningBoltData)
			end
			Main.CrosshairPointAttachment.Parent = Workspace.Terrain
			Main.CrosshairPointAttachment.WorldCFrame = CFrame.new(Dictionary.CrosshairPosition) --CFrame.new(Main.CrosshairPosition)
			if Main.ClientModule.LookAtInput then
				local FireDirection = (Main.CrosshairPointAttachment.WorldPosition - Main.FirePoint.WorldPosition).Unit
				Main.MuzzlePoint.CFrame = Main.MuzzlePoint.Parent.CFrame:toObjectSpace(CFrame.lookAt(Main.MuzzlePoint.WorldPosition, Dictionary.CrosshairPosition)) --CFrame.lookAt(Main.MuzzlePoint.WorldPosition, Main.CrosshairPosition)
				Main.CrosshairPointAttachment.WorldCFrame = CFrame.new(Dictionary.CrosshairPosition, FireDirection) --CFrame.new(Main.CrosshairPosition, FireDirection)
			end
		end
	else
		for i, v in pairs(Container) do
			if v.Main.Id == Dictionary.Id then
				if v.Main.CrosshairPointAttachment then
					v.Main.CrosshairPointAttachment:Destroy()
				end
				if v.Main.LaserBeamContainer then
					for ii, vv in pairs(v.Main.LaserBeamContainer) do
						if vv then
							vv:Destroy()
						end
						table.remove(v.Main.LaserBeamContainer, ii)
					end
				end
				if v.Main.LaserTrailData then					
					for ii, vv in pairs(LaserTrailContainer) do
						if vv.Id == v.Main.LaserTrailData.Id then
							vv.Terminate = true
							break
						end
					end
					--table.clear(v.Main.LaserTrailData)
				end
				if v.Main.LightningBoltData then					
					for ii, vv in pairs(LightningBoltContainer) do
						if vv.Id == v.Main.LightningBoltData.Id then
							vv.Terminate = true
							break
						end
					end
					--table.clear(v.Main.LightningBoltData)
				end
				table.remove(Container, i)
				break
			end
		end
	end
end

RunService.RenderStepped:Connect(function(dt)
	for i, v in next, LaserTrailContainer, nil do
		if v.Terminate then
			v.Terminate = false
			local LaserTrail = v.LaserTrail
			local ClientModule = v.ClientModule
			if LaserTrail then
				Thread:Spawn(function()
					if ClientModule.LaserTrailFadeTime > 0 then
						local DesiredSize = LaserTrail.Size * (ClientModule.ScaleLaserTrail and Vector3.new(1, ClientModule.LaserTrailScaleMultiplier, ClientModule.LaserTrailScaleMultiplier) or Vector3.new(1, 1, 1))
						local Tween = TweenService:Create(LaserTrail, TweenInfo.new(ClientModule.LaserTrailFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
						Tween:Play()
						Tween.Completed:Wait()
						LaserTrail:Destroy()
					else
						LaserTrail:Destroy()
					end	
				end)
			end
			table.remove(LaserTrailContainer, i)
		else
			if v.ClientModule.RandomizeLaserColorIn ~= "None" then
				local Hue = os.clock() % v.ClientModule.LaserColorCycleTime / v.ClientModule.LaserColorCycleTime
				local Color = Color3.fromHSV(Hue, 1, 1)
				v.LaserTrail.Color = Color
			end			
			v.LaserTrail.Size = v.ClientModule.LaserTrailShape == "Cone" and Vector3.new(v.ClientModule.LaserTrailWidth, (v.FirePoint.WorldPosition - v.CrosshairPointAttachment.WorldPosition).Magnitude, v.ClientModule.LaserTrailHeight) or Vector3.new((v.FirePoint.WorldPosition - v.CrosshairPointAttachment.WorldPosition).Magnitude, v.ClientModule.LaserTrailHeight, v.ClientModule.LaserTrailWidth)
			v.LaserTrail.CFrame = CFrame.new((v.FirePoint.WorldPosition + v.CrosshairPointAttachment.WorldPosition) * 0.5, v.CrosshairPointAttachment.WorldPosition) * (v.ClientModule.LaserTrailShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))	
		end
	end
	for i, v in next, LightningBoltContainer, nil do
		if v.Terminate then
			v.Terminate = false
			table.remove(LightningBoltContainer, i)
		else
			local BoltCFrameTable = {}
			local BoltRadius = v.ClientModule.BoltRadius
			for ii = 1, v.ClientModule.BoltCount do
				if ii == 1 then
					table.insert(BoltCFrameTable, CFrame.new(0, 0, 0))
				else
					table.insert(BoltCFrameTable, CFrame.new(math.random(-BoltRadius, BoltRadius), math.random(-BoltRadius, BoltRadius), 0))
				end
			end
			for _, vv in ipairs(BoltCFrameTable) do
				local FireDirection = (v.CrosshairPointAttachment.WorldPosition - v.FirePoint.WorldPosition).Unit
				local Start = (CFrame.new(v.FirePoint.WorldPosition, v.FirePoint.WorldPosition + FireDirection) * vv).p
				local End = (CFrame.new(v.CrosshairPointAttachment.WorldPosition, v.CrosshairPointAttachment.WorldPosition + FireDirection) * vv).p
				local Distance = (End - Start).Magnitude
				local LastPos = Start
				local RandomBoltColor = Color3.new(math.random(), math.random(), math.random())
				for ii = 0, Distance, 10 do
					local FakeDistance = CFrame.new(Start, End) * CFrame.new(0, 0, -ii - 10) * CFrame.new(-2 + (math.random() * v.ClientModule.BoltWideness), -2 + (math.random() * v.ClientModule.BoltWideness), -2 + (math.random() * v.ClientModule.BoltWideness))
					local BoltSegment = Miscs[v.ClientModule.BoltShape.."Segment"]:Clone()
					if v.ClientModule.RandomizeBoltColorIn ~= "None" then
						if v.ClientModule.RandomizeBoltColorIn == "Whole" then
							BoltSegment.Color = RandomBoltColor
						elseif v.ClientModule.RandomizeBoltColorIn == "Segment" then
							BoltSegment.Color = Color3.new(math.random(), math.random(), math.random())
						end
					else
						BoltSegment.Color = v.ClientModule.BoltColor
					end
					BoltSegment.Material = v.ClientModule.BoltMaterial
					BoltSegment.Reflectance = v.ClientModule.BoltReflectance
					BoltSegment.Transparency = v.ClientModule.BoltTransparency
					if ii + 10 > Distance then
						BoltSegment.CFrame = CFrame.new(LastPos, End) * CFrame.new(0, 0, -(LastPos - End).Magnitude / 2) * (v.ClientModule.BoltShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
					else
						BoltSegment.CFrame = CFrame.new(LastPos, FakeDistance.p) * CFrame.new(0, 0, -(LastPos - FakeDistance.p).Magnitude / 2) * (v.ClientModule.BoltShape == "Cone" and CFrame.Angles(math.pi / 2, 0, 0) or CFrame.Angles(0, math.pi / 2, 0))
					end					
					if ii + 10 > Distance then
						BoltSegment.Size = v.ClientModule.BoltShape == "Cone" and Vector3.new(v.ClientModule.BoltWidth, (LastPos - End).Magnitude, v.ClientModule.BoltHeight) or Vector3.new((LastPos - End).Magnitude, v.ClientModule.BoltHeight, v.ClientModule.BoltWidth)
					else
						BoltSegment.Size = v.ClientModule.BoltShape == "Cone" and Vector3.new(v.ClientModule.BoltWidth, (LastPos - FakeDistance.p).Magnitude, v.ClientModule.BoltHeight) or Vector3.new((LastPos - FakeDistance.p).Magnitude, v.ClientModule.BoltHeight, v.ClientModule.BoltWidth)
					end
					BoltSegment.Parent = Camera
					Thread:Delay(v.ClientModule.BoltVisibleTime, function()
						if v.ClientModule.BoltFadeTime > 0 then
							local DesiredSize = BoltSegment.Size * (v.ClientModule.ScaleBolt and Vector3.new(1, v.ClientModule.BoltScaleMultiplier, v.ClientModule.BoltScaleMultiplier) or Vector3.new(1, 1, 1))
							local Tween = TweenService:Create(BoltSegment, TweenInfo.new(v.ClientModule.BoltFadeTime, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Transparency = 1, Size = DesiredSize})
							Tween:Play()
							Tween.Completed:Wait()
							BoltSegment:Destroy()
						else
							BoltSegment:Destroy()							
						end
					end)
					LastPos = FakeDistance.p
				end
			end
		end
	end
end)

local function VisibleReplicatedMuzzle(MuzzlePointObject, Enabled)
	if MuzzlePointObject then
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
end

gunEvent.Event:Connect(function(EventName, ...)
	if EventName == "VisualizeBullet" then
		SimulateReplicatedProjectile(...)
	elseif EventName == "VisualizeHitEffect" then
		VisualizeReplicatedHitEffect(...)
	elseif EventName == "RemoveBeam" then
		RemoveExistingBeam(...)
	elseif EventName == "PlayAudio" then
		PlayReplicatedAudio(...)
	end
end)

gunFunction.OnInvoke = function(EventName, ...)
	return nil --Nothing
end 

PlayAudio.OnClientEvent:Connect(PlayReplicatedAudio)
VisualizeBullet.OnClientEvent:Connect(SimulateReplicatedProjectile)
VisualizeHitEffect.OnClientEvent:Connect(VisualizeReplicatedHitEffect)
VisualizeBeam.OnClientEvent:Connect(VisualizeReplicatedBeam)
VisibleMuzzle.OnClientEvent:Connect(VisibleReplicatedMuzzle)