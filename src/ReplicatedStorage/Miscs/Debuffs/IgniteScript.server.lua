local Humanoid = script.Parent:FindFirstChild("Humanoid")
local Head = script.Parent:FindFirstChild("Head")
local Fires = {}
local FireDamagePerSecond = 5

if Humanoid and Head then
	BurnSound = Instance.new("Sound")
	BurnSound.Name = "BurnSound"
	BurnSound.SoundId = "http://www.roblox.com/asset/?id=32791565"
	BurnSound.Parent = Head
	BurnSound.Volume = 1
	game.Debris:AddItem(BurnSound, 10)
	task.delay(0, function()
		BurnSound:Play()
	end)
	for _, part in pairs(script.Parent:GetChildren()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
	        local C = script.FireEffect:GetChildren()
	        for i=1,#C do
		        if C[i].className == "ParticleEmitter" then
			        local Particle = C[i]:Clone()
			        table.insert(Fires, Particle)
					Particle.Parent = part
			        delay(0.01, function()
			        	Particle.Enabled = true
		            end)
		        end
	        end		
		end
	end
	while script.Duration.Value > 0 do
		task.wait(0.1)
		script.Duration.Value = script.Duration.Value - 0.1
		while Humanoid:FindFirstChild("creator") do
			Humanoid.creator:Destroy()
		end
		local Tag = script.creator:clone()
		Tag.Parent = Humanoid
		game.Debris:AddItem(Tag, 5)
		Humanoid:TakeDamage(FireDamagePerSecond * 0.1)
	end
	for _, Fire in pairs(Fires) do
		Fire.Enabled = false
	end
	task.wait(5)
	for _, Fire in pairs(Fires) do
		Fire:Destroy()
	end
end
task.wait()
script:remove()
