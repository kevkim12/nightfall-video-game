local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

wait(2)

script.Parent.Ready.Changed:Connect(function()
	if script.Parent.Ready.Value == true then
		script.Parent.Parent.Parent.Profile.StatusDisplay.ImageColor3 = Color3.new(0, 1, 38/255)
	else
		script.Parent.Parent.Parent.Profile.StatusDisplay.ImageColor3 = Color3.new(1, 0, 4/255)
	end
end)
local PlayerName
local ThumbType = Enum.ThumbnailType.HeadShot
local ThumbSize = Enum.ThumbnailSize.Size420x420

script.Parent.MouseButton1Click:Connect(function()
	if script.Parent.Ready.Value == true then
		script.Parent.Parent.Parent.Profile.StatusDisplay.ImageColor3 = Color3.new(0, 1, 38/255)
	else
		script.Parent.Parent.Parent.Profile.StatusDisplay.ImageColor3 = Color3.new(1, 0, 4/255)
	end
	script.Parent.Parent.Parent.Profile.ProfilePicture.Image = Players:GetUserThumbnailAsync(Players:FindFirstChild(PlayerName).UserId, ThumbType, ThumbSize)
	script.Parent.Parent.Parent.Profile.LevelText.Text = "LEVEL" .. ReplicatedStorage.GameData.PlayerData:WaitForChild(PlayerName).Statistics.Level.Value
	script.Parent.Parent.Parent.Profile.PlayerName.Text = script.Parent.Name
	script.Parent.Parent.Parent.Profile.Buttons.Invite.Visible = true
	script.Parent.Parent.Parent.Profile.Visible = true
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Values.SelectedPlayer.Value = script.Parent.PlayerName.Value
	script.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Parent.Sounds.Select:Play()
end)

repeat wait() until script.Parent.Parent.Name == "List"
wait(2)
PlayerName = script.Parent.Name
script.Parent.Emblem.Image = ReplicatedStorage.ProfileData.Emblem:WaitForChild(ReplicatedStorage.GameData.PlayerData:WaitForChild(PlayerName).Profile.Emblem.Value).Value
script.Parent.Title.Image = ReplicatedStorage.ProfileData.Title:WaitForChild(ReplicatedStorage.GameData.PlayerData:WaitForChild(PlayerName).Profile.Title.Value).Value

ReplicatedStorage.GameData.PlayerData:WaitForChild(PlayerName).Profile.Emblem.Changed:Connect(function()
	script.Parent.Emblem.Image = ReplicatedStorage.ProfileData.Emblem:WaitForChild(ReplicatedStorage.GameData.PlayerData:WaitForChild(PlayerName).Profile.Emblem.Value).Value
end)
ReplicatedStorage.GameData.PlayerData:WaitForChild(PlayerName).Profile.Title.Changed:Connect(function()
	script.Parent.Title.Image = ReplicatedStorage.ProfileData.Title:WaitForChild(ReplicatedStorage.GameData.PlayerData:WaitForChild(PlayerName).Profile.Title.Value).Value
end)