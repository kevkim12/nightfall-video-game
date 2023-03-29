local Humanoid = script.Parent.Humanoid

local youranimation = Instance.new('Animation')
youranimation.AnimationId = 'rbxassetid://04595390905' -- please note that other users cannot load your animations, so there is no need to hide it.

repeat wait() until Humanoid:IsDescendantOf(workspace)
local AnimationTrack = Humanoid:LoadAnimation(youranimation)
AnimationTrack.Priority = Enum.AnimationPriority.Action

local LastKnownHealth
game:GetService('RunService').RenderStepped:Connect(function()
	if LastKnownHealth then
		if LastKnownHealth > Humanoid.Health then
			print('Playing')
			AnimationTrack:Play()
		end
	end
	
	LastKnownHealth = Humanoid.Health
end)