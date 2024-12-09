local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local plantRemoteEvent = game.ReplicatedStorage["Equipped Plant"]
local player = game.Players.LocalPlayer
local plants = game.Workspace["Plants and Chems"]:GetChildren()
local plantTable = {}
local mouse = player:GetMouse()

for i,v in plants do
	local plantName = v.Name
	plantTable[#plantTable + 1] = plantName
end

UIS.InputBegan:Connect(function(input, processed)
	local toolEquipped = player.Character:FindFirstChildOfClass("Tool")
	local mouseTarget = mouse.Target	
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		plantRemoteEvent:FireServer(toolEquipped,mouseTarget)
	end
end)