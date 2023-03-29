local physics = {}

	local tick = tick
	local setmt	= setmetatable
	local sin = math.sin
	local cos = math.cos
	local atan2	= math.atan2
	local tan = math.tan
	local e = 2.718281828459045
	
	physics.spring = {}
	
	function physics.spring.new(data)
		local c0,c1
		local t0
		local d,s
		local target
		local cd
		if data then
			c0,c1=0,0
			t0=os.clock()
			d,s=data.d,data.s
			target=0
			cd=0
		else
			c0,c1=0,0
			t0=os.clock()
			d,s=1,1
			target=0
			cd=0
		end
		
		local function position()
			local t=os.clock()
			local sx=s*(t-t0)
			if d==1 then
				return (c0+c1*sx)/e^sx+target
			else
				return (c0*cos(cd*sx)+c1*sin(cd*sx))/e^(d*sx)+target
			end
		end
		
		local function velocity()
			local t=os.clock()
			local sx=s*(t-t0)
			if d==1 then
				return (c1*(s-sx)-c0)/e^sx
			else
				return s*((cd*c1-c0*d)*cos(cd*sx)-(cd*c0+c1*d)*sin(cd*sx))/e^(d*sx)
			end
		end
		
		return {
			target=function(newtarget,newd,news)
				news=news or s
				local p0,v0=position(),velocity()/news
				d=newd or d
				t0=os.clock()
				target=newtarget
				c0=p0-target
				if d==1 then
					c1=v0+c0
				else
					cd=(1-d*d)^0.5
					c1=(v0+c0*d)/cd
				end
				s=news
			end;
			
			impulse=function(v)
				local p0,v0=position(),(velocity()+v)/s
				t0=os.clock()
				c0=p0-target
				if d==1 then
					c1=v0+c0
				else
					cd=(1-d*d)^0.5
					c1=(v0+c0*d)/cd
				end
			end;
			p=position;
			v=velocity;
		}
	end
	
	function physics.trajectory(sx,sy,sz,v,px,py,pz)
		local g=9.81*40
		local dx,dy,dz=px-sx,py-sy,pz-sz
		local d=(dx*dx+dz*dz)^0.5
		local th=atan2(v*v-(v*v*v*v-g*(g*d*d+2*dy*v*v))^0.5,g*d)
		return px,sy+d*tan(th),pz
	end

return physics
