-- Original script made by Luckymaxer [yes i edited this lol]

Projectile = script.Parent
Projectile.Size = Vector3.new(0.2,0.2,0.2)

Players = game:GetService("Players")
Debris = game:GetService("Debris")

Values = {}
for i, v in pairs(script:GetChildren()) do
	if string.find(string.lower(v.ClassName), string.lower("Value")) then
		Values[v.Name] = v
	end
end

BaseProjectile = Values.BaseProjectile.Value

function GetCreator()
	local Creator = Values.Creator.Value
	return (((Creator and Creator.Parent and Creator:IsA("Player")) and Creator) or nil)
end

function IsTeamMate(Player1, Player2)
	return (Player1 and Player2 and not Player1.Neutral and not Player2.Neutral and Player1.TeamColor == Player2.TeamColor)
end

function TagHumanoid(humanoid, player)
	local Creator_Tag = Instance.new("ObjectValue")
	Creator_Tag.Name = "creator"
	Creator_Tag.Value = player
	Debris:AddItem(Creator_Tag, 2)
	Creator_Tag.Parent = humanoid
end

function UntagHumanoid(humanoid)
	for i, v in pairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

function CheckTableForString(Table, String)
	for i, v in pairs(Table) do
		if string.find(string.lower(String), string.lower(v)) then
			return true
		end
	end
	return false
end

function CheckIntangible(Hit)
	local ProjectileNames = {"Water", "Part", "Projectile", "Effect", "Rail", "Laser", "Bullet"}
	if Hit and Hit.Parent then
		if ((not Hit.CanCollide or CheckTableForString(ProjectileNames, Hit.Name)) and not Hit.Parent:FindFirstChild("Humanoid")) then
			return true
		end
	end
	return false
end

function CastRay(StartPos, Vec, Length, Ignore, DelayIfHit)
	local Ignore = ((type(Ignore) == "table" and Ignore) or {Ignore})
	local RayHit, RayPos, RayNormal = game:GetService("Workspace"):FindPartOnRayWithIgnoreList(Ray.new(StartPos, Vec * Length), Ignore)
	if RayHit and CheckIntangible(RayHit) then
		if DelayIfHit then
			wait()
		end
		RayHit, RayPos, RayNormal = CastRay((RayPos + (Vec * 0.01)), Vec, (Length - ((StartPos - RayPos).magnitude)), Ignore, DelayIfHit)
	end
	return RayHit, RayPos, RayNormal
end

function FlyProjectile(Part, StartPos)
	local AlreadyHit = false
	local Player = GetCreator()
	local function PartHit(Hit)
		if not Hit or not Hit.Parent or not Player then
			return
		end
		local character = Hit.Parent
		if character:IsA("Hat") then
			character = character.Parent
		end
		if not character then
			return
		end
		local player = Players:GetPlayerFromCharacter(character)
		if player and (player == Player or IsTeamMate(Player, player)) then
			return
		end
		local humanoid = character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health == 0 then
			return
		end
		UntagHumanoid(humanoid)
		TagHumanoid(humanoid, Player)
		humanoid:TakeDamage(Values.Damage.Value)
		return character
	end
	local function CheckForContact(Hit)
		local Directions = {{Vector = Part.CFrame.lookVector, Length = (BaseProjectile.Size.Z + 2)}, {Vector = Vector3.new(0, -1, 0), Length = (BaseProjectile.Size.Y * 1.25)}, ((Hit and {Vector = CFrame.new(Part.Position, Hit.Position).lookVector, Length = (BaseProjectile.Size.Z + 2)}) or nil)}
		local ClosestRay = {DistanceApart = math.huge}
		for i, v in pairs(Directions) do
			if v then
				local Direction = CFrame.new(Part.Position, (Part.CFrame + v.Vector * 2).p).lookVector
				local RayHit, RayPos, RayNormal = CastRay((Part.Position + Vector3.new(0, 0, 0)), Direction, v.Length, {((Player and Player.Character) or nil), Part}, false)
				if RayHit then
					local DistanceApart = (Part.Position - RayPos).Magnitude
					if DistanceApart < ClosestRay.DistanceApart then
						ClosestRay = {Hit = RayHit, Pos = RayPos, Normal = RayNormal, DistanceApart = DistanceApart}
					end
				end
			end
		end
		return ((ClosestRay.Hit and ClosestRay) or nil)
	end
	local function ConnectPart(Hit)
		
		if AlreadyHit then
			return
		end
		local ClosestRay = CheckForContact(Hit)
		if not ClosestRay then
			return
		end
		AlreadyHit = true
		for i, v in pairs(Part:GetChildren()) do
			if v:IsA("BasePart") then
				for ii, vv in pairs(v:GetChildren()) do
					if vv:IsA("ParticleEmitter") then
						vv.Enabled = false
						v.Anchored = true
					elseif vv:IsA("JointInstance") then
						vv:Destroy()
					end
				end
				Debris:AddItem(v, 8)
			elseif string.find(string.lower(v.ClassName), string.lower("Body")) then
				v:Destroy()
			end
		end
		local SuccessfullyHit = PartHit(ClosestRay.Hit)
		Part.Size = Vector3.new(0.2, 0.2, 0.2)
		Part.CanCollide = false
		local Hit = ClosestRay.Hit
		if SuccessfullyHit and Hit.Parent:FindFirstChild("Humanoid") or Hit.Parent.Parent:FindFirstChild("Humanoid") then
			script.HitE:Fire(Hit)
			if Values.ProjectileLand.Value == true then
				local ProjectilePosition = ClosestRay.Pos
				local StickCFrame = CFrame.new(ProjectilePosition, StartPos)
				StickCFrame = (StickCFrame * CFrame.new(0, 0, (-(BaseProjectile.Size.Z / 2) + 0)) * CFrame.Angles(0, math.pi, 0))
				local Weld = Instance.new("Motor6D")
				Weld.Part0 = Hit
				Weld.Part1 = Part
				Weld.C0 = CFrame.new(0, 0, 0)
				Weld.C1 = (StickCFrame:inverse() * Hit.CFrame)
				Weld.Parent = Part
				Part.Orientation = Part.Orientation + Values.ProjectileLandRotation.Value
			else
				script.Parent:Destroy()
			end
		else
			script.HitE:Fire(Hit)
			if Values.ProjectileLand.Value == true then
				local ProjectilePosition = ClosestRay.Pos
				local StickCFrame = CFrame.new(ProjectilePosition, StartPos)
				StickCFrame = (StickCFrame * CFrame.new(0, 0, (-(BaseProjectile.Size.Z / 2) + 0)) * CFrame.Angles(0, math.pi, 0))
				local Weld = Instance.new("Motor6D")
				Weld.Part0 = Hit
				Weld.Part1 = Part
				Weld.C0 = CFrame.new(0, 0, 0)
				Weld.C1 = (StickCFrame:inverse() * Hit.CFrame)
				Weld.Parent = Part
				Part.Orientation = Part.Orientation + Values.ProjectileLandRotation.Value
			else
				script.Parent:Destroy()
			end
		end
		delay(Values.Lifetime.Value,function()
			Projectile:Destroy()
		end)
		Part.Name = "Effect"
	end
	Part.Touched:Connect(function(Hit)
		if not Hit or not Hit.Parent or AlreadyHit then
			return
		end
		ConnectPart(Hit)
	end)
	spawn(function()
		while Part and Part.Parent and Part.Name ~= "Effect" and not AlreadyHit do
			ConnectPart()
			wait()
		end
	end)
end

FlyProjectile(Projectile, Values.Origin.Value)