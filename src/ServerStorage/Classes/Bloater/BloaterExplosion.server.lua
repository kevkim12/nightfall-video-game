Character = script.Parent
Humanoid = Character.Humanoid
Torso = Character.Torso
local InfectedTeam = game:GetService("Teams"):WaitForChild("Infected")
local HitOnce = false

function OnDeath()
	print("Death")
	wait(0.01)
	local NewExplosion = Instance.new("Explosion")
	NewExplosion.BlastPressure = 0
	NewExplosion.BlastRadius = 5
	NewExplosion.ExplosionType = "NoCraters"
	NewExplosion.Parent = game.Workspace.Debris
	NewExplosion.Position = Torso.Position
	NewExplosion.Visible = false
	
	local Gas = game.ReplicatedStorage.Assets.BloaterGas:Clone()
	Gas.Parent = Torso
	Gas.Enabled = true
	
	NewExplosion.Hit:Connect(function(HitPart, PartDistance)
		local HumanoidValue = HitPart.Parent:FindFirstChildOfClass('Humanoid')
		if HumanoidValue ~= nil then
			local PlayerValue = game.Players:GetPlayerFromCharacter(HitPart.Parent)
			if PlayerValue ~= nil then
				if PlayerValue.Team ~= InfectedTeam and HitOnce == false and HumanoidValue.Parent.Name ~= "Infected_AI" then
					HitOnce = true
					HumanoidValue:TakeDamage(65)
				end
			end
		end
	end)
	Torso:WaitForChild("Burst"):Play()
	wait(1)
	Gas.Enabled = false
end

Humanoid.Died:connect(OnDeath)