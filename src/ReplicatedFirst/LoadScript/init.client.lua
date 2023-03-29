game.ReplicatedFirst:RemoveDefaultLoadingScreen()

local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local GUI = script.LoadGui:Clone()
GUI.Parent = PlayerGui