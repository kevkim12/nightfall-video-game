local Teams = game:GetService("Teams")
local Infected = Teams:WaitForChild("Infected")
local Attack = script.Attack
local PlayerHumanoid = script.Parent.Parent:WaitForChild("Humanoid")
local AnimationTrack = 0
local Debounce = true
local AttackAnimation1 = "rbxassetid://6929703177"
local AttackAnimation2 = "rbxassetid://6929705910"
local AttackSound = script.AttackSound

function onTouched(part)
	local Humanoid = part.Parent:findFirstChild("Humanoid")
	if Humanoid ~= nil and part.Parent.Name ~= "Infected_AI" then
		if game.Players:GetPlayerFromCharacter(part.Parent).Team ~= Infected and Debounce == true then
			Debounce = false
			Humanoid.Health = Humanoid.Health - 20
			if AnimationTrack == 0 then
				Attack.AnimationId = AttackAnimation1
				AnimationTrack = 1
			else
				Attack.AnimationId = AttackAnimation2
				AnimationTrack = 0
			end
			AttackSound.PlaybackSpeed = math.random(80,120)/100
			local animationTrack = PlayerHumanoid:LoadAnimation(Attack)
			animationTrack:Play()
			AttackSound:Play()
			wait(2)
			Debounce = true
		end
	end
end



script.Parent.Touched:connect(onTouched)