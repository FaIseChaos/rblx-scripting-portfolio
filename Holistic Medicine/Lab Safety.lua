local poison = script.Parent
local x = 1
local enabled = false

while true do
	if enabled then
		return
	elseif poison.Parent:FindFirstChild("Humanoid") and not poison.Parent:FindFirstChild("Glove") then -- player is not wearing gloves
		local humanoid = poison.Parent:FindFirstChild("Humanoid")
		while true do
			local health = humanoid.Health
			wait(1)
			local damage = x^(3/4)
			humanoid.Health = health - damage
			x = x+1
		end
		enabled = true
	end	
	wait(.01)
end