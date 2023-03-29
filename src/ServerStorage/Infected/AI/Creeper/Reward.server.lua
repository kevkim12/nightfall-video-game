local Humanoid = script.Parent.Humanoid
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Class = script.Parent.Class

function Reward()
	local Tag = Humanoid:findFirstChild("creator") 
	if Tag ~= nil then 
		if Tag.Value ~= nil then
			ReplicatedStorage.Events.RequestReward:Fire("Kill", Tag.Value, Class.Value)
		end
	end 
end 
Humanoid.Died:connect(Reward) 