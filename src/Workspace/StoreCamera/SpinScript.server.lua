local TweenService = game:GetService("TweenService")
local SpinInfo = TweenInfo.new(10, Enum.EasingStyle.Linear)

Spin1 = TweenService:Create(script.Parent, SpinInfo, {CFrame = script.Parent.CFrame * CFrame.Angles(0,math.rad(1),0)})
Spin2 = TweenService:Create(script.Parent, SpinInfo, {CFrame = script.Parent.CFrame * CFrame.Angles(0,math.rad(-1),0)})

Spin1:Play()
Spin1.Completed:Connect(function()Spin2:Play() end)
Spin2.Completed:Connect(function()Spin1:Play() end)