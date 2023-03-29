function onTouched(Part)
	local Humanoid = Part.Parent:FindFirstChild("Humanoid")
	if Humanoid ~= nil then
		if Humanoid.Parent.Name == "Infected_AI" then
			Humanoid.Health = Humanoid.Health-1000
		end
	end
end
script.Parent.Touched:connect(onTouched)