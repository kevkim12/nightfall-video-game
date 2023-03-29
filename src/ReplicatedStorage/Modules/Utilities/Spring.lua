local physics = {}

do
  	physics.spring = {}
  	do
    	local spring = {}
    	physics.spring = spring
		local e = 2.718281828459045
    	function spring.new(init)
      		local null = 0 * (init or 0)
      		local d = 1
      		local s = 1
      		local p0 = init or null
      		local v0 = null
      		local p1 = init or null
      		local t0 = os.clock()
      		local h = 0
      		local c1 = null
      		local c2 = null
      		local self = {}
      		local meta = {}
      		local function UpdateConstants()
        		if s == 0 then
          			h = 0
          			c1 = null
          			c2 = null
        		elseif d < 0.99999999 then
          			h = (1 - d * d) ^ 0.5
          			c1 = p0 - p1
          			c2 = d / h * c1 + v0 / (h * s)
        		elseif d < 1.00000001 then
          			h = 0
          			c1 = p0 - p1
          			c2 = c1 + v0 / s
        		else
         			h = (d * d - 1) ^ 0.5
          			local a = -v0 / (2 * s * h)
          			local b = -(p1 - p0) / 2
          			c1 = (1 - d / h) * b + a
          			c2 = (1 + d / h) * b - a
        		end
      		end
      		local function Pos(x)
        		if x < 0.001 then
          			return p0
        		end
        		if s == 0 then
          			return p0
        		elseif d < 0.99999999 then
          			local co = math.cos(h * s * x)
          			local si = math.sin(h * s * x)
          			local ex = e ^ (d * s * x)
          			return co / ex * c1 + si / ex * c2 + p1
        		elseif d < 1.00000001 then
          			local ex = e ^ (s * x)
          			return (c1 + s * x * c2) / ex + p1
        		else
         			local co = e ^ ((-d - h) * s * x)
          			local si = e ^ ((-d + h) * s * x)
          			return c1 * co + c2 * si + p1
        		end
      		end
      		local function Vel(x)
        		if x < 0.001 then
          			return v0
       			end
        		if s == 0 then
          			return p0
        		elseif d < 0.99999999 then
          			local co = math.cos(h * s * x)
          			local si = math.sin(h * s * x)
          			local ex = e ^ (d * s * x)
          			return s * (co * h - d * si) / ex * c2 - s * (co * d + h * si) / ex * c1
        		elseif d < 1.00000001 then
          			local ex = e ^ (s * x)
          			return -s / ex * (c1 + (s * x - 1) * c2)
        		else
          			local co = e ^ ((-d - h) * s * x)
          			local si = e ^ ((-d + h) * s * x)
          			return si * (h - d) * s * c2 - co * (d + h) * s * c1
        		end
      		end
      		local function PosVel(x)
        		if s == 0 then
          			return p0
        		elseif d < 0.99999999 then
          			local co = math.cos(h * s * x)
          			local si = math.sin(h * s * x)
          			local ex = e ^ (d * s * x)
          			return co / ex * c1 + si / ex * c2 + p1, s * (co * h - d * si) / ex * c2 - s * (co * d + h * si) / ex * c1
        		elseif d < 1.00000001 then
          			local ex = e ^ (s * x)
          			return (c1 + s * x * c2) / ex + p1, -s / ex * (c1 + (s * x - 1) * c2)
        		else
          			local co = e ^ ((-d - h) * s * x)
          			local si = e ^ ((-d + h) * s * x)
          			return c1 * co + c2 * si + p1, si * (h - d) * s * c2 - co * (d + h) * s * c1
        		end
      		end
			UpdateConstants()
      		function self.GetPosVel()
				return PosVel(os.clock() - t0)
      		end
      		function self.SetPosVel(p, v)
        		local time = os.clock()
        		p0, v0 = p, v
        		t0 = time
				UpdateConstants()
      		end
      		function self:Accelerate(a)
        		local time = os.clock()
				local p, v = PosVel(time - t0)
        		p0, v0 = p, v + a
        		t0 = time
				UpdateConstants()
      		end
      		function meta:__index(index)
        		local time = os.clock()
        		if index == "p" then
					return Pos(time - t0)
        		elseif index == "v" then
					return Vel(time - t0)
        		elseif index == "t" then
          			return p1
        		elseif index == "d" then
          			return d
        		elseif index == "s" then
          			return s
        		end
      		end
      		function meta:__newindex(index, value)
        		local time = os.clock()
        		if index == "p" then
					p0, v0 = value, Vel(time - t0)
        		elseif index == "v" then
					p0, v0 = Pos(time - t0), value
        		elseif index == "t" then
					p0, v0 = PosVel(time - t0)
          			p1 = value
        		elseif index == "d" then
          			if value == nil then
            			warn("nil value for d")
            			warn(debug.stacktrace())
            			value = d
          			end
					p0, v0 = PosVel(time - t0)
          			d = value
        		elseif index == "s" then
          			if value == nil then
            			warn("nil value for s")
            			warn(debug.stacktrace())
            			value = s
          			end
					p0, v0 = PosVel(time - t0)
          			s = value
        		elseif index == "a" then
					local p, v = PosVel(time - t0)
          			p0, v0 = p, v + value
        		end
        		t0 = time
				UpdateConstants()
      		end
			return setmetatable(self, meta)
    	end
	end
end

return physics