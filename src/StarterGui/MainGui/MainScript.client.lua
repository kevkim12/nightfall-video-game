-- TOOL BAR
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Player = game:GetService("Players").LocalPlayer
local UIS = game:GetService("UserInputService")
local Rain = require(ReplicatedStorage.Modules.Rain)

Player.CameraMaxZoomDistance = 25

local Ambience = script.Parent.Sounds.Ambience
local PlayerDeath = script.Parent.PlayerDeath
local SpawnTheme = script.Parent.Music.SpawnTheme
local LoadTheme = script.Parent.Music.LoadingTheme
local MenuTheme = script.Parent.Music.MenuTheme
local VictoryTheme = script.Parent.Music.VictoryTheme
local DefeatTheme = script.Parent.Music.DefeatTheme
local NextStageSound = script.Parent.Sounds.NextStage
local VictoryScreen = script.Parent.Fade.VictoryLabel
local DefeatScreen = script.Parent.Fade.DefeatLabel
local GameStartMessage = script.Parent.GameStartMessage
local WarningNotification = script.Parent.WarningNotification
local Leaderboard = script.Parent.Leaderboard

local fadeDuration = 2
local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

local ActiveStageColor = Color3.new(255/255, 100/255, 39/255)
local InactiveStageColor = Color3.new(63/255, 63/255, 63/255)
local FinalStageColor = Color3.new(199/255, 15/255, 18/255)

local Stages = script.Parent.GameStatus.Stages
local StageText = script.Parent.GameStatus.Stage

local Themes = {
	1837291279, -- Warzone
	9042634800, -- Village
}

local Teams = game:GetService("Teams")
local InfectedTeam = Teams:WaitForChild("Infected")
local SurvivorTeam = Teams:WaitForChild("Survivors")

local function Tween(Object, Time, Customization)
	game:GetService("TweenService"):Create(Object, TweenInfo.new(Time), Customization):Play()
end

ReplicatedStorage.Events.Weather.OnClientEvent:Connect(function(Type, Command)
	if ReplicatedStorage.GameData.GameActive.Value == true then
		if Type == "Normal Rain" then
			if Command == "Start" then
				script.Parent.Sounds.Weather:Play()
				WarningNotification.Description.Text = "Reports indicate that normal rain is approaching your location."
				WarningNotification.Visible = true
				WarningNotification:TweenPosition(UDim2.new(1,0,0.5,0))
				wait(10)
				WarningNotification:TweenPosition(UDim2.new(1.15,0,0.5,0))
				wait(2)
				WarningNotification.Visible = false
				wait(math.random(1,8))
				Rain:Enable()
			elseif Command == "Start 2" then
				Rain:Enable()
			elseif Command == "Stop" then
				Rain:Disable()
			end
		elseif Type == "Heavy Rain" then
			if Command == "Start" then
				script.Parent.Sounds.Weather:Play()
				WarningNotification.Description.Text = "Reports indicate that heavy rain is approaching your location. Prepare for limited visibility."
				WarningNotification.Visible = true
				WarningNotification:TweenPosition(UDim2.new(1,0,0.5,0))
				wait(10)
				WarningNotification:TweenPosition(UDim2.new(1.15,0,0.5,0))
				wait(2)
				WarningNotification.Visible = false
				wait(math.random(1,8))
				Rain:Enable()
			elseif Command == "Start 2" then
				Rain:Enable()
			elseif Command == "Stop" then
				Rain:Disable()
			end
		elseif Type == "Dust Storm" then
			if Command == "Start" then
				script.Parent.Sounds.Weather:Play()
				Ambience.SoundId = "rbxassetid://4541009066"
				WarningNotification.Description.Text = "Reports indicate that a dust storm is approaching your location. Prepare for limited visibility."
				WarningNotification.Visible = true
				WarningNotification:TweenPosition(UDim2.new(1,0,0.5,0))
				wait(10)
				WarningNotification:TweenPosition(UDim2.new(1.15,0,0.5,0))
				wait(2)
				WarningNotification.Visible = false
				Ambience:Play()
			elseif Command == "Start 2" then
				Ambience:Play()
			elseif Command == "Stop" then
				Ambience:Stop()
			end
		end
	end
end)

