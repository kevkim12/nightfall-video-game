local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local LootPlan = require(game.ReplicatedStorage.Modules.LootPlan)
local ItemPlan = LootPlan.new("single")

ItemPlan:AddLoot("Ammo Box", 10)
ItemPlan:AddLoot("Elastic Bandage", 40)
ItemPlan:AddLoot("M67", 10)

ReplicatedStorage.Events.LootPick.OnServerEvent:Connect(function(Player, Loot)
	local Character = Player.Character
	local Root = Character:FindFirstChild("HumanoidRootPart")
	if (Loot:FindFirstChild("Center").Position - Root.Position).Magnitude <= 12 then
		local LootClone = ServerStorage.Tools:FindFirstChild(Loot.Name):Clone()
		LootClone.Parent = Player.Backpack
		Loot:Destroy()
	end
end)

game.ReplicatedStorage.GameData.GameActive.Changed:Connect(function()
	if game.ReplicatedStorage.GameData.GameActive.Value == true then
		local Spawns = game.Workspace.Map:FindFirstChild(game.ReplicatedStorage.GameData.Map.Value).LootSpawn:GetChildren()
		for i = 1, #Spawns do
			local newItem = ReplicatedStorage.Assets.Loot:FindFirstChild(ItemPlan:GetRandomLoot()):Clone()
			newItem:SetPrimaryPartCFrame(CFrame.new(Spawns[i].CFrame.X, Spawns[i].CFrame.Y + 1, Spawns[i].CFrame.Z))
			newItem.Parent = workspace.Loot
			local Parts = newItem:GetChildren()
			for i = 1, #Parts do
				if Parts[i]:isA("Part") or Parts[i]:isA("Union") or Parts[i]:isA("MeshPart") then
					Parts[i].Anchored = false
				end
			end
			wait(1)
		end
	else
		local Loots = workspace.Loot:GetChildren()
		for i = 1, #Loots do
			Loots[i]:Destroy()
		end
	end
end)