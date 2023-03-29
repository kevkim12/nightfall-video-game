return setmetatable({}, {
	__index = function(p1, p2)
		return require(script[p2])
	end
})
