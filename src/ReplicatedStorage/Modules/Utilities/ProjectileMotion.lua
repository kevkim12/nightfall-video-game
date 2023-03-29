local module = {}

function module.CalculateBeamProjectile(x0, v0, t1, gravity)
	gravity = gravity or Vector3.new(0, 0, 0)

	--Calculate the bezier points.
	local c = 0.5 * 0.5 * 0.5
	local p3 = 0.5 * gravity * t1 * t1 + v0 * t1 + x0
	local p2 = p3 - (gravity * t1 * t1 + v0 * t1) / 3
	local p1 = (c * gravity * t1 * t1 + 0.5 * v0 * t1 + x0 - c * (x0 + p3)) / (3 * c) - p2

	--The curve sizes.
	local curve0 = (p1 - x0).Magnitude
	local curve1 = (p2 - p3).Magnitude

	--Build the world CFrames for the attachments.
	local b = (x0 - p3).Unit
	local r1 = (p1 - x0).Unit
	local u1 = r1:Cross(b).Unit
	local r2 = (p2 - p3).Unit
	local u2 = r2:Cross(b).Unit
	b = u1:Cross(r1).Unit

	local cf1 = CFrame.new(
		x0.x, x0.y, x0.z,
		r1.x, u1.x, b.x,
		r1.y, u1.y, b.y,
		r1.z, u1.z, b.z
	)

	local cf2 = CFrame.new(
		p3.x, p3.y, p3.z,
		r2.x, u2.x, b.x,
		r2.y, u2.y, b.y,
		r2.z, u2.z, b.z
	)

	return curve0, -curve1, cf1, cf2
end

function module.ShowProjectilePath(beamClone, x0, v0, t, gravity)
	gravity = gravity or Vector3.new(0, 0, 0)

	local attach0 = Instance.new("Attachment", workspace.Terrain)
	local attach1 = Instance.new("Attachment", workspace.Terrain)

	local beam = beamClone:Clone()
	beam.Attachment0 = attach0
	beam.Attachment1 = attach1
	beam.Parent = workspace.Terrain

	local curve0, curve1, cf1, cf2 = module.CalculateBeamProjectile(x0, v0, t, gravity)

	beam.CurveSize0 = curve0
	beam.CurveSize1 = curve1

	--Convert world space CFrames to be relative to the attachment parent.
	attach0.CFrame = attach0.Parent.CFrame:Inverse() * cf1
	attach1.CFrame = attach1.Parent.CFrame:Inverse() * cf2

	return beam, attach0, attach1
end

function module.UpdateProjectilePath(beam, attach0, attach1, x0, v0, t, gravity)
	gravity = gravity or Vector3.new(0, 0, 0)

	local curve0, curve1, cf1, cf2 = module.CalculateBeamProjectile(x0, v0, t, gravity)

	beam.CurveSize0 = curve0
	beam.CurveSize1 = curve1

	--Convert world space CFrames to be relative to the attachment parent.
	attach0.CFrame = attach0.Parent.CFrame:Inverse() * cf1
	attach1.CFrame = attach1.Parent.CFrame:Inverse() * cf2
end

return module