local Player = game:GetService("Players").LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InfectedAbility = ReplicatedStorage.Events.InfectedAbility
local InfectedAbilityFunction = ReplicatedStorage.Functions.InfectedAbility
local InfectedAbilityResult = ReplicatedStorage.Events.InfectedAbilityResult
local UIS = game:GetService("UserInputService")
local Character = game:GetService('Players').LocalPlayer.Character
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")
local LandingSound = HumanoidRootPart:WaitForChild("Landing")
local AbilitiesLocked = false


local SuperJump = false
local Charging = false
local Gas = false

local Debounce1 = false
local Debounce2 = false
local Debounce3 = false

local Teams = game:GetService("Teams")
local InfectedTeam = Teams:WaitForChild("Infected")
local SurvivorTeam = Teams:WaitForChild("Survivors")

local ToolBar = script.Parent.ToolBar

local Slot1 = ToolBar.Frame.Frame.Slot1
local Slot2 = ToolBar.Frame.Frame.Slot2
local Slot3 = ToolBar.Frame.Frame.Slot3


local function FormatTime(input)
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

UIS.InputBegan:Connect(function(input)
	local IsJumping = Humanoid.Jump
	if input.KeyCode == Enum.KeyCode.One and Debounce1 == false and Player.Team == InfectedTeam and Player.Character:WaitForChild("Class").Value == "Bloater" and Character:WaitForChild("Humanoid").Health > 0 then
		Debounce1 = true
		InfectedAbility:FireServer("Bloater", "Gas")
		Gas = true
		Slot1.ImageLabel.Counter.Visible = true
		Slot1.ImageLabel.BackgroundColor3 = Color3.fromRGB(76,76,77)
		Slot1.ImageLabel.ImageColor3 = Color3.fromRGB(66,66,66)
		local CoolDown = 60
		while Gas == true do
			wait()
		end
		for i = 1, 60 do
			Slot1.ImageLabel.Counter.Text = FormatTime(CoolDown)
			CoolDown = CoolDown - 1
			wait(1)
		end
		Slot1.ImageLabel.Counter.Visible = false
		Slot1.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
		Slot1.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
		Debounce1 = false
	elseif input.KeyCode == Enum.KeyCode.Two and Debounce2 == false and Player.Team == InfectedTeam and Player.Character:WaitForChild("Class").Value == "Bloater" and Character:WaitForChild("Humanoid").Health > 0 then
		Debounce2 = true
		InfectedAbility:FireServer("Bloater", "Explode")
		Slot2.ImageLabel.BackgroundColor3 = Color3.fromRGB(76,76,77)
		Slot2.ImageLabel.ImageColor3 = Color3.fromRGB(66,66,66)
		wait(5)
		Debounce2 = false
	elseif input.KeyCode == Enum.KeyCode.One and Debounce1 == false and Player.Team == InfectedTeam and Player.Character:WaitForChild("Class").Value == "Wrecker" and AbilitiesLocked == false and Character:WaitForChild("Humanoid").Health > 0 then
		Debounce1 = true
		InfectedAbility:FireServer("Wrecker", "Charge")
		Charging = true
		Slot1.ImageLabel.BackgroundColor3 = Color3.fromRGB(76,76,77)
		Slot1.ImageLabel.ImageColor3 = Color3.fromRGB(66,66,66)
		AbilitiesLocked = true
		while Charging == true do
			wait()
		end
		Slot1.ImageLabel.Counter.Visible = true
		AbilitiesLocked = false
		local CoolDown = 80
		for i = 1, 80 do
			Slot1.ImageLabel.Counter.Text = FormatTime(CoolDown)
			CoolDown = CoolDown - 1
			wait(1)
		end
		Slot1.ImageLabel.Counter.Visible = false
		Slot1.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
		Slot1.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
		Debounce1 = false
	elseif input.KeyCode == Enum.KeyCode.Two and Debounce2 == false and Player.Team == InfectedTeam and Player.Character:WaitForChild("Class").Value == "Wrecker" and AbilitiesLocked == false and Character:WaitForChild("Humanoid").Health > 0 then
		Debounce2 = true
		Slot2.ImageLabel.BackgroundColor3 = Color3.fromRGB(76,76,77)
		Slot2.ImageLabel.ImageColor3 = Color3.fromRGB(66,66,66)
		AbilitiesLocked = true
		local AbilityActivated = InfectedAbilityFunction:InvokeServer("Wrecker", "Slam")
		local CoolDown = 80
		if AbilityActivated == true then
			Slot2.ImageLabel.Counter.Visible = true
			AbilitiesLocked = false
			for i = 1, 80 do
				Slot2.ImageLabel.Counter.Text = FormatTime(CoolDown)
				CoolDown = CoolDown - 1
				wait(1)
			end
		end
		AbilitiesLocked = false
		Slot2.ImageLabel.Counter.Visible = false
		Slot2.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
		Slot2.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
		Debounce2 = false
	elseif input.KeyCode == Enum.KeyCode.Two and Debounce2 == false and Player.Team == InfectedTeam and Player.Character:WaitForChild("Class").Value == "Ravager" and AbilitiesLocked == false and Character:WaitForChild("Humanoid").Health > 0 then
		Debounce2 = true
		Slot2.ImageLabel.BackgroundColor3 = Color3.fromRGB(76,76,77)
		Slot2.ImageLabel.ImageColor3 = Color3.fromRGB(66,66,66)
		AbilitiesLocked = true
		local AbilityActivated = InfectedAbilityFunction:InvokeServer("Ravager", "Slam")
		local CoolDown = 80
		if AbilityActivated == true then
			Slot2.ImageLabel.Counter.Visible = true
			AbilitiesLocked = false
			for i = 1, 80 do
				Slot2.ImageLabel.Counter.Text = FormatTime(CoolDown)
				CoolDown = CoolDown - 1
				wait(1)
			end
		end
		AbilitiesLocked = false
		Slot2.ImageLabel.Counter.Visible = false
		Slot2.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
		Slot2.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
		Debounce2 = false
	elseif input.KeyCode == Enum.KeyCode.One and Debounce1 == false and IsJumping ~= true and Player.Team == InfectedTeam and Player.Character:WaitForChild("Class").Value == "Ravager" and Character:WaitForChild("Humanoid").Health > 0 then
		Debounce1 = true
		InfectedAbility:FireServer("Ravager", "Super Jump")
		SuperJump = true
		Slot1.ImageLabel.Counter.Visible = true
		Slot1.ImageLabel.BackgroundColor3 = Color3.fromRGB(76,76,77)
		Slot1.ImageLabel.ImageColor3 = Color3.fromRGB(66,66,66)
		local CoolDown = 30
		for i = 1, 30 do
			Slot1.ImageLabel.Counter.Text = FormatTime(CoolDown)
			CoolDown = CoolDown - 1
			wait(1)
		end
		Slot1.ImageLabel.Counter.Visible = false
		Slot1.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
		Slot1.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
		Debounce1 = false
	end
end)

