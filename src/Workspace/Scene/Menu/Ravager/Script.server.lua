local AnimationId = 10575723792

local Animation = Instance.new("Animation")
Animation.AnimationId = ("rbxassetid://%d"):format(AnimationId)
local AnimationTrack = script.Parent.Humanoid:LoadAnimation(Animation)
AnimationTrack.Looped = true
AnimationTrack:Play()