local Player = game:GetService("Players").LocalPlayer
local Camera = workspace.CurrentCamera
local ScreenshakeEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ScreenshakeEvent")
local CameraModule = require(script:WaitForChild"CameraModule")

ScreenshakeEvent.OnClientEvent:connect(function(Length,Intensity,Type)
	print"SC"
	if Type == 1 then -- FE Melee Kit Standard
		print"SC1"
		if Length and Intensity then
			print"SC1 PLAY"
			for i = 1,Length do
				local RandValue = Intensity/(Length/(Length-i))
				Camera.CFrame = Camera.CFrame * CFrame.fromEulerAnglesXYZ(Random.new():NextNumber(-RandValue*3,RandValue*3)/360,Random.new():NextNumber(-RandValue*3,RandValue*3)/360,Random.new():NextNumber(-RandValue*3,RandValue*3)/360) * CFrame.Angles(Random.new():NextNumber(-RandValue,RandValue)/360,Random.new():NextNumber(-RandValue,RandValue)/360,Random.new():NextNumber(-RandValue,RandValue)/360)
				Camera.FieldOfView = Random.new():NextNumber(70-RandValue,70+RandValue)
				game:GetService("RunService").Heartbeat:wait()
			end
			Camera.FieldOfView = 70
		end
		
	elseif Type == 2 then -- FE Gun Kit (by SuperEvilAzmil) Standard
		print("SC2")
		if Length and Intensity then
			for i = 1, Length do
				local cam_rot = Camera.CoordinateFrame - Camera.CoordinateFrame.p
				local cam_scroll = (Camera.CoordinateFrame.p - Camera.Focus.p).magnitude
				local ncf = CFrame.new(Camera.Focus.p)*cam_rot*CFrame.fromEulerAnglesXYZ((-Intensity+(math.random()*(Intensity*2)))/100, (-Intensity+(math.random()*(Intensity*2)))/100, 0)
				Camera.CoordinateFrame = ncf*CFrame.new(0, 0, cam_scroll)
				game:GetService("RunService").Heartbeat:wait()
			end
		end
		
	elseif Type == 3 then -- Edited FE Gun Kit (by thienbao2109) Standard
		print"SC3"
		if Length and Intensity then
			
			local function RAND(Min, Max, Accuracy)
				return (math.random(Min * 1, Max * 1) / 1)
			end
			
			local CurrentRecoil = Intensity^2
	        local RecoilX = math.rad(CurrentRecoil * RAND(1, 1, 0.1))
		    local RecoilY = math.rad(CurrentRecoil * RAND(0, 0, 0.1))
		    local RecoilZ = math.rad(CurrentRecoil * RAND(-1, 1, 0.1))
		    CameraModule:accelerate(RecoilX,RecoilY,RecoilZ)	    
			delay(0.03, function()
			    CameraModule:accelerateXY(-RecoilX,-RecoilY)
		    end)
		end
		
	end
	
end)
