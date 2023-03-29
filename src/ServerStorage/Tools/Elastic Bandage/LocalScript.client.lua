local Player = game.Players.LocalPlayer
repeat wait() until Player.Character
local Character = Player.Character
local Humanoid = Character:FindFirstChild("Humanoid")

local Animation = Humanoid:LoadAnimation(script.Animation)

local InUse = false

script.Parent.Activated:Connect(function()
	if InUse == false then
		InUse = true
		Animation:Play()
		script.Parent.Handle.Wrap:Play()
	end
end)

script.Parent.Unequipped:Connect(function()
	InUse = false
	Animation:Stop()
	script.Parent.Handle.Wrap:Stop()
end)

Animation:GetMarkerReachedSignal("Finish"):Connect(function(value)
	local Finish = Humanoid:LoadAnimation(script.Finish)
	Finish:Play()
end)