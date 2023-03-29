local target = script.Parent:WaitForChild("Target")
local torso = script.Parent.Parent:WaitForChild("Torso")
local down = script.Parent:WaitForChild("MouseDown")

function handler(new)
	if target.Value then
		while target.Value == new do
			if target.Value and target.Value.Parent == nil then
				target.Value = nil
				return
			end
			local look = (new.Torso.Position-torso.Position).unit * 300
			local hit = workspace:FindPartOnRayWithIgnoreList(Ray.new(torso.Position,look),{script.Parent.Parent,new.Parent})
			if not hit or (new.Torso.Position-torso.Position).magnitude < 10 then
				down:Fire(new.Torso.Position)
			end
			wait(0.2)
		end
	end
end

target.Changed:connect(handler)

if target.Value then
	handler(target.Value)
end