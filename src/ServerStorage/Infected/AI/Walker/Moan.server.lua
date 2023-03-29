local Sounds = {1158093628, 1158093080, 1158093410, 1158093834, 1158093243}
local Humanoid = script.Parent:WaitForChild("Humanoid")
local Moan = script.Parent:WaitForChild("Head").Moan
local WaitTime = 15

while Humanoid.Health > 0 do
	local Condition = math.random(1, 4)
	if Condition == 1 then
		WaitTime = 5
	elseif Condition == 2 then
		WaitTime = 10
	elseif Condition == 3 then
		WaitTime = 15
	else
		WaitTime = 20
	end
	wait(WaitTime)
	local Selection = math.random(1, #Sounds)
	local ID = Sounds[Selection]
	Moan.SoundId = "rbxassetid://" .. ID
	Moan:Play()
end