ReplicatedStorage.Events.WarningMessage.OnClientEvent:Connect(function(Type)
	if Type == "Ravager" then
		script.Parent.Sounds.Danger:Play()
		WarningNotification.Description.Text = "A Ravager has been detected within your proximity. Be aware of your surroundings."
		WarningNotification.Visible = true
		WarningNotification:TweenPosition(UDim2.new(1,0,0.5,0))
		wait(10)
		WarningNotification:TweenPosition(UDim2.new(1.15,0,0.5,0))
		wait(2)
		WarningNotification.Visible = false
	elseif Type == "Wrecker" then
		script.Parent.Sounds.Danger:Play()
		WarningNotification.Description.Text = "A Wrecker has been detected within your proximity. Keep your distance."
		WarningNotification.Visible = true
		WarningNotification:TweenPosition(UDim2.new(1,0,0.5,0))
		wait(10)
		WarningNotification:TweenPosition(UDim2.new(1.15,0,0.5,0))
		wait(2)
		WarningNotification.Visible = false
	end
end)

ReplicatedStorage.Events.UpdateTimer.OnClientEvent:Connect(function(UpdatedTime)
	script.Parent.GameStatus.Time.Text = UpdatedTime
end)

local GameMessageTweenInfo = TweenInfo.new(
	2, --Time
	Enum.EasingStyle.Linear, --EasingStyle
	Enum.EasingDirection.Out, --EasingDirection
	0, --Repeat count
	false, --Reverses if true
	0 --Delay time
)
local ShowMessageText = game:GetService("TweenService"):Create(GameStartMessage, GameMessageTweenInfo, {TextTransparency = 0})
local HideMessageText = game:GetService("TweenService"):Create(GameStartMessage, GameMessageTweenInfo, {TextTransparency = 1})
local ShowMessageStroke = game:GetService("TweenService"):Create(GameStartMessage, GameMessageTweenInfo, {TextStrokeTransparency = 0})
local HideMessageStroke = game:GetService("TweenService"):Create(GameStartMessage, GameMessageTweenInfo, {TextStrokeTransparency = 1})

ReplicatedStorage.Events.ApplyMessage.OnClientEvent:Connect(function(Target, Message)
	if Target == "Infected" then
		if Player.Team == InfectedTeam then
			GameStartMessage.Text = Message
			GameStartMessage.Visible = true
			ShowMessageText:Play()
			ShowMessageStroke:Play()
			wait(4)
			HideMessageText:Play()
			HideMessageStroke:Play()
			wait(2)
			GameStartMessage.Visible = false
		end
	elseif Target == "Survivors" then
		if Player.Team == SurvivorTeam then
			GameStartMessage.Text = Message
			GameStartMessage.Visible = true
			ShowMessageText:Play()
			ShowMessageStroke:Play()
			wait(4)
			HideMessageText:Play()
			HideMessageStroke:Play()
			wait(2)
			GameStartMessage.Visible = false
		end
	end
end)

local MapValue = ReplicatedStorage:WaitForChild("GameData").Map

local function ChangeTheme()
	if MapValue.Value == "Warzone" then
		local Type = math.random(1,2)
		if Type == 1 then
			LoadTheme.SoundId = "rbxassetid://1837291279"
		else
			LoadTheme.SoundId = "rbxassetid://1843453395"
		end
	elseif MapValue.Value == "District" then
		LoadTheme.SoundId = "rbxassetid://1841122216"
	elseif MapValue.Value == "Sewers" then
		LoadTheme.SoundId = "rbxassetid://1847800653"
	elseif MapValue.Value == "Arctic" then
		LoadTheme.SoundId = "rbxassetid://1843920845"
	end
end

-- Halloween2 - rbxassetid://13061809

ChangeTheme()

ReplicatedStorage.GameData.Map.Changed:Connect(function()
	ChangeTheme()
end)

