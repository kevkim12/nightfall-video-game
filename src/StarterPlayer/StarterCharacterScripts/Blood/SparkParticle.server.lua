Current = script.Parent:FindFirstChildWhichIsA("Humanoid").Health
function HealthChanged(Remaining)
	if Remaining < Current then
		local C = script.Parent:GetDescendants()
		for i = 1,#C do
			if C[i]:IsA("Part") or C[i]:IsA("MeshPart") or C[i]:IsA("UnionOperation") or C[i]:IsA("WedgePart") or C[i]:IsA("Seat") or C[i]:IsA("VehicleSeat") or C[i]:IsA("CornerWedgePart") or C[i]:IsA("TrussPart") then
				local Clone = script.ThisHurts:Clone()
				Clone.Parent = C[i]
				local EmitValue = Current - Remaining
				if EmitValue > 16 then
					EmitValue = 16
				end
				Clone:Emit(EmitValue)
				game.Debris:AddItem(Clone)
			end
		end
	end
	Current = Remaining
end
script.Parent:FindFirstChildWhichIsA("Humanoid").HealthChanged:connect(HealthChanged)