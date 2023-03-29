local SmokeTrail = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Modules = ReplicatedStorage:WaitForChild("Modules")

local Utilities = require(Modules.Utilities)
local Thread = Utilities.Thread

local Emitting = false
local ForceStop = false

function SmokeTrail:EmitSmokeTrail(Trail, MaxEmitTime)
	local StartTime = tick()
	while true do
		local DeltaTime = tick() - StartTime
		Emitting = true
		if ForceStop or DeltaTime >= MaxEmitTime then
			Emitting = false
			ForceStop = false
			break
		end
		Trail.Enabled = true
		Thread:Wait()
	end
	Emitting = false
	Trail.Enabled = false
end

function SmokeTrail:StopEmission()
	if Emitting == true then
		ForceStop = true
	end
end

return SmokeTrail