local character = script.Parent
local Humanoid = character:FindFirstChild("Humanoid")
local Head = character:FindFirstChild("Head")
local Torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
local Player = game.Players:GetPlayerFromCharacter(character)

local charParts = {}
local customPackageMeshes = {}

local welds = {}

local iceParts = {}

local scaleFactor = 1.1

local formSounds = {1213774145, 1213774319, 1213774433, 1213774543}
local shatterSounds = {3622822508} --220468096

local function Weld(p0, p1)
	local weld = Instance.new("Weld")
	weld.Part0 = p0
	weld.Part1 = p1
	weld.C0 = p0.CFrame:ToObjectSpace(p1.CFrame)
	weld.Name = "Weld"
	weld.Parent = p1
	table.insert(welds, weld)
end

local function DisableMove()
	Humanoid.AutoRotate = false
    Humanoid:UnequipTools()
    PreventTools = character.ChildAdded:Connect(function(Child)
	    task.wait()
	    if Child:IsA("Tool") and Child.Parent == character then
		    Humanoid:UnequipTools()
	    end
    end)
	DisableJump = Humanoid.Changed:Connect(function(Property)
		if Property == "Jump" then
			Humanoid.Jump = false
		end
	end)
	--Humanoid.PlatformStand = true
    Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
end

local function EnableMove()
	Humanoid.AutoRotate = true
	for i, v in pairs({DisableJump, PreventTools}) do
		if v then
			v:Disconnect()
		end
	end
	--Humanoid.PlatformStand = false
    Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
end

--add all the parts in the character to charParts, and accessories to accessoryParts
for i, v in pairs(character:GetDescendants()) do
	if v:IsA("BasePart") then
		if v.Name ~= "HumanoidRootPart" then
			table.insert(charParts, v)
		end
		if (v.Name ~= "Torso" or v.Name ~= "UpperTorso") and not v:IsA("Accoutrement") then
			local wrap = nil
			wrap = coroutine.wrap(function()
				task.wait(0.05)
				Weld(Torso, v)
				coroutine.yield(wrap)
			end)()
		end
	end
	--[[if v:IsA("Hat") or v:IsA("Accoutrement") or v:IsA("Accessory") then
		table.insert(charParts, v.Handle)
	end]]
	if v:IsA("CharacterMesh") then
		customPackageMeshes[v.BodyPart.Name] = v.MeshId
	end
end

--freeze the character
DisableMove()

IceForm = Instance.new("Sound")
IceForm.Name = "IceForm"
IceForm.SoundId = "rbxassetid://"..formSounds[math.random(1,#formSounds)]
IceForm.Parent = Head
IceForm.PlaybackSpeed = 1
IceForm.Volume = 1.5
game.Debris:AddItem(IceForm, 10)
task.delay(0, function() IceForm:Play() end)

for i, v in pairs(charParts) do
	do
		local clone = v:Clone()
		if v.Name == "Head" and v:FindFirstChild("Mesh") then
			if pcall(function()
				return v.Mesh.MeshType == Enum.MeshType.Head
			end) then
				clone:Destroy()
				clone = game.ReplicatedStorage.Miscs.Head:Clone()
			end
		end
		clone.Massless = true
		clone:BreakJoints()
		clone.Name = "IcePart"
		clone.Color = Color3.fromRGB(128, 187, 219)
		clone.Size = clone.Size * scaleFactor * 0.95
		clone.CanCollide = false
		clone.Anchored = false
		clone.Transparency = 0.5
		clone.BottomSurface = "Smooth"
		clone.TopSurface = "Smooth"
		clone.Material = Enum.Material.SmoothPlastic
		for _, c in pairs(clone:GetChildren()) do
			if not c:IsA("DataModelMesh") then
				c:Destroy()
			elseif c:IsA("SpecialMesh") and c.MeshType == Enum.MeshType.FileMesh then
				c.TextureId = ""
				c.Scale = c.Scale * scaleFactor
				clone.Size = v.Size * scaleFactor
			end
		end
		if customPackageMeshes[string.gsub(v.Name, " ", "")] then
			local m = Instance.new("SpecialMesh")
			m.MeshId = "rbxassetid://"..customPackageMeshes[string.gsub(v.Name, " ", "")]
			m.Scale = m.Scale * scaleFactor
			m.Parent = clone
			clone.Size = v.Size * scaleFactor
		end
		clone.Parent = character
		local w = Instance.new("Weld")
		w.Parent = clone
		w.Part0 = v
		w.Part1 = clone
		table.insert(iceParts, clone)
	end
end

--task.wait(script.Duration.Value)

while script.Duration.Value > 0 do
	task.wait(1)
	script.Duration.Value = script.Duration.Value - 1
end

--unfreeze the character
for i = 1, #iceParts do
	local C = iceParts[i]:GetChildren()
    for ii = 1, #C do
        if C[ii].className == "Weld" then
            C[ii]:Destroy()
        end
    end
	local dir = (iceParts[i].Position - iceParts[i].CFrame.p + Vector3.new(0, 1, 0)).unit
	iceParts[i].Velocity = (dir + Vector3.new(math.random() - 0.5, 1, math.random() - 0.5)) * 20
	iceParts[i].RotVelocity = (dir + Vector3.new(math.random() - 0.5, math.random() - 0.5, math.random() - 0.5)) * 10
	local force = Instance.new("BodyForce")
	force.Force = dir * 50 * iceParts[i]:GetMass()
	force.Parent = iceParts[i]
	task.delay(0.25, function() force:Destroy() end)
end

for i, v in pairs(welds) do
	if v then
		v:Destroy()
	end
end

EnableMove()

IceShatter = Instance.new("Sound")
IceShatter.Name = "IceShatter"
IceShatter.SoundId = "rbxassetid://"..shatterSounds[math.random(1, #shatterSounds)]
IceShatter.Parent = Head
IceShatter.PlaybackSpeed = 1
IceShatter.Volume = 1.5
game.Debris:AddItem(IceShatter, 10)
task.delay(0, function() IceShatter:Play() end)
IceShatter.Ended:Connect(function()
	if script then
		script:Destroy()
	end
end)