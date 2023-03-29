local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tool = script.Parent
local InUse = false
local Player = script:FindFirstAncestorWhichIsA("Player") or game.Players:GetPlayerFromCharacter(script.Parent.Parent)
local Modules = ReplicatedStorage:WaitForChild("Modules")

local WeaponSettings = Modules.WeaponSettings
local Gun = WeaponSettings.Gun

local AmmoBox = script.Parent
local Enabled = true

local Ammo = math.huge
local GunToRefillAmmo = {
	"JRC 9MM",
	"M4A1",
	"P226",
	"SCAR-L",
}
local function onActivate()
	if InUse == false then
		InUse = true
		if Enabled and Player then
			local AmmoRefilled = false
			for _, GunName in pairs(GunToRefillAmmo) do
				local Tool = Player.Backpack:FindFirstChild(GunName) or Player.Character:FindFirstChild(GunName)
				if Tool then
					local GunScript = Tool:FindFirstChild("GunServer")
					local ValueFolder = Tool:FindFirstChild("ValueFolder")
					local Module = Gun:FindFirstChild(Tool.Name).Setting
					if GunScript and ValueFolder and Module then
						local CanBeRefilled = false
						local Values = {}
						for i, v in ipairs(Module:GetChildren()) do
							if v then
								local vv = require(v)
								if ValueFolder[i].Ammo.Value < vv.MaxAmmo and vv.LimitedAmmoEnabled then
									AmmoRefilled = true
									CanBeRefilled = true
									local ChangedAmmo = (Ammo == math.huge or ValueFolder[i].Ammo.Value + Ammo >= vv.Ammo) and vv.MaxAmmo or (ValueFolder[i].Ammo.Value + Ammo)
									ValueFolder[i].Ammo.Value = ChangedAmmo
									table.insert(Values, {
										Id = i;
										Mag = vv.AmmoPerMag,
										Ammo = ChangedAmmo,
										Heat = 0,
									})
								end
							end
						end
						if CanBeRefilled then
							GunScript.ChangeMagAndAmmo:FireClient(Player, Values)
						end
					end
				end
			end
			if AmmoRefilled then
				AmmoBox:Destroy()
			end
		end
	end
end


Tool.Activated:Connect(onActivate)



---