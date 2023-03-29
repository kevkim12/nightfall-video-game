local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

while character.Parent == nil do
	character.AncestryChanged:Wait()
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local rs = game:GetService('RunService')
local mouse = game.Players.LocalPlayer:GetMouse()
local UIS = game:GetService("UserInputService")

local selectionbox = Instance.new('Highlight')
selectionbox.FillColor = Color3.fromRGB(255, 213, 0)
selectionbox.OutlineColor = Color3.fromRGB(255, 213, 0)
local isLoot = false
local targetLoot = nil

local Teams = game:GetService("Teams")
local SurvivorTeam = Teams:WaitForChild("Survivors")

rs.RenderStepped:connect(function()
	if mouse.Target ~= nil then
		if mouse.Target:FindFirstAncestorWhichIsA('Model'):FindFirstChild("Loot") ~= nil and mouse.Target:FindFirstAncestorWhichIsA('Model'):FindFirstChild("Center") ~= nil and player.Team == SurvivorTeam then
			local Distance = (mouse.Target:FindFirstAncestorWhichIsA('Model'):FindFirstChild("Center").Position - root.Position).Magnitude -- attempt to index nil with position?
			if Distance <= 10 then
				selectionbox.Parent = mouse.Target:FindFirstAncestorWhichIsA('Model')
				targetLoot = mouse.Target:FindFirstAncestorWhichIsA('Model')
				isLoot = true
			else
				selectionbox.Parent = nil
				targetLoot = nil
				isLoot = false
			end
		else
			selectionbox.Parent = nil
			targetLoot = nil
			isLoot = false
		end
	end
end)

UIS.InputBegan:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.E and isLoot == true and ((#player.Backpack:GetChildren() < 6 and player.Character:FindFirstChildWhichIsA('Tool') == nil) or (player.Character:FindFirstChildWhichIsA('Tool') and #player.Backpack:GetChildren() < 5)) then
		script.Take:Play()
		ReplicatedStorage.Events.LootPick:FireServer(targetLoot)
		selectionbox.Parent = nil
	end
end)