local ConstantModule = require(game:GetService("ServerStorage").Modules:WaitForChild("ConstantModule"))
local ConstantValue = script:WaitForChild("ConstantValue")

local Constant

for _,Constants in pairs(ConstantModule) do
	if Constants.ConstantName == ConstantValue.Value then
		Constant = Constants
	end
end

local TargetChar = script.Parent
local DisableWeapon = Instance.new("BoolValue")
DisableWeapon.Name = ("DisableWeapon")
DisableWeapon.Value = false
DisableWeapon.Parent = script

function Cleanup()
	if Billboard ~= nil then
		Billboard:Destroy()
	end
	if Constant.ConstantParticleRoute ~= nil then
		for _,V in pairs(script.Parent:GetChildren()) do
			if V:IsA("Part") or V:IsA("WedgePart") or V:IsA("CornerWedgePart") or V:IsA("UnionOperation") then
				
				for _,PE in pairs(V:GetChildren()) do
					if PE.Name == Constant.ConstantParticleRoute.Name then
						PE.Enabled = false
						delay(PE.Lifetime.Max,function()
							PE:Destroy()
						end)
					end
				end
				
			end
		end
	end
	DisableWeapon:Destroy()
	script:Destroy()
end

TargetChar.ChildRemoved:Connect(function(child)
	if child == script then DisableWeapon:Destroy() end
end)

if Constant ~= nil then
	delay(Constant.Lifetime,function() Cleanup() end)
	
	if Constant.CustomBillboardRoute ~= nil then
		Billboard = Constant.CustomBillboardRoute:Clone()
		Billboard.Parent = script.Parent:FindFirstChild("Head")
		Billboard.Enabled = true
	end
	
	if script:FindFirstChild("DisablePE") == nil and Constant.ConstantParticleRoute ~= nil then
		for _,Part in pairs(script.Parent:GetChildren()) do
			if Part:IsA("Part") or Part:IsA("WedgePart") or Part:IsA("CornerWedgePart") or Part:IsA("UnionOperation") then
				Particle = Constant.ConstantParticleRoute:Clone()
				Particle.Parent = Part
				Particle.Enabled = true
			end
		end
	end
	
	if Constant.EnableAdditionalEffectsFunc == true then
		Constant.AdditionalEffectsFunc(script.Parent, {WeaponStun = DisableWeapon})
	end
	
	while wait(Constant.Frequency) do
		if tonumber(Constant.Damage) ~= nil and script.Parent:FindFirstChild("Humanoid") then
			script.Parent.Humanoid:TakeDamage(Constant.Damage)
			if script:FindFirstChild("DisableTags") == nil then
				game:GetService("ReplicatedStorage").Events:FindFirstChild("VisualiseIndicators"):FireAllClients(script.Parent,Constant.Damage)
			end
		end
		if Constant.EnableAdditionalEffectsFunc == true and Constant.OneTime == false then
			Constant.AdditionalEffectsFunc(script.Parent, {WeaponStun = DisableWeapon})
		end
	end
else
	warn("CONSTANT NOT FOUND!")
end
