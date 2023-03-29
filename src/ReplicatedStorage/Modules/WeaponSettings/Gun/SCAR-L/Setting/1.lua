local Module = {
--	====================
--	BASIC
--	A basic settings for the gun
--	====================
	
		ModuleName = script.Name; --For security purpose
	
		Auto = false;
		BaseDamage = 20;
		FireRate = 0.125; --In second
		ReloadTime = 3; --In second
		AmmoPerMag = 31; --Set to "math.huge" to make this gun have infinite ammo and never reload
		Spread = 5; --In degree
		DamageMultipliers = { --You can add more body parts to modify damage
			["Head"] = 2,
		};
		EquipTime = 0;
		EquippedAnimationID = nil;
		EquippedAnimationSpeed = 1;
		IdleAnimationID = 10433908721; --Set to "nil" if you don't want to animate
		IdleAnimationSpeed = 1;
		FireAnimationID = 10074601820; --Set to "nil" if you don't want to animate
		FireAnimationSpeed = 1;
		ReloadAnimationID = 10079657965; --Set to "nil" if you don't want to animate
		ReloadAnimationSpeed = 1;
		
		--Enable the user to play second animation. Useful for dual wield 
		SecondaryFireAnimationEnabled = false; --You need an animation ID in order to enable it
		SecondaryFireAnimationID = nil; --Set to "nil" if you don't want to animate
		SecondaryFireAnimationSpeed = 1;
	
		--Enable the user to play aim animations
		AimAnimationsEnabled = false;
		AimIdleAnimationID = nil; --Set to "nil" if you don't want to animate
		AimIdleAnimationSpeed = 1;
		AimFireAnimationID = nil; --Set to "nil" if you don't want to animate
		AimFireAnimationSpeed = 1;
		AimSecondaryFireAnimationID = nil; --Set to "nil" if you don't want to animate. NOTE: Make sure "SecondaryFireAnimation" setting is enabled
		AimSecondaryFireAnimationSpeed = 1;	
	
		--Must enable "AltFire" first
		AltAnimationID = nil;
		AltAnimationSpeed = 1;
		AltTime = 1;	
	
--  ====================
--  MELEE ATTACK
--  Gain an ability to perform melee attack
--  ====================
	
		MeleeAttackEnabled = false;
		
		MeleeAttackAnimationID = nil;
		MeleeAttackAnimationSpeed = 1;
	
		MeleeDamage = 20;	
		MeleeDamageMultipliers = { --You can add more body parts to modify damage
			["Head"] = 2,
		};
		MeleeAttackRange = 4;
	
		--Marker effect
		MarkerEffectEnabled = true;
		MarkerEffectSize = 0.5;
		MarkerEffectTexture = {2078626}; --You can insert more IDs
		MarkerEffectVisibleTime = 3; --In second
		MarkerEffectFadeTime = 1; --In second
		MarkerPartColor = true; --Set to hit object color
	
		--Hit effect
		MeleeHitEffectEnabled = true;
		MeleeHitSoundIDs = {6000828622};
		MeleeHitSoundPitchMin = 1; --Minimum pitch factor you will acquire
		MeleeHitSoundPitchMax = 1.5; --Maximum pitch factor you will acquire
		MeleeHitSoundVolume = 1;
		CustomMeleeHitEffect = false; --Emits your custom hit effect. NOTE: If you this setting disabled, hit effect will set to default(material tracker included)
	
		--Blood effect
		MeleeBloodEnabled = false;
		MeleeHitCharSndIDs = {6398015798, 6398016125, 6398016391, 6398016618};
		MeleeHitCharSndPitchMin = 1; --Minimum pitch factor you will acquire
		MeleeHitCharSndPitchMax = 1; --Maximum pitch factor you will acquire
		MeleeHitCharSndVolume = 1;
	
		--Blood wound
		MeleeBloodWoundEnabled = false;
		MeleeBloodWoundSize = 0.5;
		MeleeBloodWoundTexture = {2078626}; --You can insert more IDs
		MeleeBloodWoundTextureColor = Color3.fromRGB(255, 0, 0);
		MeleeBloodWoundVisibleTime = 3; --In second
		MeleeBloodWoundFadeTime = 1; --In second
		MeleeBloodWoundPartColor = true; --Set to hit object color
	
		--Miscs
		MeleeKnockback = 0; --Setting above 0 will enabling the gun to push enemy back.
		MeleeLifesteal = 0; --In percent - Setting above 0 will allow user to steal enemy's health by dealing a damage to them.
		MeleeDebuff = false; --Enable the melee to give enemy a debuff. Source of debuff can be found inside "ReplicatedStorage" -> "Miscs" -> "Debuffs"
		MeleeDebuffName = "";
		MeleeDebuffChance = 100;
		ApplyMeleeDebuffOnCritical = false; --Enable "MeleeCriticalDamageEnabled" first
	
		--Critical
		MeleeCriticalDamageEnabled = false;
		MeleeCriticalBaseChance = 5; --In percent
		MeleeCriticalDamageMultiplier = 3;
	
--		To make this feature functional, the animation must be included with "KeyFrameMarker" named "MeleeDamageSequence". Learn more about it here:
--		https://developer.roblox.com/en-us/api-reference/function/AnimationTrack/GetMarkerReachedSignal
--		https://developer.roblox.com/en-us/api-reference/class/KeyframeMarker	
--		https://developer.roblox.com/en-us/articles/using-animation-editor (Animation Events part)
	
--	====================
--	LASER TRAIL
--	Create a trail of laser when travelling
--	====================	
	
		LaserTrailEnabled = false;
		LaserTrailWidth = 0.5;
		LaserTrailHeight = 0.5;
		LaserTrailColor = Color3.fromRGB(0, 170, 255);
		RandomizeLaserColorIn = "None"; --"Whole" or "Segment"? Set to "None" to not use this
		LaserColorCycleTime = 5; --Duration of time to go through rainbow (not random colors). NOTE: This setting only works when "LaserBeam" and "RandomizeLaserColorIn" are enabled
		LaserTrailMaterial = Enum.Material.Neon;
		LaserTrailShape = "Block"; --"Block", "Cylinder" or... "Cone"?
		LaserTrailReflectance = 0;
		LaserTrailTransparency = 0;
		LaserTrailVisibleTime = 1; --In second
		LaserTrailFadeTime = 0.5; --In second
		ScaleLaserTrail = false; --Scale time is influenced by "LaserTrailFadeTime"
		LaserTrailScaleMultiplier = 1.5;
	
		DamageableLaserTrail = false; --Make laser trail become deadly
		LaserTrailDamage = 20;
		LaserTrailConstantDamage = true; --Make laser damage humanoids overtime
		LaserTrailDamageRate = 0.1; --In second
	
		--Miscs
		LaserTrailKnockback = 0; --Setting above 0 will enabling the gun to push enemy back.
		LaserTrailLifesteal = 0; --In percent - Setting above 0 will allow user to steal enemy's health by dealing a damage to them.
		LaserTrailDebuff = false; --Enable the laser to give enemy a debuff. Source of debuff can be found inside "ReplicatedStorage" -> "Miscs" -> "Debuffs"
		LaserTrailDebuffName = "";
		LaserTrailDebuffChance = 100;
		ApplyLaserTrailDebuffOnCritical = false; --Enable "LaserTrailCriticalDamageEnabled" first
	
		--Critical
		LaserTrailCriticalDamageEnabled = false;
		LaserTrailCriticalBaseChance = 5; --In percent
		LaserTrailCriticalDamageMultiplier = 3;
				
--	====================
--	LIGHTNING BOLT
--	Create a trail of lightning when travelling
--	====================		
	
		LightningBoltEnabled = false;
		BoltCount = 1;
		BoltRadius = 5;
		BoltWideness = 5;
		BoltWidth = 0.5;
		BoltHeight = 0.5;
		BoltColor = Color3.fromRGB(0, 170, 255);
		RandomizeBoltColorIn = "None"; --"Whole" or "Segment"? Set to "None" to not use this
		BoltMaterial = Enum.Material.Neon;
		BoltShape = "Block"; --"Block", "Cylinder" or... "Cone"?
		BoltReflectance = 0;
		BoltTransparency = 0;
		BoltVisibleTime = 1; --In second
		BoltFadeTime = 0.5; --In second
		ScaleBolt = false; --Scale time is influenced by "BoltFadeTime"
		BoltScaleMultiplier = 1.5;	
	
--	====================
--	LASER BEAM
--  Enable the gun to fire focus beam. NOTE: This setting will enter automatic mode, and disable most of settings by default	
--	====================		
	
		LaserBeam = false;
		LaserBeamRange = 100;
		LaserBeamStartupDelay = 1;
		LaserBeamStopDelay = 1;
		IgnoreHumanoids = false;
		LookAtInput = false; --Make both muzzle and hit points look at input's position
	
		LaserBeamStartupAnimationID = nil;
		LaserBeamStartupAnimationSpeed = 1;
		LaserBeamLoopAnimationID = nil;
		LaserBeamLoopAnimationSpeed = 1;
		LaserBeamStopAnimationID = nil;
		LaserBeamStopAnimationSpeed = 1;	
	
--		To configure damage for laser beam, see "LaserTrail" settings. NOTE: You don't have to set "LaserTrailEnabled", "DamageableLaserTrail" and "LaserTrailConstantDamage" to true
	
--      When this setting is enabled, the system won't visualize muzzle flash from visual effect folder (see ReplicatedStorage -> Miscs -> GunVisualEffects), but instead will visualize it from muzzle point of gun handle. So you have to put your effect inside muzzle point (Example effect is in it). NOTEL This is optional and is not affected by "MuzzleFlashEnabled" 
	
--		If you want muzzle flash to be bursted, you can add "EmitCount" int value into it, just like the rest of visual effects. Otherwise, muzzle flash will be (in)visible (depends on whether you are firing or not)
	
--	====================
--	LIMITED AMMO
--	Make a gun has a limit ammo
--	====================

		LimitedAmmoEnabled = true;
		Ammo = 60;
		MaxAmmo = 60; --Set to "math.huge" to allow user to carry unlimited ammo	
	
--	====================
--	CROSSHAIR
--	A gun cursor
--	====================

        CrossSize = 7;
        CrossExpansion = 100;
        CrossSpeed = 15;
        CrossDamper	= 0.8;	
	
--	====================
--	HITMARKER
--	Mark on somewhere when a bullet hit character
--	====================

        HitmarkerEnabled = false;
        HitmarkerSoundIDs = {3748776946, 3748777642, 3748780065};
        --Normal
        HitmarkerColor = Color3.fromRGB(255, 255, 255);
        HitmarkerFadeTime = 0.4;
        HitmarkerSoundPitch = 1;
		--Headshot
		HeadshotHitmarker = true;
        HitmarkerColorHS = Color3.fromRGB(255, 0, 0);
        HitmarkerFadeTimeHS = 0.4;
        HitmarkerSoundPitchHS = 1;	
	
--	====================
--	CAMERA RECOILING
--	Make user's camera recoiling when shooting
--	====================

		CameraRecoilingEnabled = true;
		Recoil = 25;
		AngleX_Min = 1; --In degree
		AngleX_Max = 1; --In degree
		AngleY_Min = 0; --In degree
		AngleY_Max = 0; --In degree
		AngleZ_Min = -1; --In degree
		AngleZ_Max = 1; --In degree
        Accuracy = 0.1; --In percent. For example: 0.5 is 50%
        RecoilSpeed = 15; 
        RecoilDamper = 0.65;
		RecoilRedution = 0.5; --In percent.	
	
--	====================
--	TWEEN SETTING
--	Part of ironsight and sniper aim
--	====================

        TweenLength = 0.8; --In second
        EasingStyle = Enum.EasingStyle.Quint; --Linear, Sine, Back, Quad, Quart, Quint, Bounce or Elastic?
        EasingDirection = Enum.EasingDirection.Out; --In, Out or InOut?

--	====================
--	TWEEN SETTING(NO AIM DOWN)
--	Part of ironsight and sniper aim
--	====================

        TweenLengthNAD = 0.8; --In second
        EasingStyleNAD = Enum.EasingStyle.Quint; --Linear, Sine, Back, Quad, Quart, Quint, Bounce or Elastic?
		EasingDirectionNAD = Enum.EasingDirection.Out; --In, Out or InOut?
	
--	====================
--	IRONSIGHT
--	Allow user to ironsighting
--	====================

		IronsightEnabled = true; --NOTE: If "SniperEnabled" is enabled, this setting is not work
		FieldOfViewIS = 50;
		MouseSensitiveIS = 0.2; --In percent
		SpreadRedutionIS = 0.6; --In percent. NOTE: Must be the same value as "SpreadRedutionS"
		CrossScaleIS = 0.6;	
	
--	====================
--	SNIPER
--	Enable user to use scope
--	====================

		SniperEnabled = false; --NOTE: If "IronsightEnabled" is enabled, this setting is not work
		FieldOfViewS = 12.5;
		MouseSensitiveS = 0.2; --In percent
		SpreadRedutionS = 0.6; --In percent. NOTE: Must be the same value as "SpreadRedutionOS"
		CrossScaleS = 0;
		ScopeSensitive = 0.25;
		ScopeDelay = 0;
		ScopeKnockbackMultiplier = 5;
		ScopeKnockbackSpeed = 15;
        ScopeKnockbackDamper = 0.65;
		ScopeSwaySpeed = 15;
		ScopeSwayDamper	= 0.65;
	
--  ====================
--  SMOKE TRAIL
--  Emit smoke trail while firing. NOTE: This setting is only for client
--  ====================

		SmokeTrailEnabled = false;
		SmokeTrailRateIncrement = 1;
		MaximumRate = 4; --Beyond this will return "CurrentRate" to 0 and emit smoke trail. NOTE: Last smoke trail will be terminated after this
		MaximumTime = 1; --Maximum time that smoke trail won't be emitted
	
--	====================
--	FIRE SOUND EFFECTS
--	Special effects for fire sound
--	====================
		
		SilenceEffect = false; --Lower volume
		EchoEffect = true; --Create echo effect from distance
		LowAmmo = true; --Play sound when low ammo
		RaisePitch = false; --"LowAmmo" only. The lower ammo is, the higher pitch will play
	
		--Settings for "EchoEffect"
		DistantSoundIds = {177174605};
		DistantSoundVolume = 1.5;
	
--	====================
--	GORE VISUALIZER
--	Create gore effect when humanoid died
--	====================

        GoreEffectEnabled = false;
		GoreSoundIDs = {1930359546};
		GoreSoundPitchMin = 1; --Minimum pitch factor you will acquire
	    GoreSoundPitchMax = 1.5; --Maximum pitch factor you will acquire
		GoreSoundVolume = 1;
		FullyGibbedLimbChance = 50; --In percent
	
--	====================
--	INSPECT ANIMATION
--	Inspect the gun just to see how it looks
--	====================

		InspectAnimationEnabled = false;
		InspectAnimationID = nil; --Set to "nil" if you don't want to animate
		InspectAnimationSpeed = 1;
	
--	====================
--	TACTICAL RELOAD ANIMATION
--	Reload the gun that has only fired a few rounds out of its magazine
--	====================

		TacticalReloadAnimationEnabled = false;
		TacticalReloadAnimationID = nil; --Set to "nil" if you don't want to animate
		TacticalReloadAnimationSpeed = 1;
		TacticalReloadTime = 3;
	
--	====================
--	HOLD DOWN ANIMATION
--	Character won't fire if hold down the gun
--	====================

        HoldDownEnabled = false;
        HoldDownAnimationID = nil;
        HoldDownAnimationSpeed = 0.5;	
	
--  ====================
--  DAMAGE DROPOFF
--  Calculate how the damage of a single shot decreases when the target hit is at a distance away from the gun shot. NOTE: This setting won't apply with "ExplosiveEnabled"
--  ====================

		DamageDropOffEnabled = false;
		ZeroDamageDistance = 10000; --Anything hit at or beyond this distance will receive no damage; default is 10000
		FullDamageDistance = 1000; --Maximum distance that shots will do full damage. Default is 1000 and anything hit beyond this distance will receive less and less damage as the distance nears "ZeroDamageDistance"
		
--	====================
--	CRITICAL DAMAGE
--	Damage critically within its chance
--	====================

        CriticalDamageEnabled = false;
        CriticalBaseChance = 5; --In percent
        CriticalDamageMultiplier = 3;
		
--	====================
--	HIT VISUALIZER
--	Create hit effect when a bullet hit something but not character(And hit sound, too)
--	====================

        HitEffectEnabled = false;
		HitSoundIDs = {186809061, 186809249, 186809250, 186809252};
		HitSoundPitchMin = 1; --Minimum pitch factor you will acquire
	    HitSoundPitchMax = 1.5; --Maximum pitch factor you will acquire
		HitSoundVolume = 1;
		CustomHitEffect = false; --Emits your custom hit effect. NOTE: If you this setting disabled, hit effect will set to default(material tracker included)
	
		BulletHoleEnabled = false;
        BulletHoleSize = 0.5;
        BulletHoleTexture = {2078626}; --You can insert more IDs
        BulletHoleVisibleTime = 3; --In second
        BulletHoleFadeTime = 1; --In second
        PartColor = true; --Set to hit object color
	
--		How to add custom sounds for any material	
	
--		Go to ReplicatedStorage -> Miscs -> GunVisualEffects -> Common (Folder with specific tool name if you don't use common effects)
--		>>>
--		Open "HitEffect" folder and choose one of material folders
--		>>>
--		Add a "MaterialSounds" folder into it and insert any sound you desire
-- 		>>>
--		To play sound with different volume and pitch, add a folder named "Volume" or "Pitch" into specific sound object. Then insert two "Min" and "Max" number values into that folder, and adjust them whatever you like
	
--		How to add custom decals for bullet hole	
	
--		Do the same thing as first two steps of the way adding custom sound
--		>>>
--		Add a "MaterialDecals" folder into it and insert int value which defines id of decal. Don't forget to add "PartColor" bool value into value object, and keep it disabled if you don't want decal's color to be blended into hit part's
	
--	====================
--	BLOOD VISUALIZER
--	Create blood when a bullet hit character(And hit character sound, too)
--	====================

        BloodEnabled = false;
		HitCharSndIDs = {3802437008, 3802437361, 3802437696, 3802440043, 3802440388, 3802442962};
		HitCharSndPitchMin = 1; --Minimum pitch factor you will acquire
	    HitCharSndPitchMax = 1; --Maximum pitch factor you will acquire
		HitCharSndVolume = 1;
	
		BloodWoundEnabled = false;
		BloodWoundSize = 0.5;
		BloodWoundTexture = {2078626}; --You can insert more IDs
		BloodWoundTextureColor = Color3.fromRGB(255, 0, 0);
		BloodWoundVisibleTime = 3; --In second
		BloodWoundFadeTime = 1; --In second
		BloodWoundPartColor = true; --Set to hit object color
	
--	====================
--	BULLET WHIZZING SOUND
--	Create a sound when a bullet travelling through character
--	====================

        WhizSoundEnabled = true;
        WhizSoundIDs = {3809084884, 3809085250, 3809085650, 3809085996, 3809086455};
		WhizSoundVolume = 1;
		WhizSoundPitchMin = 1; --Minimum pitch factor you will acquire
	    WhizSoundPitchMax = 1; --Maximum pitch factor you will acquire
	    WhizDistance = 25;
	
--		Make sure "CanMovePart" is enabled. Otherwise, it won't work	
	
--	====================
--	MUZZLE
--	Create a muzzle flash when firing
--	====================
        
        MuzzleFlashEnabled = true;
        MuzzleLightEnabled = true;
        LightBrightness = 4;
        LightColor = Color3.new(255/255, 283/255, 0/255);
        LightRange = 15;
        LightShadows = true;
        VisibleTime = 0.01; --In second
	
--	====================
--	BULLET SHELL EJECTION
--	Eject bullet shells when firing
--	====================

		BulletShellEnabled = true;
		BulletShellType = "Normal";
		BulletShellDelay = 0;
		BulletShellVelocity = 17;
		BulletShellRotVelocity = 40;
		RadomizeRotVelocity = true;
		AllowCollide = false; --If false, a bullet shell will go through any parts
		DisappearTime = 5; --In second
		BulletShellParticles = false;
	
		BulletShellHitSoundEnabled = true;
		BulletShellHitSoundIDs = {3909012115};
		BulletShellHitSoundVolume = 1;
		BulletShellHitSoundPitchMin = 1; --Minimum pitch factor you will acquire
		BulletShellHitSoundPitchMax = 1; --Maximum pitch factor you will acquire
	
--	====================
--	SHOTGUN
--	Enable the gun to fire multiple bullet in one shot
--	====================

		ShotgunEnabled = false;
		BulletPerShot = 8;
		
		ShotgunPump = false; --Make user pumping like Shotgun after firing
		ShotgunPumpinAnimationID = nil; --Set to "nil" if you don't want to animate
		ShotgunPumpinAnimationSpeed = 1;
		ShotgunPumpinSpeed = 0.5; --In second
		SecondaryShotgunPump = false; --Only for dual wield
		SecondaryShotgunPumpinAnimationID = nil; --Set to "nil" if you don't want to animate
		SecondaryShotgunPumpinAnimationSpeed = 1;
		SecondaryShotgunPumpinSpeed = 0.5; --In second
		
		ShotgunReload = false; --Make user reloading like Shotgun, which user clipin shell one by one
		ShotgunClipinAnimationID = nil; --Set to "nil" if you don't want to animate
		ShotgunClipinAnimationSpeed = 1;
		ShellClipinSpeed = 0.5; --In second
		PreShotgunReload = false; --Make user pre-reloading before consecutive reload. NOTE: "ShotgunReload" must be enabled
		PreShotgunReloadAnimationID = nil; --Set to "nil" if you don't want to animate
		PreShotgunReloadAnimationSpeed = 1;
		PreShotgunReloadSpeed = 0.5; --In second
		
		ShotgunPattern = false;
		SpreadPattern = { --{x, y}. The number of tables inside it should be the same as "BulletPerShot"
			-- inner 3
			{0, -0.4};
			{-0.35, 0.2};
			{0.35, 0.2};
		
			-- outer five
			{0, 1};
			{0.95, 0.31};
			{0.59, -0.81};
			{-0.59, -0.81};
			{-0.95, 0.31};
		};
		
--		How "ShotgunPump" works [Example 1]:

--      Fire a (shot)gun
--		>>>
--		After "FireRate", user will pump it, creates pumpin delay + "PumpSound"
		
--		How "ShotgunReload" works [Example 2]:

--		Play "ShotgunClipinAnimation" + Play "ShotgunClipin" Audio
--		>>>
--		Wait "ShellClipinSpeed" second(s)
--		>>>
--		Repeat "AmmoPerClip" - "Current Ammo" times
--		>>>
--		Play "ReloadAnimation" + Play "ReloadSound"
--		>>>
--		Wait "ReloadTime"
		
--	====================
--	BURST FIRE
--	Enable the gun to do burst firing like Assault Rifle
--	====================

		BurstFireEnabled = false;
		BulletPerBurst = 3;
		BurstRate = 0.075; --In second
	
--	====================
--	SELECTIVE FIRE
--	Enable the user to switch firemode. NOTE: The following settings: "Auto", "FireRate", "BurstFireEnabled", "BulletPerBurst", "BurstRate" and "ChargedShotAdvanceEnabled" will be disabled if "SelectiveFireEnabled" is enabled
--	====================

		SelectiveFireEnabled = true;
		FireModes = {true, 1}; --"true" is a boolean which uses for autofire, while integer is being used for burst counts (Ex. ireModes = {1, 2, 3, true};)
		FireRates = {0.07, 0.1};
		BurstRates = {0, 0};
		FireModeTexts = {"AUTO", "SEMI"};
		SwitchTime = 0.25; --In second

		SwitchAnimationID = nil; --Set to "nil" if you don't want to animate
		SwitchAnimationSpeed = 1;

--		The priority of firemode is from left to right
	
--	====================
--	EXPLOSIVE
--	Make a bullet explosive so user can deal a damage to multiple enemy in single shot. NOTE: Explosion won't break joints
--	====================

		ExplosiveEnabled = false;
		ExplosionSoundEnabled = true;
		ExplosionSoundIDs = {163064102};
		ExplosionSoundVolume = 1;
		ExplosionSoundPitchMin = 1; --Minimum pitch factor you will acquire
	    ExplosionSoundPitchMax = 1.5; --Maximum pitch factor you will acquire
		ExplosionRadius = 8;
	
		DamageBasedOnDistance = false;
	
		SelfDamage = false;
		SelfDamageRedution = 0.5; --In percent
		ReduceSelfDamageOnAirOnly = false;
	
		CustomExplosion = false;
	
		ExplosionKnockback = false; --Enable the explosion to knockback player. Useful for rocket jumping
		ExplosionKnockbackPower = 50;
		ExplosionKnockbackMultiplierOnPlayer = 2;
		ExplosionKnockbackMultiplierOnTarget = 2;
	
        ExplosionCraterEnabled = true;
      	ExplosionCraterSize = 3;
        ExplosionCraterTexture = {53875997}; --You can insert more IDs
        ExplosionCraterVisibleTime = 3; --In second
        ExplosionCraterFadeTime = 1; --In second
        ExplosionCraterPartColor = false; --Set to hit object color

--	====================
--	PROJECTILE VISUALIZER
--	Display a travelling projectile
--	====================

		ProjectileType = "NewBullet"; --Set to "None" to not to visualize projectile
		BulletSpeed = 3000;
		TravelType = "Distance"; --Switch to either "Distance" or "Lifetime" to change how the bullet travels
		Range = 5000; --The furthest distance the bullet can travel
		Lifetime = 5; --The longest time the bullet can travel
		Acceleration = Vector3.new(0, 0, 0);
	
		BulletParticle = false;
		BulletType = "Normal";
		MotionBlur = true;
		BulletSize = 0.4;
		BulletBloom = 0.005;
		BulletBrightness = 400;
	
		CanSpinPart = false;
		SpinX = 3;
		SpinY = 0;
		SpinZ = 0;
	
		DebrisProjectile = false; --Enable the projectile to become debris after hit
		AnchorDebris = false;
		CollideDebris = true;
		NormalizeDebris = false;
		BounceDebris = true; --Disable "AnchorDebris" first
		BounceVelocity = 30;
	
		DecayProjectile = false; --Enable the projectile to become debris when it stops travelling
		AnchorDecay = false;
		CollideDecay = true;
		DecayVelocity = 30;
		VelocityInfluence = true; --Apply previous velocity of travelling projectile to decaying one's, instead of "DecayVelocity"
	
		DisableDebrisContents = {  --Disable projectile's contents when it becomes debris
			Light = false;
			Particle = false;
			Trail = false;
			Beam = false;
			Sound = false;
		};
	
		Homing = false; --Allow projectile to move towards target
		HomingDistance = 250;
		TurnRatePerSecond = 1;
		HomeThroughWall = false;
		LockOnOnHovering = false;
		LockOnRadius = 10;
		LockOnDistance = 100;
	
		RaycastHitbox = false; --Expand raycast. Useful for a projectile with bigger size and unique shape. NOTE: Experimental and very expensive, use it wisely
		RaycastHitboxData = { --Ray point data for raycast hitbox. Use CFrame only as it does same thing as Vector3, but also respects object space
			CFrame.new(-1, 1, -1);
			CFrame.new(1, 1, -1);
			CFrame.new(-1, -1, -1);
			CFrame.new(1, -1, -1);
			CFrame.new(1, -1, 1);
			CFrame.new(-1, -1, 1);
			CFrame.new(-1, 1, 1);
			CFrame.new(1, 1, 1);
		};
	
--		To make raycast hitbox data easily, add an attachment to projectile (create a new part if projectile doesn't exist), position it and then copy and paste its position to "RaycastHitboxData" table (CFrame.new(AttachmentPosition)). And repeat
	
		UpdateRayInExtra = false; --Additional update for your custom raycast behavior, such as sine wave projectile
		ExtraRayUpdater = function(Cast, Dt)
			--Have fun and good luck
		end;
	
		HitscanMode = true; --Enable the bullet to insta-hit regardless of its traveling speed
	
--		NOTE: Enabling "HitscanMode" will restrict the following physic-based settings:
--		"Acceleration"
--		"Homing"
--		"RaycastHitbox"
--		Ricochet effect ("BounceElasticity", "FrictionConstant", "IgnoreSlope", "SuperRicochet", "HitEventOnTermination") [Ricochet effect still works for hitscan however. But only physic-based settings are disabled]
	
--	====================
--	CHARGED SHOT
--	Make a gun charging before firing. Useful for a gun like "Railgun" or "Laser Cannon"
--	====================
		
		ChargedShotEnabled = false;
		ChargingTime = 1;
		
--	====================
--	MINIGUN
--	Make a gun delay before/after firing
--	====================

		MinigunEnabled = false;
		DelayBeforeFiring = 1;
		DelayAfterFiring = 1;
		MinigunRevUpAnimationID = nil;
		MinigunRevUpAnimationSpeed = 1;
		MinigunRevDownAnimationID = nil;
		MinigunRevDownAnimationSpeed = 1;
	
--	====================
--	BATTERY
--	Make a gun overheat when overcharge
--	====================

		BatteryEnabled = false;
		MaxHeat = 100;
		TimeBeforeCooldown = 3;
		CooldownTime = 0.05;
		CooldownRate = 1; 
		OverheatTime = 2.5;
		HeatPerFireMin = 7;
		HeatPerFireMax = 8;
		MinDepletion = 2;
		MaxDepletion = 4;
		ShotsForDepletion = 12;
		OverheatAnimationID = nil;
		OverheatAnimationSpeed = 1;
		
--	====================
--	MISCELLANEOUS
--	Etc. settings for the gun
--	====================

		Knockback = 0; --Setting above 0 will enabling the gun to push enemy back
		Lifesteal = 0; --In percent - Setting above 0 will allow user to steal enemy's health by dealing a damage to them
	
		Debuff = false; --Enable the bullet to give enemy a debuff. Source of debuff can be found inside "ReplicatedStorage" -> "Miscs" -> "Debuffs"
		DebuffName = "";
		DebuffChance = 100;
		ApplyDebuffOnCritical = false; --Enable "CriticalDamageEnabled" first

		DualFireEnabled = false; --Enable the user to fire two guns instead one. In order to make this setting work, you must clone its Handle and name it to "Handle2".

		PenetrationType = "HumanoidPenetration"; --2 types: "WallPenetration" and "HumanoidPenetration"
		PenetrationDepth = 0; --"WallPenetration" only. This is how many studs a bullet can penetrate into a wall. So if penetration is 0.5 and the wall is 1 studs thick, the bullet won't come out the other side. NOTE: "ExplosiveEnabled" doesn't apply to this, and having "RaycastHitbox" enabled can take more studs at a time when penetrating solid objects 
		PenetrationAmount = 0; --"HumanoidPenetration" only. Setting above 0 will enabling the gun to penetrate up to XX victim(s). Cannot penetrate wall. NOTE: "ExplosiveEnabled" doesn't apply to this
		PenetrationIgnoreDelay = math.huge; --Time before removing penetrated objects from ignore list. Useful for when you have "Homing" enabled. Set to "math.huge" to prevent from removing
	
		RicochetAmount = 0; --Setting above 0 will enabling the bullet to bounce objects in amount of bounces. NOTE: This will disable "PenetrationDepth" setting but "PenetrationAmount", and having "RaycastHitbox" enabled will sometimes make the bullet bounce weirdly
		BounceElasticity = 1;
		FrictionConstant = 0;
		IgnoreSlope = false; -- Enable the bullet to keep bouncing forwards on slope. Useful for a Metal Slug's Drop Shot styled projectile. NOTE: This only works when "Acceleration" is not a zero vector, and its Y axis is lower than 0
		SlopeAngle = 90; -- Angle of slope to stop bouncing forwards
		BounceHeight = 50;
		NoExplosionWhileBouncing = false; --Enable the bullet to be prevented from exploding on bounce. NOTE: "NoExplosionWhileBouncing" will be disabled after reaching 0 bounce
		StopBouncingOn = "None"; --Enable the bullet to be forced to stop bouncing after hitting "Humanoid" or "Object". Set to "None" to disable this
		SuperRicochet = false; --Enable the bullet to bounce indefinitely. NOTE: This doesn't affect "RicochetAmount" but won't remove bullet regardless of its limited amount of bounces
		BounceBetweenHumanoids = false; --Enable the bullet to reflect on other humanoids. NOTE: This has shared settings with "Homing" like "HomingDistance" and "HomeThroughWall" (No need to enable "Homing" however)
		PredictDirection = false; --Predict humanoid's movement to bounce at. NOTE: This does not apply to "HitscanMode"
	
		HitEventOnTermination = true; --Yield "FinalHit" event after exceeding maximum lifetime or travel distance. Useful for a TF2 styled grenade launcher
	
		SelfKnockback = false; --Enable the gun to knockback player. Useful for shotgun jumping
		SelfKnockbackPower = 50;
		SelfKnockbackMultiplier = 2;
		SelfKnockbackRedution = 0.8;

		ProjectileMotion = false; --Enable the gun to visible trajectory. Useful for projectile arc weapon	
	
		FriendlyFire = false; --Enable the user to inflict damage on teammates (works with custom "TEAM" as well)
	
		BlacklistParts = {["Part Name Here"] = true}; --Put any part name you want here to blacklist
		IgnoreBlacklistedParts = true; --Enable the bullet to go through blacklisted parts. Set to false to make bullet hit at them (won't detect humanoid at that moment) 	
	
--	====================
--	CHARGED SHOT ADVANCE
--	Unlike "ChargedShot", this advanced version will allow gun to charge by holding down input. NOTE: This setting will disable some features such as "Auto", "ChargedShot", "MinigunEnabled"
--	====================

		ChargedShotAdvanceEnabled = false;
		AdvancedChargingTime = 5; --Known as Level3ChargingTime
		Level1ChargingTime = 1;
		Level2ChargingTime = 2;
		ChargingSoundIncreasePitch = true;
		ChargingSoundPitchRange = {1, 1.5};

		ChargingAnimationEnabled = false; --You need an animation ID in order to enable it
		ChargingAnimationID = nil; --Set to "nil" if you don't want to animate
		ChargingAnimationSpeed = 1;

		AimChargingAnimationID = nil; --Set to "nil" if you don't want to animate
		AimChargingAnimationSpeed = 1;

		ChargeAlterTable = {
		};
	
--	====================
--	HOLD AND RELEASE
--	Similar to "ChargedShotAdvance", but this is just hold-the-trigger-and-release-to-fire feature
--	====================

		HoldAndReleaseEnabled = false;
		HoldingTime = 1; --Time before being able to fire
	
		LockOnScan = false; --Enable the gun to track targets that are within frame when holding down input, and fire at them when holding up. NOTE: This will overwrite "BurstFire" and "HoldingTime" settings
		TimeBeforeScan = 0.5;
		ScanRate = 0.5;
		MaximumTargets = 3; --Amount of targets to track
		LockOnScanBurstRate = 0.1; --In second
		ScanFrameWidth = 0.5; --Width size of frame to track targets
		ScanFrameHeight = 0.5; --Height size of frame to track targets
	
--		Charging animation and charging sound are shared from "ChargedShotAdvance" to this feature	
	
--		You can adjust scan distance by changing "LockOnDistance" value. NOTE: No need to enable "Homing" and "LockOnOnHovering" settings
	
--	====================
--	ANIMATION KEYFRAMES
--	List of keyframes that can be customized for existing animations
--	====================
	
		AnimationKeyframes = {
		};
	
--		Template:
	
--[[	
		["AnimationName"] = {
			["KeyframeName"] = function(keyframeName, tool)
				print(keyframeName)
			end;
		};	
]]
	
--		How to use:
	
--		Copy and paste template table above into "AnimationKeyframes" table and uncomment it
--		>>>
--		Change "AnimationName" to specific string that is listed below
--		>>>
--		Change "KeyframeName" to existing keyframe name from your existing animation
--		>>>
--		Now write something you want inside its callback function
	
--		NOTE: To make this work, open animation editor and import your animation. Next, add animation event (edit if it exists), and then move (event) keyframe names to "Parameter" side whilst everything in "Event Name" side is renamed to "AnimationEvents"
--		NOTE 2: You can add more than one table. For an example:
	
--[[
		AnimationKeyframes = {
			["EquippedAnim"] = {
				["1"] = function(keyframeName, tool)
					print(keyframeName)
				end;
				["2"] = function(keyframeName, tool)
					print(keyframeName)
				end;
			};
			["ReloadAnim"] = {
				["1"] = function(keyframeName, tool)
					print(keyframeName)
				end;
				["2"] = function(keyframeName, tool)
					print(keyframeName)
				end;
				["3"] = function(keyframeName, tool)
					print(keyframeName)
				end;
			};
		};
]]
	
--		List of supported animations:
-- 		IdleAnim
-- 		FireAnim
-- 		ReloadAnim
-- 		TacticalReloadAnim
-- 		ShotgunClipinAnim
-- 		ShotgunPumpinAnim
-- 		SecondaryShotgunPumpinAnim
-- 		HoldDownAnim
-- 		EquippedAnim
-- 		SecondaryFireAnim
-- 		AimIdleAnim
-- 		AimFireAnim
-- 		AimSecondaryFireAnim
-- 		AimChargingAnim
-- 		InspectAnim
-- 		PreShotgunReloadAnim
-- 		MinigunRevUpAnim
-- 		MinigunRevDownAnim
-- 		ChargingAnim
-- 		SwitchAnim
-- 		OverheatAnim
-- 		MeleeAttackAnim		
--		AltAnim
--		LaserBeamStartupAnim
--		LaserBeamLoopAnim
--		LaserBeamStopAnim	
	
--	====================
--	END OF SETTING
--	====================
}

return Module