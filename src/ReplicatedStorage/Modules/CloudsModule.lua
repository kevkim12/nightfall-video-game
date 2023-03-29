-- https://devforum.roblox.com/t/volumetric-clouds-phase-2/1230617

local CloudModule = {}
local RunService = game:GetService("RunService")

local CloudClass = {
	Tallness = 40;
	Offset = 0;
	Density = 0.2;
	Speed = 5;
	Height = 534;
	Size = 3.572;
	ShadowCast = true;
	CloudType = "Cumulus";
}

function CloudClass:new(attributes)

	local newCloudClass = {}

	attributes = attributes or {}

	newCloudClass.Tallness = attributes.Tallness or nil
	newCloudClass.Offset = attributes.Offset or nil
	newCloudClass.Density = attributes.Density or nil
	newCloudClass.Speed = attributes.Speed or nil
	newCloudClass.Height = attributes.Height or nil
	newCloudClass.Size = attributes.Size or nil
	newCloudClass.ShadowCast = attributes.ShadowCast or nil
	newCloudClass.CloudType = attributes.CloudType or nil

	self.__index = self

	setmetatable(newCloudClass, self)

	function newCloudClass:new(newAttributes)

		local newCloud = {}

		newAttributes = newAttributes or {}

		newCloud.Class = self

		newCloud.Tallness = newAttributes.Tallness or nil
		newCloud.Offset = newAttributes.Offset or nil
		newCloud.Density = newAttributes.Density or nil
		newCloud.Speed = newAttributes.Speed or nil
		newCloud.Height = newAttributes.Height or nil
		newCloud.Size = newAttributes.Size or nil
		newCloud.ShadowCast = newAttributes.ShadowCast or nil
		newCloud.CloudType = newAttributes.CloudType or nil

		-- METHODS

		function newCloud:SpawnClouds()

			spawn(function()
				
				if newCloud.CloudType == "Cumulus" then
					
					local lastCloud = script:WaitForChild("CumulusCloud")
					local DarknessVal = 100
					local RealRandom = Random.new()
					lastCloud.Position = Vector3.new(
						392.629,
						newCloud.Height, 
						-405.891
					)

					for i = 1, newCloud.Tallness do

						local cl = lastCloud:Clone()
						local ran1, ran2 = math.random(-newCloud.Offset,newCloud.Offset), math.random(-newCloud.Offset,newCloud.Offset)
						cl.Parent = workspace.Clouds
						
						cl.Position = cl.Position + Vector3.new(ran1, 5, ran2)
						cl.Texture1.Transparency = (1 - newCloud.Density)
						cl.Texture2.Transparency = (1 - newCloud.Density)
						cl.Texture1.Color3 = Color3.fromRGB(DarknessVal,DarknessVal,DarknessVal)
						cl.Texture2.Color3 = Color3.fromRGB(DarknessVal,DarknessVal,DarknessVal)
						if newCloud.ShadowCast == true then
							
							cl.CastShadow = true
							
						else
							
							cl.CastShadow = false
							
						end
						if newCloud.Size == 3.572 then

							cl.Size = Vector3.new(
								RealRandom:NextNumber(2.9,3),
								0.143,
								RealRandom:NextNumber(2.9,3)
							)

						else

							cl.Size = Vector3.new(
								RealRandom:NextNumber(2.9,newCloud.Size),
								0.143,
								RealRandom:NextNumber(2.9,newCloud.Size)
							)

						end

						DarknessVal += 10
						lastCloud = cl

						RunService.Heartbeat:Connect(function()

							cl.CFrame = cl.CFrame * CFrame.new(0, 0, (newCloud.Speed / 10))

						end)

					end
					
				end
				
				if newCloud.CloudType == "Stratus" then

					local lastCloud = script:WaitForChild("StratusCloud")
					local DarknessVal = 100
					local RealRandom = Random.new()
					lastCloud.Position = Vector3.new(
						392.629,
						newCloud.Height, 
						-405.891
					)
					
					for i = 1, newCloud.Tallness do

						local cl = lastCloud:Clone()
						local ran1, ran2 = math.random(-newCloud.Offset,newCloud.Offset), math.random(-newCloud.Offset,newCloud.Offset)
						cl.Parent = workspace.Clouds
						
						cl.Position = cl.Position + Vector3.new(ran1, 5, ran2)
						cl.Texture1.Transparency = (1 - newCloud.Density)
						cl.Texture2.Transparency = (1 - newCloud.Density)
						cl.Texture1.Color3 = Color3.fromRGB(DarknessVal,DarknessVal,DarknessVal)
						cl.Texture2.Color3 = Color3.fromRGB(DarknessVal,DarknessVal,DarknessVal)
						if newCloud.ShadowCast == true then

							cl.CastShadow = true

						else

							cl.CastShadow = false

						end
						if newCloud.Size == 3.572 then

							cl.Size = Vector3.new(
								RealRandom:NextNumber(2.9,3),
								0.143,
								RealRandom:NextNumber(2.9,3)
							)

						else

							cl.Size = Vector3.new(
								RealRandom:NextNumber(2.9,newCloud.Size),
								0.143,
								RealRandom:NextNumber(2.9,newCloud.Size)
							)

						end

						DarknessVal += 10
						lastCloud = cl

						RunService.Heartbeat:Connect(function()

							cl.CFrame = cl.CFrame * CFrame.new(0, 0, (newCloud.Speed / 10))

						end)

					end

				end

			end)

		end

		-- FUNCTION

		newCloud:SpawnClouds()

	end

	return newCloudClass

end

CloudModule.Clouds = CloudClass:new();

return CloudModule