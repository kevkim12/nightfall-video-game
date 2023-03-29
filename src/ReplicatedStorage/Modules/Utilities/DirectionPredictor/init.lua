local CardanoFerrari = require(script.CardanoFerrari)

local function solve(source, target, startVel, targetVel, bulletAccel, targetAccel, bulletSpeed)	
	local deltaPos = target - source
	local deltaVel = targetVel - startVel
	local deltaAccel = targetAccel - bulletAccel

	local impacts = {}

	if deltaAccel == Vector3.new(0, 0, 0) then
		local a = deltaVel:Dot(deltaVel) - bulletSpeed * bulletSpeed
		local b = 2 * deltaVel:Dot(deltaPos)
		local c = deltaPos:Dot(deltaPos)

		impacts = CardanoFerrari.solveQuadric(a, b, c)
	else
		local a = deltaAccel:Dot(deltaAccel) / 4
		local b = deltaAccel:Dot(deltaVel)
		local c = deltaAccel:Dot(deltaPos) + deltaVel:Dot(deltaVel) - bulletSpeed * bulletSpeed
		local d = 2 * deltaVel:Dot(deltaPos)
		local e = deltaPos:Dot(deltaPos)

		impacts = CardanoFerrari.solveQuartic(a, b, c, d, e)
	end

	if impacts ~= nil then
		local sol
		for _, v in impacts do
			if v > 0 then
				sol = v
				break
			end
		end
		if sol then
			local offsetHit = deltaPos + deltaVel * sol + (0.5 * targetAccel) * sol * sol
			local impactLocation = source + offsetHit
			local velocity = offsetHit / sol - (0.5 * bulletAccel) * sol
			return impactLocation, velocity
		end
	end
	return nil, nil
end

return solve