local Workspace = game:GetService("Workspace")
--[[
   SCP-004
   Author: Chaos
   Date:  2023
   Provides: 
]]--

local public = {}

----------------------------------
--   DEPENDENCIES & SERVICES           
----------------------------------
local import = require(game.ReplicatedStorage.Packages.import)
local TweenService = game:GetService("TweenService")
----------------------------------
--       PRIMARY VARIABLES            
----------------------------------
local SCPFolder = assert(workspace.SCPs:FindFirstChild("SCP-004"),"[ERROR] Can not find SCP-004.")
local BadKeys = { -- list of keys that will kill the player if they open the door
    "SCP-004-2",
    "SCP-004-3",
    --"SCP-004-4",
    "SCP-004-5",
    "SCP-004-6",
    "SCP-004-8",
    "SCP-004-9",
    "SCP-004-10",
    "SCP-004-11",
    "SCP-004-13"
}
local SafeKeys = { --keys that will not kill the player if they open the door
    "SCP-004-4",
    "SCP-004-7",
    "SCP-004-12"
}
local BadColors = { -- colors that the particles will turn when the door is opened by a bad key
    Color3.new(1, 0, 0),
    Color3.new(0.258823, 0.070588, 0.227450),
    Color3.new(0.984313, 1, 0),
    Color3.new(0.066666, 0, 1),
    Color3.new(0, 0.882352, 1),
    Color3.new(1, 0.4, 0),
    Color3.new(0, 0.137254, 0.341176),
    Color3.new(0.274509, 0.109803, 0),
    Color3.new(0, 0, 0),
    Color3.new(0.388235, 0, 0),
}
local RightArm = {
    "RightHand",
    "RightLowerArm",
    "RightUpperArm"
}
local LeftArm = {
    "LeftHand",
    "LeftLowerArm",
    "LeftUpperArm"
}
local RightLeg = {
    "RightFoot",
    "RightLowerLeg",
    "RightUpperLeg"
}
local LeftLeg = {
    "LeftFoot",
    "LeftLowerLeg",
    "LeftUpperLeg"
}
local KeepThese = {
    "Shirt",
    "Pants",
    "Humanoid",
    "root",
    "LowerTorso",
    "UpperTorso"
}
local UpperParts = {
    "UpperTorso",
    "LowerTorso",
    "LeftUpperLeg",
    "LeftUpperArm",
    "RightUpperLeg",
    "RightUpperArm"
}
local door = SCPFolder:FindFirstChild("door") -- location for the proximity prompt
local prompt = door:FindFirstChild("ProximityPrompt") --proximity prompt that opens the door
local killBrick = SCPFolder:FindFirstChild("kill") --part used to kill the player after they enter the door
local emitter = SCPFolder:FindFirstChild("emitter") --particle emitter that starts/stopps when the door opens/closes
local emitterStorage = SCPFolder.EmitterStorage:FindFirstChild("ParticleEmitter") --copy of the particle emitter for each time the door is opened
local restraint = SCPFolder:FindFirstChild("restraint") -- invisible part to prevent the player from entering too early
local closer = SCPFolder:FindFirstChild("closer") -- brick that detects when to close el door

local lRoot = SCPFolder.left.hinge --left door hinge
local rRoot = SCPFolder.right.hinge --right door hinge
local status = false --true = door is open, false = door is closed; false by default
local moving = false --true = door is in motion (tweening), false = door not in motion; false by default
local bad = false --true = a "Bad" key has been used on the door, false = a "safe" key has been used on the door; false by defalt - check the BadKeys & SafeKeys tables to see which ones are bad/safe
local death = false --true = someone is touching the killbrick, false = nobody is touching the killbrick; false by default - used for throttling the part:Touched() function
local doorTrap = false --true = someone is touching the brick, false =nobody is touching the brick; false by default - used for throttling the part:Touched() function

local attachments = SCPFolder.Attachments:GetChildren() --table for the attachments for the limbs to hang on
----------------------------------
--       PRIVATE FUNCTIONS            
----------------------------------

function motionDoor(leftDegree,rightDegree) --opening the door, if it is not opening correctly, fiddle with the pos/neg of math.rad(90) and swap around the x,y,z
    local swingInfo = TweenInfo.new(1.5)
    local leftTween = TweenService:Create(lRoot,swingInfo,{ --left door
        CFrame = lRoot.CFrame * CFrame.Angles(0,math.rad(leftDegree),0) -- to open the door, leftDegree should be -90 and to close it should be 90
    })
    local rightTween = TweenService:Create(rRoot,swingInfo,{ -- right door
        CFrame = rRoot.CFrame * CFrame.Angles(0,math.rad(rightDegree),0)-- to open the door, rightDegree should be 90 and to close it should be -90
    })
    leftTween:Play()
    rightTween:Play()
end

