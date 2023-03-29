local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Type
local Check = true

script.Parent.MouseButton1Click:Connect(function()
	if Check == true then
		local PrimaryContent = ReplicatedStorage.EquipmentData.Primary:GetChildren()
		local SecondaryContent = ReplicatedStorage.EquipmentData.Secondary:GetChildren()
		local ItemContent = ReplicatedStorage.EquipmentData.Item:GetChildren()
		for i = 1, #PrimaryContent do
			if PrimaryContent[i].Name == script.Parent.Name then
				Type = "Primary"
				Check = false
			end
		end
		if Check == true then
			for i = 1, #SecondaryContent do
				if SecondaryContent[i].Name == script.Parent.Name then
					Type = "Secondary"
					Check = false
				end
			end
		end
		if Check == true then
			for i = 1, #ItemContent do
				if ItemContent[i].Name == script.Parent.Name then
					Type = "Item"
					Check = false
				end
			end
		end
	end
	
	ReplicatedStorage.Events.DataSelection:FireServer(Type, script.Parent.Name)
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Sounds.Equip:Play()
end)