local ReplicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Face", script.Parent.Name)
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Sounds.Select:Play()
end)