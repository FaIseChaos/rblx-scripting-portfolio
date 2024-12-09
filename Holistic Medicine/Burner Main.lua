local TweenService = game:GetService("TweenService")
local plantRemoteEvent = game.ReplicatedStorage["Equipped Plant"]
local wkspTools = game.Workspace["Plant Tools"]
local burner = wkspTools.Burner
local spawnLoc = burner.Spawn
local button = burner.Button
local emitter = burner.Stem.ParticleEmitter
local bInputs = game.ServerStorage["Burner Inputs"]
local burnerInputs = bInputs:GetChildren()
local red = Color3.new(1,0,0)
local black = Color3.new(0,0,0)

local burnTable = {}

local enabled = false
local presented = "Empty"

local function melt(part,color,length)
	local tweenInfo = TweenInfo.new(length)
	local goal = {}
	goal.Color = color
	local meltTween = TweenService:Create(part,tweenInfo,goal)

	meltTween:Play()
end


for i,v in burnerInputs do
	local outcomeName = v.Name
	burnTable[#burnTable + 1] = outcomeName
end

plantRemoteEvent.OnServerEvent:Connect(function(player, toolEquipped, mouseTarget)
	if enabled then
		return
	elseif mouseTarget == button and emitter.Enabled == false and not toolEquipped then -- tunring on burner
		enabled = true
		emitter.Enabled = true
	elseif mouseTarget == button and emitter.Enabled == true and not toolEquipped then -- turning off burner
		enabled = true
		emitter.Enabled = false
	elseif mouseTarget == spawnLoc and emitter.Enabled == true and presented == "Empty" then -- placing something in
		enabled = true
		wait(.1)
		if table.find(burnTable,toolEquipped.Name) then
			local chem = toolEquipped:Clone()
			for i,v in chem:GetChildren() do
				if v:IsA("Script") then
					v:Destroy()
				else
					v.Position = spawnLoc.Position
					v.Anchored = true
					v.Parent = spawnLoc
					v.Name = chem.Name
				end
			end
			toolEquipped:Destroy()
			presented = toolEquipped.Name
		end
	elseif mouseTarget == spawnLoc and emitter.Enabled == false and presented ~= "Empty" then -- picking something up
		enabled = true
		wait(.1)
		local chem = bInputs:FindFirstChild(presented):Clone()
		spawnLoc:FindFirstChild(presented):Destroy()
		chem.Parent = player.Character
		presented = "Empty"
	end	
	enabled = false
end)

while true do
	wait(.01)
	if emitter.Enabled == true and presented ~= "Empty" then
		if presented == "Bismuth" then -- Molten Bismuth
			enabled = true
			wait(1)
			melt(spawnLoc:FindFirstChild("Bismuth"),red,10)
			wait(10)
			presented = "Molten Bismuth"
			spawnLoc:FindFirstChild("Bismuth").Name = "Molten Bismuth"	
			enabled = false			
		elseif presented == "Test Tube of Lavender and Hemlock" then -- Charred Lavender and Hemlock
			enabled = true
			wait(1)
			melt(spawnLoc["Test Tube of Lavender and Hemlock"].Union,black,3)
			wait(3)
			presented = "Charred Lavender and Hemlock"
			spawnLoc:FindFirstChild("Test Tube of Lavender and Hemlock").Name = "Charred Lavender and Hemlock"
			enabled = false
		end
	end
end
