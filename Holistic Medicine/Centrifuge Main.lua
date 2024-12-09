local TweenService = game:GetService("TweenService")
local plantRemoteEvent = game.ReplicatedStorage["Equipped Plant"]
local wkspTools = game.Workspace["Plant Tools"]
local centrifuge = wkspTools.Centrifuge.Centrifuge
local lid = wkspTools.Centrifuge.CentrifugeLid
local button = wkspTools.Centrifuge.CentrifugeButton
local cSpawn = wkspTools.Centrifuge.CentrifugeSpawn
local cInputs = game.ServerStorage["Centrifuge Inputs"]
local centInputs = game.ServerStorage["Centrifuge Inputs"]:GetChildren()
local originalLid = lid.CFrame
local outputs = game.ServerStorage.Centrifuge

local centTable = {}

local enabled = false
local open = false
local spawned = "Empty"

for i,v in centInputs do
	local outcomeName = v.Name
	centTable[#centTable + 1] = outcomeName
end

local tweenInfo = TweenInfo.new(2)
local goal = {}
goal.Orientation = lid.Orientation + Vector3.new(90,0,0)
goal.Position = lid.Position + Vector3.new(0,.5,1.5)
local openTween = TweenService:Create(lid,tweenInfo,goal)

local closeGoal = {}
closeGoal.CFrame = originalLid
local closeTween = TweenService:Create(lid,tweenInfo,closeGoal)

plantRemoteEvent.OnServerEvent:Connect(function(player, toolEquipped, mouseTarget) 
	if enabled then
		return
	elseif mouseTarget == lid and open == false and not toolEquipped then --animation for opening the lid
		enabled = true
		openTween:Play()
		wait(1.9)
		open = true
		wait(.1)
	elseif mouseTarget == lid and open == true and not toolEquipped then  --animation for closing the lid
		enabled = true
		closeTween:Play()
		wait(1.9)
		open = false
		wait(.1)
	elseif mouseTarget == cSpawn and spawned == "Empty" then -- placing something in
		enabled = true
		wait(.1)
		if toolEquipped and table.find(centTable,toolEquipped.Name) then
			local chem = toolEquipped:Clone()
			for i,v in chem:GetChildren() do
				v.Position = cSpawn.Position
				v.Anchored = true
				v.Parent = centrifuge
				v.Name = chem.Name
			end
			toolEquipped:Destroy()
			spawned = toolEquipped.Name
		end
		
	elseif mouseTarget == cSpawn and spawned ~= "Empty" then -- picking something up
		enabled = true
		wait(.1)
		local chem = cInputs:FindFirstChild(spawned):Clone()
		for i,v in centrifuge:GetChildren() do
			if centrifuge:FindFirstChildWhichIsA("Part") or centrifuge:FindFirstChildWhichIsA("UnionOperation") or centrifuge:FindFirstChildWhichIsA("MeshPart") then
				v:Destroy()
			end
		end
		chem.Parent = player.Character
		spawned = "Empty"
	elseif mouseTarget == button and spawned ~= "Empty" then -- activating the spin cycle!
		enabled = true
		if spawned == "Cleaner" then -- Seperated Cleaner
			for i,v in centrifuge:GetChildren() do
				if centrifuge:FindFirstChildWhichIsA("Part") or centrifuge:FindFirstChildWhichIsA("UnionOperation") or centrifuge:FindFirstChildWhichIsA("MeshPart") then
					v:Destroy()
				end			
			end			
			wait(3)
			local seperatedCleaner = outputs["Seperated Cleaner"].Handle:Clone()
			seperatedCleaner.Position = cSpawn.Position
			seperatedCleaner.Anchored = true
			seperatedCleaner.Parent = centrifuge
			spawned = "Seperated Cleaner"
		elseif spawned == "Vial of Regeneration Elixir" then -- Purified Regeneration Elixir
			enabled = true
			for i,v in centrifuge:GetChildren() do
				if centrifuge:FindFirstChildWhichIsA("Part") or centrifuge:FindFirstChildWhichIsA("UnionOperation") or centrifuge:FindFirstChildWhichIsA("MeshPart") then
					v:Destroy()
				end			
			end	
			wait(3)
			local pureRegenElixir = outputs["Vial of Purified Regeneration Elixir"].Handle:Clone()
			pureRegenElixir.Position = cSpawn.Position
			pureRegenElixir.Anchored = true
			pureRegenElixir.Parent = centrifuge
			spawned = "Vial of Purified Regeneration Elixir"
		end
	end
	enabled = false
end)