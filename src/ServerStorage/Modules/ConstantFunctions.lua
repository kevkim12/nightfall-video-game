-- ConstantFunctions

local CoF = {}

function CoF:ToggleDisableWeapon(Target, bool)
	local CST = {}
	for _, scriptF in pairs(Target:GetChildren()) do
		if scriptF.Name == ("ConstantScript") then
			table.insert(CST, scriptF)
		end
	end
	for _, CS in pairs(CST) do
		if CS:FindFirstChild("DisableWeapon") then CS.DisableWeapon.Value = bool end
	end
end

return CoF