local char = script.Parent
local FaceId = {6797513476, 6797513733, 6797514370, 6797514159}
local Selection = FaceId[math.random(#FaceId)]

char:WaitForChild("Humanoid").Died:wait()

char.Head.face.Texture = "rbxassetid://" .. Selection
script:Destroy()
