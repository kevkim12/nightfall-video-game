local GF = {}

function GF:AddressTableValue(Value)
	if Value ~= nil and Value[1] ~= nil then
		if tonumber(Value[1]) ~= nil and tonumber(Value[2]) ~= nil then
			return Random.new():NextNumber(Value[1],Value[2])
		elseif tonumber(Value[2]) == nil then
			return Value[1]
		end
	end
end

function GF:FindDisableWeapon(Tool)
	local CST = {}
	local CSTReturning = false
	for _, scriptF in pairs(Tool.Parent:GetChildren()) do
		if scriptF.Name == ("ConstantScript") then
			table.insert(CST, scriptF)
		end
	end
	for _, CS in pairs(CST) do
		if CS:FindFirstChild("DisableWeapon") and CS.DisableWeapon.Value == true then CSTReturning = true; break end
	end
	return CSTReturning
end


return GF
