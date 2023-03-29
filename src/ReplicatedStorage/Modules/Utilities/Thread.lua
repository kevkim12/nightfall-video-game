local RunService = game:GetService("RunService")
local Timer = require(script.Parent.Timer)

local Thread = {}

--[[
function Thread:Wait(t)
	if t ~= nil then
		local TotalTime = 0
		TotalTime = TotalTime + RunService.Heartbeat:Wait()
		while TotalTime < t do
			TotalTime = TotalTime + RunService.Heartbeat:Wait()
		end
	else
		RunService.Heartbeat:Wait()
	end
end

function Thread:Spawn(callback)
	coroutine.resume(coroutine.create(callback))
end

function Thread:Delay(t, callback)
	local timer = Timer.new()
	timer:SetActive(true)
	timer:FireOnTimeReached(t, function()
		self:Spawn(callback)
		timer:Destroy()
	end)
end
]]

function Thread:Wait(t)
	if t ~= nil then
		task.wait(t)
	else
		task.wait()
	end
end

function Thread:Spawn(callback)
	task.spawn(callback)
end

function Thread:Delay(t, callback)
	task.delay(t, callback)
end

return Thread