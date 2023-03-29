--Character

local RunService = game:GetService("RunService")
 
local playerModel = script.Parent
local humanoid = playerModel:WaitForChild("Humanoid")
 
local function updateBobbleEffect()
	local now = tick()
	if humanoid.MoveDirection.Magnitude > 0 then -- Are we walking?
		local velocity = humanoid.RootPart.Velocity
		local bobble_X = math.cos(now * 9) / 5
		local bobble_Y = math.abs(math.sin(now * 12)) / 5
		
		local bobble = Vector3.new(bobble_X,bobble_Y,0) * math.min(1, velocity.Magnitude / humanoid.WalkSpeed)
		humanoid.CameraOffset = humanoid.CameraOffset:lerp(bobble,.25)
	else
		-- Scale down the CameraOffset so that it shifts back to its regular position.
		humanoid.CameraOffset = humanoid.CameraOffset * 0.75
	end
end
 
-- Update the effect on every single frame.
RunService.RenderStepped:Connect(updateBobbleEffect)