local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SurvivorTeam = game:GetService("Teams"):WaitForChild("Survivors")
local Track = Instance.new("Animation")
local Combo = 1
local Enabled = true
local Debounce = true
local Damage = 20

local function Attack(Player, Character, Humanoid)
	if Humanoid.Parent.Name ~= Character.Name then
		if game.Players:GetPlayerFromCharacter(Humanoid.Parent).Team == SurvivorTeam then
			if Humanoid.Health > 0 then
				Humanoid:TakeDamage(Damage)
				local S = Instance.new("Sound", Character.Torso)
				S.SoundId = "rbxassetid://4988621968"
				S.PlaybackSpeed = math.random(80,120)/100
				S:Play()
			end
		end
	end
end

script.Parent.OnServerEvent:connect(function(Player, Action)
	local Character = Player.Character
	local LeftArm = Character:WaitForChild("Left Arm")
	local RightArm = Character:WaitForChild("Right Arm")
	if Enabled == false then return end
	if Combo == 1 then
		Enabled = false
		Track.AnimationId = "rbxassetid://10580738470"
		local Anim = Character.Humanoid:LoadAnimation(Track)
		Anim:Play()
		Combo = 2
		RightArm.Touched:Connect(function(Object)
			if Debounce == true then
				Debounce = false
				Attack(Player, Character, Object.Parent:FindFirstChild("Humanoid"))
			end
		end)
		wait(1)
		Debounce = true
	elseif Combo == 2 then
		Enabled = false
		Track.AnimationId = "rbxassetid://10580738470"
		local Anim = Character.Humanoid:LoadAnimation(Track)
		Anim:Play()
		Combo = 1
		LeftArm.Touched:Connect(function(Object)
			if Debounce == true then
				Debounce = false
				Attack(Player, Character, Object.Parent:FindFirstChild("Humanoid"))
			end
		end)
		wait(1)
		Debounce = true
	end
	Enabled = true
end)