local Player = game.Players.LocalPlayer

local RStorage = game:GetService("ReplicatedStorage")
local FMKClientModules = RStorage:WaitForChild("Modules")
local FMKGF = FMKClientModules:WaitForChild("MeleeGlobalFunctions")
FMKGF = require(FMKGF)
local DamageTagVisualizer = RStorage:WaitForChild("Events"):WaitForChild("VisualiseIndicators")
local Settings = require(RStorage:WaitForChild("Modules"):WaitForChild("VisualiseSettingsModule")).VisualiseIndicator_Settings

local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

DamageTagVisualizer.OnClientEvent:connect(function(Target,Damage,BonusTable)
	if Target and Damage then
		
		local TextT = {}
		table.insert(TextT,math.floor(Damage))
		
		local Critical = false
		local Backstab = false
		
		if BonusTable ~= nil then
			for _,Bonus in pairs(BonusTable) do
				if Bonus == "CriticalChance" then
					Critical = true
					table.insert(TextT,Settings.CriticalAdditionalText)
				elseif Bonus == "Backstab" then
					Backstab = true
					table.insert(TextT,Settings.BackstabAdditionalText)
				end
			end
		end
		
		local SetLifetime = FMKGF:AddressTableValue(Settings.TextLifetime)
		local AdditionalLifetime = FMKGF:AddressTableValue(Settings.TextFadeTween[1])
		
		local THead = Target:WaitForChild("Head")
		local DamageTagGUI = RStorage.Modules.VisualiseSettingsModule:WaitForChild("DamageTagGUI"):Clone()
		DamageTagGUI.Parent = THead
		DamageTagGUI.Enabled = true
		
		local BlinkingTextF = coroutine.create(function(Text,Type)
			if Type == 1 and Settings.CriticalTextBlinking == true then -- Critical
				repeat
					TweenService:Create(Text,TweenInfo.new(Settings.CriticalTextBlinkingTween[1],Settings.CriticalTextBlinkingTween[2],Settings.CriticalTextBlinkingTween[3],Settings.CriticalTextBlinkingTween[4],Settings.CriticalTextBlinkingTween[5],Settings.CriticalTextBlinkingTween[6]),
					{TextColor3 = Settings.CriticalTextBlinkingColor}):Play()
					wait(Settings.CriticalTextBlinkingTween[1])
					TweenService:Create(Text,TweenInfo.new(Settings.CriticalTextBlinkingTween[1],Settings.CriticalTextBlinkingTween[2],Settings.CriticalTextBlinkingTween[3],Settings.CriticalTextBlinkingTween[4],Settings.CriticalTextBlinkingTween[5],Settings.CriticalTextBlinkingTween[6]),
					{TextColor3 = Settings.CriticalTextColor}):Play()
					wait(Settings.CriticalTextBlinkingTween[1])
				until DamageTagGUI:FindFirstChild("DamageText") == nil
			elseif Type == 2 and Settings.BackstabTextBlinking == true then
				repeat
					TweenService:Create(Text,TweenInfo.new(Settings.BackstabTextBlinkingTween[1],Settings.BackstabTextBlinkingTween[2],Settings.BackstabTextBlinkingTween[3],Settings.BackstabTextBlinkingTween[4],Settings.BackstabTextBlinkingTween[5],Settings.BackstabTextBlinkingTween[6]),
					{TextColor3 = Settings.BackstabTextBlinkingColor}):Play()
					wait(Settings.BackstabTextBlinkingTween[1])
					TweenService:Create(Text,TweenInfo.new(Settings.BackstabTextBlinkingTween[1],Settings.BackstabTextBlinkingTween[2],Settings.BackstabTextBlinkingTween[3],Settings.BackstabTextBlinkingTween[4],Settings.BackstabTextBlinkingTween[5],Settings.BackstabTextBlinkingTween[6]),
					{TextColor3 = Settings.BackstabTextColor}):Play()
					wait(Settings.CriticalTextBlinkingTween[1])
				until DamageTagGUI:FindFirstChild("DamageText") == nil
			elseif Type == 3 and Settings.BackstabTextBlinking == true then
				repeat
					TweenService:Create(Text,TweenInfo.new(Settings.CriticalTextBlinkingTween[1],Settings.CriticalTextBlinkingTween[2],Settings.CriticalTextBlinkingTween[3],Settings.CriticalTextBlinkingTween[4],Settings.CriticalTextBlinkingTween[5],Settings.CriticalTextBlinkingTween[6]),
					{TextColor3 = Settings.CriticalTextBlinkingColor:lerp(Settings.BackstabTextBlinkingColor,.5)}):Play()
					wait(Settings.CriticalTextBlinkingTween[1])
					TweenService:Create(Text,TweenInfo.new(Settings.CriticalTextBlinkingTween[1],Settings.CriticalTextBlinkingTween[2],Settings.CriticalTextBlinkingTween[3],Settings.CriticalTextBlinkingTween[4],Settings.CriticalTextBlinkingTween[5],Settings.CriticalTextBlinkingTween[6]),
					{TextColor3 = Settings.CriticalTextColor:lerp(Settings.BackstabTextColor,.5)}):Play()
					wait(Settings.CriticalTextBlinkingTween[1])
				until DamageTagGUI:FindFirstChild("DamageText") == nil
			end
		end)
		
		if Critical == true and Backstab == false then 
			DamageTagGUI.DamageText.TextColor3 = Settings.CriticalTextColor
			DamageTagGUI.DamageText.TextStrokeColor3 = Settings.CriticalTextStrokeColor
			coroutine.resume(BlinkingTextF,DamageTagGUI.DamageText,1)
		elseif Critical == false and Backstab == true then
			DamageTagGUI.DamageText.TextColor3 = Settings.BackstabTextColor
			DamageTagGUI.DamageText.TextStrokeColor3 = Settings.BackstabTextStrokeColor
			coroutine.resume(BlinkingTextF,DamageTagGUI.DamageText,2)
		elseif Critical == true and Backstab == true then
			DamageTagGUI.DamageText.TextColor3 = Settings.CriticalTextColor:lerp(Settings.BackstabTextColor,.5)
			DamageTagGUI.DamageText.TextStrokeColor3 = Settings.CriticalTextStrokeColor:lerp(Settings.BackstabTextStrokeColor,.5)
			coroutine.resume(BlinkingTextF,DamageTagGUI.DamageText,3)
		end
		
		DamageTagGUI.DamageText.Text = table.concat(TextT,"")
		Debris:AddItem(DamageTagGUI,SetLifetime + AdditionalLifetime)
		
		--
		
		TweenService:Create(DamageTagGUI.DamageText,Settings.TextEntranceTween,{TextTransparency=0}):Play()
		TweenService:Create(DamageTagGUI.DamageText,Settings.TextEntranceTween,{TextStrokeTransparency=0}):Play()
		TweenService:Create(DamageTagGUI,Settings.TextRiseTween,{ExtentsOffsetWorldSpace=Vector3.new(0,DamageTagGUI.ExtentsOffsetWorldSpace.Y+FMKGF:AddressTableValue(Settings.TextRise),0)}):Play()
		
		delay(SetLifetime,function()
			TweenService:Create(DamageTagGUI.DamageText,TweenInfo.new(AdditionalLifetime,Settings.TextFadeTween[2],Settings.TextFadeTween[3],Settings.TextFadeTween[4],Settings.TextFadeTween[5],Settings.TextFadeTween[6]),{TextTransparency=1}):Play()
			TweenService:Create(DamageTagGUI.DamageText,TweenInfo.new(AdditionalLifetime,Settings.TextFadeTween[2],Settings.TextFadeTween[3],Settings.TextFadeTween[4],Settings.TextFadeTween[5],Settings.TextFadeTween[6]),{TextStrokeTransparency=1}):Play()
		end)
	end
end)


