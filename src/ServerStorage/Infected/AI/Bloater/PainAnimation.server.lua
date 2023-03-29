local Humanoid = script.Parent.Humanoid
local Animation = Instance.new('Animation')
Animation.AnimationId = 'rbxassetid://10564742360'

local AnimationMode = 1

repeat wait() until Humanoid:IsDescendantOf(workspace)
local AnimationTrack = Humanoid:LoadAnimation(Animation)

local LastKnownHealth
Humanoid.HealthChanged:Connect(function(Health)
	if LastKnownHealth then
		if LastKnownHealth > Health then
			AnimationTrack:Play()
		end
	end
	LastKnownHealth = Health
end)