function weld(part0,part1,needsUnanchored) -- simple welding function
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = part0
    weld.Part1 = part1
    weld.Parent = part0
    if needsUnanchored == true then
        part0.Parent.Anchored = false
    end
    
end

function CloneMe(player) --a function that clones a player
    player.Archivable = true
    local clone = player:Clone()
    player.Archivable = false
    return clone
end

function limbPicker() --picks which limb will be dangled by the rope
    local random = math.random(1,4)
    if random == 1 then
        return RightArm
    elseif random == 2 then
        return RightLeg
    elseif random == 3 then
        return LeftArm
    elseif random == 4 then
        return LeftLeg
    end
end

function limbLocator(part) --checks which limb the input is a part of
    if table.find(RightArm,part) then
        return "RightUpperArm"
    elseif table.find(LeftArm,part) then
        return "LeftUpperArm"
    elseif table.find(LeftLeg,part) then
        return "LeftUpperLeg"
    elseif table.find(RightLeg,part) then
        return "RightUpperLeg"
    end
end

function colorPicker(key) --returns the color that the key is associated with
    if key == "SCP-004-2" then --death room
        return Color3.new(1,0,0)
    elseif key == "SCP-004-3" then --death room (slowly)
        return Color3.new(1,.5,0)
    elseif key == "SCP-004-4" then --breach shelter
        return Color3.new(1,1,0)
    elseif key == "SCP-004-5" then
        return Color3.new(0.6, 0.0, 0.6)
    elseif key == "SCP-004-6" then
        return Color3.new(0, 0.9, 1)
    elseif key == "SCP-004-8" then
        return Color3.new(0.380392, 0, 0)
    elseif key == "SCP-004-9" then
        return Color3.new(0, 0, 0)
    elseif key == "SCP-004-10" then
        return Color3.new(1,1,1)
    elseif key == "SCP-004-11" then
        return Color3.new(0,.15,.35)
    elseif key == "SCP-004-13" then
        return Color3.new(0,.4,0)
    end

end

