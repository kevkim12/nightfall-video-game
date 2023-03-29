local PlayerUsername = script.Parent.Parent.Parent.Name
local Power = 0
local Triggered = false

script.Parent.Equipped:connect(function(mouse)
	mouse.Button1Down:connect(function()
		Triggered = true
		game.ReplicatedStorage.Events.GrenadeTriggered:FireServer(PlayerUsername)
	while Power < 5 do
		Power = Power + 1
		--script.Parent.Name = 'Throw Power: '.. Power*10 ..'%'
		wait(.2)
	end
end)
	mouse.Button1Up:connect(function()
		game.ReplicatedStorage.Events.GrenadeThrow:FireServer(PlayerUsername, Power, "Success")
		script.Parent:Destroy()
		
	end)
end)

script.Parent.Unequipped:connect(function(mouse)
	if Triggered == true then
		game.ReplicatedStorage.Events.GrenadeThrow:FireServer(PlayerUsername, 0, "Fail")
	end
end)