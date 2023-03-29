local GlassShattering = {}

local Debris = game:GetService("Debris")
local Workspace = game:GetService("Workspace")

local function CreateTriangle(pos, pos2, cframe, part, sizeZ)
	--sizeZ = 0.2
	local tableToSort = {{
			longest = cframe - pos2, 
			other = pos - pos2, 
			position = pos2
		}, {
			longest = pos - cframe, 
			other = pos2 - cframe, 
			position = cframe
		}, {
			longest = pos2 - pos, 
			other = cframe - pos, 
			position = pos
		}}
	table.sort(tableToSort, function(a, b)
		return b.longest.Magnitude < a.longest.Magnitude
	end)
	local sortedTable = tableToSort[1]
	local v = math.acos(sortedTable.longest.Unit:Dot(sortedTable.other.Unit))
	local newSize = Vector2.new(sortedTable.other.Magnitude * math.cos(v), sortedTable.other.Magnitude * math.sin(v))
	local newSize2 = Vector2.new(sortedTable.longest.Magnitude - newSize.x, newSize.y)
	local newPos = sortedTable.position + sortedTable.other / 2
	local newPos2 = sortedTable.position + sortedTable.longest + (sortedTable.other - sortedTable.longest) / 2
	local Unit = sortedTable.longest:Cross(sortedTable.other).Unit
	local unit2 = Unit:Cross(sortedTable.longest).Unit
	local unit3 = sortedTable.longest.Unit
	local newPart = part:Clone()
	local newPart2 = part:Clone()
	newPart.Size = Vector3.new(sizeZ, newSize.y, newSize.x)
	newPart2.Size = Vector3.new(sizeZ, newSize2.y, newSize2.x)
	newPart.CFrame = CFrame.new(newPos.x, newPos.y, newPos.z, -Unit.x, unit2.x, unit3.x, -Unit.y, unit2.y, unit3.y, -Unit.z, unit2.z, unit3.z)
	newPart2.CFrame = CFrame.new(newPos2.x, newPos2.y, newPos2.z, Unit.x, unit2.x, -unit3.x, Unit.y, unit2.y, -unit3.y, Unit.z, unit2.z, -unit3.z)
	newPart.Anchored = false
	newPart2.Anchored = false
	return {newPart, newPart2}
end

local function GetThinAxis(hit)
	local size = {hit.Size.X, hit.Size.Y, hit.Size.Z}
	local minimumSize = math.min(size[1], size[2], size[3])
	local axis = nil
	if minimumSize == size[1] then
		axis = 1 --x
	end
	if minimumSize == size[2] then
		axis = 2 --y
	end
	if minimumSize == size[3] then
		axis = 3 --z
	end
	return axis, minimumSize
end

local function GetPoints(hit)
	local y = nil
	local y2 = nil
	local x = nil
	local x2 = nil
	local z = nil
	local z2 = nil
	local axis = GetThinAxis(hit)
	local partSizeX = hit.Size.X / 2
	local partSizeY = hit.Size.Y / 2
	local partSizeZ = hit.Size.Z / 2
	y = CFrame.new(0, partSizeY, 0)
	y2 = CFrame.new(0, -partSizeY, 0)
	x2 = CFrame.new(-partSizeX, 0, 0)
	x = CFrame.new(partSizeX, 0, 0)
	z2 = CFrame.new(0, 0, -partSizeZ)
	z = CFrame.new(0, 0, partSizeZ)
	if axis == 1 then
		local points = {hit.CFrame * y * z2, hit.CFrame * y2 * z2, hit.CFrame * y2 * z, hit.CFrame * y * z}
		if hit:IsA("WedgePart") then
			table.remove(points, 1)
		end
		return points
	end
	if axis == 2 then
		return {hit.CFrame * z2 * x, hit.CFrame * z * x, hit.CFrame * z * x2, hit.CFrame * z2 * x2}
	end
	if not axis == 3 then return end
	return {hit.CFrame * y * x, hit.CFrame * y2 * x, hit.CFrame * y2 * x2, hit.CFrame * y * x2}
end

local function GetShatterPoint(hit, pos)
	local axis, minimumSize = GetThinAxis(hit)
	local vector = nil
	if axis == 1 then
		vector = hit.CFrame.RightVector
	end
	if axis == 2 then
		vector = hit.CFrame.UpVector
	end
	if axis == 3 then
		vector = hit.CFrame.LookVector
	end
	if (function(vector, minimumSize)
		local a = CFrame.new(pos, pos + vector).p - hit.CFrame.p
		local b = CFrame.new(pos, pos + vector * -1).p - hit.CFrame.p
		if a.X ^ 2 + a.Y ^ 2 + a.Z ^ 2 < b.X ^ 2 + b.Y ^ 2 + b.Z ^ 2 then
			return false
		end
		return true
	end)(vector, minimumSize) then
		vector = vector * -1
	end
	return (CFrame.new(pos, pos + vector) * CFrame.new(0, 0, -minimumSize / 2)).p, vector
end

function GlassShattering:Shatter(hit, pos, dir)
	local cframe = nil
	local points = GetPoints(hit)
	local vector = nil
	cframe, vector = GetShatterPoint(hit, pos)
	local trianglePart = Instance.new("WedgePart")
	trianglePart.Reflectance = hit.Reflectance
	trianglePart.Transparency = hit.Transparency
	trianglePart.TopSurface = hit.TopSurface
	trianglePart.BottomSurface = hit.BottomSurface
	trianglePart.FrontSurface = hit.FrontSurface
	trianglePart.BackSurface = hit.BackSurface
	trianglePart.LeftSurface = hit.LeftSurface
	trianglePart.RightSurface = hit.RightSurface
	trianglePart.Color = hit.Color
	trianglePart.Material = hit.Material
	local axis, minimumSize = GetThinAxis(hit)
	local cframeData
	if #points == 4 then
		cframeData = {{points[1], points[2], cframe}, {points[2], points[3], cframe}, {points[3], points[4], cframe}, {points[4], points[1], cframe}}
	else
		cframeData = {{points[1], points[2], cframe}, {points[2], points[3], cframe}, {points[3], points[1], cframe}}
	end
	local fragments = {}
	for i = 1, #cframeData do
		table.insert(fragments, (CreateTriangle(cframeData[i][1].p, cframeData[i][2].p, cframeData[i][3], trianglePart, minimumSize)))
	end
	hit.CanCollide = false
	hit.Transparency = 1
	for i = 1, #fragments do
		for ii = 1, #fragments[i] do
			local triangle = fragments[i][ii]
			triangle.Name = "_shatter"
			triangle.Parent = Workspace
			triangle.Velocity = dir
			triangle.CanCollide = true
			Debris:AddItem(triangle, 10)
		end
	end
end

return GlassShattering