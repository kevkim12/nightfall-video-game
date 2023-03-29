local part = script.Parent
local debounce = false

local density = .7
local friction = 100
local elasticity = 0
local frictionWeight = 100
local elasticityWeight = 0

-- Construct new PhysicalProperties and set

part.Touched:Connect(function()
	if part.Parent.Name ~= script.Parent.User.Value and debounce == false then
		debounce = true
		local physProperties = PhysicalProperties.new(density, friction, elasticity, frictionWeight, elasticityWeight)
		part.CustomPhysicalProperties = physProperties
	end
end)
