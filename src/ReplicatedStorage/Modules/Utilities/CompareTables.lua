local function CompareTables(arr1, arr2)
	for i, v in pairs(arr1) do
		if (typeof(v) == "table") then
			if typeof(arr2[i]) == "table" then
				if (CompareTables(arr2[i], v) == false) then
					return false
				end
			else
				local matched = true
				for ii, vv in pairs(v) do
					if (vv ~= arr2[i]) then
						matched = false
						break
					end
				end
				if not matched then
					return false
				end
			end
		else
			if (v ~= arr2[i]) then
				return false
			end
		end
	end
	return true
end

return CompareTables