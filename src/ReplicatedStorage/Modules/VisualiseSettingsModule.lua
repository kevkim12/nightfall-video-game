VisualiseSettings = {
	
	VisualiseIndicator_Settings = {
		
		--
		
		CriticalTextColor = Color3.fromRGB(205,205,0),
		CriticalTextStrokeColor = Color3.fromRGB(0,0,0),
		CriticalAdditionalText = "!", -- Any text you want to add after the damage value [EX : 150!]
		
		CriticalTextBlinking = true, -- The text will flash slightly over a loop.
		CriticalTextBlinkingColor = Color3.fromRGB(245,245,0),
		CriticalTextBlinkingTween = {0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0}, 
		
		BackstabTextColor = Color3.fromRGB(145,0,0),
		BackstabTextStrokeColor = Color3.fromRGB(0,0,0),
		BackstabAdditionalText = "!", -- If both a Critical and a Backstab happens, the two AdditionalText will be merged ONLY if TextMerge is set to true. [EX : 300!!]
		
		BackstabTextBlinking = true, -- If both a Critical and Backstab happens and TextBlinking is set to true on either value, then the text will merge the colours of CriticalTextBlinkingColor and BackstabTextBlinkingColor! Additionally, it will use the CriticalText tween.
		BackstabTextBlinkingColor = Color3.fromRGB(185,0,0),
		BackstabTextBlinkingTween = {0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0},
			
		TextMerge = true; -- If set to true, then it merges Backstab and CriticalText text if they happen at the same time.
			
		--
		
		TextEntranceTween = TweenInfo.new(0.1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0), -- A TweenInfo on the text gradually appearing.
		
		TextRise = {2.5,3.5}; -- How many studs the text will rise before stopping.
		TextRiseTween = TweenInfo.new(0.75,Enum.EasingStyle.Quart,Enum.EasingDirection.Out,0,false,0), -- A TweenInfo on the text gradually rising.
		
		TextLifetime = {0.3,0.4}, -- How long the text will last
		
		TextFadeTween = {{1.4,1.5},Enum.EasingStyle.Quart,Enum.EasingDirection.In,0,false,0}, -- A TweenInfo on the text gradually disappearing.
		
	}
	
}

return VisualiseSettings