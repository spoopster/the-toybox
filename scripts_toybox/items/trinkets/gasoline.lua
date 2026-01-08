local TICKSPEED_PER_MULT = 0.5

---@param npc EntityNPC
local function gggg(_, npc)
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_GASOLINE)) then return end

    if(npc:GetBurnCountdown()>0) then
        local mult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_GASOLINE)
        local ogtimer = npc:GetBurnDamageTimer()

        if(ogtimer%20==3) then
           npc:SetBurnDamageTimer(npc:GetBurnDamageTimer()+(20*(1-1/(1+mult*TICKSPEED_PER_MULT)))//1)
        end

        npc:SetBurnCountdown(npc:GetBurnCountdown()+1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_NPC_UPDATE, gggg)