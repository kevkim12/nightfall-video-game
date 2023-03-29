local chatServ = game:GetService("Chat")
local event = game:GetService("ReplicatedStorage").Events:WaitForChild("ChatEvent")

event.OnServerEvent:Connect(function(plr, message)
	if message ~= "" then
		local filteredVersion = chatServ:FilterStringForBroadcast(message, plr)
		event:FireAllClients(filteredVersion, plr.Name)
	end
end)