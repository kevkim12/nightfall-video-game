local Tool = script.Parent.Parent

local Attack = 
{
		
	-- Information Tables --
	
	["AnimationTable"] = {
		
			{ID = ("rbxassetid://6906553891"), speed = {1.75}, animationType = "Attack", hitboxTimes={0, 0.5}},
			{ID = ("rbxassetid://6906508309"), speed = {1.75}, animationType = "Attack", hitboxTimes={0, 0.5}},
			--{ID = ("rbxassetid://6909515519"), speed = {1.75}, animationType = "Attack", hitboxTimes={0, 0.5}},
		
	};
			
	["SoundsTable"] = {
			
			--{soundID = "rbxassetid://3755636638", pitch = {1}, volume = {0.5}, timeposition = {0}, delaysound = {.1}, soundType = "Swing"},
			{soundID = "rbxassetid://3755636638", pitch = {.9}, volume = {0.7}, timeposition = {0}, delaysound = {.1}, soundType = "Swing"},
			
			{soundID = "rbxassetid://175024455", pitch = {1}, volume = {0.5}, timeposition = {.12}, delaysound = {0}, soundType = "ImpactSound"},
			{soundID = "rbxassetid://3932505023", pitch = {1}, volume = {0.5}, timeposition = {0}, delaysound = {0}, soundType = "ImpactSound"},
			{soundID = "rbxassetid://4306991691", pitch = {1}, volume = {0.5}, timeposition = {.11}, delaysound = {0}, soundType = "ImpactSound"},

	};
	
	["MiscTable"] = {
			
	};
	
	-- Base Stats -- [ These stats are required to be inputted ]
				
	["BaseDamage"] = {65}; 
	["AttackDelay"] = (1);
			
	["Handle1Hitbox"] = true, 
	["Handle2Hitbox"] = false,
		
}
	
return Attack