wait(math.random(.5,1))
while true do
	script.Parent.light_red.PointLight.Enabled = true
	script.Parent.light_rack_red.PointLight.Enabled = true
	script.Parent.light_rack_red_front.PointLight.Enabled = true
	script.Parent.light_red.Material = Enum.Material.Neon
	script.Parent.light_rack_red.Material = Enum.Material.Neon
	script.Parent.light_rack_red_front.Material = Enum.Material.Neon
	script.Parent.light_blue1.PointLight.Enabled = false
	script.Parent.light_rack_blue.PointLight.Enabled = false
	script.Parent.light_rack_blue_front.PointLight.Enabled = false
	script.Parent.light_blue1.Material = Enum.Material.SmoothPlastic
	script.Parent.light_rack_blue.Material = Enum.Material.SmoothPlastic
	script.Parent.light_rack_blue_front.Material = Enum.Material.SmoothPlastic
	wait(.1)
	script.Parent.light_blue1.PointLight.Enabled = true
	script.Parent.light_rack_blue.PointLight.Enabled = true
	script.Parent.light_rack_blue_front.PointLight.Enabled = true
	script.Parent.light_blue1.Material = Enum.Material.Neon
	script.Parent.light_rack_blue.Material = Enum.Material.Neon
	script.Parent.light_rack_blue_front.Material = Enum.Material.Neon
	script.Parent.light_red.PointLight.Enabled = false
	script.Parent.light_rack_red.PointLight.Enabled = false
	script.Parent.light_rack_red_front.PointLight.Enabled = false
	script.Parent.light_red.Material = Enum.Material.SmoothPlastic
	script.Parent.light_rack_red.Material = Enum.Material.SmoothPlastic
	script.Parent.light_rack_red_front.Material = Enum.Material.SmoothPlastic
	wait(.1)
end