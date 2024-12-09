local area = script.Parent
local plantStorage = game.ServerStorage["Plant Storage"]
local plantType = area.Name

local number = {}

local max = 10

local function plantRaycast(spawnArea)
	local part = plantStorage:FindFirstChild(plantType):FindFirstChild(math.random(1,7)):Clone()
	part.Position = (spawnArea.CFrame * CFrame.new((math.random() - 0.5) * spawnArea.Size.X,0, (math.random() - 0.5) * spawnArea.Size.Z)).Position
	part.Position = part.Position + Vector3.new(0,15,0)
	part.Anchored = true
	part.Parent = area
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {spawnArea,area:GetChildren()} -- blacklisted parts/models
	rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = workspace:Raycast(part.Position,Vector3.new(0,-90,0),rayParams)
	
	local rayPos = raycastResult.Position
	part.Position = rayPos + Vector3.new(0,part.Size.Y/2,0)
end

wait(3)

while true do
	wait(2)
	table.clear(number)
	for i,v in script.Parent:GetChildren() do
		if v.ClassName == "MeshPart" then
			local part = v.Name
			number[#number + 1] = part
		end
	end
	if table.getn(number) < max then
		plantRaycast(area)
	end
end
