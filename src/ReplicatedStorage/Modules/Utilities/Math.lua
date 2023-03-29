local Math = {}

local function ToQuaternion(c)
	local x, y, z,
	xx, yx, zx,
	xy, yy, zy,
	xz, yz, zz = CFrame.new().components(c)
	local tr = xx + yy + zz
	if tr > 2.99999 then
		return x, y, z, 0, 0, 0, 1
	elseif tr > -0.99999 then
		local m = 2 * (tr + 1) ^ 0.5
		return x, y, z,
			(yz - zy) / m,
			(zx - xz) / m,
			(xy - yx) / m,
			m / 4
	else
		local qx = xx + yx + zx + 1
		local qy = xy + yy + zy + 1
		local qz = xz + yz + zz + 1
		local m	= (qx * qx + qy * qy + qz * qz) ^ 0.5
		return x, y, z, qx / m, qy / m, qz / m, 0
	end
end

function Math.Randomize(value)
	return (0.5 - math.random()) * 2 * value
end

function Math.Randomize2(min, max, accuracy)
	local inverse = 1 / (accuracy or 1)
	return (math.random(min * inverse, max * inverse) / inverse)
end

function Math.Lerp(a, b, t)
	return a + (b - a) * t
end

function Math.ToQuaternion(c)
	ToQuaternion(c)
end

function Math.Interpolator(c0, c1)
	if c1 then
		local x0, y0, z0, qx0, qy0, qz0, qw0 = ToQuaternion(c0)
		local x1, y1, z1, qx1, qy1, qz1, qw1 = ToQuaternion(c1)
		local x, y, z = x1 - x0, y1 - y0, z1 - z0
		local c = qx0 * qx1 + qy0 * qy1 + qz0 * qz1 + qw0 * qw1
		if c < 0 then
			qx0, qy0, qz0, qw0 = -qx0, -qy0, -qz0, -qw0
		end
		if c < 0.9999 then
			local s = (1 - c * c) ^ 0.5
			local th = math.acos(c)
			return function(t)
				local s0 = math.sin(th * (1 - t)) / s
				local s1 = math.sin(th * t) / s
				return CFrame.new(
					x0 + t * x,
					y0 + t * y,
					z0 + t * z,
					s0 * qx0 + s1 * qx1,
					s0 * qy0 + s1 * qy1,
					s0 * qz0 + s1 * qz1,
					s0 * qw0 + s1 * qw1
				)
			end
		else
			return function(t)
				return CFrame.new(x0 + t * x, y0 + t * y, z0 + t * z, qx1, qy1, qz1, qw1)
			end
		end
	else
		local x, y, z, qx, qy, qz, qw = ToQuaternion(c0)
		if qw < 0.9999 then
			local s = (1 - qw * qw) ^ 0.5
			local th = math.acos(qw)
			return function(t)
				local s1 = math.sin(th * t) / s
				return CFrame.new(
					t * x,
					t * y,
					t * z,
					s1 * qx,
					s1 * qy,
					s1 * qz,
					math.sin(th * (1 - t)) / s + s1 * qw
				)
			end
		else
			return function(t)
				return CFrame.new(t * x, t * y, t * z, qx, qy, qz, qw)
			end
		end
	end
end

function Math.FromAxisAngle(x, y, z)
	if not y then
		x, y, z = x.X, x.Y, x.Z
	end
	local m = (x * x + y * y + z * z) ^ 0.5
	if m > 1e-5 then
		local si = math.sin(m / 2) / m
		return CFrame.new(0, 0, 0, si * x, si * y, si * z, math.cos(m / 2))
	else
		return CFrame.new()
	end
end

return Math
