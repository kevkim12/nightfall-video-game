local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local PlayerName = script.Parent.Name
local ID
local MaleScreams = {232921590, 232921580, 232921573, 166221318, 167094166, 166221285, 166221367, 169907033, 166221396}
local FemaleScreams = {5538537294, 5538539107, 5538544605, 5538540460, 5538546663, 5538547181}


if Players[PlayerName]:WaitForChild("leaderstats").Character.Gender.Value == "Male" then
	ID = MaleScreams[math.random(1,#MaleScreams)]
elseif Players[PlayerName]:WaitForChild("leaderstats").Character.Gender.Value == "Female" then
	ID = FemaleScreams[math.random(1,#FemaleScreams)]
end

local hum = nil
local sound = "rbxassetid://"..ID

repeat
	wait()
	hum = script.Parent:FindFirstChild("Humanoid")
until hum ~= nil

hum.Died:connect(function()
	local sd = Instance.new("Sound")
	sd.Parent = hum.Parent.Head
	sd.SoundId = sound
	sd.Volume = 2
	sd:Play()
end)

