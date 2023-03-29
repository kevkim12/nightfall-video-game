local BrickTable = {}

function RecursiveGeneric(Parent, Func, ClassLimit)
 for _, Child in pairs(Parent:GetChildren()) do
  if not ClassLimit or Child:IsA(ClassLimit) then
   Func(Child)
  end
  RecursiveGeneric(Child, Func, ClassLimit)
 end
end

RecursiveGeneric(
 script.Parent,
 function(Brick) table.insert(BrickTable, Brick) end,
 "BasePart"
)

local Base = BrickTable[1]
table.remove(BrickTable, 1)

for _, Part in pairs(BrickTable) do
 local Weld = Instance.new("Weld")
 Weld.Part0 = Base
 Weld.Part1 = Part
 Weld.C1 = Part.CFrame:inverse() * Base.CFrame
 Weld.Parent = Base
 Part.Anchored = false
end

Base.Anchored = false