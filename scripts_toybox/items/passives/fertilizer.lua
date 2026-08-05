local MAX_FLIES = 3
local STACK_MAX_FLIES = 2

local SPAWN_FREQ = 2*30
local NO_SHOOTING_FREQ_BOOST = 0.6*30
local NO_MOVING_FREQ_BOOST = 0.6*30

---@param pl EntityPlayer
local function playerUpdate(_, pl)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_FERTILIZER)) then return end

    local data = ToyboxMod:getEntityDataTable(pl)
    data.FERTILIZER_LAST_FRAME = (data.FERTILIZER_LAST_FRAME or pl.FrameCount)

    local nextSpawn = SPAWN_FREQ
    if(pl:GetFireDirection()==Direction.NO_DIRECTION) then
        nextSpawn = nextSpawn-NO_SHOOTING_FREQ_BOOST
    end
    if(pl:GetMovementDirection()==Direction.NO_DIRECTION) then
        nextSpawn = nextSpawn-NO_MOVING_FREQ_BOOST
    end
    nextSpawn = nextSpawn//1

    if((pl.FrameCount-data.FERTILIZER_LAST_FRAME)>=nextSpawn) then
        local maxNumFlies = MAX_FLIES+STACK_MAX_FLIES*(pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_FERTILIZER)-1)

        local numflies = 0
        local plhash = GetPtrHash(pl)
        for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR,FamiliarVariant.BLUE_FLY)) do
            if(GetPtrHash(ent:ToFamiliar().Player)==plhash) then
                if(EntitySaveStateManager.GetEntityData(ToyboxMod, ent).FERTILIZER_FLY) then
                    numflies = numflies+1
                end
            end
        end
        if(numflies<maxNumFlies) then
            local fly = pl:AddBlueFlies(1, pl.Position, nil)

            for _, ent in ipairs(Isaac.FindByType(3,FamiliarVariant.BLUE_FLY)) do
                if(ent.FrameCount==0 and GetPtrHash(ent:ToFamiliar().Player)==plhash) then
                    local flyData = EntitySaveStateManager.GetEntityData(ToyboxMod, ent)
                    flyData.FERTILIZER_FLY = true
                end
            end

            data.FERTILIZER_LAST_FRAME = pl.FrameCount

            ToyboxMod.SFX:Play(865, 0.6, nil, nil, 1.05+math.random()*0.3)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, playerUpdate)