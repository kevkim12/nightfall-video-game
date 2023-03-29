local StarterGui = game:GetService("StarterGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
StarterGui:SetCore("TopbarEnabled", false)
StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)

if game:GetService("RunService"):IsStudio() then
	wait(5)
else
	wait(15)
end

-- VARIABLES --
local Players = game:GetService("Players")
local Player = game.Players.LocalPlayer

local HomeMenu = script.Parent.Frame.Menu.TopBar.Home
local LoadoutMenu = script.Parent.Frame.Menu.TopBar.Loadout
local StoreMenu = script.Parent.Frame.Menu.TopBar.Store
local VirusMenu = script.Parent.Frame.Menu.TopBar.Virus
local PartyListMenu = script.Parent.Frame.Menu.Profile.Other.Party
local ProfileMenu = script.Parent.Frame.Menu.Profile.Other.Profile
local SettingsMenu = script.Parent.Frame.Menu.Profile.Other.Settings
local MessageLabel = script.Parent.Frame.Menu.MessageLabel
local Background = script.Parent.Background

local MenuSelection = "Home"
local OtherSelection
local StoreSelection = "Home"
local SubStoreSelection
local Status = script.Parent.Values.Status.Value
local ForPurchase = script.Parent.Values.ForPurchase
local SelectionType = script.Parent.Values.SelectionType

local MapValue = ReplicatedStorage.GameData.Map

local HomeWindow = script.Parent.Frame.Windows.Home
local LoadoutWindow = script.Parent.Frame.Windows.Loadout
local StoreWindow = script.Parent.Frame.Windows.Store
local VirusWindow = script.Parent.Frame.Windows.Virus
local PartyListWindow = script.Parent.Frame.Menu.MenuWindows.Party
local PartyCreateWindow = script.Parent.Frame.Menu.MenuWindows.PartyCreate

local SelectSound = script.Parent.Sounds.Select
local BeepSound = script.Parent.Sounds.Beep
local DenySound = script.Parent.Sounds.Deny
local BuySound = script.Parent.Sounds.Buy
local ClickSound = script.Parent.Sounds.Click
local NewPartySound = script.Parent.Sounds.NewParty

local SkinToneSelection = script.Parent.Frame.Windows.Loadout.CharacterFrame.Frame.SkinToneSelection
local Navigation = script.Parent.Frame.Windows.Store.Left.Navigation
local ProductsWindow = script.Parent.Frame.Windows.Store.Left.Products
local fadeDuration = .2
local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local ThumbType = Enum.ThumbnailType.HeadShot
local ThumbSize = Enum.ThumbnailSize.Size420x420
local PlayerImage, isReady = Players:GetUserThumbnailAsync(Player.UserId, ThumbType, ThumbSize)

local PlayerSquad = ReplicatedStorage:WaitForChild("GameData").PlayerSquad:FindFirstChild(Player.Name)
local XP = ReplicatedStorage.GameData.PlayerData:FindFirstChild(Player.Name).Statistics.XP.Value
local Level = ReplicatedStorage.GameData.PlayerData:FindFirstChild(Player.Name).Statistics.Level.Value
local Credit = ReplicatedStorage.GameData.PlayerData:FindFirstChild(Player.Name).Statistics.Credit.Value
local XPNeeded = 5000
local LevelDisplay = script.Parent.Frame.Menu.Profile.Level

local Bar = script.Parent.Frame.Menu.Profile.XPBar.Fill

local CreditDisplay = script.Parent.Frame.Menu.Profile.Credits

local NeedPlayer = ReplicatedStorage.GameData.NeedPlayer
local Loading = ReplicatedStorage.GameData.Loading
local GameActive = ReplicatedStorage.GameData.GameActive

CreditDisplay.Text = "$" .. Credit
LevelDisplay.Text = "LEVEL " .. Level

local change = XP / XPNeeded
Bar:TweenSize(UDim2.new(change,0,1,0), "In", "Linear", 0.5)
script.Parent.Frame.Menu.Profile.XPBar.TextLabel.Text = (change * 100) .. "%"

local RoundDecimals = function(num, places)

	places = math.pow(10, places or 0)
	num = num * places

	if num >= 0 then 
		num = math.floor(num + 0.5) 
	else 
		num = math.ceil(num - 0.5) 
	end

	return num / places

end

ReplicatedStorage.Events.UpdateData.OnClientEvent:Connect(function(Type, Amount)
	if Type == "Credit" then
		script.Parent.Frame.Menu.Profile.Credits.Text = "$" .. Amount
	elseif Type == "XP" then
		XPNeeded = 5000
		change = Amount / XPNeeded
		Bar:TweenSize(UDim2.new(change,0,1,0), "In", "Linear", 0.5)
		script.Parent.Frame.Menu.Profile.XPBar.TextLabel.Text = (RoundDecimals(change, 2) * 100) .. "%"
	elseif Type == "Level" then
		LevelDisplay.Text = "LEVEL" .. Amount
	end
end)

if NeedPlayer.Value == true then
	MessageLabel.Text = "GAME INACTIVE"
end

NeedPlayer.Changed:Connect(function()
	if NeedPlayer.Value == true then
		MessageLabel.Text = "GAME INACTIVE"
	end
end)

if Loading.Value == true then
	MessageLabel.Text = "LOADING"
end

Loading.Changed:Connect(function()
	if Loading.Value == true then
		MessageLabel.Text = "LOADING"
	end
end)

GameActive.Changed:Connect(function()
	if GameActive.Value == false then
		MessageLabel.Text = "GAME INACTIVE"
		HomeWindow.Right.Map.MapLabel.Time.Text = "00:00"
	else
		MessageLabel.Text = "GAME ACTIVE"
	end
end)

ReplicatedStorage.Events.MenuMessage.OnClientEvent:Connect(function(Message)
	MessageLabel.Text = Message
end)

ReplicatedStorage.Events.UpdateTimer.OnClientEvent:Connect(function(Timer, Type)
	if Type == "INTERMISSION" then
		MessageLabel.Text = "INTERMISSION: " .. Timer
		if GameActive.Value == false and Timer == 0 then
			wait(1)
			if GameActive.Value == false and Timer == 0 and MessageLabel.Text ~= "STARTING GAME" then
				MessageLabel.Text = "GAME INACTIVE"
			end
		end
	elseif Type == "GAME" and GameActive.Value == true then
		MessageLabel.Text = "GAME ACTIVE"
		HomeWindow.Right.Map.MapLabel.Time.Text = Timer
	end
end)

ReplicatedStorage.Events.SoundEffect.OnClientEvent:Connect(function(Type, Command)
	if Type == "Beep" and Command == "Play" then
		BeepSound:Play()
	end
end)

-- MENU BAR --
HomeMenu.MouseEnter:Connect(function()
	if MenuSelection ~= "Home" then
		HomeMenu.TextLabel.Font = ("GothamSemibold")
		HomeMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	end
end)
HomeMenu.MouseLeave:Connect(function()
	if MenuSelection ~= "Home" then
		HomeMenu.TextLabel.Font = ("Gotham")
		HomeMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	end
end)
HomeMenu.MouseButton1Click:Connect(function()
	if MenuSelection ~= "Home" then
		SelectSound:Play()
	end
	game:GetService("TweenService"):Create(Background, tweenInfo, {BackgroundTransparency = 1}):Play()
	MenuSelection = "Home"
	HomeMenu.TextLabel.TextColor3 = Color3.new(1, 1, 1)
	LoadoutMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	StoreMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	VirusMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	HomeMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	LoadoutMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	StoreMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	VirusMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	HomeMenu.TextLabel.Font = ("GothamSemibold")
	LoadoutMenu.TextLabel.Font = ("Gotham")
	StoreMenu.TextLabel.Font = ("Gotham")
	VirusMenu.TextLabel.Font = ("Gotham")
	HomeWindow.Visible = true
	LoadoutWindow.Visible = false
	StoreWindow.Visible = false
	VirusWindow.Visible = false
end)

LoadoutMenu.MouseEnter:Connect(function()
	if MenuSelection ~= "Loadout" then
		LoadoutMenu.TextLabel.Font = ("GothamSemibold")
		LoadoutMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	end
end)
LoadoutMenu.MouseLeave:Connect(function()
	if MenuSelection ~= "Loadout" then
		LoadoutMenu.TextLabel.Font = ("Gotham")
		LoadoutMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	end
end)
LoadoutMenu.MouseButton1Click:Connect(function()
	if MenuSelection ~= "Loadout" then
		SelectSound:Play()
	end
	game:GetService("TweenService"):Create(Background, tweenInfo, {BackgroundTransparency = 0}):Play()
	MenuSelection = "Loadout"
	HomeMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	LoadoutMenu.TextLabel.TextColor3 = Color3.new(1, 1, 1)
	StoreMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	VirusMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	HomeMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	LoadoutMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	StoreMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	VirusMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	HomeMenu.TextLabel.Font = ("Gotham")
	LoadoutMenu.TextLabel.Font = ("GothamSemibold")
	StoreMenu.TextLabel.Font = ("Gotham")
	VirusMenu.TextLabel.Font = ("Gotham")
	HomeWindow.Visible = false
	LoadoutWindow.Visible = true
	StoreWindow.Visible = false
	VirusWindow.Visible = false
end)

StoreMenu.MouseEnter:Connect(function()
	if MenuSelection ~= "Store" then
		StoreMenu.TextLabel.Font = ("GothamSemibold")
		StoreMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	end
end)
StoreMenu.MouseLeave:Connect(function()
	if MenuSelection ~= "Store" then
		StoreMenu.TextLabel.Font = ("Gotham")
		StoreMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	end
end)
StoreMenu.MouseButton1Click:Connect(function()
	if MenuSelection ~= "Store" then
		SelectSound:Play()
	end
	game:GetService("TweenService"):Create(Background, tweenInfo, {BackgroundTransparency = 1}):Play()
	MenuSelection = "Store"
	HomeMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	LoadoutMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	StoreMenu.TextLabel.TextColor3 = Color3.new(1, 1, 1)
	VirusMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	HomeMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	LoadoutMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	StoreMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	VirusMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	HomeMenu.TextLabel.Font = ("Gotham")
	LoadoutMenu.TextLabel.Font = ("Gotham")
	StoreMenu.TextLabel.Font = ("GothamSemibold")
	VirusMenu.TextLabel.Font = ("Gotham")
	HomeWindow.Visible = false
	LoadoutWindow.Visible = false
	StoreWindow.Visible = true
	VirusWindow.Visible = false
end)