ReplicatedStorage.Events.SoundEffect.OnClientEvent:Connect(function(Type, Command)
	if Type == "Spawn" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		wait(3)
		SpawnTheme.Volume = 0.5
		SpawnTheme:Play()
	elseif Type == "Load" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		LoadTheme.Volume = 0.5
		LoadTheme:Play()
	elseif Type == "Load" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Stop" then
		Tween(LoadTheme, 2, {Volume = 0});
	elseif Type == "Menu" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		MenuTheme.Volume = 0.5
		MenuTheme:Play()
		--game:GetService("UserInputService").MouseIconEnabled = true
	elseif Type == "Menu" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Stop" then
		Tween(MenuTheme, 2, {Volume = 0});
		--game:GetService("UserInputService").MouseIconEnabled = false
	elseif Type == "Spawn" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Stop" then
		Tween(SpawnTheme, 2, {Volume = 0});
	elseif Type == "Victory" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		VictoryTheme.Volume = 0.5
		VictoryTheme:Play()
	elseif Type == "Victory" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Stop" then
		Tween(VictoryTheme, 2, {Volume = 0});
	elseif Type == "Defeat" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		DefeatTheme.Volume = 0.5
		DefeatTheme:Play()
	elseif Type == "Defeat" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Stop" then
		Tween(DefeatTheme, 2, {Volume = 0});
	elseif Type == "NextStage" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		NextStageSound:Play()
	end
end)

ReplicatedStorage.Events.ScreenEffect.OnClientEvent:Connect(function(Type, Command, Special)
	if Type == "Victory" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		game:GetService("TweenService"):Create(VictoryScreen, tweenInfo, {TextTransparency = 0}):Play()
		wait(3)
		Leaderboard.Visible = true
	elseif Type == "Victory" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Stop" then
		game:GetService("TweenService"):Create(VictoryScreen, tweenInfo, {TextTransparency = 1}):Play()
		Leaderboard.Visible = false
		wait(1)
		game:GetService("TweenService"):Create(script.Parent.Fade, tweenInfo, {BackgroundTransparency = 1}):Play()
	elseif Type == "Defeat" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Play" then
		game:GetService("TweenService"):Create(DefeatScreen, tweenInfo, {TextTransparency = 0}):Play()
		wait(3)
		Leaderboard.Visible = true
	elseif Type == "Defeat" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Stop" then
		game:GetService("TweenService"):Create(DefeatScreen, tweenInfo, {TextTransparency = 1}):Play()
		Leaderboard.Visible = false
		wait(1)
		game:GetService("TweenService"):Create(script.Parent.Fade, tweenInfo, {BackgroundTransparency = 1}):Play()
	elseif Type == "NextStage" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Increment" then
		if Special < 5 then
			Stages["Stage"..Special].BackgroundColor3 = ActiveStageColor
		else
			Stages["Stage"..Special].BackgroundColor3 = FinalStageColor
		end
		StageText.Text = "STAGE " .. Special
	elseif Type == "NextStage" and ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true and Command == "Reset" then
		Stages.Stage1.BackgroundColor3 = InactiveStageColor
		Stages.Stage2.BackgroundColor3 = InactiveStageColor
		Stages.Stage3.BackgroundColor3 = InactiveStageColor
		Stages.Stage4.BackgroundColor3 = InactiveStageColor
		Stages.Stage5.BackgroundColor3 = InactiveStageColor
		StageText.Text = "STAGE 1"
	end
end)

