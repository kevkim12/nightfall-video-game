local AnimationId = 6929628435

wait(.5)

local Animation = Instance.new("Animation")
Animation.AnimationId = ("rbxassetid://%d"):format(AnimationId)
local AnimationTrack = script.Parent.Humanoid:LoadAnimation(Animation)
AnimationTrack.Looped = true
AnimationTrack:Play()