VirusMenu.MouseEnter:Connect(function()
	if MenuSelection ~= "Virus" then
		VirusMenu.TextLabel.Font = ("GothamSemibold")
		VirusMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	end
end)
VirusMenu.MouseLeave:Connect(function()
	if MenuSelection ~= "Virus" then
		VirusMenu.TextLabel.Font = ("Gotham")
		VirusMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	end
end)
VirusMenu.MouseButton1Click:Connect(function()
	if MenuSelection ~= "Virus" then
		SelectSound:Play()
	end
	game:GetService("TweenService"):Create(Background, tweenInfo, {BackgroundTransparency = 0}):Play()
	MenuSelection = "Virus"
	HomeMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	LoadoutMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	StoreMenu.TextLabel.TextColor3 = Color3.new(204/255, 202/255, 206/255)
	VirusMenu.TextLabel.TextColor3 = Color3.new(1, 1, 1)
	HomeMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	LoadoutMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	StoreMenu.TextLabel.Size = UDim2.new(1, 0, 0.382, 0)
	VirusMenu.TextLabel.Size = UDim2.new(1, 0, 0.445, 0)
	HomeMenu.TextLabel.Font = ("Gotham")
	LoadoutMenu.TextLabel.Font = ("Gotham")
	StoreMenu.TextLabel.Font = ("Gotham")
	VirusMenu.TextLabel.Font = ("GothamSemibold")
	HomeWindow.Visible = false
	LoadoutWindow.Visible = false
	StoreWindow.Visible = false
	VirusWindow.Visible = true
end)

local Player1 = PartyListWindow.PlayersFrame.List.Player1
local Player2 = PartyListWindow.PlayersFrame.List.Player2
local Player3 = PartyListWindow.PlayersFrame.List.Player3
local Player4 = PartyListWindow.PlayersFrame.List.Player4

local Player1XPNeeded = 5000
local Player1Bar = Player1.PlayerInfo.Frame.XPBar.Fill
local change = XP / Player1XPNeeded

PartyListMenu.MouseEnter:Connect(function()
	if OtherSelection ~= "Party" then
		PartyListMenu.UIGradient.Enabled = false
	end
end)
PartyListMenu.MouseLeave:Connect(function()
	if OtherSelection ~= "Party" then
		PartyListMenu.UIGradient.Enabled = true
	end
end)
PartyListMenu.MouseButton1Click:Connect(function()
	if OtherSelection ~= "Party" then
		OtherSelection = "Party"
		PartyListMenu.UIGradient.Enabled = false
		SettingsMenu.UIGradient.Enabled = true
		ProfileMenu.UIGradient.Enabled = true
		SelectSound:Play()
		if ReplicatedStorage.GameData.PlayerSquad:WaitForChild(Player.Name).InParty.Value == true then
			PartyListWindow.Visible = true
			PartyCreateWindow.Visible = false
		else
			PartyListWindow.Visible = false
			PartyCreateWindow.Visible = true
		end
	else
		OtherSelection = ""
		PartyListMenu.UIGradient.Enabled = true
		SettingsMenu.UIGradient.Enabled = true
		ProfileMenu.UIGradient.Enabled = true
		SelectSound:Play()
		PartyListWindow.Visible = false
		PartyCreateWindow.Visible = false
	end
end)
PartyListWindow.Background.Buttons.Close.MouseButton1Click:Connect(function()
	OtherSelection = ""
	PartyListWindow.Visible = false
	PartyListMenu.UIGradient.Enabled = true
	SelectSound:Play()
end)
PartyListWindow.Background.Buttons.Leave.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.Party:FireServer("Leave")
	SelectSound:Play()
end)
PartyCreateWindow.Frame.Buttons.Close.MouseButton1Click:Connect(function()
	OtherSelection = ""
	PartyCreateWindow.Visible = false
	PartyListMenu.UIGradient.Enabled = true
	SelectSound:Play()
end)
PartyCreateWindow.Frame.Buttons.Create.MouseButton1Click:Connect(function()
	SelectSound:Play()
	ReplicatedStorage.Events.Party:FireServer("Create")
end)


local change = XP / Player1XPNeeded
Player1Bar:TweenSize(UDim2.new(change,0,1,0), "In", "Linear", 0.5)
Player1.PlayerInfo.Frame.Level.LevelText.Text = "LEVEL " .. Level

ReplicatedStorage.Events.UpdateData.OnClientEvent:Connect(function(Type, Amount)
	if Type == "XP" then
		change = XP / Player1XPNeeded
		Player1Bar:TweenSize(UDim2.new(change,0,1,0), "In", "Linear", 0.5)
	elseif Type == "Level" then
		Player1.PlayerInfo.Frame.Level.LevelText.Text = "LEVEL " .. Amount
	end
end)

PlayerSquad.InParty.Changed:Connect(function()
	if PlayerSquad.InParty.Value == false then
		PartyListWindow.Visible = false
		PartyCreateWindow.Visible = true
	else
		PartyListWindow.Visible = true
		PartyCreateWindow.Visible = false
	end
end)
PlayerSquad.PartyOwner.Changed:Connect(function()
	if PlayerSquad.PartyOwner.Value == true then
		Player1.PartyLeader.Visible = true
	else
		Player1.PartyLeader.Visible = false
	end
end)

Player1.Image = PlayerImage
Player1.PlayerInfo.Frame.Tag.Title.Username.Text = Player.Name
local PartyPlayer1Selection = false

Player1.MouseButton1Click:Connect(function()
	if PartyPlayer1Selection == false then
		Player1.PlayerInfo.Visible = true
		PartyPlayer1Selection = true
	elseif PartyPlayer1Selection == true then
		Player1.PlayerInfo.Visible = false
		PartyPlayer1Selection = false
	end
	SelectSound:Play()
end)
Player1.PlayerInfo.Frame.Buttons.Close.MouseButton1Click:Connect(function()
	Player1.PlayerInfo.Visible = false
	PartyPlayer1Selection = false
	SelectSound:Play()
end)

-- HOME
local StatusButton = script.Parent.Frame.Windows.Home.Status.StatusButton
local StatusLabel = script.Parent.Frame.Windows.Home.Status.StatusButton.Frame.StatusTitle
local StatusDisplay = script.Parent.Frame.Windows.Home.Status.StatusButton.Frame.StatusDisplay
local ProfileFrame = script.Parent.Frame.Windows.Home.Right.Players.Profile

local StatusLocked = false
ReplicatedStorage.Events.StatusLock.OnClientEvent:Connect(function(Command)
	if Command == "Lock" then
		StatusLocked = true
		StatusDisplay.ImageColor3 = Color3.new(1, 1, 0)
		StatusLabel.Text = "LOCKED"
	elseif Command == "Unlock" then
		StatusLocked = false
		if Status == true then
			StatusButton.Image = "rbxassetid://6859458402"
			StatusLabel.Text = "ACTIVE"
			StatusDisplay.ImageColor3 = Color3.new(0, 1, 38/255)
			PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusTitle.Text = "ACTIVE"
			PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusDisplay.ImageColor3 = Color3.new(0, 1, 38/255)
		elseif Status == false then
			StatusButton.Image = "rbxassetid://6857304521"
			StatusLabel.Text = "INACTIVE"
			StatusDisplay.ImageColor3 = Color3.new(1, 0, 4/255)
			PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusTitle.Text = "INACTIVE"
			PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusDisplay.ImageColor3 = Color3.new(1, 0, 4/255)
		end
	end
end)


StatusButton.MouseButton1Click:Connect(function()
	ClickSound:Play()
	if Status == false and StatusLocked == false then
		game.ReplicatedStorage.Events.ToggleReady:FireServer(true)
		Status = true
		StatusButton.Image = "rbxassetid://6859458402"
		StatusLabel.Text = "ACTIVE"
		StatusDisplay.ImageColor3 = Color3.new(0, 1, 38/255)
		PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusTitle.Text = "ACTIVE"
		PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusDisplay.ImageColor3 = Color3.new(0, 1, 38/255)
	elseif Status == true and StatusLocked == false then
		game.ReplicatedStorage.Events.ToggleReady:FireServer(false)
		Status = false
		StatusButton.Image = "rbxassetid://6857304521"
		StatusLabel.Text = "INACTIVE"
		StatusDisplay.ImageColor3 = Color3.new(1, 0, 4/255)
		PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusTitle.Text = "INACTIVE"
		PartyListWindow.PlayersFrame.List.Player1.PlayerInfo.Frame.StatusLabel.StatusDisplay.ImageColor3 = Color3.new(1, 0, 4/255)
	end
end)

if ReplicatedStorage.GameData.StatusLocked.Value == true then
	StatusLocked = true
	StatusDisplay.ImageColor3 = Color3.new(1, 1, 0)
	StatusLabel.Text = "LOCKED"
end

StatusButton.MouseEnter:Connect(function()
	StatusButton.ImageColor3 = Color3.new(1,1,1)
end)
StatusButton.MouseLeave:Connect(function()
	StatusButton.ImageColor3 = Color3.new(226/255, 226/255, 226/255)
end)
ProfileFrame.Buttons.Close.MouseButton1Click:Connect(function()
	ProfileFrame.Visible = false
	script.Parent.Values.SelectedPlayer.Value = ""
	SelectSound:Play()
end)
ProfileFrame.Buttons.Invite.MouseButton1Click:Connect(function()
	DenySound:Play()
end)

local MapFrame = HomeWindow.Right.Map.MapFrame.ImageFrame
local MapImage1 = MapFrame.Slide1
local MapImage2 = MapFrame.Slide2
local MapImage3 = MapFrame.Slide3
local MapImage4 = MapFrame.Slide4

