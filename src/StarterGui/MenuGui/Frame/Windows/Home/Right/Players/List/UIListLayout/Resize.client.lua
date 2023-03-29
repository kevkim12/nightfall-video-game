script.Parent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	local absoluteSize = script.Parent.AbsoluteContentSize
	script.Parent.Parent.CanvasSize = UDim2.new(0, absoluteSize.X, 0, absoluteSize.Y)
end)