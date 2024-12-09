local plantRemoteEvent = game.ReplicatedStorage["Equipped Plant"]
local wkspPlants = game.ServerStorage["Plants and Chems"]
local wkspTools = game.Workspace["Plant Tools"]
local ttHolder = wkspTools:FindFirstChild("Test Tube Holder")
local ssOutcomes = game.ServerStorage["MaP Outcomes"]
local ssCentrifuge = game.ServerStorage.Centrifuge

local LaV = ssOutcomes["Test Tube of Lavender and Valerian"]
local LaH = ssOutcomes["Test Tube of Lavender and Hemlock"]
local LaMP = ssOutcomes["Test Tube of Lavender and Mutated Plant"]
local Values = ttHolder:GetChildren()
local valueTable = {}

local ttPlants = ssOutcomes:GetChildren()
local ttPlantTable = {}
local inputs = {wkspPlants.Honey.Name, wkspPlants.Aloe.Name, wkspPlants.Stick.Name, ssCentrifuge["Seperated Cleaner"].Name, ssOutcomes["Molten Bismuth"].Name, ssOutcomes["Charred Lavender and Hemlock"].Name, wkspPlants.Bismuth}
local finalOutcomes = {ssOutcomes["Vial of Wound Cleaner"].Name,ssOutcomes["Vial of Helavian"].Name,ssOutcomes["Vial of Regeneration Elixir"].Name,ssOutcomes["Poison Darts"].Name, ssOutcomes["Tracking Device"].Name, ssOutcomes["Vial of Burn Treatment"],ssOutcomes.Bandage.Name}

local enabled = false

