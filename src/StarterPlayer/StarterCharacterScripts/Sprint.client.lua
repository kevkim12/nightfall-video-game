local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Player = game.Players.LocalPlayer
	local Character = workspace:WaitForChild(Player.Name)
		local Humanoid = Character:WaitForChild('Humanoid')
		
local RunAnimation = Instance.new('Animation')
RunAnimation.AnimationId = 'rbxassetid://10960457778'
RAnimation = Humanoid:LoadAnimation(RunAnimation)

Running = false
local NoStamina = false

local Teams = game:GetService("Teams")
local InfectedTeam = Teams:WaitForChild("Infected")
local SurvivorTeam = Teams:WaitForChild("Survivors")

function Handler(BindName, InputState)
	if InputState == Enum.UserInputState.Begin and BindName == 'RunBind' and Player.Team == SurvivorTeam then
		ReplicatedStorage.Events.Sprint:FireServer("Began")
		Running = true
	elseif InputState == Enum.UserInputState.End and BindName == 'RunBind' then
		ReplicatedStorage.Events.Sprint:FireServer("Ended")
		Running = false
		if RAnimation.IsPlaying then
			RAnimation:Stop()
		end
	end
end

Humanoid.Running:connect(function(Speed)
	if Player.Team == SurvivorTeam then
		if Speed >= 16 and Running and not RAnimation.IsPlaying then
			RAnimation:Play()
		elseif Speed >= 16 and not Running and RAnimation.IsPlaying then
			RAnimation:Stop()
		elseif Speed == 16 and RAnimation.IsPlaying then
			RAnimation:Stop()
		end
	end
end)

Humanoid.Changed:connect(function()
	if Humanoid.Jump and RAnimation.IsPlaying and Player.Team == SurvivorTeam then
		RAnimation:Stop()
	end
end)

ReplicatedStorage.Events.StaminaUpdate.OnClientEvent:Connect(function(stamina, maxStamina)
	Player.PlayerGui.MainGui.PlayerBars.StaminaBar.Bar.Size = UDim2.new((stamina / maxStamina) * 1, 0, .929, 0)
end)

game:GetService('ContextActionService'):BindAction('RunBind', Handler, true, Enum.KeyCode.LeftShift)

RunService.RenderStepped:Connect(function(step)
	if Humanoid.WalkSpeed == 16 and Player.Team == SurvivorTeam then
		RAnimation:Stop()
	end
end)