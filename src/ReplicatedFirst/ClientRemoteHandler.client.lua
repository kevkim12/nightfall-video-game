local SetSubject = game.ReplicatedStorage:WaitForChild("SetSubject")

function onEvent_SetSubject(Humanoid)
	workspace.CurrentCamera.CameraSubject = Humanoid
end

SetSubject.OnClientEvent:Connect(onEvent_SetSubject)