local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Camera = Workspace.CurrentCamera

local CamCF, PortSize, H, PX, PY, SX, SY, RScaleX, RScaleY

local function UpdateScreenCulling(NewCamCF, NewPortSize, NewFOV)
    CamCF = NewCamCF
    PortSize = NewPortSize
    H = NewFOV * math.pi / 180 / 2
    PY = PortSize.Y
    PX = PortSize.X
    SY = math.tan(H)
    SX = PX / PY * SY
    RScaleY = (1 + SY * SY) ^ 0.5
    RScaleX = (1 + SX * SX) ^ 0.5
end

UpdateScreenCulling(Camera.CFrame, Camera.ViewportSize, Camera.FieldOfView)

RunService.RenderStepped:Connect(function(dt)
	UpdateScreenCulling(Camera.CFrame, Camera.ViewportSize, Camera.FieldOfView)
end)

return function(Position, Radius)
    local R = CFrame.new().pointToObjectSpace(CamCF, Position)
    local RZ = -R.Z
    local RX = R.X
    local RY = R.Y
    return -RZ * SX < RX + RScaleX * Radius and RX - RScaleX * Radius < RZ * SX and -RZ * SY < RY + RScaleY * Radius and RY - RScaleY * Radius < RZ * SY and RZ > -Radius
end