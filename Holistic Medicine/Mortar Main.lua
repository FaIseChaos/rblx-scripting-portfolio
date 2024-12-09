local plantRemoteEvent = game.ReplicatedStorage["Equipped Plant"]
local plants = workspace["Plants and Chems"]:GetChildren()
local tools = workspace["Plant Tools"]:GetChildren()
local gPlants = game.ServerStorage["Grindable Plants"]:GetChildren()

local wkspPlants = game.ServerStorage["Plants and Chems"]
local wkspTools = game.Workspace["Plant Tools"]
local Mortar = wkspTools.Mortar
local Rag = wkspTools.Rag
local Pestle = wkspTools.Pestle
local ssTools = game.ServerStorage["Plants and Chems"]
local ssOutcomes = game.ServerStorage["MaP Outcomes"]

local plantTable = {}
local toolTable = {}
local gPlantTable = {}
local prepared = {}
local grind = {}

local enabled = false
local loop = true

local LaV = {wkspPlants.Lavender, wkspPlants.Valerian}
local LaH = {wkspPlants.Hemlock, wkspPlants.Lavender}
local LaMP = {wkspPlants.Lavender, wkspPlants["Mutated Plant"]}

local grindPlants = {wkspPlants.Lavender, wkspPlants.Valerian, wkspPlants.Hemlock, wkspPlants["Mutated Plant"]}

for i,v in plants do
	local plantName = v.Name
	plantTable[#plantTable + 1] = plantName
end

for i,v in tools do
	local toolName = v.Name
	toolTable[#toolTable + 1] = toolName
end

for i,v in gPlants do
	local gPlantName = v.Name
	gPlantTable[#gPlantTable + 1 ] = gPlantName
end

local function CheckArrayEquality(t1,t2) -- checks if t1 and t2 are the same; order does not matter
	if table.getn(t1) == table.getn(t2) then
		for i,v in pairs(t1) do
			print(table.find(t2, v))
			if (table.find(t2, v)) == nil then
				return false
			end
		end
		return true
	end
	return false
end

local function CheckArrayContent(t1,t2) -- checks if t1 has exactly one similarity with t2 NOTE: t1<t2
	local p = 0
	for i,v in pairs(t1) do
		
		if table.find(t2, v)~= nil then
			p = p + 1
			if p > 1 then
				return false
			end
		end
	end

	if p == 1 then
		return true
	end
end

local function CheckGrind()
	for i,v in grindPlants do
		if table.find(grind,v) then
			if v.Name == "Valerian" then
				return "Test Tube of Valerian"
			elseif v.Name == "Hemlock" then
				return "Test Tube of Hemlock"
			elseif v.Name == "Lavender" then
				return "Test Tube of Lavender"
			elseif v.Name == "Mutated Plant" then
				return "Test Tube of Mutated Plant"
			end
		end
	end
end


--print(plantTable)
--print(toolTable)
--print(gPlantTable)


plantRemoteEvent.OnServerEvent:Connect(function(player, toolEquipped, mouseTarget)
	if enabled then
		return
	elseif not toolEquipped then
		return
	elseif mouseTarget == Mortar and table.find(gPlantTable, toolEquipped.Name) then
		if #prepared > 1 then
			return
		end
		local enabled = true
		table.insert(prepared, toolEquipped)
		print("prepared: ",prepared)
		toolEquipped = nil
		if player.Character:FindFirstChildOfClass("Tool") then
			player.Character:FindFirstChildOfClass("Tool"):Destroy()
		end	

	elseif mouseTarget == Rag and toolEquipped.Name == ssTools.Water.Name then
		local enabled = true
		print(table.find(plantTable, ssTools.Water))
		table.clear(prepared)
		table.clear(grind)
		print("prepared: ", prepared)
		print("grind:", grind)

	elseif  mouseTarget == Mortar and toolEquipped.Name == ssTools.Pestle.Name then
		local enabled = true
		for i,v in grindPlants do
			if loop == true then
				if grindPlants[i].Name == prepared[1].Name then
					--print(grindPlants[i], " found in Mortar")
					table.insert(grind, grindPlants[i])
					table.remove(prepared, 1)
					loop = false
				else 
					--print(grindPlants[i].Name, "is not in Mortar")
				end		
			end
		end
		loop = true
		print("grind: ",grind)
		print("prepared: ", prepared)
	elseif mouseTarget == Mortar and toolEquipped.Name == ssTools["Test Tube"].Name then
		local enabled = true
		if grind[1] == grind[2] and grind[1] ~= nil then
			player.Character:FindFirstChildOfClass("Tool"):Destroy()
			local outcome = ssOutcomes:FindFirstChild(CheckGrind()):Clone()
			outcome.Parent = player.Character
			table.remove(grind,1)
			print(grind)
		elseif CheckArrayEquality(grind,LaV) then
			table.clear(grind)
			player.Character:FindFirstChildOfClass("Tool"):Destroy()
			local gLaV = ssOutcomes:FindFirstChild("Test Tube of Lavender and Valerian"):Clone()
			gLaV.Parent = player.Character
			print("Ground-up Lavender and Valerian")
		elseif CheckArrayEquality(grind,LaH) then
			table.clear(grind)
			player.Character:FindFirstChildOfClass("Tool"):Destroy()
			local gHaL = ssOutcomes:FindFirstChild("Test Tube of Lavender and Hemlock"):Clone()
			gHaL.Parent = player.Character			
			print("Ground-up Lavender and Hemlock")
		elseif CheckArrayEquality(grind,LaMP) then
			table.clear(grind)
			player.Character:FindFirstChildOfClass("Tool"):Destroy()
			local LaMP = ssOutcomes:FindFirstChild("Test Tube of Lavender and Mutated Plant"):Clone()
			LaMP.Parent = player.Character				
			print("Ground-up Lavender and Mutated Plant")
		elseif CheckArrayContent(grind,grindPlants) then
			player.Character:FindFirstChildOfClass("Tool"):Destroy()
			local outcome = ssOutcomes:FindFirstChild(CheckGrind()):Clone()
			outcome.Parent = player.Character
			print(outcome.Name)
			table.clear(grind)
			print(grind)
		else
			print("not a combination!")
		end
	end
	local enabled = false
end)