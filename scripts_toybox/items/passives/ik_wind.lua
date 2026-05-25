local LUCK_FOR_REROLL = 4

---@param slot EntitySlot
local function slotUpdate(_, slot)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_IK_WIND)) then return end

    local data = ToyboxMod:getEntityDataTable(slot)
    local sp = slot:GetSprite()

    if(slot:GetState()==SlotState.REWARD) then
        if(data.IK_EXTRA_ROLLS==nil) then
            local pl = PlayerManager.GetRandomCollectibleOwner(ToyboxMod.COLLECTIBLE_IK_WIND, slot:GetDropRNG():Next())
            local luck = (pl and pl.Luck or 0)

            local num = luck//LUCK_FOR_REROLL
            if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_IK_WIND):RandomFloat()<(luck/LUCK_FOR_REROLL)%1) then
                num = num+1
            end

            --if(num>0) then
                data.IK_EXTRA_ROLLS = num--math.random(0,2)
                if(num>0) then
                    data.IK_EXTRA_DATA = {
                        Anim = sp:GetAnimation(),
                        OverlayAnim = sp:GetOverlayAnimation(),
                        Timeout = slot:GetTimeout(),
                        PlaybackSpeed = sp.PlaybackSpeed,
                        Frame = 0,
                    }
                end
            --end
        end
    elseif(slot:GetState()==SlotState.IDLE) then
        if(data.IK_EXTRA_ROLLS) then
            if(data.IK_EXTRA_ROLLS==0) then
                if(data.IK_EXTRA_DATA) then
                    sp.PlaybackSpeed = data.IK_EXTRA_DATA.PlaybackSpeed or 1
                end

                data.IK_EXTRA_ROLLS = nil
                data.IK_EXTRA_DATA = nil
            else
                data.IK_EXTRA_ROLLS = data.IK_EXTRA_ROLLS-1
                if(data.IK_EXTRA_DATA) then
                    sp.PlaybackSpeed = 2
                    sp:Play(data.IK_EXTRA_DATA.Anim, true)
                    sp:PlayOverlay(data.IK_EXTRA_DATA.OverlayAnim, true)
                    slot:SetTimeout(data.IK_EXTRA_DATA.Timeout//2)
                end
                slot:SetState(SlotState.REWARD)
            end
        end
    end

    if(data.IK_EXTRA_ROLLS and data.IK_EXTRA_DATA) then
        data.IK_EXTRA_FRAME = (data.IK_EXTRA_FRAME or 0)+1
    else
        data.IK_EXTRA_FRAME = math.max(0, math.min(60, data.IK_EXTRA_FRAME or 0)-4)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, slotUpdate)

local CANCEL_RENDER = false

---@param slot EntitySlot
---@param offs Vector
local function slotPreRender(_, slot, offs)
    if(CANCEL_RENDER) then return end

    local data = ToyboxMod:getEntityDataTable(slot)
    if((data.IK_EXTRA_FRAME or 0)<=0) then return end

    local frame = data.IK_EXTRA_FRAME or 0

    local sp = slot:GetSprite()
    local ogColor = Color.Lerp(sp.Color, sp.Color, 0)
    local ogScale = Vector(sp.Scale.X, sp.Scale.Y)

    sp.Color = Color(0,0,0,math.min(frame/60, 1)*0.35,255/255,200/255,63/255)
    sp.Scale = ogScale*(1+math.min(frame/30, 1)*0.075)

    CANCEL_RENDER = true

    slot:Render(offs)

    CANCEL_RENDER = nil

    sp.Color = ogColor
    sp.Scale = ogScale
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_SLOT_RENDER, CallbackPriority.IMPORTANT, slotPreRender)