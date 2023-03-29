local ScrollingFrame = script.Parent


ScrollingFrame.ChildAdded:Connect(function(child)
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollingFrame.UIGridLayout.AbsoluteContentSize.Y)
	ScrollingFrame.CanvasPosition = Vector2.new(0, ScrollingFrame.CanvasSize.Y.Offset)
end)

