local plantRemoteEvent = game.ReplicatedStorage["Equipped Plant"]
local wkspTools = game.Workspace["Plant Tools"]
local burner = wkspTools.Burner
local radius = wkspTools.Burner.Radius

local enabled = false

while true do
	if enabled == true then
		return
	end
	local touching = game.Workspace:GetPartsInPart(radius)
	for i, v in touching do
		if v.Parent == nil then
			wait()
		elseif v.Parent:FindFirstChild("Humanoid") ~= nil then
			if burner.Stem.ParticleEmitter.Enabled == true and burner.Spawn:FindFirstChildWhichIsA("Part") or burner.Spawn:FindFirstChildWhichIsA("UnionOperation") then
				enabled = true
				local player = v.Parent
				if player:FindFirstChild("Gas Mask") then
					enabled = false				
					print("wearing gas mask")
					wait(.01)
				else
					print("damage")
					local humanoid = v.Parent:FindFirstChild("Humanoid")
					local health = humanoid.Health
					local damage = 15
					humanoid.Health = health - damage
					wait(2)
					enabled = false
				end				
			end
		end

	end
	wait(.01)
end