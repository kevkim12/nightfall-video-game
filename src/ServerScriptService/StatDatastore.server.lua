local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Players = game:GetService("Players")
local Rewards = require(ServerStorage.Modules.Rewards)
local NotifyRewards = ReplicatedStorage.Events.NotifyRewards

local DataStore2 = require(ServerScriptService.DataStore2)
local MainKey = "NightfallKey1"
DataStore2.Combine(MainKey, "Statistics", "Profile", "Character", "Equipment", "Inventory")

local PlayerData = {
	Statistics = {
		["Level"] = 0;
		["XP"] = 0;
		["Credit"] = 0;
	};
	
	Profile = {
		["Emblem"] = "Default Emblem"; -- new
		["Title"] = "Default Title";
		
	};
	
	Character = {
		["Gender"] = "Male";
		["Skin Tone"] = "Option1";
		["Face"] = "Skeptical";
		["Hair"] = "";
		["Other"] = "None";
		
		["Head"] = "None";
		["Clothes"] = "Casual Contractor";
	};
	
	Equipment = {
		["Primary"] = "JRC 9MM";
		["Secondary"] = "Baseball Bat";
		["Item"] = "Elastic Bandage";
	};
	
	Inventory = {
		-- PRIMARY
		["JRC 9MM"] = true;
		["M4A1"] = false;
		["SCAR-L"] = false;
		
		-- SECONDARY
		["Baseball Bat"] = true;
		["M32A1"] = false;
		["P226"] = false;
		
		-- ITEM
		["Elastic Bandage"] = true;
		["M67"] = false;
		
		-- Emblem
		["Default Emblem"] = true;
		
		-- TITLE
		["Default Title"] = true;
		
		-- FACE
		["Cautious"] = false;
		["Concerned"] = false;
		["Positive"] = true;
		["Sad"] = true;
		["Serious"] = false;
		["Sickened"] = false;
		["Skeptical"] = true;
		["Unamused"] = false;
		["Upset"] = false;
		
		
		-- HEAD
		["6b47 [EMR]"] = false;
		["ACH [OCP]"] = false;
		["ACH [Tactical]"] = false;
		["CG634 [CADPAT]"] = false;
		["CG634 [Tactical]"] = false;
		["None"] = true;
		
		-- CLOTHES
		["Casual Contractor"] = true;
		["Casual Friday"] = true;
		["Dust"] = false;
		["Foxhole"] = false;
		["Frogman"] = false;
		["Hazmat"] = false;
		["Leaf"] = false;
		["Lone Wolf"] = false;
		["Nightfall"] = false;
		["Nocturnal"] = false;
		["Outland"] = false;
		["Patriot"] = false;
		["Ricochet"] = false;
		["Swift Operator"] = false;
		["The Collector"] = false;
		["White Death"] = false;
	}
}

local xpToLevelUp = function(level)
	return 5000
end

