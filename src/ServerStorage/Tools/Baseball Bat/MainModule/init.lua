local Tool = script.Parent

Module = {
	
	TOOL_VERSION = ("v1.2.2");

	MainSettings = {
		
		["MainAnimationTable"] = {
			{ID = "rbxassetid://94160581", Type = "Equip", Speed = 1.75};
			{ID = "rbxassetid://6906104068", Type = "Idle", Speed = 1};
		};
		
		["MainSoundsTable"] = {
			-- {ID = "rbxassetid:// ID HERE ", Type = "LOOK IN ARRAY BELOW", Speed = {MIN, MAX}, Volume = {MIN, MAX}};
			
		};
		
		-- MainSounds [ WeaponTakeDamage, WeaponBreak, AttackBlockStart, AttackBlockLoop, AttackBlockEnd, AttackBlockImpact ]
		-- The EquipSound is in the Handle. You can add an IdleSound to the weapon by insertting a new sound called "IdleSound" in the handle.
		
		--======--
		
		WeaponTags = {
			--["TEAMEnabled"] = true; -- Allows for team-based combat with the FE Melee kit! [NOTE : Requires a BrickColorValue named TEAM to work!]
		}
		
	};
	
	VisualSettings = {
		["EnableChargeBar"] = false;
		["VisibleTrail"] = false;
		["VisibleDamageTag"] = false;
		
	};
	
	Abilities = { -- You can grab abilities to put from the AbilityModule. Make sure to use the ability's name!
--		"Test",
	};

};

return Module