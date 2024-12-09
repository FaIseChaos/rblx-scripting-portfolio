local DataStoreService = game:GetService("DataStoreService")

local SSplants = game.ServerStorage["Plants and Chems"]
local PlantDataStore = DataStoreService:GetDataStore("PlantDataStore")
local plantRemoteEvent = game.ReplicatedStorage["Equipped Plant"]
local Boxes = workspace["Holistic Storage Boxes"]:GetChildren()
local infinate = {SSplants.Stick.Name,SSplants["Test Tube"].Name,SSplants.Cleaner,SSplants.Water}
local plantStorage = game.ServerStorage["Plant Storage Tools"].Tools

local exclude = {"Cabinets","Cleaner","Stick","Test Tube","Water"}

local lavender 
local hemlock 
local valerian 
local honey 
local aloe 
local bismuth 
local iodine 
local mutplant

local function PlacePlants(v,plantNumber,plantName)
	print(v)
	print(plantNumber)
	print(plantName)
	if v.Name == plantName then
		local part = SSplants:FindFirstChild(plantName):Clone()
		local handle = part:FindFirstChild("Handle")
		handle.Position = (v.CFrame * CFrame.new((math.random() - 0.5) * v.Size.X,0, (math.random() - 0.5) * v.Size.Z)).Position
		handle.Position = handle.Position + Vector3.new(0,1,0)
		handle.Anchored = true
		handle.Name = part.Name
		handle.Parent = v
		part:Destroy()
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {v:GetChildren()} -- blacklisted parts/models
		rayParams.FilterType = Enum.RaycastFilterType.Blacklist
		local raycastResult = workspace:Raycast(handle.Position,Vector3.new(0,-90,0),rayParams)

		local rayPos = raycastResult.Position
		if plantName ~= "Hemlock" then
			handle.Position = rayPos + Vector3.new(0,handle.Size.Z/2,0)
			handle.Orientation = Vector3.new(math.random(-180,180),math.random(-180,180),90)
		else
			handle.Position = rayPos + Vector3.new(0,handle.Size.Y/2,0)
		end
	end
end

local function GetData() -- getting data
	local lavdata
	local hemdata
	local valdata
	local honeydata
	local aloedata
	local bisdata
	local iodinedata
	local mpdata
	
	local success, errormessage = pcall(function()
		lavdata = PlantDataStore:GetAsync("lavender")
		hemdata = PlantDataStore:GetAsync("hemlock")
		valdata = PlantDataStore:GetAsync("valerian")
		honeydata = PlantDataStore:GetAsync("honey")
		aloedata = PlantDataStore:GetAsync("aloe")
		bisdata = PlantDataStore:GetAsync("bismuth")
		iodinedata = PlantDataStore:GetAsync("iodine")
		mpdata = PlantDataStore:GetAsync("mutplant")
	end)
	
	if success then --if you want to modify the amount in storage, change the "data" value (the one on the right side of equals) then run the game. After that, return it to what was set to before to prevent the number from setting to that every time the server restarts
		lavender = lavdata
		hemlock = hemdata
		valerian = valdata
		honey = honeydata
		aloe = aloedata
		bismuth = bisdata
		iodine = iodinedata
		mutplant = mpdata
		print("Data Stored!")
		print("Lavender Stored: ",lavender)
		print("Hemlock Stored: ",hemlock)
		print("Valerian Stored: ",valerian)
		print("Honey Stored: ",honey)
		print("Aloe Stored: ",aloe)
		print("Bismuth Stored: ",bismuth)
		print("Iodine Stored: ",iodine)
		print("Mutated Plant Stored: ", mutplant)
	else
		print("error getting data")
		warn(errormessage)
	end
end

local function SaveData() -- saving data
	local success, errormessage = pcall(function()
		PlantDataStore:SetAsync("lavender",lavender)
		PlantDataStore:SetAsync("hemlock",hemlock)
		PlantDataStore:SetAsync("valerian",valerian)
		PlantDataStore:SetAsync("honey",honey)
		PlantDataStore:SetAsync("aloe",aloe)
		PlantDataStore:SetAsync("bismuth",bismuth)
		PlantDataStore:SetAsync("iodine",iodine)
		PlantDataStore:SetAsync("mutplant",mutplant)
	end)
	
	if success then
		print("Data saved!")
		print("Lavender Stored: ",lavender)
		print("Hemlock Stored: ",hemlock)
		print("Valerian Stored: ",valerian)
		print("Honey Stored: ",honey)
		print("Aloe Stored: ",aloe)
		print("Bismuth Stored: ",bismuth)
		print("Iodine Stored: ",iodine)
		print("Mutated Plant Stored: ", mutplant)
	else
		print("error saving data")
		warn(errormessage)
	end