ReplicatedStorage.Events.UpdateStages.OnClientEvent:Connect(function(Stage)
	if Stage == "1" then
		Stages.Stage1.BackgroundColor3 = ActiveStageColor
		Stages.Stage2.BackgroundColor3 = InactiveStageColor
		Stages.Stage3.BackgroundColor3 = InactiveStageColor
		Stages.Stage4.BackgroundColor3 = InactiveStageColor
		Stages.Stage5.BackgroundColor3 = InactiveStageColor
		StageText.Text = "STAGE 1"
	elseif Stage == "2" then
		Stages.Stage1.BackgroundColor3 = ActiveStageColor
		Stages.Stage2.BackgroundColor3 = ActiveStageColor
		Stages.Stage3.BackgroundColor3 = InactiveStageColor
		Stages.Stage4.BackgroundColor3 = InactiveStageColor
		Stages.Stage5.BackgroundColor3 = InactiveStageColor
		StageText.Text = "STAGE 2"
	elseif Stage == "3" then
		Stages.Stage1.BackgroundColor3 = ActiveStageColor
		Stages.Stage2.BackgroundColor3 = ActiveStageColor
		Stages.Stage3.BackgroundColor3 = ActiveStageColor
		Stages.Stage4.BackgroundColor3 = InactiveStageColor
		Stages.Stage5.BackgroundColor3 = InactiveStageColor
		StageText.Text = "STAGE 3"
	elseif Stage == "4" then
		Stages.Stage1.BackgroundColor3 = ActiveStageColor
		Stages.Stage2.BackgroundColor3 = ActiveStageColor
		Stages.Stage3.BackgroundColor3 = ActiveStageColor
		Stages.Stage4.BackgroundColor3 = ActiveStageColor
		Stages.Stage5.BackgroundColor3 = InactiveStageColor
		StageText.Text = "STAGE 4"
	elseif Stage == "5" then
		Stages.Stage1.BackgroundColor3 = ActiveStageColor
		Stages.Stage2.BackgroundColor3 = ActiveStageColor
		Stages.Stage3.BackgroundColor3 = ActiveStageColor
		Stages.Stage4.BackgroundColor3 = ActiveStageColor
		Stages.Stage5.BackgroundColor3 = FinalStageColor
		StageText.Text = "STAGE 5"
	end
end)

ReplicatedStorage.Events.PlayerDeath.OnClientEvent:Connect(function(PlayerName)
	if ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true then
		PlayerDeath.DeathMessage.Text = PlayerName:upper() .. " WAS KILLED"
		script.Parent.PlayerDeath.Visible = true
		script.Parent.Sounds.SurvivorDeath:Play()
		local DeathTweenInfo = TweenInfo.new(
			1, --Time
			Enum.EasingStyle.Linear, --EasingStyle
			Enum.EasingDirection.Out, --EasingDirection
			0, --Repeat count
			false, --Reverses if true
			0 --Delay time
		)
		local HideBlood = game:GetService("TweenService"):Create(PlayerDeath, DeathTweenInfo, {ImageTransparency = 1})
		local ShowBlood = game:GetService("TweenService"):Create(PlayerDeath, DeathTweenInfo, {ImageTransparency = .2})
		local HideText = game:GetService("TweenService"):Create(PlayerDeath.DeathMessage, DeathTweenInfo, {TextTransparency = 1})
		local ShowText = game:GetService("TweenService"):Create(PlayerDeath.DeathMessage, DeathTweenInfo, {TextTransparency = 0})
		local HideTextStroke =  game:GetService("TweenService"):Create(PlayerDeath.DeathMessage, DeathTweenInfo, {TextStrokeTransparency = 1})
		local ShowTextStroke =  game:GetService("TweenService"):Create(PlayerDeath.DeathMessage, DeathTweenInfo, {TextStrokeTransparency = 0})
		ShowBlood:Play()
		ShowText:Play()
		ShowTextStroke:Play()
		wait(3)
		HideBlood:Play()
		HideText:Play()
		HideTextStroke:Play()
		wait(5)
		script.Parent.PlayerDeath.Visible = false
	end
end)

local MapLoadFrame = script.Parent.MapLoadFrame
local MapImage = MapLoadFrame.Icon
local MapName = MapLoadFrame.TopBar.MapName
local MapLoadTweenInfo = TweenInfo.new(
	3, --Time
	Enum.EasingStyle.Linear, --EasingStyle
	Enum.EasingDirection.Out, --EasingDirection
	0, --Repeat count
	false, --Reverses if true
	0 --Delay time
)
local ContentTweenInfo = TweenInfo.new(
	1, --Time
	Enum.EasingStyle.Linear, --EasingStyle
	Enum.EasingDirection.Out, --EasingDirection
	0, --Repeat count
	false, --Reverses if true
	0 --Delay time
)

