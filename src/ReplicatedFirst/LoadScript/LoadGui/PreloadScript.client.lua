script.Parent.IntroFrame.Sound:Play()
if game:GetService("RunService"):IsStudio() then
	script.Parent.IntroFrame.Visible = false
	script.Parent.IntroFrame.Sound.Volume = 0
else
	script.Parent.IntroFrame.Visible = true
end

local LoadTime = 20
local ContentProvider = game:GetService("ContentProvider")
local fadeDuration = 2
local tweenInfo = TweenInfo.new(fadeDuration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)
function Tween(Object, Time, Customization)
	game:GetService("TweenService"):Create(Object, TweenInfo.new(Time), Customization):Play()
end

local FillBar = script.Parent.IntroFrame.LoadBar.Fill

local willTween = FillBar:TweenSize(
	UDim2.new(1, 0, 1, 0),  -- endSize (required)
	Enum.EasingDirection.Out,    -- easingDirection (default Out)
	Enum.EasingStyle.Linear,
	LoadTime,
	true
)

local function LoadAssets(AssetList)
	-- Takes an asset list and preloads it. Will not wait for them to load. 
 
	for _, AssetId in pairs(AssetList) do
		ContentProvider:Preload("http://www.roblox.com/asset/?id=" .. AssetId)
	end
end
LoadAssets({
-- Menu Gui
	-- Nightfall Logo
	6760304498,
	-- Active Button
	6859458402,
	-- Inactive Button
	6857304521
})

wait(LoadTime)
Tween(script.Parent.IntroFrame.Sound, 2, {Volume = 0});

for i,v in pairs(script.Parent:GetDescendants()) do
	
	if v:IsA('Frame') then
		game:GetService("TweenService"):Create(v, tweenInfo, {BackgroundTransparency = 1}):Play()
	elseif v:IsA('ImageLabel') then
		game:GetService("TweenService"):Create(v, tweenInfo, {ImageTransparency = 1}):Play()
	elseif v:IsA('TextLabel') then
		game:GetService("TweenService"):Create(v, tweenInfo, {TextTransparency = 1}):Play()
		game:GetService("TweenService"):Create(v, tweenInfo, {TextStrokeTransparency = 1}):Play()
	end
end

wait(3)
script.Parent.Parent:WaitForChild("MainGui").Music.MenuTheme:Play()
wait(7)
script.Parent:remove()