for i,v in ttPlants do
	local outcomeName = v.Name
	ttPlantTable[#ttPlantTable + 1] = outcomeName
end

for i,v in Values do
	if v.ClassName == "Part" then
		valueTable[#valueTable + 1] = v
	end
end

local function Reset(player, mouseTarget, name, color, combo)
	player.Character:FindFirstChildOfClass("Tool"):Destroy()
	mouseTarget.Handle.Union.Color = color
	mouseTarget.Value.Value = name	
	if combo == nil then return
	else
		mouseTarget.Combo.Value = combo
	end
end

plantRemoteEvent.OnServerEvent:Connect(function(player, toolEquipped, mouseTarget)
	if enabled then
		return		
	elseif table.find(Values,mouseTarget) then
		if not toolEquipped then -- picking something up
			local enabled = true
			local clonedTT = ssOutcomes:FindFirstChild(mouseTarget.Value.Value):Clone()
			clonedTT.Parent = player.Character
			mouseTarget:FindFirstChild("Handle"):Destroy()
			mouseTarget.Value.Value = "Empty"
			if mouseTarget.Combo.Value ~= "Empty" then
				local savedCombo = mouseTarget.Combo:Clone()
				savedCombo.Parent = toolEquipped.Handle
			end
			mouseTarget.Combo.Value = "Empty"
		elseif table.find(ttPlantTable,toolEquipped.Name) and mouseTarget.Value.Value == "Empty" and not table.find(finalOutcomes,toolEquipped.Name) then --inserting something new
			local enabled = true
			local testTube = toolEquipped:Clone()
			wait(.15)
			
			player.Character:FindFirstChildOfClass("Tool"):Destroy()
			for i,v in testTube:GetChildren() do
				if v:IsA("Script") then
					v:Destroy()
				else
					v.Position = ttHolder:FindFirstChild(mouseTarget.Name).Position
					v.Parent = ttHolder:FindFirstChild(mouseTarget.Name)
					v.Anchored = true
					testTube:Destroy()
				end
			end
			ttHolder:FindFirstChild(mouseTarget.Name).Value.Value = toolEquipped.Name
			--if toolEquipped.Handle:FindFirstChild("Combo") then
			--	local savedCombo = toolEquipped.Handle.Combo.Value
			--end
			if toolEquipped:FindFirstChild("Handle") and toolEquipped.Handle.Combo.Value ~= "Empty" then
				mouseTarget.Combo.Value = toolEquipped.Handle.Combo.Valuea
			end
		elseif table.find(inputs,toolEquipped.Name) then -- recipies
			local enabled = true
			if mouseTarget.Value.Value == "Empty" then
				return
			elseif mouseTarget.Value.Value == "Test Tube of Lavender and Valerian" and toolEquipped.Name == "Honey" then -- Helavian (sedation serum)
				player.Character:FindFirstChildOfClass("Tool"):Destroy()
				mouseTarget:FindFirstChild("Handle"):Destroy()
				mouseTarget.Value.Value = "Empty"
				local helavian = ssOutcomes["Vial of Helavian"]:Clone()
				helavian.Parent = player.Character
			elseif mouseTarget.Value.Value == "Test Tube of Mutated Plant" and toolEquipped.Name == "Honey" and mouseTarget.Combo.Value ~= "Test Tube of Mutated Plant + Molten Bismith" then -- Regeneration Elixir 
				player.Character:FindFirstChildOfClass("Tool"):Destroy()
				mouseTarget:FindFirstChild("Handle"):Destroy()
				mouseTarget.Value.Value = "Empty"
				local elixir = ssOutcomes["Vial of Regeneration Elixir"]
				elixir.Parent = player.Character
			elseif mouseTarget.Value.Value == "Test Tube of Mutated Plant" and toolEquipped.Name == "Molten Bismuth"  then -- Tracking Device Step 1
				Reset(player,mouseTarget,"Test Tube of Mutated Plant",Color3.new(0,.5,0),"Test Tube of Mutated Plant + Molten Bismith")
			elseif mouseTarget.Value.Value == "Test Tube of Lavender and Mutated Plant" and toolEquipped.Name == "Molten Bismuth" then -- SCP Infection Cure
				player.Character:FindFirstChildOfClass("Tool"):Destroy()
				mouseTarget:FindFirstChild("Handle"):Destroy()
				mouseTarget.Value.Value = "Empty"
				local cure = ssOutcomes["Vial of Infection Immunity"]
				cure.Parent = player.Character
			elseif mouseTarget.Value.Value == "Test Tube of Lavender" then -- Bandages
				if toolEquipped.Name == "Honey" or toolEquipped.Name == "Aloe" then 
					if toolEquipped.Name == "Honey" and mouseTarget.Combo.Value ~= "Honey" then 
						if mouseTarget.Combo.Value == "Aloe" then
							mouseTarget.Combo.Value = "Empty"
							mouseTarget.Value.Value = "Empty"
							player.Character:FindFirstChildOfClass("Tool"):Destroy()
							mouseTarget:FindFirstChild("Handle"):Destroy()
							local bandage = ssOutcomes.Bandage:Clone()
							wait(1)
							bandage.Parent = player.Character
						elseif mouseTarget.Combo.Value ~= "Aloe" then
							mouseTarget.Combo.Value = "Honey"
							player.Character:FindFirstChildOfClass("Tool"):Destroy()
							mouseTarget.Handle.Union.Color = Color3.new(0,.5,.5)
						end
					elseif toolEquipped.Name == "Aloe" and mouseTarget.Combo.Value ~= "Aloe" then
						if mouseTarget.Combo.Value == "Honey" then
							mouseTarget.Combo.Value = "Empty"
							mouseTarget.Value.Value = "Empty"
							player.Character:FindFirstChildOfClass("Tool"):Destroy()
							mouseTarget:FindFirstChild("Handle"):Destroy()
							local bandage = ssOutcomes.Bandage:Clone()
							wait(1)
							bandage.Parent = player.Character
						elseif mouseTarget.Combo.Value ~= "Honey" then
							mouseTarget.Combo.Value = "Aloe"
							player.Character:FindFirstChildOfClass("Tool"):Destroy()
							mouseTarget.Handle.Union.Color = Color3.new(0,.5,.3)
						end
					end
				end
			elseif mouseTarget.Value.Value == "Test Tube of Hemlock" and toolEquipped.Name == "Stick" then -- Poison Darts
				player.Character:FindFirstChildOfClass("Tool"):Destroy()
				mouseTarget:FindFirstChild("Handle"):Destroy()
				mouseTarget.Value.Value = "Empty"
				local darts = ssOutcomes["Poison Darts"]:Clone()
				darts.Parent = player.Character
			elseif mouseTarget.Value.Value == "Charred Lavender and Hemlock" then -- Burn Treatment
				if toolEquipped.Name == "Honey" and mouseTarget.Combo.Value ~= "Honey" then 
					if mouseTarget.Combo.Value == "Aloe" then
						player.Character:FindFirstChildOfClass("Tool"):Destroy()
						mouseTarget:FindFirstChild("Handle"):Destroy()
						mouseTarget.Value.Value = "Empty"
						local burn = ssOutcomes["Vial of Burn Treatment"]
						burn.Parent = player.Character
					elseif mouseTarget.Combo.Value ~= "Aloe" then
						Reset(player, mouseTarget, "Charred Lavender and Hemlock", Color3.new(1,.5,0), "Honey")
					end
				elseif toolEquipped.Name == "Aloe" and mouseTarget.Combo.Value ~= "Aloe" then
					if mouseTarget.Combo.Value == "Honey" then
						player.Character:FindFirstChildOfClass("Tool"):Destroy()
						mouseTarget:FindFirstChild("Handle"):Destroy()
						mouseTarget.Value.Value = "Empty"
						local burn = ssOutcomes["Vial of Burn Treatment"]
						burn.Parent = player.Character
					elseif mouseTarget.Combo.Value ~= "Honey" then
						Reset(player,mouseTarget, "Charred Lavender and Hemlock", Color3.new(0,.2,0), "Aloe")
					end
				end
			elseif 	mouseTarget.Value.Value == "Test Tube" and toolEquipped.Name == "Seperated Cleaner" then -- Wound Cleaner
				player.Character:FindFirstChildOfClass("Tool"):Destroy()
				mouseTarget:FindFirstChild("Handle"):Destroy()
				mouseTarget.Value.Value = "Empty"
				local woundCleaner = ssOutcomes["Vial of Wound Cleaner"]
				woundCleaner.Parent = player.Character
			elseif toolEquipped.Name == "Bismuth" and mouseTarget.Value.Value == "Test Tube" then
				print("bismuth")
				player.Character:FindFirstChildOfClass("Tool"):Destroy()
				mouseTarget:FindFirstChild("Handle"):Destroy()
				mouseTarget.Value.Value = "Empty"
				local bismuth = ssOutcomes["Test Tube of Bismuth"]:Clone()
				bismuth.Parent = player.Character
			elseif mouseTarget.Combo.Value == "Test Tube of Mutated Plant + Molten Bismith" and toolEquipped.Name == "Honey" then -- Tracking Device Step 2
				player.Character:FindFirstChildOfClass("Tool"):Destroy()
				mouseTarget:FindFirstChild("Handle"):Destroy()
				mouseTarget.Value.Value = "Empty"
				mouseTarget.Combo.Value = "Empty" 
				wait(.1)
				local tracker = ssOutcomes["Tracking Device"]:Clone()
				tracker.Parent = player.Character
			end
			
		end
	end
	local enabled = false
end)
