																																			--[[
---------------------------
-- WEAPON TAG MODULE --
---------------------------

Initially added in the pre-v1.13 version.
This is the list of all executable MainModule weapon tags with their proper functions

This will also allow you to make your own effects if they are listed in a tool's WeaponTags!

--SEM.ExampleTag = {
--	EffectFunc = (function(Data)
--		-- Use your Data argument here. Remember to list your weapon tag in
--	end)
--};
																																			]]--

local SEM = {}

SEM.WeaponWalkspeed = {
	EffectFunc = (function(Data)
		if Data.UseHum then
			Data.UseHum.WalkSpeed = Data.WalkspeedChange
		end
	end)
};

return SEM