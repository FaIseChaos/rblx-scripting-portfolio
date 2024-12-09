-----------------------------------------------
--[VARIABLES]--
-----------------------------------------------

local energyData = workspace.EnergyData

--[IDEAL VALUES]--
local V_ref = 10 --isobutane
local V_ref1 = 25 --geothermal
local V_ref2 = 12.5 --cooling water
local V_ref3 = 20 --makeup water

--[IDEAL SCREW COUNT]--
local pumpScrews = 10 -- amount of screws in each pump

--[MAINTENANCE NUMBERS, 0 < M < 1]-- physical repairs like a screw loose or a rusty pannel
local isoM = 1 --isobutane maintenance
local geoM = 1 --geothermal maintenance

--["CURRENT STATISTICS" THAT ARE MEASURED AND INPUTTED INTO THE FUNCTIONS]-- electrical repairs, (friday the 13th ring skill checks)
local IsobutaneVelocity = 10
local GeothermalVelocity = 25
local CoolingWaterVelocity = 20
local MakeupWaterLevel = 20



----------------------------------------------------------------------------------------------
--[FUNCTIONS THAT CALCULATE VELOCITY]-- visual: https://www.desmos.com/calculator/ewl3l4x02i
----------------------------------------------------------------------------------------------

local function pump(isobutane,maintenance) -- calculates isobutane "efficency" based on velocity as a percent
	return maintenance * math.exp(-0.1*(isobutane - V_ref)^2)
end

local function pump1(geothermal,maintenance) -- calculates geothermal "efficency" based on velocity as a percent
	return maintenance * math.exp(-0.05*(geothermal - V_ref1)^2)
end

local function pump2(coolingWater) -- calculates cooling water "efficency" based on velocity as a percent
	return 1 - (1/(1+math.exp(0.5*(coolingWater - V_ref2))))
end

local function makeup(makeupWater) 
	return makeupWater / V_ref3
end

local function C_net(isobutane,geothermal,coolingWater,makeupWater) -- maximum output for this is 0.9770226300899744 - this is the % efficency of the entire network
	return pump(isobutane,isoM) * pump1(geothermal,geoM) * pump2(coolingWater) * makeup(makeupWater)
end

local function W_net(C_net) -- maximum output for this is 1.0799999999956134 (1.08)
	return C_net * 1.10539916552
end

local function round(p,n)
	local m = 10^p
	return math.floor(n*m)/m
end

print("Initial Values:")
print("C_net: ",round(3,C_net(IsobutaneVelocity,GeothermalVelocity,CoolingWaterVelocity,MakeupWaterLevel)))
print("W_net: ",round(3,W_net(C_net(IsobutaneVelocity,GeothermalVelocity,CoolingWaterVelocity,MakeupWaterLevel))))
print("pump: ",round(3,pump(IsobutaneVelocity,isoM)))
print("pump1: ",round(3,pump1(GeothermalVelocity,geoM)))
print("pump2: ",round(3,pump2(CoolingWaterVelocity)))
print("makeup: ",round(3,makeup(MakeupWaterLevel)))

-----------------------------------------------
--[SETTLING GUIS]--
-----------------------------------------------

local geoVel = energyData["Geothermal Velocity"].Screen.SurfaceGui.Counter
local isoVel = energyData["Isobutane Velocity"].Screen.SurfaceGui.Counter
local waterVel = energyData["Water Velocity"].Screen.SurfaceGui.Counter
local Wnet = energyData["Electricity Output"].Screen.SurfaceGui.Counter
local velocityScreens = {geoVel,isoVel,waterVel}

geoVel.Text = GeothermalVelocity
isoVel.Text = IsobutaneVelocity
waterVel.Text = CoolingWaterVelocity
Wnet.Text = round(3,W_net(C_net(IsobutaneVelocity,GeothermalVelocity,CoolingWaterVelocity,MakeupWaterLevel)))

local function Maintenance(v,exp)
	if v == geoVel then
		geoVel.Maintenance.Value -= (math.random(1,1000)*1/10^(exp * 1.25))
		geoM = geoVel.Maintenance.Value
		geoVel.Text = round(3,GeothermalVelocity * pump1(GeothermalVelocity,geoM))	
	elseif v == isoVel then
		isoVel.Maintenance.Value -= (math.random(1,1000)*1/10^(exp * 1.25))
		isoM = isoVel.Maintenance.Value
		isoVel.Text = round(3,IsobutaneVelocity * pump(IsobutaneVelocity,isoM))
	end
end

local function coolingWear(exp)
	CoolingWaterVelocity -= (math.random(2,1000)*1/10^(exp * 1.25))
	waterVel.Text = round(3,CoolingWaterVelocity)
end

while true do
	for i,v in velocityScreens do
		if v ~= waterVel then
			if v.Components.Value ~= pumpScrews then
				if v.Components.Value > 0 and v.Maintenance.Value > 0 then
					Maintenance(v,v.Components.Value)
				elseif v.Maintenance.Value <= 0  then
					if v == geoVel then
						v.Maintenance.Value = 0
						geoM = geoVel.Maintenance.Value
						geoVel.Text = 0
					elseif v == isoVel then
						v.Maintenance.Value = 0
						isoM = isoVel.Maintenance.Value
						isoVel.Text = 0
					end
				end
			end
		else
			if v.Components.Value ~= pumpScrews then
				if waterVel.Components.Value > 0 then
					coolingWear(waterVel.Components.Value)
				elseif CoolingWaterVelocity <= 0 then
					CoolingWaterVelocity = 0 
					waterVel.Text = 0
				end
			end
		end
	end
	
	Wnet.Text = round(3,W_net(C_net(IsobutaneVelocity,GeothermalVelocity,CoolingWaterVelocity,MakeupWaterLevel)))
	
	wait(.005)
end
