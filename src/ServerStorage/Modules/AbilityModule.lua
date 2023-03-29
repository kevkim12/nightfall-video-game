local ServerStorage = game:GetService("ServerStorage")
local AFM = require(ServerStorage.Modules.AbilityModuleMain) -- This is a seperate module that will continously be updated with more functions.

-- Type this in the Command Bar to see its functions : require(4698038381):AbilityFunctions()

local Abilities = {
	
	{
		
		AbilityName = "Test";
		AbilityDescription = "TestAbility";
		AbilityCooldown = 5;
		AbilityKeybind = "E";
		
		PreventExecutionDuringAttackFrame = false;
		AbilityServerFunc = function(Player, Tool, MouseHit)
			print'This is the ability printing in the Server!'
		end;
		
	};

};

return Abilities