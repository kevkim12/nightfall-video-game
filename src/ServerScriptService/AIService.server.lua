-- AI Spawn Service
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Stage = ReplicatedStorage.GameData.Stage
local ServerStorage = game:GetService("ServerStorage")
local AICurrent = ServerStorage.Infected.Capacity:WaitForChild("AICurrent")
local AIMax = ServerStorage.Infected.Capacity:WaitForChild("AIMax")
local AI = ServerStorage.Infected.AI:WaitForChild("Walker")
local WS = game:GetService("Workspace")
local InfectedScreams = {1158092384, 1158093982, 1158094154, 1158094311, 1158094454, 1158094691}
local LootPlan = require(game.ReplicatedStorage.Modules.LootPlan)
local InfectedPlan = LootPlan.new("single")

InfectedPlan:AddLoot("Walker", 80)
InfectedPlan:AddLoot("Bloater", 10)
InfectedPlan:AddLoot("Creeper", 10)

local function DesertOutfit(character)
	local Number = math.random(1,10)
	local Storage = game.ServerStorage.Infected.Accessories["Desert Wartorn"]
	local ClothingContent = Storage["Outfit"..Number]:GetChildren()
	for i = 1, #ClothingContent do
		if ClothingContent[i].Name == "TacticalBala" then
			ClothingContent[i].AttachmentPos = Vector3.new(0, 0.5, -0)
		elseif ClothingContent[i].Name == "SkiMask" then
			ClothingContent[i].AttachmentPos = Vector3.new(0, 0.46, -0.002)
		end
		ClothingContent[i]:Clone().Parent = character
		
	end
	local FaceId = {6797440099, 6797440388, 6797455282, 6797460023, 6797465110, 6797472035, 6797477271}
	local Val = FaceId[math.random(1,#FaceId)]
	character.Head:WaitForChild("face").Texture = ("rbxassetid://" .. Val)
end

while true do
	wait(1)
	if game.ReplicatedStorage.GameData.GameActive.Value == true then
		math.randomseed(tick())
		if AICurrent.Value < AIMax.Value then
			local InfectedStartPoints = game.Workspace:WaitForChild("Map"):WaitForChild(ServerStorage.Maps.MapData.CurrentMap.Value):WaitForChild("InfectedSpawn"):GetChildren()
			local Count = #InfectedStartPoints
			while AICurrent.Value < AIMax.Value do
				wait(3)
				local InfectedNumber = math.random(1, Count)
				AI = ServerStorage.Infected.AI:WaitForChild(InfectedPlan:GetRandomLoot())
				local InfectedClone = AI:Clone()
				local ID = InfectedScreams[math.random(1,#InfectedScreams)]
				InfectedClone.Head:WaitForChild("Death").SoundId = "rbxassetid://" .. ID
				DesertOutfit(InfectedClone)
				InfectedClone.Parent = WS.NPC
				InfectedClone:MoveTo(InfectedStartPoints[InfectedNumber].Position)
				InfectedClone.Name = "Infected_AI"
				local Active = WS.NPC:GetChildren()
				AICurrent.Value = #Active
			end
		else
			local Active = WS.NPC:GetChildren()
			AICurrent.Value = #Active
		end
	end
end