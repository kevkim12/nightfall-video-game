local Light1 = script.Parent.Light1
local Light2 = script.Parent.Light2
local ParticleEmitter = script.Parent.Specks.ParticleEmitter

local DustOn = {
	NumberSequenceKeypoint.new( 0, 1);
	NumberSequenceKeypoint.new(.0515, 0);
	NumberSequenceKeypoint.new(.928, 0);
	NumberSequenceKeypoint.new( 1, 1);
}

local DustOff = {
	NumberSequenceKeypoint.new( 0, 1);
	NumberSequenceKeypoint.new(.0515, 1);
	NumberSequenceKeypoint.new(.928, 1);
	NumberSequenceKeypoint.new( 1, 1);
}

local function TurnOn()
	Light1.Material = Enum.Material.Neon
	Light2.Material = Enum.Material.Neon
	Light1.Color = Color3.fromRGB(163, 162, 165)
	Light2.Color = Color3.fromRGB(163, 162, 165)
	Light1.PointLight.Enabled = true
	Light2.PointLight.Enabled = true
	ParticleEmitter.Transparency = NumberSequence.new(DustOn)
end

local function TurnOff()
	Light1.Material = Enum.Material.Metal
	Light2.Material = Enum.Material.Metal
	Light1.Color = Color3.fromRGB(0, 0, 0)
	Light2.Color = Color3.fromRGB(0, 0, 0)
	Light1.PointLight.Enabled = false
	Light2.PointLight.Enabled = false
	ParticleEmitter.Transparency = NumberSequence.new(DustOff)
end

while true do
	local Chance = math.random(10,40)
	local Repeat = math.random(1, 2)
	wait(Chance)
	TurnOff()
	wait(.1)
	TurnOn()
	if Repeat == 1 then
		TurnOff()
		wait(.1)
		TurnOn()
	end
	Chance = math.random(20,40)
	wait(Chance)
end