-- ConstantModule

local MoF = script.Parent
local CoF = require(MoF:WaitForChild("ConstantFunctions"))

--[[

ConstantFunctions

	CoF:ToggleDisableWeapon(Tool, bool)
	Example : CoF:ToggleDisableWeapon(Tool, true) --] Disables a player's weapon.

--]]

local ConstantSettings = {
	
	--[[ Bleeding Constant ]] {
		ConstantName = ("Bleeding"),
		
		ConstantParticleRoute = script:WaitForChild("BleedingPE"), -- Put nil if there isn't any.
		
		CustomBillboard = true;
		CustomBillboardRoute = script:WaitForChild("BleedingBB"); -- Put nil if there isn't any.
		
		Damage = (5); -- If you want no damage, then put nil.
		Lifetime = (2);
		Frequency = (1);
		
		EnableAdditionalEffectsFunc = true; -- Enables AdditionalEffectsFunc.www
		OneTime = false; -- When set to false, the AdditionalEffects function will run according to the frequency.
		AdditionalEffectsFunc = function(Target) -- Runs any additional effects
			
		end;
	};
	
	--[[ Example Constant ]] {
		ConstantName = ("Stupidity"),
		
		ConstantParticleRoute = nil, -- Put nil if there isn't any.
		
		CustomBillboard = false;
		CustomBillboardRoute = nil; -- Put nil if there isn't any.
		
		Damage = (1); -- If you want no damage, then put nil.
		Lifetime = (5);
		Frequency = (0.5);
		
		EnableAdditionalEffectsFunc = true; -- Enables AdditionalEffectsFunc.
		OneTime = false; -- When set to false, the AdditionalEffects function will run according to the frequency.
		AdditionalEffectsFunc = function(Target) -- Runs any additional effects
			print(Target.Name.." is stupid.")
		end;
	};
	
	--[[ Example Constant ]] {
		ConstantName = ("aaa"),

		ConstantParticleRoute = nil, -- Put nil if there isn't any.

		CustomBillboard = false;
		CustomBillboardRoute = nil; -- Put nil if there isn't any.

		Damage = (5); -- If you want no damage, then put nil.
		Lifetime = (5);
		Frequency = (0.5);

		EnableAdditionalEffectsFunc = true; -- Enables AdditionalEffectsFunc.
		OneTime = false; -- When set to false, the AdditionalEffects function will run according to the frequency.
		AdditionalEffectsFunc = function(Target) -- Runs any additional effects
			CoF:ToggleDisableWeapon(Target, true)
		end;
	};
	
};

return ConstantSettings