

local SPEED_UP = 0.16
local CHARGES_ON_ROOM = 1

local chargeOrder = {
    ActiveSlot.SLOT_PRIMARY,
    ActiveSlot.SLOT_SECONDARY,
    ActiveSlot.SLOT_POCKET,
    ActiveSlot.SLOT_POCKET2
}

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_SOLAR_PANEL)) then return end
    local mult = player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SOLAR_PANEL)

    player.MoveSpeed = player.MoveSpeed+mult*SPEED_UP
end
--ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_SPEED)

local function addChargeOnNewRoom(_)
    local room = Game():GetRoom()
    if(not (room:IsClear() and room:IsFirstVisit())) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        local numCharges = CHARGES_ON_ROOM*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_SOLAR_PANEL)

        local addedNormalCharge = false

        if(numCharges>0) then
            for _, slot in ipairs(chargeOrder) do
                local doOvercharge = pl:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY)
                local isOvercharged = (pl:GetActiveCharge(slot)>=pl:GetActiveMaxCharge(slot))

                local numAdded = pl:AddActiveCharge(numCharges,slot,true,doOvercharge,false)
                if(numAdded>0) then
                    addedNormalCharge = not isOvercharged

                    break
                end
            end
        end

        if(addedNormalCharge) then
            local notif = Isaac.Spawn(1000, EffectVariant.HEART, 0, pl.Position, Vector.Zero, nil):ToEffect() ---@cast notif EntityEffect
            local sp = notif:GetSprite()
            sp:Load("gfx_tb/effects/effect_notify.anm2", true)
            sp:Play("BatteryNormal", true)

            notif.SpriteOffset = Vector(0, -25)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, addChargeOnNewRoom)