end

local function Insert(plant)
	if plant == "Lavender" then
		lavender = lavender + 1
		print(lavender)
	elseif plant == "Hemlock" then
		hemlock = hemlock + 1
		print(hemlock)
	elseif plant == "Valerian" then
		valerian = valerian + 1
		print(valerian)
	elseif plant == "Honey" then
		honey = honey + 1
		print(honey)
	elseif plant == "Aloe" then	
		aloe = aloe + 1
		print(aloe)
	elseif plant == "Bismuth" then
		bismuth = bismuth + 1
	elseif plant == "Iodine" then
		iodine = iodine + 1
	elseif plant == "Mutated Plant" then
		mutplant = mutplant + 1
	end
end

local function Remove(plant)
	if plant == "Lavender" then
		lavender = lavender - 1
		print(lavender)
	elseif plant == "Hemlock" then
		hemlock = hemlock - 1
		print(hemlock)
	elseif plant == "Valerian" then
		valerian = valerian - 1
		print(valerian)
	elseif plant == "Honey" then
		honey = honey - 1
		print(honey)
	elseif plant == "Aloe" then	
		aloe = aloe - 1
		print(aloe)
	elseif plant == "Bismuth" then
		bismuth = bismuth - 1
	elseif plant == "Iodine" then
		iodine = iodine - 1
	elseif plant == "Mutated Plant" then
		mutplant = mutplant - 1
	end
end

local function PlantCheck(plant)
	if plant == "Lavender" and lavender > 0 then return true
	elseif plant == "Hemlock" and hemlock > 0 then return true
	elseif plant == "Valerian" and valerian > 0 then return true
	elseif plant == "Honey" and honey > 0 then return true
	elseif plant == "Aloe" and aloe > 0 then return true
	elseif plant == "Bismuth" and bismuth > 0 then return true
	elseif plant == "Iodine" and iodine > 0 then return true	
	elseif plant == "Mutated Plant" and mutplant > 0 then return true
	else return false
	end
end


GetData()
local plantCount = {
	Lavender = lavender,
	Hemlock = hemlock,
	Valerian = valerian,
	Honey = honey,
	Aloe = aloe,
	Bismuth = bismuth,
	Iodine = iodine,
	MP = mutplant
}
	
print(plantCount)

for i,v in pairs(Boxes) do
	if v.Name == "Mutated Plant" then -- you can't have spaces in dictionary and the key is connected to the part name
		for c = plantCount["MP"],1,-1 do
			PlacePlants(v,plantCount["MP"],v.Name)
		end
	elseif not table.find(exclude,v.Name) then
		for c = plantCount[v.Name],1,-1 do
			PlacePlants(v,plantCount[v.Name],v.Name)
		end
	end
end

plantRemoteEvent.OnServerEvent:Connect(function(player, toolEquipped, mouseTarget) 
	if table.find(Boxes,mouseTarget) then 
		if toolEquipped and toolEquipped.Name == mouseTarget.Name then --inserting
			print("destry")
			toolEquipped:Destroy()
			Insert(mouseTarget.Name)
			if mouseTarget.Name == "Mutated Plant" then
				PlacePlants(mouseTarget,plantCount["MP"],mouseTarget.Name)
			elseif not table.find(exclude,mouseTarget.Name) then
				PlacePlants(mouseTarget,plantCount[mouseTarget.Name],mouseTarget.Name)
			end
		elseif not toolEquipped then --picking up
			print("picking up")
			if PlantCheck(mouseTarget.Name) then
				local plant = SSplants:FindFirstChild(mouseTarget.Name):Clone()
				plant.Parent = player.Character
				Remove(mouseTarget.Name)
				mouseTarget:FindFirstChild(mouseTarget.Name):Destroy()
			elseif table.find(infinate,mouseTarget.Name)then
				local plant = SSplants:FindFirstChild(mouseTarget.Name):Clone()
				plant.Parent = player.Character
			end

		end
	end
end)

while true do
	SaveData()
	wait(30)
end