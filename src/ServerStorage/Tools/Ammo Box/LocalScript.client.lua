local Player = game.Players.LocalPlayer
repeat wait() until Player.Character
local Character = Player.Character
local Humanoid = Character:FindFirstChild("Humanoid")

local InUse = false

script.Parent.Activated:Connect(function()
	if InUse == false then
		InUse = true
		script.Parent.Handle.Use:Play()
	end
end)
