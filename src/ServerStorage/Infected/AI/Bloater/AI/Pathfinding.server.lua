debugMode = false
targetNPCs = false

--

local Teams = game:GetService("Teams")
local Survivors = Teams:WaitForChild("Survivors")
local Infected = Teams:WaitForChild("Infected")

h = script.Parent.Parent:WaitForChild("Humanoid")
pathService = game:GetService("PathfindingService")
targetV = script.Parent:WaitForChild("Target")

local model = script.Parent.Parent
local torso = model:WaitForChild("Torso")

function closestTargetAndPath()
	local humanoids = {}
	if targetNPCs then
		local function recurse(o)
			for _,obj in pairs(o:GetChildren()) do
				if obj:IsA("Model") then
					if obj:findFirstChild("Humanoid") and obj:findFirstChild("Torso") and obj.Humanoid ~= h and obj.Humanoid.Health > 0 and not obj:findFirstChild("ForceField") and game.Players:GetPlayerFromCharacter(obj.Parent) ~= nil then
						if game.Players:GetPlayerFromCharacter(obj.Parent).Team == Survivors then
							table.insert(humanoids,obj.Humanoid)
						end
					end
				end
				recurse(obj)
			end
		end
		recurse(workspace)
	else
		for _,v in pairs(game.Players:GetPlayers()) do
			if v.Character and v.Character:findFirstChild("HumanoidRootPart") and v.Character:findFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 and not v:findFirstChild("ForceField") and v.Team == Survivors then
				if (model.HumanoidRootPart.Position - v.Character.HumanoidRootPart.Position).magnitude < 300 then
					table.insert(humanoids,v.Character.Humanoid)
				end
			end
		end
	end
	local closest,path,dist
	for _,humanoid in pairs(humanoids) do
		local myPath = pathService:ComputeRawPathAsync(h.Torso.Position,humanoid.Torso.Position,500)
		if myPath.Status ~= Enum.PathStatus.FailFinishNotEmpty then
			-- Now that we have a successful path, we need to figure out how far we need to actually travel to reach this point.
			local myDist = 0
			local previous = h.Torso.Position
			for _,point in pairs(myPath:GetPointCoordinates()) do
				myDist = myDist + (point-previous).magnitude
				previous = point
			end
			if not dist or myDist < dist then -- if true, this is the closest path so far.
				closest = humanoid
				path = myPath
				dist = myDist
			end
		end
	end
	return closest,path
end

function goToPos(loc)
	h:MoveTo(loc)
	local distance = (loc-h.Torso.Position).magnitude
	local start = tick()
	while distance > 4 do
		if tick()-start > distance/h.WalkSpeed then -- Something may have gone wrong. Just break.
			break
		end
		distance = (loc-h.Torso.Position).magnitude
		wait()
	end
end

torso.Touched:Connect(function(obj)
	if not obj.Parent:FindFirstChild("Humanoid") and not obj.Parent:FindFirstChildWhichIsA("Accessory") then
		model.Humanoid.Jump = true
	end
end)

while wait() do
	local target,path = closestTargetAndPath()
	local didBreak = false
	local targetStart
	if target and h.Torso then
		targetV.Value = target
		targetStart = target.Torso.Position
		roaming = false
		local previous = h.Torso.Position
		local points = path:GetPointCoordinates()
		local s = #points > 1 and 2 or 1
		for i = s,#points do
			local point = points[i]
			if didBreak then 
				break
			end
			if target and target.Torso and target.Health > 0 and game.Players:GetPlayerFromCharacter(target.Parent).Team ~= nil then
				if game.Players:GetPlayerFromCharacter(target.Parent).Team == Survivors then
					if (target.Torso.Position-targetStart).magnitude < 1.5 then
						local pos = previous:lerp(point,.5)
						local moveDir = ((pos - h.Torso.Position).unit * 2)
						goToPos(previous:lerp(point,.5))
						previous = point
					end
				end
			else
				didBreak = true
				break
			end
		end
	else
		targetV.Value = nil
		wait(math.random(5,15))
		h:MoveTo(h.Torso.Position + Vector3.new(math.random(-16, 16), 0, math.random(-16, 16)))
	end
	if not didBreak and targetStart then
		goToPos(targetStart)
	end
end