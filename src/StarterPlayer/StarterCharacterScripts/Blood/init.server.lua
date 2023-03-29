local D = game.Workspace:GetDescendants()
for i = 1,#D do
	if D[i]:IsA("Humanoid") and not D[i].Parent:FindFirstChild("SparkParticle") then
		local Cloned = script.SparkParticle:Clone()
		Cloned.Parent = D[i].Parent
		Cloned.Disabled = false
	end
end
function Added(item)
	if item:IsA("Humanoid") and not item.Parent:FindFirstChild("SparkParticle") then
		local Cloned = script.SparkParticle:Clone()
		Cloned.Parent = item.Parent
		Cloned.Disabled = false
	end
end
game.Workspace.DescendantAdded:connect(Added)