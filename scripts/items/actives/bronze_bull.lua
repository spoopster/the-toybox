local mod = MilcomMOD

local REWIND_DUR = 200
local REWIND_INTERVAL = 3

---@param player EntityPlayer
local function useItem(_, _, rng, player, flags)
    for _, npc in ipairs(Isaac.GetRoomEntities()) do
        if(npc:IsActiveEnemy(false)) then
            mod:setData(npc, "IS_REWINDING", 1)
        end
    end

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, useItem, mod.COLLECTIBLE_BRONZE_BULL)

---@param npc EntityNPC
local function npcUpdate(_, npc)
    local data = mod:getDataTable(npc)
    if(data.IS_REWINDING) then
        --npc.Velocity = Vector(0,0)

        local rData = data.REWIND_DATA[math.max(1,data.REWIND_COUNTER-data.IS_REWINDING)]
        if(rData) then
            npc.Velocity = (rData.Position-npc.Position)/2
            npc.I1 = rData.I1
            npc.I2 = rData.I2
            npc.TargetPosition = rData.TargetPos
            npc.Target = rData.Target
            npc.State = rData.State

            local sp = npc:GetSprite()
            sp:SetFrame(rData.Anim, rData.Frame)
        end

        data.IS_REWINDING = data.IS_REWINDING+REWIND_INTERVAL
        if(data.IS_REWINDING>REWIND_DUR) then
            data.IS_REWINDING=nil
            data.REWIND_COUNTER = math.max(0, data.REWIND_COUNTER-REWIND_DUR)
            npc.Velocity = Vector(0,0)
        end

        return true
    else
        if(data.REWIND_DATA==nil) then data.REWIND_DATA = {} end
        if(data.REWIND_COUNTER==nil) then data.REWIND_COUNTER = 1 end

        local sp = npc:GetSprite()

        data.REWIND_DATA[data.REWIND_COUNTER] = {
            Position = npc.Position,
            Velocity = npc.Velocity,
            Data = npc:GetData(),
            ModData = mod:getDataTable(npc),
            Anim = sp:GetAnimation(),
            Frame = sp:GetFrame(),
            State = npc.State,
            I1 = npc.I1,
            I2 = npc.I2,
            TargetPos = npc.TargetPosition,
            Target = npc.Target,
        }
        data.REWIND_COUNTER = data.REWIND_COUNTER+1
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, -math.huge, npcUpdate)