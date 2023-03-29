local module = {}

local TS = game:GetService("TweenService")
local Debris = game:GetService("Debris")

------Settings------
local AccurateRepresentation = true -- will include floor color,material and transparency
local DespawnTime = 2
local FlyingDebrisCollision = false
local AmountFlyingDebris = math.random(6,8)
--------------------

-----RandomDebris-----
local Colors = {
	Color3.fromRGB(91, 91, 91),
}
local Materials = {
	Enum.Material.Plastic,
}
----------------------

function module.Create(radius,Position,rockSize)
	local ModelCircle = Instance.new("Model",workspace.Terrain)
	ModelCircle.Name = "Debris"
	Debris:AddItem(ModelCircle,5)
	
	local Y = Position.Y

	local Material
	local Transparency 
	local Color

	local IgnoreList = {}

	for _,object in pairs(workspace:GetDescendants()) do
		if object.Name == "Debree" or object:FindFirstChildWhichIsA("Humanoid") then
			table.insert(IgnoreList,object)
		end
	end

	local RPParams = RaycastParams.new()
	RPParams.FilterDescendantsInstances = IgnoreList
	RPParams.FilterType = Enum.RaycastFilterType.Blacklist

	local ray = workspace:Raycast(Position + Vector3.new(0,0.1,0),Vector3.new(0,-999,0),RPParams)

	if ray then
		Y = ray.Position.Y
		Material = ray.Material
		Transparency = ray.Instance.Transparency
		Color = ray.Instance.Color
	else
		warn("No ground found")
		return
	end

	local parts = {}

	for i = 0,radius * 8,rockSize do
		table.insert(parts,Instance.new("Part",ModelCircle))
	end

	local function getXAndZPositions(angle)
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		return x, z
	end
	
	for i, part in pairs(parts) do
		part.Anchored = true
		part.CanCollide = false
		part.Name = "Debree"
		part.Size = Vector3.new(0,0,0)
		local angle = (i*rockSize) * (360 / #parts)
		local x,z = getXAndZPositions(angle)
		table.insert(IgnoreList,part)
		RPParams.FilterDescendantsInstances = IgnoreList
		
		for _,v in pairs(Enum.NormalId:GetEnumItems()) do
			part[v.Name.."Surface"] = Enum.SurfaceType.Smooth
		end
		
		part.CFrame = CFrame.new(Position) * CFrame.new(x, 0, z)
		part.Position = Vector3.new(part.Position.X,Y,part.Position.Z)
		part.CFrame *= CFrame.Angles(math.rad(math.random(-90,90)),math.rad(math.random(-90,90)),math.rad(math.random(-90,90)))
						
		if AccurateRepresentation == true then
			local raynew = workspace:Raycast(part.Position + Vector3.new(0,0.1,0),Vector3.new(0,-999,0),RPParams)

			if raynew then
				part.Material = raynew.Material
				part.Transparency = raynew.Instance.Transparency
				part.Color = raynew.Instance.Color
			else				
				part.Material = Material
				part.Transparency = Transparency
				part.Color = Color
			end
		else
			part.Material = Materials[math.random(1,#Materials)]
			part.Color = Colors[math.random(1,#Colors)]
		end

		part.Parent = workspace
		TS:Create(part,TweenInfo.new(0.2),{Size = Vector3.new(rockSize,rockSize,rockSize)}):Play()
		
		task.spawn(function()
			task.wait(DespawnTime)
			TS:Create(part,TweenInfo.new(0.1),{Size = Vector3.new(0,0,0)}):Play()
			Debris:AddItem(part,0.11)
		end)
	end

	for i = 0,AmountFlyingDebris do
		local DebrisVelocity = Vector3.new(math.random(-50,50),math.floor(70,120),math.random(-50,50))
		
		local part = Instance.new("Part",ModelCircle)
		part.CanCollide = false
		part.Size = Vector3.new(0,0,0)
		part.Massless = true
		part.Name = "Debree"
		part.BottomSurface = Enum.SurfaceType.Smooth
		part.TopSurface = Enum.SurfaceType.Smooth
		TS:Create(part,TweenInfo.new(0.2),{Size = Vector3.new(rockSize,rockSize,rockSize)}):Play()

		if AccurateRepresentation == true then
			part.Material = Material
			part.Transparency = Transparency
			part.Color = Color
		else
			part.Material = Materials[math.random(1,#Materials)]
			part.Color = Colors[math.random(1,#Colors)]
		end
		
		part.Position = Position + Vector3.new(0,rockSize,0)
		part.Velocity = DebrisVelocity
		part.AssemblyAngularVelocity = Vector3.new(math.random(-90,90),math.random(-90,90),math.random(-90,90))
		
		task.spawn(function()
			task.wait(0.5)
			part.CanCollide = FlyingDebrisCollision
		end)
		
		task.spawn(function()
			task.wait(DespawnTime)
			TS:Create(part,TweenInfo.new(0.5,Enum.EasingStyle.Cubic),{Size = Vector3.new(0,0,0)}):Play()

			Debris:AddItem(part,1)
		end)
	end
	
	return
end

return module
