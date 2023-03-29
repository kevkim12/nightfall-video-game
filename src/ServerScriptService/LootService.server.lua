local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local LootPlan = require(ReplicatedStorage.Modules.LootPlan)
local ItemPlan = LootPlan.new("single")


local NoItemChance = 80
ItemPlan:AddLoot("None", NoItemChance)
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

ReplicatedStorage.GameData.Stage.Changed:Connect(function()
	local Stage = ReplicatedStorage.GameData.Stage
	if Stage.Value == 2 then
		ItemPlan:ChangeLootChance("None", NoItemChance * 1.5)
	elseif Stage.Value == 3 then
		ItemPlan:ChangeLootChance("None", NoItemChance * 2)
	elseif Stage.Value == 4 then
		ItemPlan:ChangeLootChance("None", NoItemChance * 2.5)
	elseif Stage.Value == 5 then
		ItemPlan:ChangeLootChance("None", NoItemChance * 3)
	end
	if ReplicatedStorage.GameData.GameActive.Value == true and ReplicatedStorage.GameData.Stage.Value > 0 then
		local Spawns = game.Workspace.Map:FindFirstChild(game.ReplicatedStorage.GameData.Map.Value).LootSpawn:GetChildren()
		--local LootLimit = #Spawns
		for i = 1, #Spawns do
			local SelectedLoot = ItemPlan:GetRandomLoot()
			if SelectedLoot ~= "None" then
				local newItem = ReplicatedStorage.Assets.Loot:FindFirstChild(SelectedLoot):Clone()
				newItem:SetPrimaryPartCFrame(Spawns[i].CFrame * CFrame.new(math.random(-Spawns[i].Size.X/2, Spawns[i].Size.X/2), 1.1 ,math.random(-Spawns[i].Size.Z/2, Spawns[i].Size.Z/2)))
				--newItem:SetPrimaryPartCFrame(CFrame.new(math.random(Spawns[i].CFrame.X/2), Spawns[i].CFrame.Y + 1, math.random(Spawns[i].CFrame.Z/2)))
				newItem.Parent = workspace.Loot
				local Parts = newItem:GetChildren()
				for i = 1, #Parts do
					if Parts[i]:isA("Part") or Parts[i]:isA("Union") or Parts[i]:isA("MeshPart") then
						Parts[i].Anchored = false
					end
				end
				wait(.3)
			end
		end
	else
		local Loots = workspace.Loot:GetChildren()
		for i = 1, #Loots do
			Loots[i]:Destroy()
		end
	end
end)