local function UpdateMap()
	if MapValue.Value == "Warzone" then
		MapFrame.Slide1.Visible = true
		MapFrame.Slide1.Image = "rbxassetid://6955151021"
		MapFrame.Slide2.Image = "rbxassetid://6959940111"
		MapFrame.Slide3.Image = "rbxassetid://6959975928"
		MapFrame.Slide4.Image = "rbxassetid://6959953699"
		MapFrame.MapName.Text = string.upper(MapValue.Value)
	elseif MapValue.Value == "District" then
		MapFrame.Slide1.Visible = true
		MapFrame.Slide1.Image = "rbxassetid://10943774364"
		MapFrame.Slide2.Image = "rbxassetid://10943775422"
		MapFrame.Slide3.Image = "rbxassetid://10943776655"
		MapFrame.Slide4.Image = "rbxassetid://10892179718"
		MapFrame.MapName.Text = string.upper(MapValue.Value)
	elseif MapValue.Value == "Sewers" then
		MapFrame.Slide1.Visible = true
		MapFrame.Slide1.Image = "rbxassetid://11361038145"
		MapFrame.Slide2.Image = "rbxassetid://11361039778"
		MapFrame.Slide3.Image = "rbxassetid://11361050126"
		MapFrame.Slide4.Image = "rbxassetid://11361051923"
		MapFrame.MapName.Text = string.upper(MapValue.Value)
	elseif MapValue.Value == "Arctic" then
		MapFrame.Slide1.Visible = true
		MapFrame.Slide1.Image = "rbxassetid://11090189497"
		MapFrame.Slide2.Image = "rbxassetid://11090190782"
		MapFrame.Slide3.Image = "rbxassetid://11090191983"
		MapFrame.Slide4.Image = "rbxassetid://11090295684"
		MapFrame.MapName.Text = string.upper(MapValue.Value)
	end
end

local Image1Tween = game:GetService("TweenService"):Create(MapImage1, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
	Position = UDim2.new(-0.77, 0, 0, 0)
}
)
local Image2Tween = game:GetService("TweenService"):Create(MapImage2, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
	Position = UDim2.new(0, 0, 0, 0)
}
)
local Image3Tween = game:GetService("TweenService"):Create(MapImage3, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
	Position = UDim2.new(-0.77, 0, 0, 0)
}
)
local Image4Tween = game:GetService("TweenService"):Create(MapImage4, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0), {
	Position = UDim2.new(0, 0, 0, 0)
}
)
local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

Image1Tween:Play()
Image1Tween.Completed:Connect(function()
	wait()
	game:GetService("TweenService"):Create(MapFrame.Slide1, tweenInfo, {ImageTransparency = 1}):Play()
	game:GetService("TweenService"):Create(MapFrame.Slide2, tweenInfo, {ImageTransparency = 0}):Play()
	MapFrame.Slide2.Position = UDim2.new(-0.77, 0, 0, 0)
	Image2Tween:Play()
end)
Image2Tween.Completed:Connect(function()
	wait()
	game:GetService("TweenService"):Create(MapFrame.Slide3, tweenInfo, {ImageTransparency = 0}):Play()
	game:GetService("TweenService"):Create(MapFrame.Slide2, tweenInfo, {ImageTransparency = 1}):Play()


	MapFrame.Slide3.Position = UDim2.new(0, 0, 0, 0)
	Image3Tween:Play()
end)
Image3Tween.Completed:Connect(function()
	wait()
	game:GetService("TweenService"):Create(MapFrame.Slide4, tweenInfo, {ImageTransparency = 0}):Play()
	game:GetService("TweenService"):Create(MapFrame.Slide3, tweenInfo, {ImageTransparency = 1}):Play()


	MapFrame.Slide4.Position = UDim2.new(-0.77, 0, 0, 0)
	Image4Tween:Play()
end)
Image4Tween.Completed:Connect(function()
	wait()
	game:GetService("TweenService"):Create(MapFrame.Slide1, tweenInfo, {ImageTransparency = 0}):Play()
	game:GetService("TweenService"):Create(MapFrame.Slide4, tweenInfo, {ImageTransparency = 1}):Play()


	MapFrame.Slide1.Position = UDim2.new(0, 0, 0, 0)
	Image1Tween:Play()
end)

UpdateMap()

local Voted = false
local VoteFrame = script.Parent.Frame.Windows.Home.VoteFrame
ReplicatedStorage.Events.StartVoteScreen.OnClientEvent:Connect(function(Map1, Mode1, Map2, Mode2, Map3, Mode3)
	VoteFrame.Visible = true
	Voted = false
	VoteFrame.Frame.OptionFrame.Map1.Votes.Text = 0
	VoteFrame.Frame.OptionFrame.Map2.Votes.Text = 0
	VoteFrame.Frame.OptionFrame.Map3.Votes.Text = 0
	VoteFrame.Frame.OptionFrame.Map1.MapButton.ImageColor3 = Color3.fromRGB(255,255,255)
	VoteFrame.Frame.OptionFrame.Map2.MapButton.ImageColor3 = Color3.fromRGB(255,255,255)
	VoteFrame.Frame.OptionFrame.Map3.MapButton.ImageColor3 = Color3.fromRGB(255,255,255)
	VoteFrame.Frame.OptionFrame.Map1.MapButton.Image = ReplicatedStorage.Assets.MapIcons:WaitForChild(Map1).Value
	VoteFrame.Frame.OptionFrame.Map1.MapButton.MapName.Text = Map1
	VoteFrame.Frame.OptionFrame.Map1.MapButton.Map.Value = Map1
	VoteFrame.Frame.OptionFrame.Map1.Mode.Text = Mode1
	VoteFrame.Frame.OptionFrame.Map2.MapButton.Image = ReplicatedStorage.Assets.MapIcons:WaitForChild(Map2).Value
	VoteFrame.Frame.OptionFrame.Map2.MapButton.MapName.Text = Map2
	VoteFrame.Frame.OptionFrame.Map2.MapButton.Map.Value = Map2
	VoteFrame.Frame.OptionFrame.Map2.Mode.Text = Mode2
	VoteFrame.Frame.OptionFrame.Map3.MapButton.Image = ReplicatedStorage.Assets.MapIcons:WaitForChild(Map3).Value
	VoteFrame.Frame.OptionFrame.Map3.MapButton.MapName.Text = Map3
	VoteFrame.Frame.OptionFrame.Map3.MapButton.Map.Value = Map3
	VoteFrame.Frame.OptionFrame.Map3.Mode.Text = Mode3
end)

ReplicatedStorage.Events.EndVoteScreen.OnClientEvent:Connect(function()
	VoteFrame.Visible = false
end)

ReplicatedStorage.Events.VoteCountdown.OnClientEvent:Connect(function(Time)
	VoteFrame.Frame.TextLabel.Text = " VOTE FOR THE NEXT MAP - " .. Time
end)

ReplicatedStorage.Events.UpdateVotes.OnClientEvent:Connect(function(Vote1, Vote2, Vote3)
	VoteFrame.Frame.OptionFrame.Map1.Votes.Text = Vote1
	VoteFrame.Frame.OptionFrame.Map2.Votes.Text = Vote2
	VoteFrame.Frame.OptionFrame.Map3.Votes.Text = Vote3
end)

VoteFrame.Frame.OptionFrame.Map1.MapButton.MouseButton1Click:Connect(function()
	if Voted == false then
		Voted = true
		VoteFrame.Frame.OptionFrame.Map1.MapButton.ImageColor3 = Color3.fromRGB(255,255,255)
		VoteFrame.Frame.OptionFrame.Map2.MapButton.ImageColor3 = Color3.fromRGB(70,70,70)
		VoteFrame.Frame.OptionFrame.Map3.MapButton.ImageColor3 = Color3.fromRGB(70,70,70)
		ReplicatedStorage.Events.VoteSelection:FireServer(1)
		SelectSound:Play()
	end
end)
VoteFrame.Frame.OptionFrame.Map2.MapButton.MouseButton1Click:Connect(function()
	if Voted == false then
		Voted = true
		VoteFrame.Frame.OptionFrame.Map1.MapButton.ImageColor3 = Color3.fromRGB(70,70,70)
		VoteFrame.Frame.OptionFrame.Map2.MapButton.ImageColor3 = Color3.fromRGB(255,255,255)
		VoteFrame.Frame.OptionFrame.Map3.MapButton.ImageColor3 = Color3.fromRGB(70,70,70)
		ReplicatedStorage.Events.VoteSelection:FireServer(2)
		SelectSound:Play()
	end
end)
VoteFrame.Frame.OptionFrame.Map3.MapButton.MouseButton1Click:Connect(function()
	if Voted == false then
		Voted = true
		VoteFrame.Frame.OptionFrame.Map1.MapButton.ImageColor3 = Color3.fromRGB(70,70,70)
		VoteFrame.Frame.OptionFrame.Map2.MapButton.ImageColor3 = Color3.fromRGB(70,70,70)
		VoteFrame.Frame.OptionFrame.Map3.MapButton.ImageColor3 = Color3.fromRGB(255,255,255)
		ReplicatedStorage.Events.VoteSelection:FireServer(3)
		SelectSound:Play()
	end
end)

ReplicatedStorage.GameData.Map.Changed:Connect(function()
	UpdateMap()
end)

-- LOADOUT
local CurrentSkinTone = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Character["Skin Tone"].Value
local CurrentPrimary = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Equipment.Primary.Value
local CurrentSecondary = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Equipment.Secondary.Value
local CurrentItem = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Equipment.Item.Value
local CurrentPrimary = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Equipment.Primary.Value
local CurrentFace = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Character.Face.Value
local CurrentHead = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Character.Head.Value
local CurrentClothes = ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Character.Clothes.Value
local TotalPrimary = ReplicatedStorage.EquipmentData.Primary:GetChildren()
local TotalSecondary = ReplicatedStorage.EquipmentData.Secondary:GetChildren()
local TotalItem = ReplicatedStorage.EquipmentData.Item:GetChildren()
local OwnedFaces = ReplicatedStorage.CharacterData.Face:GetChildren()
local OwnedHeads = ReplicatedStorage.CharacterData.Head:GetChildren()
local OwnedClothes = ReplicatedStorage.CharacterData.Clothes:GetChildren()
local LoadoutCharacter = script.Parent.Frame.Windows.Loadout.CharacterModel.ViewportFrame.WorldModel.LoadoutCharacter
local InventoryFrame = script.Parent.Frame.Windows.Loadout.InventoryFrame
local CharacterFrame = script.Parent.Frame.Windows.Loadout.CharacterFrame
local ClothingSelection = CharacterFrame.Frame.ClothingSelection
local CharacterFace = LoadoutCharacter.Head.face
local EquipmentFrame = script.Parent.Frame.Windows.Loadout.Right.EquipmentFrame
local EquipmentInventory = script.Parent.Frame.Windows.Loadout.Right.Bottom.EquipmentInventory
local EquipmentStatistics = script.Parent.Frame.Windows.Loadout.Right.Bottom.EquipmentStatistics
local PrimaryEquipButton = script.Parent.Frame.Windows.Loadout.Right.EquipmentFrame.Frame.Primary
local SecondaryEquipButton = script.Parent.Frame.Windows.Loadout.Right.EquipmentFrame.Frame.Secondary
local ItemEquipButton = script.Parent.Frame.Windows.Loadout.Right.EquipmentFrame.Frame.Item

