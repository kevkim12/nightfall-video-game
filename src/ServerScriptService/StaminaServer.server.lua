local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

local maxStamina = 500
local staminaRegen = 2

local sprintModifier = 1.8
local sprintStaminaCost = 1

local sprintingPlayers = {}
local JumpingPlayers = {}

players.PlayerAdded:Connect(function(player)
	local stamina = Instance.new("IntValue", player)
	stamina.Value = maxStamina
	stamina.Name = "Stamina"
	
	stamina.Changed:Connect(function(property)
		replicatedStorage.Events.StaminaUpdate:FireClient(player, stamina.Value, maxStamina)
	end)
end)

replicatedStorage.Events.Sprint.OnServerEvent:Connect(function(player, state)
	local humanoid = player.Character.Humanoid
	
	if state == "Began" and humanoid.MoveDirection.Magnitude > 0 then
		sprintingPlayers[player.Name] = humanoid.WalkSpeed
		humanoid.WalkSpeed = humanoid.WalkSpeed * sprintModifier
	elseif state == "Ended" and sprintingPlayers[player.Name] then
		humanoid.WalkSpeed = sprintingPlayers[player.Name]
		sprintingPlayers[player.Name] = nil
	end
end)

runService.Heartbeat:Connect(function()
	for index, player in pairs(players:GetChildren()) do
		local stamina = player.Stamina
		local name = player.Name
		local humanoid
		if player.Character then
			humanoid = player.Character.Humanoid
		end
		
		if not sprintingPlayers[name] then
			if stamina.Value > maxStamina then
				stamina.Value = maxStamina
			elseif stamina.Value < maxStamina then
				stamina.Value = stamina.Value + staminaRegen
			end
		else
			if stamina.Value >= sprintStaminaCost and humanoid.MoveDirection.Magnitude > 0 then
				stamina.Value = stamina.Value - sprintStaminaCost
			else
				player.Character.Humanoid.WalkSpeed = sprintingPlayers[name]
				sprintingPlayers[name] = nil
			end
		end
	end
end)