LandingSound.Changed:Connect(function()
	if LandingSound.Playing and SuperJump == true and Player.Team == InfectedTeam and Player.Character:WaitForChild("Class").Value == "Ravager" and Character:WaitForChild("Humanoid").Health > 0 then
		InfectedAbility:FireServer("Ravager", "Super Jump Land")
		SuperJump = false
	end
end)

ReplicatedStorage.GameData.PlayerStatus:WaitForChild(Player.Name).ClassValue.Changed:Connect(function()
	Slot1.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	Slot1.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
	Slot2.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	Slot3.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
	Slot3.ImageLabel.BackgroundColor3 = Color3.fromRGB(163, 162, 165)
	Slot3.ImageLabel.ImageColor3 = Color3.fromRGB(255,255,255)
	if ReplicatedStorage.GameData.PlayerStatus:WaitForChild(Player.Name).ClassValue.Value == "Walker" then
		Slot1.ImageLabel.Image = ""
		Slot2.ImageLabel.Image = ""
		Slot3.ImageLabel.Image = ""
	elseif ReplicatedStorage.GameData.PlayerStatus:WaitForChild(Player.Name).ClassValue.Value == "Runner" then
		Slot1.ImageLabel.Image = ""
		Slot2.ImageLabel.Image = ""
		Slot3.ImageLabel.Image = ""
	elseif ReplicatedStorage.GameData.PlayerStatus:WaitForChild(Player.Name).ClassValue.Value == "Bloater" then
		Slot1.ImageLabel.Image = "rbxassetid://10677548345" -- Gas
		Slot2.ImageLabel.Image = "rbxassetid://10677521783" -- Explode
		Slot3.ImageLabel.Image = ""
		Slot1.Visible = true
		Slot2.Visible = true
		Slot3.Visible = false
	elseif ReplicatedStorage.GameData.PlayerStatus:WaitForChild(Player.Name).ClassValue.Value == "Wrecker" then
		Slot1.ImageLabel.Image = "rbxassetid://10666417549" -- Charge
		Slot2.ImageLabel.Image = "rbxassetid://10666356227" -- Slam
		Slot3.ImageLabel.Image = ""
		Slot1.Visible = true
		Slot2.Visible = true
		Slot3.Visible = false
	elseif ReplicatedStorage.GameData.PlayerStatus:WaitForChild(Player.Name).ClassValue.Value == "Ravager" then
		Slot1.ImageLabel.Image = "rbxassetid://10677610323" -- Jump
		Slot2.ImageLabel.Image = "rbxassetid://6934479282" -- Smash
		Slot3.ImageLabel.Image = "" -- Rock throw
		Slot1.Visible = true
		Slot2.Visible = true
		Slot3.Visible = false
	end
end)

InfectedAbilityResult.OnClientEvent:Connect(function(Class, Ability)
	if Class == "Wrecker" then
		Charging = false
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if Charging == true then
		Humanoid:Move(Vector3.new(0,0,-1), true)
	end
end)