local function ChangeSkinTone(Tone)
	if Tone == "Option1" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(255/255, 216/255, 185/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(255/255, 216/255, 185/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(255/255, 216/255, 185/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(255/255, 216/255, 185/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(255/255, 216/255, 185/255)
	elseif Tone == "Option2" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(255/255, 207/255, 169/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(255/255, 207/255, 169/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(255/255, 207/255, 169/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(255/255, 207/255, 169/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(255/255, 207/255, 169/255)
	elseif Tone == "Option3" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(255/255, 208/255, 164/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(255/255, 208/255, 164/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(255/255, 208/255, 164/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(255/255, 208/255, 164/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(255/255, 208/255, 164/255)
	elseif Tone == "Option4" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(245/255, 197/255, 148/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(245/255, 197/255, 148/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(245/255, 197/255, 148/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(245/255, 197/255, 148/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(245/255, 197/255, 148/255)
	elseif Tone == "Option5" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(245/255, 187/255, 136/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(245/255, 187/255, 136/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(245/255, 187/255, 136/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(245/255, 187/255, 136/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(245/255, 187/255, 136/255)
	elseif Tone == "Option6" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(245/255, 182/255, 130/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(245/255, 182/255, 130/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(245/255, 182/255, 130/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(245/255, 182/255, 130/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(245/255, 182/255, 130/255)
	elseif Tone == "Option7" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(201/255, 156/255, 125/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(201/255, 156/255, 125/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(201/255, 156/255, 125/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(201/255, 156/255, 125/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(201/255, 156/255, 125/255)
	elseif Tone == "Option8" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(178/255, 126/255, 89/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(178/255, 126/255, 89/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(178/255, 126/255, 89/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(178/255, 126/255, 89/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(178/255, 126/255, 89/255)
	elseif Tone == "Option9" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(150/255, 104/255, 70/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(150/255, 104/255, 70/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(150/255, 104/255, 70/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(150/255, 104/255, 70/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(150/255, 104/255, 70/255)
	elseif Tone == "Option10" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(100/255, 68/255, 47/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(100/255, 68/255, 47/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(100/255, 68/255, 47/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(100/255, 68/255, 47/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(100/255, 68/255, 47/255)
	elseif Tone == "Option11" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(76/255, 50/255, 35/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(76/255, 50/255, 35/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(76/255, 50/255, 35/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(76/255, 50/255, 35/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(76/255, 50/255, 35/255)
	elseif Tone == "Option12" then
		LoadoutCharacter["Body Colors"].HeadColor3 = Color3.new(57/255, 35/255, 21/255)
		LoadoutCharacter["Body Colors"].LeftArmColor3 = Color3.new(57/255, 35/255, 21/255)
		LoadoutCharacter["Body Colors"].RightArmColor3 = Color3.new(57/255, 35/255, 21/255)
		LoadoutCharacter["Body Colors"].RightLegColor3 = Color3.new(57/255, 35/255, 21/255)
		LoadoutCharacter["Body Colors"].TorsoColor3 = Color3.new(57/255, 35/255, 21/255)
	end
end



SkinToneSelection.Option1.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option1")
	SelectSound:Play()
end)
SkinToneSelection.Option2.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option2")
	SelectSound:Play()
end)
SkinToneSelection.Option3.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option3")
	SelectSound:Play()
end)
SkinToneSelection.Option4.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option4")
	SelectSound:Play()
end)
SkinToneSelection.Option5.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option5")
	SelectSound:Play()
end)
SkinToneSelection.Option6.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option6")
	SelectSound:Play()
end)
SkinToneSelection.Option7.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option7")
	SelectSound:Play()
end)
SkinToneSelection.Option8.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option8")
	SelectSound:Play()
end)
SkinToneSelection.Option9.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option9")
	SelectSound:Play()
end)
SkinToneSelection.Option10.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option10")
	SelectSound:Play()
end)
SkinToneSelection.Option11.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option11")
	SelectSound:Play()
end)
SkinToneSelection.Option12.MouseButton1Click:Connect(function()
	ReplicatedStorage.Events.DataSelection:FireServer("Skin Tone", "Option12")
	SelectSound:Play()
end)

local function ChangePrimary(Primary)
	local PrimaryInfo = ReplicatedStorage.EquipmentData.Primary:FindFirstChild(Primary)
	PrimaryEquipButton.ImageLabel.Image = PrimaryInfo.Icon.Value
	PrimaryEquipButton.TextLabel.Text = PrimaryInfo.Name
	HomeWindow.Status.Equipped.Primary.ImageLabel.Image = PrimaryInfo.Icon.Value
	HomeWindow.Status.Equipped.Primary.TextLabel.Text = PrimaryInfo.Name
end

local function ChangeSecondary(Secondary)
	local SecondaryInfo = ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(Secondary)
	SecondaryEquipButton.ImageLabel.Image = SecondaryInfo.Icon.Value
	SecondaryEquipButton.TextLabel.Text = SecondaryInfo.Name
	HomeWindow.Status.Equipped.Secondary.ImageLabel.Image = SecondaryInfo.Icon.Value
	HomeWindow.Status.Equipped.Secondary.TextLabel.Text = SecondaryInfo.Name
end

local function ChangeItem(Item)
	local ItemInfo = ReplicatedStorage.EquipmentData.Item:FindFirstChild(Item)
	ItemEquipButton.ImageLabel.Image = ItemInfo.Icon.Value
	ItemEquipButton.TextLabel.Text = ItemInfo.Name
	HomeWindow.Status.Equipped.Item.ImageLabel.Image = ItemInfo.Icon.Value
	HomeWindow.Status.Equipped.Item.TextLabel.Text = ItemInfo.Name
end

local function ChangeFace(Face)
	local FaceInfo = ReplicatedStorage.CharacterData.Face:FindFirstChild(Face)
	CharacterFace.Texture = FaceInfo.Icon.Value
	CharacterFrame.Frame.BodySelection.FaceOption.Image = FaceInfo.Icon.Value
end

local function ChangeHead(Head)
	local HeadInfo = ReplicatedStorage.CharacterData.Head:FindFirstChild(Head)
	CharacterFrame.Frame.ClothingSelection.HeadOption.Image =  HeadInfo.Icon.Value
end

local function ChangeClothes(Clothes)
	local ClothesInfo = ReplicatedStorage.CharacterData.Clothes:FindFirstChild(Clothes)
	CharacterFrame.Frame.ClothingSelection.ClothesOption.Image = ClothesInfo.Icon.Value
end

CharacterFrame.Frame.BodySelection.FaceOption.MouseButton1Click:Connect(function()
	SelectSound:Play()
	LoadoutWindow.InventoryFrame.Visible = true
	LoadoutWindow.InventoryFrame.Content.FaceFrame.Visible = true
	LoadoutWindow.InventoryFrame.Content.HeadFrame.Visible = false
	LoadoutWindow.InventoryFrame.Content.ClothesFrame.Visible = false
end)
CharacterFrame.Frame.ClothingSelection.HeadOption.MouseButton1Click:Connect(function()
	SelectSound:Play()
	LoadoutWindow.InventoryFrame.Visible = true
	LoadoutWindow.InventoryFrame.Content.FaceFrame.Visible = false
	LoadoutWindow.InventoryFrame.Content.HeadFrame.Visible = true
	LoadoutWindow.InventoryFrame.Content.ClothesFrame.Visible = false
end)
CharacterFrame.Frame.ClothingSelection.ClothesOption.MouseButton1Click:Connect(function()
	SelectSound:Play()
	LoadoutWindow.InventoryFrame.Visible = true
	LoadoutWindow.InventoryFrame.Content.FaceFrame.Visible = false
	LoadoutWindow.InventoryFrame.Content.HeadFrame.Visible = false
	LoadoutWindow.InventoryFrame.Content.ClothesFrame.Visible = true
end)

LoadoutWindow.InventoryFrame.InventoryLabel.Close.MouseButton1Click:Connect(function()
	SelectSound:Play()
	LoadoutWindow.InventoryFrame.Visible = false
end)

local EquipmentFrameSelection = ""
EquipmentFrame.Frame.Primary.MouseButton1Click:Connect(function()
	if EquipmentFrameSelection ~= "Primary" then
		EquipmentInventory.Label.TextLabel.Text = " PRIMARY"
		SelectSound:Play()
		EquipmentInventory.Primary.Visible = true
		EquipmentInventory.Secondary.Visible = false
		EquipmentInventory.Item.Visible = false
		EquipmentInventory.Visible = true
		EquipmentFrameSelection = "Primary"
	end
end)
EquipmentFrame.Frame.Secondary.MouseButton1Click:Connect(function()
	if EquipmentFrameSelection ~= "Secondary" then
		EquipmentInventory.Label.TextLabel.Text = " SECONDARY"
		SelectSound:Play()
		EquipmentInventory.Primary.Visible = false
		EquipmentInventory.Secondary.Visible = true
		EquipmentInventory.Item.Visible = false
		EquipmentInventory.Visible = true
		EquipmentFrameSelection = "Secondary"
	end
end)
EquipmentFrame.Frame.Item.MouseButton1Click:Connect(function()
	if EquipmentFrameSelection ~= "Item" then
		EquipmentInventory.Label.TextLabel.Text = " ITEM"
		SelectSound:Play()
		EquipmentInventory.Primary.Visible = false
		EquipmentInventory.Secondary.Visible = false
		EquipmentInventory.Item.Visible = true
		EquipmentInventory.Visible = true
		EquipmentFrameSelection = "Item"
	end
end)
EquipmentInventory.Label.Close.MouseButton1Click:Connect(function()
	SelectSound:Play()
	EquipmentInventory.Visible = false
	EquipmentFrameSelection = ""
end)

local function CreatePrimaryButtons()
	for i = 1, #TotalPrimary do
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Primary:FindFirstChild(TotalPrimary[i].Name).Value == true and EquipmentInventory.Primary:FindFirstChild(TotalPrimary[i].Name) == nil then
			local PrimaryButtonClone = ReplicatedStorage.Assets.EquipmentFrame:Clone()
			PrimaryButtonClone.ImageLabel.Image = ReplicatedStorage.EquipmentData.Primary[TotalPrimary[i].Name].Icon.Value
			PrimaryButtonClone.Name = ReplicatedStorage.EquipmentData.Primary[TotalPrimary[i].Name].Name
			PrimaryButtonClone.TextLabel.Text = ReplicatedStorage.EquipmentData.Primary[TotalPrimary[i].Name].Name
			PrimaryButtonClone.Parent = EquipmentInventory.Primary
		end
	end
end

local function CreateSecondaryButtons()
	for i = 1, #TotalSecondary do
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(TotalSecondary[i].Name).Value == true and EquipmentInventory.Secondary:FindFirstChild(TotalSecondary[i].Name) == nil then
			local SecondaryButtonClone = ReplicatedStorage.Assets.EquipmentFrame:Clone()
			SecondaryButtonClone.ImageLabel.Image = ReplicatedStorage.EquipmentData.Secondary[TotalSecondary[i].Name].Icon.Value
			SecondaryButtonClone.Name = ReplicatedStorage.EquipmentData.Secondary[TotalSecondary[i].Name].Name
			SecondaryButtonClone.TextLabel.Text = ReplicatedStorage.EquipmentData.Secondary[TotalSecondary[i].Name].Name
			SecondaryButtonClone.Parent = EquipmentInventory.Secondary
		end
	end
end

local function CreateItemButtons()
	for i = 1, #TotalItem do
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(TotalItem[i].Name).Value == true and EquipmentInventory.Item:FindFirstChild(TotalItem[i].Name) == nil then
			local ItemButtonClone = ReplicatedStorage.Assets.EquipmentFrame:Clone()
			ItemButtonClone.ImageLabel.Image = ReplicatedStorage.EquipmentData.Item[TotalItem[i].Name].Icon.Value
			ItemButtonClone.Name = ReplicatedStorage.EquipmentData.Item[TotalItem[i].Name].Name
			ItemButtonClone.TextLabel.Text = ReplicatedStorage.EquipmentData.Item[TotalItem[i].Name].Name
			ItemButtonClone.Parent = EquipmentInventory.Item
		end
	end
end

local function CreateFaceButtons()
	for i = 1, #OwnedFaces do
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Face:FindFirstChild(OwnedFaces[i].Name).Value == true and InventoryFrame.Content.FaceFrame:FindFirstChild(OwnedFaces[i].Name) == nil then
			local FaceFrameClone = ReplicatedStorage.Assets.FaceFrame:Clone()
			FaceFrameClone.ImageLabel.Image = ReplicatedStorage.CharacterData.Face[OwnedFaces[i].Name].Icon.Value
			FaceFrameClone.Name = ReplicatedStorage.CharacterData.Face[OwnedFaces[i].Name].Name
			FaceFrameClone.TextLabel.Text = ReplicatedStorage.CharacterData.Face[OwnedFaces[i].Name].Name
			FaceFrameClone.Parent = InventoryFrame.Content.FaceFrame
		end
	end
end

local function CreateHeadButtons()
	for i = 1, #OwnedHeads do
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Head:FindFirstChild(OwnedHeads[i].Name).Value == true and InventoryFrame.Content.HeadFrame:FindFirstChild(OwnedHeads[i].Name) == nil then
			local HeadFrameClone = ReplicatedStorage.Assets.HeadFrame:Clone()
			HeadFrameClone.ImageLabel.Image = ReplicatedStorage.CharacterData.Head[OwnedHeads[i].Name].Icon.Value
			HeadFrameClone.Name = ReplicatedStorage.CharacterData.Head[OwnedHeads[i].Name].Name
			HeadFrameClone.TextLabel.Text = ReplicatedStorage.CharacterData.Head[OwnedHeads[i].Name].Name
			HeadFrameClone.Parent = InventoryFrame.Content.HeadFrame
		end
	end
end

local function CreateClothingButtons()
	for i = 1, #OwnedClothes do
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Clothes:FindFirstChild(OwnedClothes[i].Name).Value == true and InventoryFrame.Content.ClothesFrame:FindFirstChild(OwnedClothes[i].Name) == nil then
			local ClothingFrameClone = ReplicatedStorage.Assets.ClothesFrame:Clone()
			ClothingFrameClone.ImageLabel.Image = ReplicatedStorage.CharacterData.Clothes[OwnedClothes[i].Name].Icon.Value
			ClothingFrameClone.Name = ReplicatedStorage.CharacterData.Clothes[OwnedClothes[i].Name].Name
			ClothingFrameClone.TextLabel.Text = ReplicatedStorage.CharacterData.Clothes[OwnedClothes[i].Name].Name
			ClothingFrameClone.Parent = InventoryFrame.Content.ClothesFrame
		end
	end
end

-- STORE
local function NavigationSelection(Selected)
	local NavigationItems = Navigation.Frame.Buttons:GetChildren()
	for i = 1, #NavigationItems do
		if NavigationItems[i]:isA("TextButton") then
			if NavigationItems[i].Name ~= Selected then
				NavigationItems[i].BackgroundColor3 = Color3.new(1,1,1)
				NavigationItems[i].TextLabel.TextColor3 = Color3.new(45/255,45/255,45/255)
			else
				NavigationItems[i].BackgroundColor3 = Color3.new(74/255, 74/255, 74/255)
				NavigationItems[i].TextLabel.TextColor3 = Color3.new(1,1,1)
			end
		end
	end
end

Navigation.Frame.Buttons.Home.MouseButton1Click:Connect(function()
	if StoreSelection ~= "Home" then
		SelectSound:Play()
	end
	ProductsWindow.HomeTitle.Visible = true
	ProductsWindow.EquipmentSelection.Visible = false
	ProductsWindow.CharacterSelection.Visible = false
	ProductsWindow.ProfileSelection.Visible = false
	ProductsWindow.RobuxSelection.Visible = false
	StoreSelection = "Home"
	NavigationSelection(StoreSelection)
	ProductsWindow.Content.Home.Visible = true
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
Navigation.Frame.Buttons.Equipment.MouseButton1Click:Connect(function()
	if StoreSelection ~= "Equipment" then
		SelectSound:Play()
	end
	SubStoreSelection = "Primary"
	ProductsWindow.HomeTitle.Visible = false
	ProductsWindow.EquipmentSelection.Primary.BackgroundTransparency = 0
	ProductsWindow.EquipmentSelection.Secondary.BackgroundTransparency = 0.5
	ProductsWindow.EquipmentSelection.Item.BackgroundTransparency = 0.5
	ProductsWindow.EquipmentSelection.Visible = true
	ProductsWindow.CharacterSelection.Visible = false
	ProductsWindow.ProfileSelection.Visible = false
	ProductsWindow.RobuxSelection.Visible = false
	StoreSelection = "Equipment"
	NavigationSelection(StoreSelection)
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = true
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
Navigation.Frame.Buttons.Character.MouseButton1Click:Connect(function()
	if StoreSelection ~= "Character" then
		SelectSound:Play()
	end
	SubStoreSelection = "Head"
	ProductsWindow.HomeTitle.Visible = false
	ProductsWindow.CharacterSelection.Face.BackgroundTransparency = 0.5
	ProductsWindow.CharacterSelection.Head.BackgroundTransparency = 0
	ProductsWindow.CharacterSelection.Clothing.BackgroundTransparency = 0.5
	ProductsWindow.EquipmentSelection.Visible = false
	ProductsWindow.CharacterSelection.Visible = true
	ProductsWindow.ProfileSelection.Visible = false
	ProductsWindow.RobuxSelection.Visible = false
	StoreSelection = "Character"
	NavigationSelection(StoreSelection)
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = true
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
Navigation.Frame.Buttons.Profile.MouseButton1Click:Connect(function()
	if StoreSelection ~= "Profile" then
		SelectSound:Play()
	end
	SubStoreSelection = "Titles"
	ProductsWindow.HomeTitle.Visible = false
	ProductsWindow.ProfileSelection.Titles.BackgroundTransparency = 0
	ProductsWindow.EquipmentSelection.Visible = false
	ProductsWindow.CharacterSelection.Visible = false
	ProductsWindow.ProfileSelection.Visible = true
	ProductsWindow.RobuxSelection.Visible = false
	StoreSelection = "Profile"
	NavigationSelection(StoreSelection)
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = true
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
Navigation.Frame.Buttons.Robux.MouseButton1Click:Connect(function()
	if StoreSelection ~= "Robux" then
		SelectSound:Play()
	end
	SubStoreSelection = "Credits"
	ProductsWindow.HomeTitle.Visible = false
	ProductsWindow.EquipmentSelection.Visible = false
	ProductsWindow.CharacterSelection.Visible = false
	ProductsWindow.ProfileSelection.Visible = false
	ProductsWindow.RobuxSelection.Visible = true
	StoreSelection = "Robux"
	NavigationSelection(StoreSelection)
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = true
	ProductsWindow.Content.Gamepasses.Visible = false
end)

ProductsWindow.EquipmentSelection.Primary.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Primary" then
		SelectSound:Play()
	end
	SubStoreSelection = "Primary"
	ProductsWindow.EquipmentSelection.Primary.BackgroundTransparency = 0
	ProductsWindow.EquipmentSelection.Secondary.BackgroundTransparency = 0.5
	ProductsWindow.EquipmentSelection.Item.BackgroundTransparency = 0.5
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = true
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.EquipmentSelection.Secondary.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Secondary" then
		SelectSound:Play()
	end
	SubStoreSelection = "Secondary"
	ProductsWindow.EquipmentSelection.Primary.BackgroundTransparency = 0.5
	ProductsWindow.EquipmentSelection.Secondary.BackgroundTransparency = 0
	ProductsWindow.EquipmentSelection.Item.BackgroundTransparency = 0.5
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = true
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.EquipmentSelection.Item.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Item" then
		SelectSound:Play()
	end
	SubStoreSelection = "Item"
	ProductsWindow.EquipmentSelection.Primary.BackgroundTransparency = 0.5
	ProductsWindow.EquipmentSelection.Secondary.BackgroundTransparency = 0.5
	ProductsWindow.EquipmentSelection.Item.BackgroundTransparency = 0
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = true
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.CharacterSelection.Face.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Face" then
		SelectSound:Play()
	end
	SubStoreSelection = "Face"
	ProductsWindow.CharacterSelection.Head.BackgroundTransparency = 0.5
	ProductsWindow.CharacterSelection.Clothing.BackgroundTransparency = 0.5
	ProductsWindow.CharacterSelection.Face.BackgroundTransparency = 0
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = true
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.CharacterSelection.Head.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Head" then
		SelectSound:Play()
	end
	SubStoreSelection = "Head"
	ProductsWindow.CharacterSelection.Head.BackgroundTransparency = 0
	ProductsWindow.CharacterSelection.Clothing.BackgroundTransparency = 0.5
	ProductsWindow.CharacterSelection.Face.BackgroundTransparency = 0.5
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = true
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.CharacterSelection.Clothing.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Clothing" then
		SelectSound:Play()
	end
	SubStoreSelection = "Clothing"
	ProductsWindow.CharacterSelection.Head.BackgroundTransparency = 0.5
	ProductsWindow.CharacterSelection.Clothing.BackgroundTransparency = 0
	ProductsWindow.CharacterSelection.Face.BackgroundTransparency = 0.5
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = true
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.ProfileSelection.Titles.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Titles" then
		SelectSound:Play()
	end
	SubStoreSelection = "Titles"
	ProductsWindow.ProfileSelection.Titles.BackgroundTransparency = 0
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = true
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.RobuxSelection.Credits.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Credits" then
		SelectSound:Play()
	end
	SubStoreSelection = "Credits"
	ProductsWindow.RobuxSelection.Credits.BackgroundTransparency = 0
	ProductsWindow.RobuxSelection.Gamepasses.BackgroundTransparency = 0.5
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = true
	ProductsWindow.Content.Gamepasses.Visible = false
end)
ProductsWindow.RobuxSelection.Gamepasses.MouseButton1Click:Connect(function()
	if SubStoreSelection ~= "Gamepasses" then
		SelectSound:Play()
	end
	SubStoreSelection = "Gamepasses"
	ProductsWindow.RobuxSelection.Credits.BackgroundTransparency = 0.5
	ProductsWindow.RobuxSelection.Gamepasses.BackgroundTransparency = 0
	ProductsWindow.Content.Home.Visible = false
	ProductsWindow.Content.Primary.Visible = false
	ProductsWindow.Content.Secondary.Visible = false
	ProductsWindow.Content.Item.Visible = false
	ProductsWindow.Content.Face.Visible = false
	ProductsWindow.Content.Head.Visible = false
	ProductsWindow.Content.Clothing.Visible = false
	ProductsWindow.Content.Titles.Visible = false
	ProductsWindow.Content.Credits.Visible = false
	ProductsWindow.Content.Gamepasses.Visible = true
end)

local ContentWindow = script.Parent.Frame.Windows.Store.Left.Products.Content

local NumericalLetters = "a" or "b" or "c"
local PrimaryProducts = ReplicatedStorage.EquipmentData.Primary:GetChildren()
local function StorePrimaryButtons()
	for i = 1, #PrimaryProducts do
		if ContentWindow.Primary:FindFirstChild(NumericalLetters .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. PrimaryProducts[i].Name) == nil then
			local PrimaryStoreFrameClone = ReplicatedStorage.Assets.EquipmentStoreFrame:Clone()
			PrimaryStoreFrameClone.ProductName.Value = PrimaryProducts[i].Name
			PrimaryStoreFrameClone.ProductType.Value = PrimaryProducts[i].ProductType.Value
			PrimaryStoreFrameClone.ImageLabel.Image = ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Icon.Value
			if ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value >= 0 and ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value < 10 then
				PrimaryStoreFrameClone.Name = "a".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name
			elseif ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value >= 10 and ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value < 100 then
				PrimaryStoreFrameClone.Name = "b".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name
			elseif ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value >= 100 and ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value < 1000 then
				PrimaryStoreFrameClone.Name = "c".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name	
			end
			PrimaryStoreFrameClone.TextLabel.Text = " " .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name
			PrimaryStoreFrameClone.Lock.TextLabel.Text = "$" .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Price.Value
			PrimaryStoreFrameClone.Parent = ContentWindow.Primary
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Primary:FindFirstChild(PrimaryProducts[i].Name).Value == true then
				ContentWindow.Primary:FindFirstChild(PrimaryStoreFrameClone.Name).Lock.Visible = false
			elseif Level < ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value then
				ContentWindow.Primary:FindFirstChild(PrimaryStoreFrameClone.Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value
			else
				ContentWindow.Primary:FindFirstChild(PrimaryStoreFrameClone.Name).Lock.TextLabel.Text = "$" .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Price.Value
			end
		else
			if ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value >= 0 and ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value < 10 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Primary:FindFirstChild(PrimaryProducts[i].Name).Value == true then
					ContentWindow.Primary:FindFirstChild("a".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value then
					ContentWindow.Primary:FindFirstChild("a".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value
				end
			elseif ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value >= 10 and ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value < 100 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Primary:FindFirstChild(PrimaryProducts[i].Name).Value == true then
					ContentWindow.Primary:FindFirstChild("b".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value then
					ContentWindow.Primary:FindFirstChild("b".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value
				end
			elseif ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value >= 100 and ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value < 1000 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Primary:FindFirstChild(PrimaryProducts[i].Name).Value == true then
					ContentWindow.Primary:FindFirstChild("c".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value then
					ContentWindow.Primary:FindFirstChild("c".. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Primary[PrimaryProducts[i].Name].Level.Value
				end
			end
		end
	end
end

local SecondaryProducts = ReplicatedStorage.EquipmentData.Secondary:GetChildren()
local function StoreSecondaryButtons()
	for i = 1, #SecondaryProducts do
		if ContentWindow.Secondary:FindFirstChild(NumericalLetters .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. SecondaryProducts[i].Name) == nil then
			local SecondaryStoreFrameClone = ReplicatedStorage.Assets.EquipmentStoreFrame:Clone()
			SecondaryStoreFrameClone.ProductName.Value = SecondaryProducts[i].Name
			SecondaryStoreFrameClone.ProductType.Value = SecondaryProducts[i].ProductType.Value
			SecondaryStoreFrameClone.ImageLabel.Image = ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Icon.Value
			if ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value >= 0 and ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value < 10 then
				SecondaryStoreFrameClone.Name = "a".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name
			elseif ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value >= 10 and ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value < 100 then
				SecondaryStoreFrameClone.Name = "b".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name
			elseif ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value >= 100 and ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value < 1000 then
				SecondaryStoreFrameClone.Name = "c".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name	
			end
			SecondaryStoreFrameClone.TextLabel.Text = " " .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name
			SecondaryStoreFrameClone.Lock.TextLabel.Text = "$" .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Price.Value
			SecondaryStoreFrameClone.Parent = ContentWindow.Secondary
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(SecondaryProducts[i].Name).Value == true then
				ContentWindow.Secondary:FindFirstChild(SecondaryStoreFrameClone.Name).Lock.Visible = false
			elseif Level < ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value then
				ContentWindow.Secondary:FindFirstChild(SecondaryStoreFrameClone.Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value
			else
				ContentWindow.Secondary:FindFirstChild(SecondaryStoreFrameClone.Name).Lock.TextLabel.Text = "$" .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Price.Value
			end
		else
			if ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value >= 0 and ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value < 10 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(SecondaryProducts[i].Name).Value == true then
					ContentWindow.Secondary:FindFirstChild("a".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value then
					ContentWindow.Secondary:FindFirstChild("a".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value
				end
			elseif ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value >= 10 and ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value < 100 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(SecondaryProducts[i].Name).Value == true then
					ContentWindow.Secondary:FindFirstChild("b".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value then
					ContentWindow.Secondary:FindFirstChild("b".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value
				end
			elseif ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value >= 100 and ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value < 1000 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(SecondaryProducts[i].Name).Value == true then
					ContentWindow.Secondary:FindFirstChild("c".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value then
					ContentWindow.Secondary:FindFirstChild("c".. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Secondary[SecondaryProducts[i].Name].Level.Value
				end
			end
		end
	end
end

local ItemProducts = ReplicatedStorage.EquipmentData.Item:GetChildren()
local function StoreItemButtons()
	for i = 1, #ItemProducts do
		if ContentWindow.Item:FindFirstChild(NumericalLetters .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ItemProducts[i].Name) == nil then
			local ItemStoreFrameClone = ReplicatedStorage.Assets.EquipmentStoreFrame:Clone()
			ItemStoreFrameClone.ProductName.Value = ItemProducts[i].Name
			ItemStoreFrameClone.ProductType.Value = ItemProducts[i].ProductType.Value
			ItemStoreFrameClone.ImageLabel.Image = ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Icon.Value
			if ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value >= 0 and ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value < 10 then
				ItemStoreFrameClone.Name = "a".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name
			elseif ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value >= 10 and ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value < 100 then
				ItemStoreFrameClone.Name = "b".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name
			elseif ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value >= 100 and ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value < 1000 then
				ItemStoreFrameClone.Name = "c".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name	
			end
			ItemStoreFrameClone.TextLabel.Text = " " .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name
			ItemStoreFrameClone.Lock.TextLabel.Text = "$" .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Price.Value
			ItemStoreFrameClone.Parent = ContentWindow.Item
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(ItemProducts[i].Name).Value == true then
				ContentWindow.Item:FindFirstChild(ItemStoreFrameClone.Name).Lock.Visible = false
			elseif Level < ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value then
				ContentWindow.Item:FindFirstChild(ItemStoreFrameClone.Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value
			else
				ContentWindow.Item:FindFirstChild(ItemStoreFrameClone.Name).Lock.TextLabel.Text = "$" .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Price.Value
			end
		else
			if ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value >= 0 and ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value < 10 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(ItemProducts[i].Name).Value == true then
					ContentWindow.Item:FindFirstChild("a".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value then
					ContentWindow.Item:FindFirstChild("a".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value
				end
			elseif ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value >= 10 and ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value < 100 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(ItemProducts[i].Name).Value == true then
					ContentWindow.Item:FindFirstChild("b".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value then
					ContentWindow.Item:FindFirstChild("b".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value
				end
			elseif ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value >= 100 and ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value < 1000 then
				if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(ItemProducts[i].Name).Value == true then
					ContentWindow.Item:FindFirstChild("c".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name).Lock.Visible = false
				elseif Level < ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value then
					ContentWindow.Item:FindFirstChild("c".. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value .. ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Name).Lock.TextLabel.Text = "LEVEL " ..  ReplicatedStorage.EquipmentData.Item[ItemProducts[i].Name].Level.Value
				end
			end
		end
	end
end

local FaceProducts = ReplicatedStorage.CharacterData.Face:GetChildren()
local function StoreFaceButtons()
	for i = 1, #FaceProducts do
		if ContentWindow.Face:FindFirstChild(FaceProducts[i].Name) == nil and FaceProducts[i].Name ~= "None" then
			local FaceStoreFrameClone = ReplicatedStorage.Assets.FaceStoreFrame:Clone()
			FaceStoreFrameClone.Name = FaceProducts[i].Name
			FaceStoreFrameClone.ProductName.Value = FaceProducts[i].Name
			FaceStoreFrameClone.ProductType.Value = FaceProducts[i].ProductType.Value
			FaceStoreFrameClone.ImageLabel.Image = ReplicatedStorage.CharacterData.Face[FaceProducts[i].Name].Icon.Value
			FaceStoreFrameClone.TextLabel.Text = ReplicatedStorage.CharacterData.Face[FaceProducts[i].Name].Name
			FaceStoreFrameClone.Lock.TextLabel.Text = "$" .. ReplicatedStorage.CharacterData.Face[FaceStoreFrameClone.TextLabel.Text].Price.Value
			FaceStoreFrameClone.Parent = ContentWindow.Face
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Face:FindFirstChild(FaceProducts[i].Name).Value == true then
				ContentWindow.Face:FindFirstChild(FaceStoreFrameClone.Name).Lock.Visible = false
			else
				FaceStoreFrameClone.Lock.Visible = true
			end
		elseif FaceProducts[i].Name ~= "None" then
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Face:FindFirstChild(FaceProducts[i].Name).Value == true then
				ContentWindow.Face:FindFirstChild(FaceProducts[i].Name).Lock.Visible = false
			else
				ContentWindow.Face:FindFirstChild(FaceProducts[i].Name).Lock.Visible = true
			end
		end
	end
end

local HeadProducts = ReplicatedStorage.CharacterData.Head:GetChildren()
local function StoreHeadButtons()
	for i = 1, #HeadProducts do
		if ContentWindow.Head:FindFirstChild(HeadProducts[i].Name) == nil and HeadProducts[i].Name ~= "None" then
			local HeadStoreFrameClone = ReplicatedStorage.Assets.HeadStoreFrame:Clone()
			HeadStoreFrameClone.Name = HeadProducts[i].Name
			HeadStoreFrameClone.ProductName.Value = HeadProducts[i].Name
			HeadStoreFrameClone.ProductType.Value = HeadProducts[i].ProductType.Value
			HeadStoreFrameClone.ImageLabel.Image = ReplicatedStorage.CharacterData.Head[HeadProducts[i].Name].Icon.Value
			HeadStoreFrameClone.TextLabel.Text = ReplicatedStorage.CharacterData.Head[HeadProducts[i].Name].Name
			HeadStoreFrameClone.Lock.TextLabel.Text = "$" .. ReplicatedStorage.CharacterData.Head[HeadStoreFrameClone.TextLabel.Text].Price.Value
			HeadStoreFrameClone.Parent = ContentWindow.Head
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Head:FindFirstChild(HeadProducts[i].Name).Value == true then
				ContentWindow.Head:FindFirstChild(HeadStoreFrameClone.Name).Lock.Visible = false
			else
				HeadStoreFrameClone.Lock.Visible = true
			end
		elseif HeadProducts[i].Name ~= "None" then
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Head:FindFirstChild(HeadProducts[i].Name).Value == true then
				ContentWindow.Head:FindFirstChild(HeadProducts[i].Name).Lock.Visible = false
			else
				ContentWindow.Head:FindFirstChild(HeadProducts[i].Name).Lock.Visible = true
			end
		end
	end
end

local ClothingProducts = ReplicatedStorage.CharacterData.Clothes:GetChildren()
local function StoreClothingButtons()
	for i = 1, #ClothingProducts do
		if ContentWindow.Clothing:FindFirstChild(ClothingProducts[i].Name) == nil then
			local ClothingStoreFrameClone = ReplicatedStorage.Assets.ClothingStoreFrame:Clone()
			ClothingStoreFrameClone.Name = ClothingProducts[i].Name
			ClothingStoreFrameClone.ProductName.Value = ClothingProducts[i].Name
			ClothingStoreFrameClone.ProductType.Value = ClothingProducts[i].ProductType.Value
			ClothingStoreFrameClone.ImageLabel.Image = ReplicatedStorage.CharacterData.Clothes[ClothingProducts[i].Name].Icon.Value
			ClothingStoreFrameClone.TextLabel.Text = ReplicatedStorage.CharacterData.Clothes[ClothingProducts[i].Name].Name
			ClothingStoreFrameClone.Parent = ContentWindow.Clothing
			ClothingStoreFrameClone.Lock.TextLabel.Text = "$" .. ReplicatedStorage.CharacterData.Clothes[ClothingProducts[i].Name].Price.Value
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Clothes:FindFirstChild(ClothingProducts[i].Name).Value == true then
				ContentWindow.Clothing:FindFirstChild(ClothingStoreFrameClone.Name).Lock.Visible = false
			else
				ClothingStoreFrameClone.Lock.Visible = true
			end
		else
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Clothes:FindFirstChild(ClothingProducts[i].Name).Value == true then
				ContentWindow.Clothing:FindFirstChild(ClothingProducts[i].Name).Lock.Visible = false
			else
				ContentWindow.Clothing:FindFirstChild(ClothingProducts[i].Name).Lock.Visible = true
			end
		end
	end
end

StoreFaceButtons()
StoreHeadButtons()
StorePrimaryButtons()
StoreSecondaryButtons()
StoreItemButtons()
StoreClothingButtons()
CreatePrimaryButtons()
CreateSecondaryButtons()
CreateItemButtons()
CreateFaceButtons()
CreateHeadButtons()
CreateClothingButtons()
ChangePrimary(CurrentPrimary)
ChangeSecondary(CurrentSecondary)
ChangeItem(CurrentItem)
ChangeFace(CurrentFace)
ChangeSkinTone(CurrentSkinTone)
ChangeHead(CurrentHead)
ChangeClothes(CurrentClothes)

ReplicatedStorage.Events.UpdateData.OnClientEvent:Connect(function(Type, Data)
	if Type == "Skin Tone" then
		ChangeSkinTone(Data)
	elseif Type == "Face" then
		ChangeFace(Data)
	elseif Type == "Head" then
		ChangeHead(Data)
	elseif Type == "Clothes" then
		ChangeClothes(Data)
	elseif Type == "Primary" then
		ChangePrimary(Data)
	elseif Type == "Secondary" then
		ChangeSecondary(Data)
	elseif Type == "Item" then
		ChangeItem(Data)
	elseif Type == "Inventory" then
		StoreFaceButtons()
		StoreHeadButtons()
		StoreClothingButtons()
		StorePrimaryButtons()
		StoreSecondaryButtons()
		StoreItemButtons()
		CreatePrimaryButtons()
		CreateSecondaryButtons()
		CreateItemButtons()
		CreateHeadButtons()
		CreateClothingButtons()
		CreateFaceButtons()
	end
end)

local Purchase = script.Parent.Frame.Windows.Store.Purchase.Background
local StoreLoading = script.Parent.Frame.Windows.Store.StoreLoading

Purchase.Buttons.Close.MouseButton1Click:Connect(function()
	script.Parent.Frame.Windows.Store.Purchase.Visible = false
	SelectSound:Play()
end)

Purchase.Buttons.Purchase.MouseButton1Click:Connect(function()
	if SelectionType.Value == "Primary" then
		if Level >= ReplicatedStorage.EquipmentData.Primary:FindFirstChild(ForPurchase.Value).Level.Value and Credit >= ReplicatedStorage.EquipmentData.Primary:FindFirstChild(ForPurchase.Value).Price.Value then
			ReplicatedStorage.Events.Purchase:FireServer(ForPurchase.Value, "Primary")
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Primary:FindFirstChild(ForPurchase.Value).Value == false then
				Purchase.Buttons.Purchase.Visible = false
			end
			BuySound:Play()
			StoreWindow.Purchase.Visible = false
		else
			DenySound:Play()
		end
	elseif SelectionType.Value == "Secondary 1" or SelectionType.Value == "Secondary 2" or SelectionType.Value == "Melee" then
		if Level >= ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Level.Value and Credit >= ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Price.Value then
			ReplicatedStorage.Events.Purchase:FireServer(ForPurchase.Value, "Secondary")
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(ForPurchase.Value).Value == false then
				Purchase.Buttons.Purchase.Visible = false
			end
			BuySound:Play()
			StoreWindow.Purchase.Visible = false
		else
			DenySound:Play()
		end
	elseif SelectionType.Value == "Explosive Item" or SelectionType.Value == "Healing Item" then
		if Level >= ReplicatedStorage.EquipmentData.Item:FindFirstChild(ForPurchase.Value).Level.Value and Credit >= ReplicatedStorage.EquipmentData.Item:FindFirstChild(ForPurchase.Value).Price.Value then
			ReplicatedStorage.Events.Purchase:FireServer(ForPurchase.Value, "Item")
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(ForPurchase.Value).Value == false then
				Purchase.Buttons.Purchase.Visible = false
			end
			BuySound:Play()
			StoreWindow.Purchase.Visible = false
		else
			DenySound:Play()
		end
	elseif SelectionType.Value == "Face" then
		if Credit >= ReplicatedStorage.CharacterData.Face:FindFirstChild(ForPurchase.Value).Price.Value then
			if SelectionType.Value == "Face" then
				ReplicatedStorage.Events.Purchase:FireServer(ForPurchase.Value, "Face")
			end
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Face:FindFirstChild(ForPurchase.Value).Value == false then
				Purchase.Buttons.Purchase.Visible = false
			end
			BuySound:Play()
			StoreWindow.Purchase.Visible = false
		else
			DenySound:Play()
		end
	elseif SelectionType.Value == "Head" then
		if Credit >= ReplicatedStorage.CharacterData.Head:FindFirstChild(ForPurchase.Value).Price.Value then
			if SelectionType.Value == "Head" then
				ReplicatedStorage.Events.Purchase:FireServer(ForPurchase.Value, "Head")
			end
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Head:FindFirstChild(ForPurchase.Value).Value == false then
				Purchase.Buttons.Purchase.Visible = false
			end
			BuySound:Play()
			StoreWindow.Purchase.Visible = false
		else
			DenySound:Play()
		end
	elseif SelectionType.Value == "Clothes" then
		if Credit >= ReplicatedStorage.CharacterData.Clothes:FindFirstChild(ForPurchase.Value).Price.Value then
			if SelectionType.Value == "Clothes" then
				ReplicatedStorage.Events.Purchase:FireServer(ForPurchase.Value, "Clothes")
			end
			if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Clothes:FindFirstChild(ForPurchase.Value).Value == false then
				Purchase.Buttons.Purchase.Visible = false
			end
			BuySound:Play()
			StoreWindow.Purchase.Visible = false
		else
			DenySound:Play()
		end
	end
end)

ForPurchase.Changed:Connect(function()
	if SelectionType.Value == "Primary" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Primary:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		elseif Level < ReplicatedStorage.EquipmentData.Primary:FindFirstChild(ForPurchase.Value).Level.Value then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = false
		Purchase.ImageFrame2.Visible = true
		Purchase.Statistics["0Ammunition"].Visible = true
		Purchase.Statistics["0Type"].Visible = false
		Purchase.Statistics["1Amount"].Visible = false
		Purchase.Statistics["1Damage"].Visible = true
		Purchase.Statistics["1Country"].Visible = false
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = false
		Purchase.Statistics["3RateOfFire"].Visible = true
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = true
		Purchase.Statistics["4Usage"].Visible = false
		Purchase.ImageFrame2.ImageLabel.Image = ReplicatedStorage.EquipmentData.Primary:FindFirstChild(ForPurchase.Value).Icon2.Value
		Purchase.Title.Text = ForPurchase.Value
	elseif SelectionType.Value == "Secondary 2" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		elseif Level < ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Level.Value then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = false
		Purchase.ImageFrame2.Visible = true
		Purchase.Statistics["0Ammunition"].Visible = true
		Purchase.Statistics["0Type"].Visible = false
		Purchase.Statistics["1Amount"].Visible = false
		Purchase.Statistics["1Damage"].Visible = true
		Purchase.Statistics["1Country"].Visible = false
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = false
		Purchase.Statistics["3RateOfFire"].Visible = true
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = true
		Purchase.Statistics["4Usage"].Visible = false
		Purchase.ImageFrame2.ImageLabel.Image = ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Icon2.Value
		Purchase.Title.Text = ForPurchase.Value
	elseif SelectionType.Value == "Secondary 1" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		elseif Level < ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Level.Value then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = true
		Purchase.ImageFrame2.Visible = false
		Purchase.Statistics["0Ammunition"].Visible = true
		Purchase.Statistics["0Type"].Visible = false
		Purchase.Statistics["1Amount"].Visible = false
		Purchase.Statistics["1Damage"].Visible = true
		Purchase.Statistics["1Country"].Visible = false
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = false
		Purchase.Statistics["3RateOfFire"].Visible = true
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = true
		Purchase.Statistics["4Usage"].Visible = false
		Purchase.ImageFrame2.ImageLabel.Image = ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Icon2.Value
		Purchase.Title.Text = ForPurchase.Value
	elseif SelectionType.Value == "Melee" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Secondary:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		elseif Level < ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Level.Value then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = false
		Purchase.ImageFrame2.Visible = true
		Purchase.Statistics["0Ammunition"].Visible = false
		Purchase.Statistics["0Type"].Visible = false
		Purchase.Statistics["1Amount"].Visible = false
		Purchase.Statistics["1Damage"].Visible = true
		Purchase.Statistics["1Country"].Visible = false
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = true
		Purchase.Statistics["3RateOfFire"].Visible = false
		Purchase.Statistics["3Speed"].Visible = true
		Purchase.Statistics["4Modes"].Visible = false
		Purchase.Statistics["4Usage"].Visible = false
		Purchase.ImageFrame2.ImageLabel.Image = ReplicatedStorage.EquipmentData.Secondary:FindFirstChild(ForPurchase.Value).Icon2.Value
		Purchase.Title.Text = ForPurchase.Value
	elseif SelectionType.Value == "Explosive Item" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		elseif Level < ReplicatedStorage.EquipmentData.Item:FindFirstChild(ForPurchase.Value).Level.Value then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = true
		Purchase.ImageFrame2.Visible = false
		Purchase.Statistics["0Ammunition"].Visible = false
		Purchase.Statistics["0Type"].Visible = true
		Purchase.Statistics["1Amount"].Visible = true
		Purchase.Statistics["1Damage"].Visible = false
		Purchase.Statistics["1Country"].Visible = false
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = true
		Purchase.Statistics["3RateOfFire"].Visible = false
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = false
		Purchase.Statistics["4Usage"].Visible = true
		Purchase.ImageFrame1.ImageLabel.Image = ReplicatedStorage.EquipmentData.Item:FindFirstChild(ForPurchase.Value).Icon2.Value
		Purchase.Title.Text = ForPurchase.Value
	elseif SelectionType.Value == "Healing Item" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Item:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		elseif Level < ReplicatedStorage.EquipmentData.Item:FindFirstChild(ForPurchase.Value).Level.Value then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = true
		Purchase.ImageFrame2.Visible = false
		Purchase.Statistics["0Ammunition"].Visible = false
		Purchase.Statistics["0Type"].Visible = true
		Purchase.Statistics["1Amount"].Visible = true
		Purchase.Statistics["1Damage"].Visible = false
		Purchase.Statistics["1Country"].Visible = false
		Purchase.Statistics["1Healing"].Visible = true
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = false
		Purchase.Statistics["3RateOfFire"].Visible = false
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = false
		Purchase.Statistics["4Usage"].Visible = true
		Purchase.ImageFrame1.ImageLabel.Image = ReplicatedStorage.EquipmentData.Item:FindFirstChild(ForPurchase.Value).Icon2.Value
		Purchase.Title.Text = ForPurchase.Value
	elseif SelectionType.Value == "Face" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Face:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = true
		Purchase.ImageFrame2.Visible = false
		Purchase.Statistics["0Ammunition"].Visible = false
		Purchase.Statistics["0Type"].Visible = true
		Purchase.Statistics["1Amount"].Visible = false
		Purchase.Statistics["1Damage"].Visible = false
		Purchase.Statistics["1Country"].Visible = false
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = false
		Purchase.Statistics["3RateOfFire"].Visible = false
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = false
		Purchase.Statistics["4Usage"].Visible = false
		Purchase.ImageFrame1.ImageLabel.Image = ReplicatedStorage.CharacterData.Face:FindFirstChild(ForPurchase.Value).Icon.Value
		Purchase.Title.Text = ForPurchase.Value
		Purchase.Statistics["0Type"].Stat.Text = ReplicatedStorage.CharacterData.Face:FindFirstChild(ForPurchase.Value).FaceType.Value
	elseif SelectionType.Value == "Head" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Head:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = true
		Purchase.ImageFrame2.Visible = false
		Purchase.Statistics["0Ammunition"].Visible = false
		Purchase.Statistics["0Type"].Visible = true
		Purchase.Statistics["1Amount"].Visible = false
		Purchase.Statistics["1Damage"].Visible = false
		Purchase.Statistics["1Country"].Visible = true
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = false
		Purchase.Statistics["3RateOfFire"].Visible = false
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = false
		Purchase.Statistics["4Usage"].Visible = false
		Purchase.ImageFrame1.ImageLabel.Image = ReplicatedStorage.CharacterData.Head:FindFirstChild(ForPurchase.Value).Icon.Value
		Purchase.Title.Text = ForPurchase.Value
		Purchase.Statistics["0Type"].Stat.Text = ReplicatedStorage.CharacterData.Head:FindFirstChild(ForPurchase.Value).HeadType.Value
		Purchase.Statistics["1Country"].Stat.Text = ReplicatedStorage.CharacterData.Head:FindFirstChild(ForPurchase.Value).Country.Value
	elseif SelectionType.Value == "Clothes" then
		if ReplicatedStorage.GameData.PlayerData:WaitForChild(Player.Name).Inventory.Clothes:FindFirstChild(ForPurchase.Value).Value == true then
			Purchase.Buttons.Purchase.Visible = false
		else
			Purchase.Buttons.Purchase.Visible = true
		end
		Purchase.ImageFrame1.Visible = true
		Purchase.ImageFrame2.Visible = false
		Purchase.Statistics["0Ammunition"].Visible = false
		Purchase.Statistics["0Type"].Visible = true
		Purchase.Statistics["1Amount"].Visible = false
		Purchase.Statistics["1Damage"].Visible = false
		Purchase.Statistics["1Country"].Visible = true
		Purchase.Statistics["1Healing"].Visible = false
		Purchase.Statistics["2Space"].Visible = false
		Purchase.Statistics["3Radius"].Visible = false
		Purchase.Statistics["3RateOfFire"].Visible = false
		Purchase.Statistics["3Speed"].Visible = false
		Purchase.Statistics["4Modes"].Visible = false
		Purchase.Statistics["4Usage"].Visible = false
		Purchase.ImageFrame1.ImageLabel.Image = ReplicatedStorage.CharacterData.Clothes:FindFirstChild(ForPurchase.Value).Icon.Value
		Purchase.Title.Text = ForPurchase.Value
		Purchase.Statistics["0Type"].Stat.Text = ReplicatedStorage.CharacterData.Clothes:FindFirstChild(ForPurchase.Value).ClothingType.Value
		Purchase.Statistics["1Country"].Stat.Text = ReplicatedStorage.CharacterData.Clothes:FindFirstChild(ForPurchase.Value).Country.Value
	end
end)