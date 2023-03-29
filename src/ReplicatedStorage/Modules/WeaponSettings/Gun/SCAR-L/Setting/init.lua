local Module = {
--	====================
--	BASIC
--	A basic settings for the gun
--	====================
	
		UseCommonVisualEffects = true; --Enable to use default visual effect folder named "Common". Otherwise, use visual effect with specific tool name (ReplicatedStorage -> Miscs -> GunVisualEffects)
		AutoReload = true; --Reload automatically when you run out of mag; disabling it will make you reload manually
		CancelReload = true; --Exit reload state when you fire the gun
		DirectShootingAt = "None"; --"FirstPerson", "ThirdPerson" or "Both". Make bullets go straight from the fire point instead of going to input position. Set to "None" to disable this
	
		PrimaryHandle = "Handle";
		SecondaryHandle = "Handle2"; --Check "DualWeldEnabled" for detail
	
		CustomGripEnabled = false; --NOTE: Must disable "RequiresHandle" first
		CustomGripName = "Handle";
		CustomGripPart0 = {"Character", "Right Arm"}; --Base
		CustomGripPart1 = {"Tool", "Handle"}; --Target
		AlignC0AndC1FromDefaultGrip = true;
		CustomGripCFrame = false;
		CustomGripC0 = CFrame.new(0, 0, 0);
		CustomGripC1 = CFrame.new(0, 0, 0);	
		
		--CustomGripPart[0/1] = {Ancestor, InstanceName}
		--Supported ancestors: Tool, Character
		--NOTE: Don't set "CustomGripName" to "RightGrip"
	
--	====================
--	WALK SPEED REDUTION
--	Nerf chraracter's walk speed when equip the gun
--	====================

        WalkSpeedRedutionEnabled = false;
        WalkSpeedRedution = 6;
	
--	====================
--	MISCELLANEOUS
--	Etc. settings for the gun
--	====================

		DualWeldEnabled = false; --Enable the user to hold two guns instead one. In order to make this setting work, you must clone its PrimaryHandle and name it like SecondaryHandle. NOTE: Enabling "CustomGripEnabled" won't make this setting working	
		AltFire = false; --Enable the user to alt fire. NOTE: Must have aleast two setting modules
	
		MagCartridge = false; --Display magazine cartridge interface (cosmetic only)
		MaxCount = 200;
		RemoveOldAtMax = false;
		MaxRotationSpeed = 360;
		Drag = 1;
		Gravity = Vector2.new(0, 1000);
		Ejection = true;
		Shockwave = true;
		Velocity = 50;
		XMin = -4;
		XMax = -2;
		YMin = -6;
		YMax = -5;
		DropAllRemainingBullets = false;
		DropVelocity = 10;
		DropXMin = -5;
		DropXMax = 5;
		DropYMin = -0.1;
		DropYMax = 0;
		
--	====================
--	INPUTS
--	List of inputs that can be customized
--	====================
	
		Keyboard = {
			Reload = Enum.KeyCode.R;
			HoldDown = Enum.KeyCode.E;
			Inspect = Enum.KeyCode.F;
			Switch = Enum.KeyCode.V;
			ToogleAim = Enum.KeyCode.Q;
			Melee = Enum.KeyCode.H;
			AltFire = Enum.KeyCode.C;
		};
	
		Controller = {
			Fire = Enum.KeyCode.ButtonR1;
			Reload = Enum.KeyCode.ButtonX;
			HoldDown = Enum.KeyCode.DPadUp;
			Inspect = Enum.KeyCode.DPadDown;
			Switch = Enum.KeyCode.DPadRight;
			ToogleAim = Enum.KeyCode.ButtonL1;
			Melee = Enum.KeyCode.ButtonR3;
			AltFire = Enum.KeyCode.DPadRight;
		};
	
--	====================
--	END OF SETTING
--	====================
}

return Module