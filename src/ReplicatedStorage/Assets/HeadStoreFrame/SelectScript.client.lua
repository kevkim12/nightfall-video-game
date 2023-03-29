local ReplicatedStorage = game:GetService("ReplicatedStorage")

script.Parent.MouseButton1Click:Connect(function()
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Values.SelectionType.Value = script.Parent.ProductType.Value
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Values.ForPurchase.Value = script.Parent.ProductName.Value
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Sounds.Select:Play()
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Frame.Windows.Store.Purchase.Visible = true
end)