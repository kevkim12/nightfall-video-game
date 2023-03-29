local Inventory = script.Parent.ToolBar
local UIS = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game.Players.LocalPlayer
local Character = workspace:WaitForChild(Player.Name)
local Backpack = Player.Backpack
local Hum = Character:WaitForChild("Humanoid")
--local GameStatus = ReplicatedStorage:WaitForChild("GameData")
local Slots = script.Parent.ToolBar.Frame.Frame
local SemiSlots = script.Parent.ToolBar.Frame
local EquippedColor = Color3.new(182/255, 182/255, 182/255)
local UnequippedColor = Color3.new(213/255, 213/255, 213/255)
local OriginalColor = Color3.new(1,1,1)
local ActivatedColor = Color3.new(93/255, 93/255, 93/255)
local SemiSlots = script.Parent.ToolBar.Frame
local Teams = game:GetService("Teams")
local UIS = game:GetService("UserInputService")
local RequestTimer = 0
local MaxItems = 5

local InputKeys = {
	["One"] = {txt = "1"},
	["Two"] = {txt = "2"},
	["Three"] = {txt = "3"},
	["Four"] = {txt = "4"},
	["Five"] = {txt = "5"},
	["Six"] = {txt = "6"},
}

local InputOrder = {
	InputKeys["One"],InputKeys["Two"],InputKeys["Three"],InputKeys["Four"],InputKeys["Five"],InputKeys["Six"]
}
local function HandleEquip(Tool)
	if Tool then
		if Tool.Parent ~= Character then
			Hum:EquipTool(Tool)
		else
			Hum:UnequipTools()
		end
	end
end

function Create() -- creates all the icons at once (and will only run once)

	local toShow = #InputOrder
	for i = 1, #InputOrder do

		local value = InputOrder[i]

		local tool = value["tool"]
		if tool then
			Slots["Slot"..i].ImageLabel.Image = tool.TextureId
		end


	end	
end

function setup() -- sets up all the tools already in the backpack (and will only run once)
	local tools = Backpack:GetChildren()
	for i = 1, #tools do 
		if tools[i]:IsA("Tool") then -- does not assume that all objects in the backpack will be a tool (2.11.18)
			for i = 1, #InputOrder do
				local value = InputOrder[i]
				if not value["tool"] then -- if the tool slot is free...
					value["tool"] = tools[i]	
					break -- stop searching for a free slot
				end
			end
		end
	end
	Create()
end

function adjust()
	for key, value in pairs(InputKeys) do
		local tool = value["tool"]
		local icon = Slots:FindFirstChild("Slot"..value["txt"])
		if tool then
			icon.ImageLabel.Image = tool.TextureId
			if tool.Parent == Character then -- if the tool is equipped...
				icon.ImageLabel.UIStroke.Color = Color3.new(1, 1, 1)
			else
				icon.ImageLabel.UIStroke.Color = Color3.new(88/255, 88/255, 88/255)
			end
		else
			icon.ImageLabel.Image = ""
			icon.ImageLabel.UIStroke.Color = Color3.new(88/255, 88/255, 88/255)
		end
	end
end

function onKeyPress(inputObject) -- press keys to equip/unequip
	local key = inputObject.KeyCode.Name
	local value = InputKeys[key]
	if value and UIS:GetFocusedTextBox() == nil then -- don't equip/unequip while typing in text box
		HandleEquip(value["tool"])
	end 
end

function handleAddition(adding)

	if adding:IsA("Tool") then
		local new = true
		for key, value in pairs(InputKeys) do
			local tool = value["tool"]
			if tool then
				if tool == adding then
					new = false
				end
			end
		end

		if new then
			for i = 1, #InputOrder do
				local tool = InputOrder[i]["tool"]
				if not tool then -- if the tool slot is free...
					InputOrder[i]["tool"] = adding
					break
				end
			end
		end
		adjust()
	end
end

