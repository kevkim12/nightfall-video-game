local Tool = script.Parent
local InUse = false

local function onUnequip()
	InUse = false
end

local function onActivate()
	if InUse == false then
		InUse = true
		wait(1.8)
		if InUse == true then
			local vCharacter = Tool.Parent
			local childs = vCharacter:GetChildren()
			local human = vCharacter:FindFirstChild("Humanoid")
			if (human ~= nil) then
				human.Health = human.Health + 30
			end
			Tool:Destroy()
		end
	end
end


Tool.Unequipped:Connect(onUnequip)
Tool.Activated:Connect(onActivate)
