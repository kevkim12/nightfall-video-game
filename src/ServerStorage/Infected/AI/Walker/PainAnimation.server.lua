local Humanoid = script.Parent.Humanoid
local Animation = Instance.new('Animation')
Animation.AnimationId = 'rbxassetid://10564650574'

local AnimationMode = 1

repeat wait() until Humanoid:IsDescendantOf(workspace)
local AnimationTrack = Humanoid:LoadAnimation(Animation)

local LastKnownHealth
Humanoid.HealthChanged:Connect(function(Health)
	if LastKnownHealth then
		if LastKnownHealth > Health then
			if AnimationMode == 1 then
				AnimationMode = 0
				Animation.AnimationId = 'rbxassetid://10564650574'
			elseif AnimationMode == 0 then
				AnimationMode = 1
				Animation.AnimationId = 'rbxassetid://10564658207'
			end
			AnimationTrack:Play()
		end
	end
	LastKnownHealth = Health
end)