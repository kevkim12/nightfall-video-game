local module = {}

local Players = game:GetService("Players")

module.CanDamage = function(targetObj, taggerObj, friendlyFire)
	local humanoid = targetObj:FindFirstChildOfClass("Humanoid")
	if taggerObj and humanoid then
		if friendlyFire then
			return true
		else
			local player = Players:GetPlayerFromCharacter(taggerObj)
			local p = Players:GetPlayerFromCharacter(targetObj)
			if p and player then
				if p == player then
					return false
				else
					if p.Neutral or player.Neutral then
						return true
					elseif p.TeamColor ~= player.TeamColor then
						return true
					end
				end
			else
				local targetTEAM = targetObj:FindFirstChild("TEAM")
				local TEAM = taggerObj:FindFirstChild("TEAM")
				if TEAM and targetTEAM then
					if targetTEAM.Value ~= TEAM.Value then
						return true
					else
						return false
					end
				else
					return true					
				end
			end
		end
	end
	return false
end

return module