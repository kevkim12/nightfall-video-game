local face = script.Parent.Head.face
local clonedface = face:Clone()
clonedface.Parent = face.Parent
clonedface.Texture = ""
clonedface.Name = "Scars"

local humanoid = script.Parent:WaitForChild("Humanoid")
local humanoidHealth = humanoid.Health
humanoid.HealthChanged:Connect(function(newHealth)
    if newHealth < 50 then
        script.parent.Head.Scars.Texture = "rbxassetid://1591535988"
else
	script.parent.Head.Scars.Texture = ""
    end
    humanoidHealth = newHealth
end)