game.Players.PlayerAdded:Connect(function(player)
	local StatisticsUserData = DataStore2("Statistics", player):GetTable(PlayerData.Statistics)
	local ProfileUserData = DataStore2("Profile", player):GetTable(PlayerData.Profile)
	local EquipmentUserData = DataStore2("Equipment", player):GetTable(PlayerData.Equipment)
	local CharacterUserData = DataStore2("Character", player):GetTable(PlayerData.Character)
	local InventoryUserData = DataStore2("Inventory", player):GetTable(PlayerData.Inventory)
	
	-- Leaderstat values (TRY NOT TO USE)
	
	local Equipment = Instance.new("Folder"); Equipment.Parent = player; Equipment.Name = "Equipment"
	local EquippedPrimary = Instance.new("StringValue"); EquippedPrimary.Parent = Equipment; EquippedPrimary.Name = "Primary"
	local EquippedSecondary = Instance.new("StringValue"); EquippedSecondary.Parent = Equipment; EquippedSecondary.Name = "Secondary"
	local EquippedItem = Instance.new("StringValue"); EquippedItem.Parent = Equipment; EquippedItem.Name = "Item"
	
	-- Get datastore
	local StatisticsData = DataStore2("Statistics", player)
	local ProfileData = DataStore2("Profile", player)
	local CharacterData = DataStore2("Character", player)
	local EquipmentData = DataStore2("Equipment", player)
	local InventoryData = DataStore2("Inventory", player)
	
	local function UpdateStatistics(UpdatedValue)
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Statistics"):WaitForChild("Level").Value = StatisticsData:Get(UpdatedValue).Level
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Statistics"):WaitForChild("XP").Value = StatisticsData:Get(UpdatedValue).XP
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Statistics"):WaitForChild("Credit").Value = StatisticsData:Get(UpdatedValue).Credit
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Level", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Statistics"):WaitForChild("Level").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "XP", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Statistics"):WaitForChild("XP").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Credit", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Statistics"):WaitForChild("Credit").Value)
	end
	
	local function UpdateProfile(UpdatedValue)
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Profile"):WaitForChild("Emblem").Value = ProfileData:Get(UpdatedValue).Emblem
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Profile"):WaitForChild("Title").Value = ProfileData:Get(UpdatedValue).Title
	end
	
	local function UpdateCharacter(UpdatedValue)
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Skin Tone").Value = CharacterData:Get(UpdatedValue)["Skin Tone"]
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Face").Value = CharacterData:Get(UpdatedValue)["Face"]
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Hair").Value = CharacterData:Get(UpdatedValue)["Hair"]
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Other").Value = CharacterData:Get(UpdatedValue)["Other"]
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Head").Value = CharacterData:Get(UpdatedValue)["Head"]
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Clothes").Value = CharacterData:Get(UpdatedValue)["Clothes"]
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Skin Tone", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Skin Tone").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Face", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Face").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Hair", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Hair").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Other", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Other").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Head", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Head").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Clothes", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Character"):WaitForChild("Clothes").Value)
	end
	
	local function UpdateEquipment(UpdatedValue)
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Equipment"):WaitForChild("Primary").Value = EquipmentData:Get(UpdatedValue).Primary
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Equipment"):WaitForChild("Secondary").Value = EquipmentData:Get(UpdatedValue).Secondary
		ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Equipment"):WaitForChild("Item").Value = EquipmentData:Get(UpdatedValue).Item
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Primary", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Equipment"):WaitForChild("Primary").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Secondary", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Equipment"):WaitForChild("Secondary").Value)
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Item", ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Equipment"):WaitForChild("Item").Value)
	end
	
	local function UpdateInventory(UpdatedValue)
		local Inventory = ReplicatedStorage.GameData.PlayerData:WaitForChild(player.Name):WaitForChild("Inventory")
		Inventory:WaitForChild("Face"):WaitForChild("Cautious").Value = InventoryData:Get(InventoryUserData)["Cautious"]
		Inventory:WaitForChild("Face"):WaitForChild("Concerned").Value = InventoryData:Get(InventoryUserData)["Concerned"]
		Inventory:WaitForChild("Face"):WaitForChild("Positive").Value = InventoryData:Get(InventoryUserData)["Positive"]
		Inventory:WaitForChild("Face"):WaitForChild("Sad").Value = InventoryData:Get(InventoryUserData)["Sad"]
		Inventory:WaitForChild("Face"):WaitForChild("Serious").Value = InventoryData:Get(InventoryUserData)["Serious"]
		Inventory:WaitForChild("Face"):WaitForChild("Sickened").Value = InventoryData:Get(InventoryUserData)["Sickened"]
		Inventory:WaitForChild("Face"):WaitForChild("Skeptical").Value = InventoryData:Get(InventoryUserData)["Skeptical"]
		Inventory:WaitForChild("Face"):WaitForChild("Unamused").Value = InventoryData:Get(InventoryUserData)["Unamused"]
		Inventory:WaitForChild("Face"):WaitForChild("Upset").Value = InventoryData:Get(InventoryUserData)["Upset"]
		
		Inventory:WaitForChild("Head"):WaitForChild("6b47 [EMR]").Value = InventoryData:Get(InventoryUserData)["6b47 [EMR]"]
		Inventory:WaitForChild("Head"):WaitForChild("ACH [OCP]").Value = InventoryData:Get(InventoryUserData)["ACH [OCP]"]
		Inventory:WaitForChild("Head"):WaitForChild("ACH [Tactical]").Value = InventoryData:Get(InventoryUserData)["ACH [Tactical]"]
		Inventory:WaitForChild("Head"):WaitForChild("CG634 [CADPAT]").Value = InventoryData:Get(InventoryUserData)["CG634 [CADPAT]"]
		Inventory:WaitForChild("Head"):WaitForChild("CG634 [Tactical]").Value = InventoryData:Get(InventoryUserData)["CG634 [Tactical]"]
		Inventory:WaitForChild("Head"):WaitForChild("None").Value = InventoryData:Get(InventoryUserData)["None"]
		
		Inventory:WaitForChild("Clothes"):WaitForChild("Casual Friday").Value = InventoryData:Get(InventoryUserData)["Casual Friday"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Casual Contractor").Value = InventoryData:Get(InventoryUserData)["Casual Contractor"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Dust").Value = InventoryData:Get(InventoryUserData)["Dust"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Foxhole").Value = InventoryData:Get(InventoryUserData)["Foxhole"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Frogman").Value = InventoryData:Get(InventoryUserData)["Frogman"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Hazmat").Value = InventoryData:Get(InventoryUserData)["Hazmat"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Leaf").Value = InventoryData:Get(InventoryUserData)["Leaf"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Lone Wolf").Value = InventoryData:Get(InventoryUserData)["Lone Wolf"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Nightfall").Value = InventoryData:Get(InventoryUserData)["Nightfall"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Nocturnal").Value = InventoryData:Get(InventoryUserData)["Nocturnal"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Outland").Value = InventoryData:Get(InventoryUserData)["Outland"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Patriot").Value = InventoryData:Get(InventoryUserData)["Patriot"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Ricochet").Value = InventoryData:Get(InventoryUserData)["Ricochet"]
		Inventory:WaitForChild("Clothes"):WaitForChild("Swift Operator").Value = InventoryData:Get(InventoryUserData)["Swift Operator"]
		Inventory:WaitForChild("Clothes"):WaitForChild("The Collector").Value = InventoryData:Get(InventoryUserData)["The Collector"]
		Inventory:WaitForChild("Clothes"):WaitForChild("White Death").Value = InventoryData:Get(InventoryUserData)["White Death"]
		
		Inventory:WaitForChild("Primary"):WaitForChild("JRC 9MM").Value = InventoryData:Get(InventoryUserData)["JRC 9MM"]
		Inventory:WaitForChild("Primary"):WaitForChild("M4A1").Value = InventoryData:Get(InventoryUserData)["M4A1"]
		Inventory:WaitForChild("Primary"):WaitForChild("SCAR-L").Value = InventoryData:Get(InventoryUserData)["SCAR-L"]
		
		Inventory:WaitForChild("Secondary"):WaitForChild("Baseball Bat").Value = InventoryData:Get(InventoryUserData)["Baseball Bat"]
		Inventory:WaitForChild("Secondary"):WaitForChild("M32A1").Value = InventoryData:Get(InventoryUserData)["M32A1"]
		Inventory:WaitForChild("Secondary"):WaitForChild("P226").Value = InventoryData:Get(InventoryUserData)["P226"]
		
		Inventory:WaitForChild("Item"):WaitForChild("Elastic Bandage").Value = InventoryData:Get(InventoryUserData)["Elastic Bandage"]
		Inventory:WaitForChild("Item"):WaitForChild("M67").Value = InventoryData:Get(InventoryUserData)["M67"]
		
		ReplicatedStorage.Events.UpdateData:FireClient(player, "Inventory", "None")
	end
	
	UpdateStatistics(StatisticsUserData)
	UpdateProfile(ProfileUserData)
	UpdateCharacter(CharacterUserData)
	UpdateEquipment(EquipmentUserData)
	UpdateInventory(InventoryUserData)
	
	StatisticsData:OnUpdate(UpdateStatistics)
	ProfileData:OnUpdate(UpdateProfile)
	CharacterData:OnUpdate(UpdateCharacter)
	EquipmentData:OnUpdate(UpdateEquipment)
	InventoryData:OnUpdate(UpdateInventory)
	
	ProfileUserData["Title"] = "Default Title"
	ProfileData:Set(ProfileUserData)
	
	local CurrentHead = CharacterUserData["Head"]
	local CurrentClothes = CharacterUserData["Clothes"]
	ReplicatedStorage.Events.DataSelection.OnServerEvent:Connect(function(plr, Type, Selection)
		if player.Name == plr.Name then
			if Type == "Skin Tone" then
				CharacterUserData["Skin Tone"] = Selection
				CharacterData:Set(CharacterUserData)
			elseif Type == "Face" then
				CharacterUserData["Face"] = Selection
				CharacterData:Set(CharacterUserData)
			elseif Type == "Primary" then
				if InventoryData:Get(InventoryUserData)[Selection] == true then
					EquipmentUserData["Primary"] = Selection
					EquipmentData:Set(EquipmentUserData)
				end
			elseif Type == "Secondary" then
				if InventoryData:Get(InventoryUserData)[Selection] == true then
					EquipmentUserData["Secondary"] = Selection
					EquipmentData:Set(EquipmentUserData)
				end
			elseif Type == "Item" then
				if InventoryData:Get(InventoryUserData)[Selection] == true then
					EquipmentUserData["Item"] = Selection
					EquipmentData:Set(EquipmentUserData)
				end
			elseif Type == "Head" then
				if InventoryData:Get(InventoryUserData)[Selection] == true then
					CharacterUserData["Head"] = Selection
					CharacterData:Set(CharacterUserData)
					local CharacterModel = player.PlayerGui.MenuGui.Frame.Windows.Loadout.CharacterModel.ViewportFrame.WorldModel.LoadoutCharacter
					local Content = CharacterModel:GetChildren()
					if CurrentHead ~= Selection then
						for i = 1, #Content do
							if Content[i]:isA("Hat") or Content[i]:isA("Accessory") then
								Content[i]:Destroy()
							end
						end
						local HeadItems = game.ServerStorage.CharacterContent.Head:FindFirstChild(Selection)
						local HeadItemsContent = HeadItems:GetChildren()
						for i = 1, #HeadItemsContent do
							local HeadItemClone = HeadItemsContent[i]:Clone()
							HeadItemClone.Parent = CharacterModel
						end
					end
					CurrentHead = Selection
				end
			elseif Type == "Clothes" then
				if InventoryData:Get(InventoryUserData)[Selection] == true then
					CharacterUserData["Clothes"] = Selection
					CharacterData:Set(CharacterUserData)
					local CharacterModel = player.PlayerGui.MenuGui.Frame.Windows.Loadout.CharacterModel.ViewportFrame.WorldModel.LoadoutCharacter
					local Content = CharacterModel:GetChildren()
					if CurrentClothes ~= Selection then
						for i = 1, #Content do
							if Content[i]:isA("Shirt") or Content[i]:isA("Pants") then
								Content[i]:Destroy()
							end
						end
						local ClothingItems = game.ServerStorage.CharacterContent.Clothes:FindFirstChild(Selection)
						local ClothingItemsContent = ClothingItems:GetChildren()
						for i = 1, #ClothingItemsContent do
							local ClothingItemClone = ClothingItemsContent[i]:Clone()
							ClothingItemClone.Parent = CharacterModel
						end
					end
					CurrentClothes = Selection
				end
			end
		end
	end)
	
	ReplicatedStorage.Events.Purchase.OnServerEvent:Connect(function(plr, Product, Type)
		if player.Name == plr.Name then
			if Type == "Primary" or Type == "Secondary" or Type == "Item" then
				if InventoryData:Get(InventoryUserData)[Product] == false and StatisticsData:Get(StatisticsUserData)["Credit"] >= ServerStorage:WaitForChild("EquipmentData")[Type]:FindFirstChild(Product).Price.Value and StatisticsData:Get(StatisticsUserData)["Level"] >= ServerStorage:WaitForChild("EquipmentData")[Type]:FindFirstChild(Product).Level.Value then
					StatisticsUserData.Credit = StatisticsUserData.Credit - ServerStorage:WaitForChild("EquipmentData")[Type]:FindFirstChild(Product).Price.Value
					StatisticsData:Set(StatisticsUserData)
					InventoryUserData[Product] = true
					InventoryData:Set(InventoryUserData)
				end
			elseif Type == "Face" then
				if InventoryData:Get(InventoryUserData)[Product] == false and StatisticsData:Get(StatisticsUserData)["Credit"] >= ServerStorage:WaitForChild("CharacterData")[Type]:FindFirstChild(Product).Price.Value then
					StatisticsUserData.Credit = StatisticsUserData.Credit - ServerStorage:WaitForChild("CharacterData")[Type]:FindFirstChild(Product).Price.Value
					StatisticsData:Set(StatisticsUserData)
					InventoryUserData[Product] = true
					InventoryData:Set(InventoryUserData)
				end
			elseif Type == "Head" then
				if InventoryData:Get(InventoryUserData)[Product] == false and StatisticsData:Get(StatisticsUserData)["Credit"] >= ServerStorage:WaitForChild("CharacterData")[Type]:FindFirstChild(Product).Price.Value then
					StatisticsUserData.Credit = StatisticsUserData.Credit - ServerStorage:WaitForChild("CharacterData")[Type]:FindFirstChild(Product).Price.Value
					StatisticsData:Set(StatisticsUserData)
					InventoryUserData[Product] = true
					InventoryData:Set(InventoryUserData)
				end
			elseif Type == "Clothes" then
				if InventoryData:Get(InventoryUserData)[Product] == false and StatisticsData:Get(StatisticsUserData)["Credit"] >= ServerStorage:WaitForChild("CharacterData")[Type]:FindFirstChild(Product).Price.Value then
					StatisticsUserData.Credit = StatisticsUserData.Credit - ServerStorage:WaitForChild("CharacterData")[Type]:FindFirstChild(Product).Price.Value
					StatisticsData:Set(StatisticsUserData)
					InventoryUserData[Product] = true
					InventoryData:Set(InventoryUserData)
				end
			end
		end
	end)
	
	
	local FirstTimeModel = player.PlayerGui:WaitForChild("MenuGui").Frame.Windows.Loadout.CharacterModel.ViewportFrame.WorldModel.LoadoutCharacter
	local FirstContent = FirstTimeModel:GetChildren()
	local FirstHeadItems = game.ServerStorage.CharacterContent.Head:FindFirstChild(CurrentHead)
	local FirstHeadItemsContent = FirstHeadItems:GetChildren()
	local FirstClothesItems = game.ServerStorage.CharacterContent.Clothes:FindFirstChild(CurrentClothes)
	local FirstClothesItemsContent = FirstClothesItems:GetChildren()
	if FirstHeadItemsContent ~= nil then
		for i = 1, #FirstHeadItemsContent do
			local HeadItemClone = FirstHeadItemsContent[i]:Clone()
			HeadItemClone.Parent = FirstTimeModel
		end
	end
	if FirstClothesItemsContent ~= nil then
		for i = 1, #FirstClothesItemsContent do
			local ClothingItemClone = FirstClothesItemsContent[i]:Clone()
			ClothingItemClone.Parent = FirstTimeModel
		end
	end
	
	ReplicatedStorage.Events.RequestReward.Event:Connect(function(Type, Player, Class)
		if player == Player then
			if Type == "Kill" then
				StatisticsUserData["Credit"] = StatisticsUserData["Credit"] + Rewards["Kill Credits"][Class]
				StatisticsUserData["XP"] = StatisticsUserData["XP"] + Rewards["Kill XP"][Class]
				StatisticsData:Set(StatisticsUserData)
				NotifyRewards:FireClient(player, "+$" .. Rewards["Kill Credits"][Class], "KILLED " .. string.upper(Class))
			elseif Type == "Survival Win" then
				StatisticsUserData["Credit"] = StatisticsUserData["Credit"] +Rewards["Game Credits"]["Survival Win"]
				StatisticsUserData["XP"] = StatisticsUserData["XP"] + Rewards["Game XP"]["Survival Win"]
				--NotifyRewards:FireClient(player, "+$" .. Rewards["Game Credits"]["Survival Win"], "SURVIVOR VICTORY")
			end
		end
	end)
end)