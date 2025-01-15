local mod = MilcomMOD

local POP_OUT_PLAYER_SAFEDIST = 80

local GROUND_HIDE_DURATION = 60
local IDLE_WAIT_DURATION = 120
local ATTACK_TELEGRAPH_DURATION = 30
local ATTACK_WAIT_DURATION = 120

local VALID_ROCKS = {
    [GridEntityType.GRID_ROCK] = true,
    [GridEntityType.GRID_ROCKT] = true,
    [GridEntityType.GRID_ROCK_BOMB] = true,
    [GridEntityType.GRID_ROCK_ALT] = true,
    [GridEntityType.GRID_TNT] = true,
    [GridEntityType.GRID_ROCK_SS] = true,
    [GridEntityType.GRID_ROCK_SPIKED] = true,
    [GridEntityType.GRID_ROCK_ALT2] = true,
    [GridEntityType.GRID_ROCK_GOLD] = true,
    [GridEntityType.GRID_POOP] = true,
}

---@param npc EntityNPC
local function stumpyInit(_, npc)
    if(not (npc.Variant==mod.VAR_STUMPY)) then return end

    npc:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE

    npc:GetSprite():Play("DigIn", true)
    npc.State = NpcState.STATE_IDLE
    npc.StateFrame = IDLE_WAIT_DURATION
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, stumpyInit, mod.NPC_MAIN)

---@param npc EntityNPC
local function stumpyUpdte(_, npc)
    if(not (npc.Variant==mod.VAR_STUMPY)) then return end
    local sp = npc:GetSprite()
    local data = mod:getEntityDataTable(npc)

    if(npc.State==NpcState.STATE_IDLE) then
        if(npc.StateFrame==1) then
            local room = Game():GetRoom()
            local failsafe = 40000
            repeat
                failsafe = failsafe-1
                npc.Position = room:GetRandomPosition(40)
            until(failsafe<=0 or (
                room:GetGridCollisionAtPos(npc.Position)==GridCollisionClass.COLLISION_NONE and
                #Isaac.FindInRadius(npc.Position, POP_OUT_PLAYER_SAFEDIST, EntityPartition.PLAYER)==0
            ))

            sp:Play("PopOut", true)
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
        end

        if(npc.StateFrame==IDLE_WAIT_DURATION) then
            sp:Play("DigIn", true)
        end

        if(sp:IsFinished("PopOut")) then
            sp:Play("Idle", true)
        end
        if(sp:IsFinished("DigIn")) then
            npc.State = NpcState.STATE_SPECIAL
            npc.StateFrame = 0

            npc.I1 = 1
        end
    elseif(npc.State==NpcState.STATE_ATTACK) then
        if(npc.StateFrame==1) then
            local rocksToPickFrom = {}
            local room = Game():GetRoom()
            for i=0, room:GetGridSize()-1 do
                local gridEnt = room:GetGridEntity(i)
                if(gridEnt and VALID_ROCKS[gridEnt:GetType()]) then
                    if((gridEnt:ToRock()==nil) or (gridEnt:ToRock() and gridEnt.State==2)) then
                        table.insert(rocksToPickFrom, i)
                    end
                end
            end

            local numRocks = #rocksToPickFrom
            if(numRocks<=0) then
                npc.StateFrame = 0
                npc.State = NpcState.STATE_IDLE
            else
                local rng = npc:GetDropRNG()
                local chosenIdx = rocksToPickFrom[rng:RandomInt(numRocks)+1]
                local chosenGrid = room:GetGridEntity(chosenIdx)
                local pos = room:GetGridPosition(chosenIdx)

                npc.Position = pos

                sp:Play("PopOut", true)
                npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL

                if(chosenGrid:ToRock()) then
                    chosenGrid = chosenGrid:ToRock()
                    if(chosenGrid.Anim=="big") then
                        chosenGrid.Anim = "normal"
                        chosenGrid:UpdateAnimFrame()
                    end
                end

                local oldSprite = chosenGrid:GetSprite()
                local newSprite = Sprite()
                newSprite:Load(oldSprite:GetFilename(), true)
                newSprite:SetFrame(oldSprite:GetAnimation(), oldSprite:GetFrame())
                newSprite.Color = oldSprite.Color

                data.STUMPY_ROCKSPRITE = newSprite
                data.STUMPY_ROCKDESC = chosenGrid.Desc

                if(chosenGrid:ToRock()) then
                    chosenGrid.State = 2
                    chosenGrid:ToRock():UpdateNeighbors()
                end
                room:RemoveGridEntityImmediate(chosenIdx, 0, false)
                room:SpawnGridEntity(chosenIdx, GridEntityType.GRID_DECORATION, 0, 0, 0)
                
                chosenGrid = room:GetGridEntity(chosenIdx)
                if(chosenGrid) then
                    chosenGrid:GetSprite():ReplaceSpritesheet(0, "gfx/tb_empty.png", true)
                end
            end
        end

        if(sp:IsEventTriggered("Shoot") and (npc.Target and npc.Target:Exists())) then
            local dir = (npc.Target.Position-npc.Position)
            local proj = npc:FireGridEntity(data.STUMPY_ROCKSPRITE, data.STUMPY_ROCKDESC, dir:Resized(7), Game():GetRoom():GetBackdropType())

            local heightScale = 1.8
            proj.FallingAccel = 1*heightScale-0.1
            proj.FallingSpeed = -17.5*heightScale
        end

        if(npc.StateFrame==ATTACK_TELEGRAPH_DURATION) then
            sp:Play("Attack", true)

            npc.Target = npc:GetPlayerTarget()
        end
        if(npc.StateFrame==ATTACK_WAIT_DURATION) then
            sp:Play("DigIn", true)
        end

        if(sp:IsFinished("PopOut")) then
            sp:Play("Idle", true)
        end
        if(sp:IsFinished("Attack")) then
            sp:Play("Idle", true)
        end
        if(sp:IsFinished("DigIn")) then
            npc.State = NpcState.STATE_SPECIAL
            npc.StateFrame = 0

            npc.I1 = 0
        end
    elseif(npc.State==NpcState.STATE_SPECIAL) then
        if(npc.StateFrame==1) then
            npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        end

        if(npc.StateFrame==GROUND_HIDE_DURATION) then
            npc.StateFrame = 0
            if(npc.I1==0) then
                npc.State = NpcState.STATE_IDLE
            else
                npc.State = NpcState.STATE_ATTACK
            end
        end
    end

    npc.StateFrame = npc.StateFrame+1
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, stumpyUpdte, mod.NPC_MAIN)