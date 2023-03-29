local AFM = {}

function AFM:PlayAnimation(Player, ID)
	if Player and ID then
		local PlayerCharacter = Player.Character
		if PlayerCharacter ~= nil then
			local PlayerHum = PlayerCharacter:FindFirstChild("Humanoid")
			if PlayerHum ~= nil then
				local AnimationC = Instance.new("Animation", PlayerCharacter)
				AnimationC.AnimationId = "rbxassetid://"..ID
				PlayerHum:LoadAnimation(AnimationC):Play()
			end
		end
	else
		warn("Arguments needed for PlayAnimation function!")
	end
end
AFM.PlayAnimationARG = "AFM:PlayAnimation(Player, ID)"

function AFM:PlayAttackFrame(Player, Tool, AttackFrame, MouseHit)
	if Player and Tool and AttackFrame then
		local ISBE = Tool.FEMeleeKitEvents.Attack.Initiate_Server.Initiate_ServerBE
		if ISBE ~= nil then
			ISBE:Fire(nil, MouseHit ~= nil and MouseHit or nil, tostring(AttackFrame), Player)
		end
	else
		warn("Arguments needed for PlayAttackFrame function!")
	end
end
AFM.PlayAttackFrameARG = "AFM:PlayAttackFrame(Player, Tool, AttackFrame, MouseHit)"

function AFM:RepairWeapon(Tool, Amount)
	if Tool and Amount then
		local RW = Tool.FEMeleeKitEvents.Misc.RepairWeapon
		if RW ~= nil then
			RW:Fire(Amount)
		end
	else
		warn("Arguments needed for RepairWeapon function!")
	end
end
AFM.RepairWeaponARG = "AFM:RepairWeapon(Tool, Amount)"
	
function AFM:AbilityFunctions()
	print("[ABILITY FUNCTIONS] Available functions")
	for i, v in pairs(AFM) do
		if string.find(i, "ARG") ~= nil then
			print(v)
		end
	end
end

return AFM