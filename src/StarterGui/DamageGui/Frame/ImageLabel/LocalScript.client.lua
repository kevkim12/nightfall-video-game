repeat wait() until game:GetService("Players").LocalPlayer.Character ~= nil
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character
local humanoid = char:WaitForChild("Humanoid")
while wait() do
	script.Parent.ImageTransparency = humanoid.Health /humanoid.MaxHealth
end