local ReplicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseEnter:Connect(function()
	script.Parent.ImageLabel.ImageColor3 = Color3.new(1, 1, 1)
end)

script.Parent.MouseLeave:Connect(function()
	script.Parent.ImageLabel.ImageColor3 = Color3.new(190/255, 190/255, 190/255)
end)

script.Parent.MouseButton1Click:Connect(function()
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Values.SelectionType.Value = script.Parent.ProductType.Value
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Values.ForPurchase.Value = script.Parent.ProductName.Value
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Sounds.Select:Play()
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Frame.Windows.Store.Purchase.Visible = true
end)