function handleRemoval(removing) 
	if removing:IsA("Tool") then
		if removing.Parent ~= Character and removing.Parent ~= Backpack then
			for i = 1, #InputOrder do
				if InputOrder[i]["tool"] == removing then
					InputOrder[i]["tool"] = nil
					break
				end
			end
		end
		adjust()
	end
end

UIS.InputBegan:Connect(onKeyPress)

Character.ChildAdded:Connect(handleAddition)
Character.ChildRemoved:Connect(handleRemoval)

Backpack.ChildAdded:Connect(handleAddition)
Backpack.ChildRemoved:Connect(handleRemoval)

setup()

Slots.Slot1.MouseButton1Click:Connect(function()
	local value = InputKeys["One"]
	if value and UIS:GetFocusedTextBox() == nil then -- don't equip/unequip while typing in text box
		HandleEquip(value["tool"])
	end 
end)
Slots.Slot2.MouseButton1Click:Connect(function()
	local value = InputKeys["Two"]
	if value and UIS:GetFocusedTextBox() == nil then -- don't equip/unequip while typing in text box
		HandleEquip(value["tool"])
	end 
end)
Slots.Slot3.MouseButton1Click:Connect(function()
	local value = InputKeys["Three"]
	if value and UIS:GetFocusedTextBox() == nil then -- don't equip/unequip while typing in text box
		HandleEquip(value["tool"])
	end 
end)
Slots.Slot4.MouseButton1Click:Connect(function()
	local value = InputKeys["Four"]
	if value and UIS:GetFocusedTextBox() == nil then -- don't equip/unequip while typing in text box
		HandleEquip(value["tool"])
	end 
end)
Slots.Slot5.MouseButton1Click:Connect(function()
	local value = InputKeys["Five"]
	if value and UIS:GetFocusedTextBox() == nil then -- don't equip/unequip while typing in text box
		HandleEquip(value["tool"])
	end 
end)
Slots.Slot6.MouseButton1Click:Connect(function()
	local value = InputKeys["Six"]
	if value and UIS:GetFocusedTextBox() == nil then -- don't equip/unequip while typing in text box
		HandleEquip(value["tool"])
	end 
end)

local function formatTime(input)
	local output
	if type(input) ~= "number" or input < 0 then
		output = "--:--"
	else
		local formatString = "%i:%.2i"
		local seconds = math.floor(input % 60)
		local minutes = math.floor(input / 60)
		output = formatString:format(minutes, seconds)
	end
	return output
end

local function RequestCooldown()
	ReplicatedStorage.Events.RequestAssistance:FireServer()
	RequestTimer = 180
	SemiSlots.RequestButton.Counter.Visible = true
	SemiSlots.RequestButton.ImageLabel.ImageColor3 = ActivatedColor
	for i = 1, 180 do
		SemiSlots.RequestButton.Counter.Text = formatTime(RequestTimer)
		wait(1)
		RequestTimer = RequestTimer - 1
	end
	SemiSlots.RequestButton.Counter.Visible = false
	SemiSlots.RequestButton.ImageLabel.ImageColor3 = OriginalColor
end

UIS.InputBegan:Connect(function(input, processed)
	if not processed then
		if input.KeyCode == Enum.KeyCode.Q and RequestTimer < 1 and Player.Team == Teams["Survivors"] then
			RequestCooldown()
		end
	end
end)

SemiSlots.RequestButton.MouseButton1Click:Connect(function()
	if RequestTimer < 1 and Player.Team == Teams["Survivors"] then
		RequestCooldown()
	end
end)

ReplicatedStorage.Events.RequestResponse.OnClientEvent:Connect(function(PlayerName)
	if Player.Team == Teams["Survivors"] then
		local MarkerClone = ReplicatedStorage.Assets.AssistanceMarker:Clone()
		MarkerClone.Position = game.Workspace:WaitForChild(PlayerName).HumanoidRootPart.Position + Vector3.new(0, 5, 0)
		MarkerClone.Parent = game.Workspace.Debris
		script.Parent.Sounds.RequestAssistance:Play()
		wait(30)
		MarkerClone:Destroy()
	end
end)