local ShowMapImage = game:GetService("TweenService"):Create(MapImage, MapLoadTweenInfo, {ImageTransparency = 0})
local ShowTopBar = game:GetService("TweenService"):Create(MapLoadFrame.TopBar, MapLoadTweenInfo, {BackgroundTransparency = 0.3})
local ShowBottomBar = game:GetService("TweenService"):Create(MapLoadFrame.BottomBar, MapLoadTweenInfo, {BackgroundTransparency = 0.3})
local ShowMapTitle = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.MapName, ContentTweenInfo, {TextTransparency = 0})
local ShowMapLocation = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.Location.Coordinates, ContentTweenInfo, {TextTransparency = 0})
local ShowMapLocationIcon = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.Location.LocationIcon, ContentTweenInfo, {ImageTransparency = 0})
local ShowMapMode = game:GetService("TweenService"):Create(MapLoadFrame.BottomBar.Mode, ContentTweenInfo, {TextTransparency = 0})
local ShowMapTime = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.MapStats.Time, ContentTweenInfo, {TextTransparency = 0})
local ShowMapTemp = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.MapStats.Temperature, ContentTweenInfo, {TextTransparency = 0})

local HideMapImage = game:GetService("TweenService"):Create(MapImage, MapLoadTweenInfo, {ImageTransparency = 1})
local HideTopBar = game:GetService("TweenService"):Create(MapLoadFrame.TopBar, MapLoadTweenInfo, {BackgroundTransparency = 1})
local HideBottomBar = game:GetService("TweenService"):Create(MapLoadFrame.BottomBar, MapLoadTweenInfo, {BackgroundTransparency = 1})
local HideMapTitle = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.MapName, MapLoadTweenInfo, {TextTransparency = 1})
local HideMapLocation = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.Location.Coordinates, MapLoadTweenInfo, {TextTransparency = 1})
local HideMapLocationIcon = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.Location.LocationIcon, MapLoadTweenInfo, {ImageTransparency = 1})
local HideMapMode = game:GetService("TweenService"):Create(MapLoadFrame.BottomBar.Mode, MapLoadTweenInfo, {TextTransparency = 1})
local HideMapTime = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.MapStats.Time, MapLoadTweenInfo, {TextTransparency = 1})
local HideMapTemp = game:GetService("TweenService"):Create(MapLoadFrame.TopBar.MapStats.Temperature, MapLoadTweenInfo, {TextTransparency = 1})

ShowMapImage.Completed:Connect(function()
	ShowMapTitle:Play()
	wait(.2)
	ShowMapLocation:Play()
	ShowMapLocationIcon:Play()
	wait(.2)
	ShowMapMode:Play()
	ShowMapTime:Play()
	ShowMapTemp:Play()
end)

local function HideMapInfo()
	HideMapImage:Play()
	HideTopBar:Play()
	HideBottomBar:Play()
	HideMapTitle:Play()
	HideMapLocation:Play()
	HideMapLocationIcon:Play()
	HideMapMode:Play()
	HideMapTime:Play()
	HideMapTemp:Play()
end

local ObjectiveDescription = script.Parent.Objective.Description
local GameMode

local RewardsFrame = script.Parent:WaitForChild("Rewards").RewardsFrame
local LayoutCount = 0

local RewardsTweenInfo = TweenInfo.new(
	.5, --Time
	Enum.EasingStyle.Linear, --EasingStyle
	Enum.EasingDirection.Out, --EasingDirection
	0, --Repeat count
	false, --Reverses if true
	0 --Delay time
)

