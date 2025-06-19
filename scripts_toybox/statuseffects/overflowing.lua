

function ToyboxMod:addOverflowing(npc, player, amount, rng)
    local d = ToyboxMod:getEntityDataTable(npc)

    local oldData = d.STATUS_OVERFLOW_DATA or {}
    d.STATUS_OVERFLOW_DATA = {
        DURATION = (oldData.DURATION or 0)+amount,
        PLAYER = player or oldData.PLAYER or Isaac.GetPlayer(),
        RNG = rng or ToyboxMod:generateRng(),
        WAS_SPRITE_STOPPED = (oldData.WAS_SPRITE_STOPPED),
    }
    if(d.STATUS_OVERFLOW_DATA.WAS_SPRITE_STOPPED==nil) then d.STATUS_OVERFLOW_DATA.WAS_SPRITE_STOPPED = npc:GetSprite():IsPlaying() end
end
function ToyboxMod:hasOverflowing(npc)
    local d = ToyboxMod:getEntityData(npc, "STATUS_OVERFLOW_DATA")
    return (d and d.DURATION>0)
end
function ToyboxMod:getOverloadingDuration(npc)
    local d = ToyboxMod:getEntityData(npc, "STATUS_OVERFLOW_DATA")
    if(not d) then return 0
    else return d.DURATION end
end

ToyboxMod:addCustomStatusEffect(
    "Overflowing",
    Color(1,1,1,1,0,0,0),
    function(npc)
        return ToyboxMod:hasOverflowing(npc)
    end
)

local function cancelOverflowingUpdate(_, npc)
    if(ToyboxMod:hasOverflowing(npc)) then
        local d = ToyboxMod:getEntityData(npc, "STATUS_OVERFLOW_DATA")

        d.DURATION = d.DURATION-1
        if(d.DURATION<=0) then
            if(d.WAS_SPRITE_STOPPED==false) then npc:GetSprite():Continue(true) end
            d=nil
        else
            if(npc:GetSprite():IsPlaying()) then
                npc:GetSprite():Stop(true)
                --print("go")
            end
        end

        ToyboxMod:setEntityData(npc, "STATUS_OVERFLOW_DATA", d)

        return true
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, -math.huge, cancelOverflowingUpdate)

---@param npc EntityNPC
local function overflowingNpcRender(_, npc, offset)
    if(ToyboxMod:hasOverflowing(npc)) then
        local s = npc:GetSprite()
        local rng = ToyboxMod:getEntityData(npc, "STATUS_OVERFLOW_DATA").RNG

        for i=1,2 do
            s:Render(Isaac.WorldToScreen(npc.Position+Vector(rng:RandomFloat()-0.5,rng:RandomFloat()-0.5)*26))
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, overflowingNpcRender)