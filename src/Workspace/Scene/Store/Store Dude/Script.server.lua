local AnimationId = 7018811814

local Animation = Instance.new("Animation")
Animation.AnimationId = ("rbxassetid://%d"):format(AnimationId)
local AnimationTrack = script.Parent.Humanoid:LoadAnimation(Animation)
AnimationTrack.Looped = true
AnimationTrack:Play()