ReplicatedStorage.Events.NotifyRewards.OnClientEvent:Connect(function(Amount, Description)
	local Frame = RewardsFrame:Clone()
	Frame.Parent = script.Parent.Rewards
	Frame.Name = "Reward"
	Frame.Amount.Text = Amount
	Frame.Description.Text = Description
	Frame.LayoutOrder = LayoutCount
	LayoutCount = LayoutCount - 1
	Frame.Visible = true

	local HideAmountText = game:GetService("TweenService"):Create(Frame.Amount, RewardsTweenInfo, {TextTransparency = 1})
	local HideDescriptionText = game:GetService("TweenService"):Create(Frame.Description, RewardsTweenInfo, {TextTransparency = 1})
	local HideAmountStroke = game:GetService("TweenService"):Create(Frame.Amount, RewardsTweenInfo, {TextStrokeTransparency = 1})
	local HideDescriptionStroke = game:GetService("TweenService"):Create(Frame.Description, RewardsTweenInfo, {TextStrokeTransparency = 1})


	delay(3, function()
		HideAmountText:Play()
		HideDescriptionText:Play()
		HideAmountStroke:Play()
		HideDescriptionStroke:Play()

		HideAmountText.Completed:Connect(function()
			Frame:Destroy()
		end)
	end)
end)

ReplicatedStorage.Events.LoadScreen.OnClientEvent:Connect(function(Type, Command, Map, Mode, Time, Temp)
	if ReplicatedStorage.GameData.PlayerStatus[Player.Name].Value == true then
		if Type == "Map" then
			if Command == "Play" then
				if Map == "Warzone" then
					MapImage.Image = "rbxassetid://6955151021"
					MapName.Text = "WARZONE"
					MapLoadFrame.TopBar.Location.Coordinates.Text = "31°01'33.1\"N 64°58'47.8\"E"
				elseif Map == "District" then
					MapImage.Image = "rbxassetid://10943774364"
					MapName.Text = "DISTRICT"
					MapLoadFrame.TopBar.Location.Coordinates.Text = "38°54'03.5\"N 77°06'01.3\"W"
				elseif Map == "Sewers" then
					MapImage.Image = "rbxassetid://11361038145"
					MapName.Text = "SEWERS"
					MapLoadFrame.TopBar.Location.Coordinates.Text = "40°45'19.7\"N 73°58'46.5\"W"
				elseif Map == "Arctic" then
					MapImage.Image = "rbxassetid://11090189497"
					MapName.Text = "ARCTIC"
					MapLoadFrame.TopBar.Location.Coordinates.Text = "43°20'02.0\"N 114°18'01.3\"W"
				end
				if Mode == "Survival" then
					MapLoadFrame.BottomBar.Mode.Text = "SURVIVAL"
					GameMode = Mode
					if Player.Team == SurvivorTeam then
						ObjectiveDescription.Text = "Survive the night."
					elseif Player.Team == InfectedTeam then
						ObjectiveDescription.Text = "Kill the survivors."
					end
				elseif Mode == "Objective" then
					MapLoadFrame.BottomBar.Mode.Text = "OBJECTIVE"
					GameMode = Mode
				end
				MapLoadFrame.TopBar.MapStats.Time.Text = " TIME: " .. Time
				local Celcius = (Temp - 32) *.5556
				MapLoadFrame.TopBar.MapStats.Temperature.Text = " TEMP: " .. Temp .. "°F / " .. ((Celcius + 0.5) - (Celcius + 0.5) % 1) .. "°C"
				script.Parent.MapLoadFrame.Visible = true
				ShowMapImage:Play()
				ShowTopBar:Play()
				ShowBottomBar:Play()
			elseif Command == "Stop" then
				HideMapInfo()
				wait(4)
				script.Parent.MapLoadFrame.Visible = false
			end
		end
	end
end)

Player:GetPropertyChangedSignal("Team"):Connect(function()
	if Player.Team == InfectedTeam and GameMode == "Survival" then
		ObjectiveDescription.Text = "Kill the survivors."
	end
end)

local textbox = script.Parent.BottomBar.Send.TextBox
local holder = script.Parent.BottomBar.ScrollingFrame
local event = game:GetService("ReplicatedStorage").Events:WaitForChild("ChatEvent")
local template = game:GetService("ReplicatedStorage").Assets:WaitForChild("ChatLine")
local number = 1

UIS.InputBegan:Connect(function(input, gameProcessedEvent)
	if input.UserInputType == Enum.UserInputType.Keyboard == true then
		if input.KeyCode == Enum.KeyCode.Slash and not UIS:GetFocusedTextBox() then
			wait()
			textbox:CaptureFocus()
		elseif input.KeyCode == Enum.KeyCode.Tab and Leaderboard.Visible == false then
			Leaderboard.Visible = true
		elseif input.KeyCode == Enum.KeyCode.Tab and Leaderboard.Visible == true then
			Leaderboard.Visible = false
		end
	end
end)

