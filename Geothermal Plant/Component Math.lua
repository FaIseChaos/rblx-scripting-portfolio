local RE = game.ReplicatedStorage["Equipped Plant"]
local energyData = workspace.EnergyData
local velocityScreens = {energyData["Geothermal Velocity"],energyData["Isobutane Velocity"],energyData["Water Velocity"]}
local buttons = {}

local enabled = false

for i,v in velocityScreens do
	buttons[#buttons + 1] = v:FindFirstChild("Add")
	buttons[#buttons + 1] = v:FindFirstChild("Subtract")
end

RE.OnServerEvent:Connect(function(player,toolEquipped,mouseTarget)
	if enabled then
		return
	elseif table.find(buttons,mouseTarget) then
		enabled = true
		local components = mouseTarget.Parent.Screen.SurfaceGui.Counter.Components
		
		if mouseTarget.Name == "Add" then
			components.Value += 1
			print("add ", mouseTarget.Parent.Name,"(",components.Value,")")
		elseif mouseTarget.Name == "Subtract" then
			components.Value -= 1	
			print("subtract ", mouseTarget.Parent.Name,"(",components.Value,")")
		end
		enabled = false
	end
end)