wait(1)
local tool = script.Parent
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

while character.Parent == nil do
	character.AncestryChanged:Wait()
end

local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")
local camera = workspace.CurrentCamera

local head = character:WaitForChild("Head")
local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
local leftArm = character:FindFirstChild("Left Arm") or character:FindFirstChild("LeftUpperArm")
local rightArm = character:FindFirstChild("Right Arm") or character:FindFirstChild("RightUpperArm")

local neck = torso:FindFirstChild("Neck") or head:FindFirstChild("Neck")
local leftShoulder = torso:FindFirstChild("Left Shoulder") or leftArm:FindFirstChild("LeftShoulder")
local rightShoulder = torso:FindFirstChild("Right Shoulder") or rightArm:FindFirstChild("RightShoulder")

local defaultHeadC1 = neck.C1
local defaultLeftArmC1 = leftShoulder.C1
local defaultRightArmC1 = rightShoulder.C1

local defaultHeadC0 = neck.C0
local defaultLeftArmC0 = leftShoulder.C0
local defaultRightArmC0 = rightShoulder.C0

local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

local spring = require(game.ReplicatedStorage.Modules.spring)

local mouseDeltaDivision = 200

local swayOffset = CFrame.new()
local movementOffset = CFrame.new()

local swaySpring = spring.create()
local movementSpring = spring.create()

local whitelistedArmNames = {
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	
	"Right Arm",
	
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",

	"Left Arm",
}

local function setTransparency(part)
	if part and part:IsA("BasePart") and table.find(whitelistedArmNames, part.Name) then
		part.LocalTransparencyModifier = 0
		
		part.Changed:Connect(function(property)    
			part.LocalTransparencyModifier = 0
		end)
	end
end

local function inFirstPerson()
	local dist = (camera.CFrame.Position - (root.Position + Vector3.new(0,1.5,0))).Magnitude
	return dist < 1
end

local function getBobbing(addition,speed,modifier)
	return math.sin(tick()*addition*speed)*modifier
end

local function renderStepped(dt)
	local speed = 1.5 * (humanoid.WalkSpeed / 16)
	local modifier = 4
	
	local mouseDelta = userInputService:GetMouseDelta()
	local walkCycle = Vector3.new(getBobbing(10,speed,modifier),getBobbing(5,speed,modifier), 0) * dt
	
	swaySpring:shove(Vector3.new(mouseDelta.x / mouseDeltaDivision,mouseDelta.y / mouseDeltaDivision))	
	
	movementOffset = movementSpring:update(dt)
	swayOffset = swaySpring:update(dt)
	
	local movementCF = CFrame.new()
	movementCF = CFrame.new(movementOffset.y, movementOffset.x, movementOffset.z)

	if humanoid.MoveDirection.Magnitude > 0 then
		movementSpring:shove(walkCycle)
	else
		movementSpring:shove(Vector3.new())
	end
	
	if inFirstPerson() and tool.Parent == character then
		local torsoX,torsoY,torsoZ = torso.CFrame:ToEulerAnglesYXZ()
		local cameraX, cameraY, _ = camera.CFrame:ToEulerAnglesYXZ()
		
		local torsoRot = CFrame.Angles(0,torsoY,torsoZ)
		local cameraPos = CFrame.new(0,0,-0.5)
		local cameraRot = CFrame.Angles(0, -cameraY, 0)
		local swayCF = CFrame.Angles(swayOffset.y, swayOffset.x, swayOffset.x/2)
		
		local camCF = camera.CFrame * cameraPos * cameraRot * torsoRot * swayCF * movementCF
		
		if character:FindFirstChild("Torso") then
			-- R6
			rightShoulder.C0 = torso.CFrame:inverse() * (camCF * CFrame.Angles(0,math.rad(90),0) * CFrame.new(0,-1,1))
			leftShoulder.C0 = torso.CFrame:inverse() * (camCF * CFrame.Angles(0,math.rad(-90),0) * CFrame.new(0,-1,1))
		else
			-- R15
			rightShoulder.C0 = torso.CFrame:inverse() * (camCF * CFrame.Angles(0,math.rad(0),0) * CFrame.new(1,-1,0))
			leftShoulder.C0 = torso.CFrame:inverse() * (camCF * CFrame.Angles(0,math.rad(0),0) * CFrame.new(-1,-1,0))
		end
	else
		neck.C1 = defaultHeadC1
		leftShoulder.C1 = defaultLeftArmC1
		rightShoulder.C1 = defaultRightArmC1
		
		neck.C0 = defaultHeadC0
		leftShoulder.C0 = defaultLeftArmC0
		rightShoulder.C0 = defaultRightArmC0
	end
end

for _,v in pairs(character:GetChildren()) do
	setTransparency(v)
end
runService.RenderStepped:Connect(renderStepped)