----------------------------------
--       PUBLIC FUNCTIONS            
----------------------------------
function public:Start()
    weld(lRoot,lRoot.Parent,true) --welds the doors to the hinges
    weld(rRoot,rRoot.Parent,true)

    closer.Touched:Connect(function(part)
        if part.Parent:FindFirstChild("Humanoid") then --checks if the thing that touched is a player
            if doorTrap == false and status == true and moving == false and bad == true then --if the door is open then...
                doorTrap = true -- used to throttle the function
                motionDoor(90,-90) -- closes the door
                moving = true -- door is moving
                for _,v in emitter:GetChildren() do --disables all the particle emitters
                    v.Enabled = false
                end
                task.wait(1.5)
                status = false -- door is closed
                moving = false -- door is not moving
            end
        end
    end)

    killBrick.Touched:Connect(function(part)
        if part.Parent:FindFirstChild("Humanoid") then --checks if the thing that touched it is a player
            local player = part.Parent
            if death == false and bad == true then --death checks if the function is already running & bad checks if the bad key was used to open the door
                death = true -- used so the function only runs once
                restraint.CanCollide = true --prevents someone from walking in behind them
                local currentLimb --initalized to be used to later to identify which limb has been chosed to be ripped off the body and strung up
                local charClone = CloneMe(player) --clones the player
                charClone.Parent = SCPFolder 
                local limb = limbPicker() --picks a limb
                local originalLimb = {} --used later for lining up the limbs
                for _,v in limb do
                    table.insert(originalLimb,v)
                end
                local root = Instance.new("Part") -- creates a part that gives the removed limb proper gravity
                root.Parent = charClone
                root.Size = Vector3.new(1,2,1)
                root.Transparency = 1
                root.CanCollide = true
                root.Anchored = true
                for _,v in limb do --loop for each part of the limb (foot/hand,lower,and upper)
                    if charClone:FindFirstChild(v) then --checks to see if v exists
                        if charClone:FindFirstChild(v):IsA("MeshPart") or charClone:FindFirstChild(v):IsA("Part") then --ensures v is a limb (or root) and not a accessory/shirt/pants/etc.
                            local limbPart = charClone:FindFirstChild(v) --defines the part of the limb that the loop is currently on
                            limbPart.Anchored = true
                            limbPart.CanCollide = false
                            if not table.find(UpperParts,v) then --checks if v is the upper part of a limb
                                currentLimb = charClone:FindFirstChild(limbLocator(v)) --defines the upper limb of the part that the loop is currently on
                                weld(charClone:FindFirstChild(limbLocator(v)),charClone:FindFirstChild(v)) --welds the lower part of the limb to the upper part
                                limbPart.Anchored = false
                            else
                                weld(root,limbPart) --welds the upper part of the limb to the root
                                root.Orientation = limbPart.Orientation --aligns the root to the limb
                                root.Position = Vector3.new(limbPart.Position.x,limbPart.Position.y - .5,limbPart.Position.z)--aligns the root to the limb
                            end
                        end
                    end
                end
                for _,v in limb do
                    local actual = charClone:FindFirstChild(v) --connects v to the actual limb
                    if charClone:FindFirstChild(v) then --checks to see if v exists
                        if actual:IsA("MeshPart") or actual:IsA("Part") then --ensures v is a limb (or root) and not a shirt/pants/humanoid/etc.
                            actual.Anchored = false
                            actual.CanCollide = false
                        end
                    end
                end
                for _,v in KeepThese do --adds the limbs to the table that specifies what to keep in the player model
                    table.insert(limb,v)
                end
                print(limb)
                for _,v in charClone:GetChildren() do
                    if table.find(limb,v.Name) then --checks if v is a limb
                        task.wait()
                    else --deletes anything that is not a limb or otherwise needed to keep (check the KeepThese table for what is kept)
                        v:Destroy()
                    end
                end
                charClone:FindFirstChild("LowerTorso"):Destroy() --deleting these after everything else because if you do it earlier then it won't work
                charClone:FindFirstChild("UpperTorso"):Destroy()
                local randomAttachment = math.random(1,#attachments) --picks a random attachment within the factory
                local attachment = attachments[randomAttachment]
                currentLimb.Position = attachment.Position - Vector3.new(0,2,0) --ligns up and positions the limbs to be strung up on a rope
                currentLimb.Orientation = Vector3.new(0,0,0)
                charClone:FindFirstChild(originalLimb[2]).Position = currentLimb.Position - Vector3.new(0,.6,0)
                charClone:FindFirstChild(originalLimb[2]).Orientation = Vector3.new(0,0,0)
                charClone:FindFirstChild(originalLimb[1]).Position = currentLimb.Position - Vector3.new(0,.5,0)
                charClone:FindFirstChild(originalLimb[1]).Orientation = Vector3.new(0,0,0)
                local rope = Instance.new("RopeConstraint") --creates a rope constraint
                rope.Parent = attachment
                rope.Visible = true
                rope.Attachment0 = attachment.Attachment
                local rootAtt = Instance.new("Attachment")
                rootAtt.Parent = currentLimb
                rope.Attachment1 = rootAtt
                rope.Length = math.random(4,8)
                task.wait(.333) -- prevents the kill brick from being spammed
                death = false -- used so the function only runs once
                bad = false -- disables the badkey door
                status = false -- door is closed
                while player.Humanoid.Health > 0 do
                    task.wait(.5)
                    player.Humanoid.Health = player.Humanoid.Health - 10
                end
            end
        end

    end)

    prompt.Triggered:Connect(function(player) --when the player holds e to trigger the proximity prompt 
        print(player.Character.Name)
        local toolEquipped = player.Character:FindFirstChildOfClass("Tool")
        if not moving then -- if the door is not in motion then...
            moving = true
            if not status then -- if the door is CLOSED then...
                status = true
                if toolEquipped and table.find(BadKeys,toolEquipped.Name) then --checks if the key that is held is one that will kill the player
                    bad = true --toggles kill brick
                    doorTrap = false
                    print("[SCP-004] Opening door")
                    local newEmitter = emitterStorage:Clone() -- creates a new particle emitter
                    newEmitter.Parent = SCPFolder.emitter
                    newEmitter.Enabled = true
                    newEmitter.Color = ColorSequence.new{ -- makes colors transition from one to another on the way down
                            ColorSequenceKeypoint.new(0, colorPicker(toolEquipped.Name)),
                            ColorSequenceKeypoint.new(1, colorPicker(toolEquipped.Name))
                        }
                    motionDoor(-90,90) -- opens the door
                    task.wait(1.5)
                    restraint.CanCollide = false
                elseif toolEquipped and table.find(SafeKeys,toolEquipped.Name) then -- checks if the key that is held is one that will NOT kill the player
                    print("[SCP-004] Opening door")
                    motionDoor(-90,90) -- opens the door 
                    task.wait(1.5)
                    restraint.CanCollide = false
                else -- debugging
                    print("[SCP-004] Not holding a key!")
                    status = false
                end
            elseif status then -- if the door is OPEN then...
                status = false
                bad = false --toggles kill brick
                print(emitter:GetChildren())
                for _,v in ipairs(emitter:GetChildren()) do
                    v.Enabled = false -- turns off the particles so they slowly trickle down very pretty like :^)
                end
                print("[SCP-004] Closing door")
                motionDoor(90,-90) -- closes the door
                restraint.CanCollide = true
                task.wait(2)
            end
            moving = false
        elseif moving then -- if the door is in motion
            print("[SCP-004] Door is in motion!")
        end
    end)

end

----------------------------------
--          MAIN CODE            
----------------------------------

return public