-- CHAT
textbox.PlaceholderText = "CLICK HERE OR PRESS '/' TO CHAT"

local RunService = game:GetService("RunService")

RunService.RenderStepped:Connect(function(step)
	if string.len(textbox.Text) > 120 then
		textbox.Text = string.sub(textbox.Text, 1, 120)
	end
	if textbox:IsFocused() then
		textbox.Parent.Size = UDim2.new(0.893, 0, 0.557, 0)
		textbox.PlaceholderText = ""
	end
end)

textbox.FocusLost:Connect(function(ep)
	if (ep) and textbox.Text ~= "" then
		event:FireServer(textbox.Text)
		textbox.Text = ""
	else
		textbox.Text = ""
	end
	textbox.Parent.Size = UDim2.new(0.204, 0, 0.557, 0)
	textbox.PlaceholderText = "CLICK HERE OR PRESS '/' TO CHAT"
end)


--||	Variables

local ScrollingFrame = script.Parent.BottomBar.ScrollingFrame
local TextService = game:GetService("TextService")

-- Config

local PixelsPerLine = 20

local PredefinedTextSize = 16
local PredefinedFont = Enum.Font.SourceSans

--||	Functions

function GetSize(String)
	return TextService:GetTextSize(String, PredefinedTextSize, PredefinedFont, Vector2.new(math.huge, math.huge)).X
end

function NewLabel(String, Position, Color)
	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.TextSize = PredefinedTextSize
	Label.Font = PredefinedFont
	Label.Text = String 
	Label.Position = Position
	Label.Size = UDim2.new(0, GetSize(String), 0, PixelsPerLine)
	Label.TextColor3 = Color or Color3.fromRGB(255, 255, 255) -- team
	--Label.Font = ("SourceSansBold")

	return Label
end

function NewMessage(Sender, MessageText)
	Sender = "[ " .. Sender .. " ]:  "
	
	local Message = script.Template:Clone()
	Message.Parent = ScrollingFrame
	
	local PixelBudgetPerLine = Message.Container.AbsoluteSize.X
	local PixelsSpent = 0
	local Line = 0
	
	-- Sender
	
	local Label = NewLabel(Sender, UDim2.new(0, PixelsSpent, 0, 20*Line), Color3.fromRGB(255, 255, 255))
	Label.Parent = Message.Container
	--Label.Font = ("SourceSansBold")
	PixelsSpent += GetSize(Sender)
	
	-- Message w/iterations
	
	local SubStart = 1
	
	for i = 1, #MessageText do
		local String = string.sub(MessageText, SubStart, i)
		local StringSize = GetSize(String)
		
		if PixelsSpent + StringSize > PixelBudgetPerLine then
			local String = string.sub(MessageText, SubStart, i-1)
			local StringSize = GetSize(String)
			
			local Label = NewLabel(String, UDim2.new(0, PixelsSpent, 0, 20*Line), Color3.fromRGB(255, 255, 255))
			Label.Parent = Message.Container
			
			PixelsSpent = 0
			Line += 1
			SubStart = i
			
			continue
		end
		
		if i == #MessageText then
			local Label = NewLabel(String, UDim2.new(0, PixelsSpent, 0, 20*Line), Color3.fromRGB(255, 255, 255))
			Label.Parent = Message.Container
		end
	end
	
	Message.Size = UDim2.new(Message.Size.X.Scale, Message.Size.X.Offset, 0, (Line+1) * PixelsPerLine)
	
	-- Scrolling frame
	
	ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, ScrollingFrame.UIListLayout.AbsoluteContentSize.Y)
	ScrollingFrame.CanvasPosition = Vector2.new(0, ScrollingFrame.CanvasSize.Y.Offset)
end

event.OnClientEvent:Connect(function(message, plrThatSent)
	NewMessage(plrThatSent, message)
end)