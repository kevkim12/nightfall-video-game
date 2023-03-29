local HP_PER_SPOT = 5 -- how many health points lost allows for a blood spot
local MAX_SPLATTERS = 100 -- max amt to generate
local CONE_ANGLE = 120 -- the angle of the cone of downward spray - MUST BE <180
local MAX_SPLATTER_DISTANCE = 30 -- how far away to splatter at the most
local MIN_SIZE, MAX_SIZE = 0.3, 1 -- min, max radius of particles
local LIFETIME = 15 -- how long to keep spatters

CONE_ANGLE = math.rad(CONE_ANGLE/2)
local template = script:WaitForChild("Blood"):Clone()
script.Blood:Destroy()
local model = workspace.Debris


local function Expand(obj, size)
	local start = obj.Size
	local cframe = obj.CFrame
	for i = 0, 1, 0.05 do
		wait()
		obj.Transparency = 0
		obj.Size = start:Lerp(size, i)
		obj.CFrame = cframe
	end
	wait(LIFETIME)
	for i = 0, 1, 0.05 do
		wait()
		obj.Transparency = 0
	end
	obj:Destroy()
end

local function GetNormal(part, pos)
	local shape
	if part:IsA("Part") then shape = part.Shape.Value
	elseif part:IsA("WedgePart") then shape = 3
	elseif part:IsA("CornerWedgePart") then shape = 4
	else shape = 5
	end
	if shape == 0 then
		return (pos-part.Position).unit, "curve", pos
	elseif shape == 1 or shape == 3 then
		local r = part.CFrame:pointToObjectSpace(pos)/part.Size
		local rot = part.CFrame-part.Position
		if r.x > 0.4999 then return rot*Vector3.new(1,0,0), "right", pos
		elseif r.x < -0.4999 then return rot*Vector3.new(-1,0,0), "left", pos
		elseif r.y > 0.4999 then return rot*Vector3.new(0,1,0), "top", pos
		elseif r.y < -0.4999 then return rot*Vector3.new(0,-1,0), "bottom", pos
		elseif r.z > 0.4999 then return rot*Vector3.new(0,0,1), "back", pos
		elseif r.z < -0.4999 then return rot*Vector3.new(0,0,-1), "front", pos
		end
		return rot*Vector3.new(0,part.Size.Z,-part.Size.Y).unit, "ramp", pos
	elseif shape == 2 then -- Cylinders
		return (pos-part.Position).unit, "curve", pos
	elseif shape == 4 then
		local r = part.CFrame:pointToObjectSpace(pos)/part.Size
		local rot = part.CFrame-part.Position
		if r.x > 0.4999 then return rot*Vector3.new(1,0,0), "right", pos
		elseif r.y < -0.4999 then return rot*Vector3.new(0,-1,0), "bottom", pos
		elseif r.z < -0.4999 then return rot*Vector3.new(0,0,-1), "front", pos
		elseif r.unit:Dot(Vector3.new(1,0,1).unit) > 0 then return rot*Vector3.new(0,part.Size.Z,part.Size.Y).unit, "lslope", pos
		end
		return rot*Vector3.new(-part.Size.Y,part.Size.X,0).unit, "rslope", pos
	else
		return Vector3.new(0,1,0), "unknown", pos
	end
end

local min, random, rad, pi, tan = math.min, math.random, math.rad, math.pi, math.tan
local ignore = {model}
game.Players.PlayerAdded:connect(function(player)
	player.CharacterAdded:connect(function(character)
		local torso, humanoid = character:WaitForChild("HumanoidRootPart"), character:WaitForChild("Humanoid")
		local lastHealth = humanoid.Health
		table.insert(ignore, character)
		humanoid.HealthChanged:connect(function(health)
			for i = 1, min(MAX_SPLATTERS, (lastHealth-health)/HP_PER_SPOT) do
				local part, pos
				local try = 1
				repeat
					local p
					repeat
						p = Vector2.new(random()*2-1, random()*2-1)
					until p.magnitude <= 1
					local r = tan(random()*CONE_ANGLE)
					local dir = Vector3.new(r*p.x, -1, r*p.y).unit
					part, pos = workspace:FindPartOnRayWithIgnoreList(Ray.new(torso.Position, dir*MAX_SPLATTER_DISTANCE), ignore)
					try = try + 1
				until part or try > 5
				if part then
					local splat = template:Clone()
					local size = min(splat.Size.X, splat.Size.Z) * MIN_SIZE + random()*(MAX_SIZE-MIN_SIZE)
					splat.FormFactor = Enum.FormFactor.Custom
					splat.Size = Vector3.new()
					splat.CFrame = CFrame.new(pos, pos + GetNormal(part, pos)) * CFrame.Angles(-pi/2, 0, 0)
					splat.Transparency = 1
					coroutine.resume(coroutine.create(function()
						Expand(splat, Vector3.new(size, splat.Size.Y, size))
					end))
					splat.Parent = model
				end
			end
			lastHealth = health
		end)
	end)
end)