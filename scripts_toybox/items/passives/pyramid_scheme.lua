
local sfx = SFXManager()

local JAM_CHANCE = 0.075
local COIN_MULT = 2
local FLAT_COIN_ADD = {1,3}


local function spawnPyramidNoTreasure()
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_PYRAMID_SCHEME)) then return end

    local hasTreasure = false
    local rooms = Game():GetLevel():GetRooms()
    for i = 0, rooms.Size-1 do
        local room = rooms:Get(i)
        if(room.Data and room.Data.Type==RoomType.ROOM_TREASURE) then
            hasTreasure = true
        end
    end

    if(not hasTreasure) then
        local room = Game():GetRoom()
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos()+Vector(0,-1)*40)

        local pyramid = Isaac.Spawn(6,ToyboxMod.SLOT_PYRAMID_DONATION,0,pos,Vector.Zero,nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, spawnPyramidNoTreasure)

local function spawnPyramidTreasure()
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_PYRAMID_SCHEME)) then return end
    local room = Game():GetRoom()

    if(room:IsFirstVisit() and room:GetType()==RoomType.ROOM_TREASURE) then
        local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())

        local pyramid = Isaac.Spawn(6,ToyboxMod.SLOT_PYRAMID_DONATION,0,pos,Vector.Zero,nil)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, spawnPyramidTreasure)

---@param slot EntitySlot
local function postSlotInit(_, slot)
    slot:SetState(1)
    slot:SetSize(slot.Size, Vector(2,1)*slot.SizeMulti, 24)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, postSlotInit, ToyboxMod.SLOT_PYRAMID_DONATION)

---@param slot EntitySlot
local function updateDonoDisplay(slot)
    local sp = slot:GetSprite()
    local dono = slot:GetDonationValue()
    local frame1,frame2,frame3 = (dono//100)%10, (dono//10)%10, dono%10

    sp:SetLayerFrame(5, frame1)
    sp:SetLayerFrame(6, frame2)
    sp:SetLayerFrame(7, frame3)
end

---@param slot EntitySlot
local function postSlotUpdate(_, slot)
    local state = slot:GetState()
    local sp = slot:GetSprite()

    if(slot:GetState()==1) then --IDLE
        sp:Play("Idle")
        updateDonoDisplay(slot, false)
    
        if(Isaac.GetPlayer():GetNumCoins()>0 and slot:GetTouch()~=0 and slot:GetTimeout()==0) then
            Isaac.GetPlayer():AddCoins(-1)

            slot:SetState(2)
            sp:PlayOverlay("InsertCoin", true)
        elseif(slot:GetTouch()==0) then
            slot:SetTriggerTimerNum(0)
        end
    end
    if(slot:GetState()==2) then
        updateDonoDisplay(slot, false)

        if(sp:IsOverlayEventTriggered("CoinInsert")) then
            slot:SetDonationValue(slot:GetDonationValue()+1)
            slot:SetTriggerTimerNum(slot:GetTriggerTimerNum()+1)

            local timeout = math.max(15-5*(slot:GetTriggerTimerNum()-1), 5)
            slot:SetTimeout(timeout)

            sfx:Play(SoundEffect.SOUND_COIN_SLOT)

            if(slot:GetDropRNG():RandomFloat()<JAM_CHANCE) then
                slot:SetState(3)
                sp:Play("Explode", true)

                slot:SetDonationValue(0)
                slot:CreateDropsFromExplosion()

                local explosion = Isaac.Spawn(1000,EffectVariant.BOMB_EXPLOSION,0,slot.Position,Vector.Zero,nil):ToEffect()
                for i=0, Game():GetNumPlayers()-1 do
                    local pl = Isaac.GetPlayer(i)
                    if(pl.Variant==PlayerVariant.PLAYER) then
                        pl:AnimateSad()
                    end
                end
            end
        end
        if(sp:IsOverlayFinished()) then
            slot:SetState(1)
        end
    end
    if(slot:GetState()==3) then
        sp:Play("Broken")
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, postSlotUpdate, ToyboxMod.SLOT_PYRAMID_DONATION)

---@param slot EntitySlot
local function slotExplosionDrops(_, slot)
    local rng = slot:GetDropRNG()
    local coinValue = slot:GetDonationValue()*COIN_MULT
    if(coinValue==0) then
        coinValue = rng:RandomInt(FLAT_COIN_ADD[1], FLAT_COIN_ADD[2])
    else
        sfx:Play(SoundEffect.SOUND_CASH_REGISTER)
    end

    local coinStack = {}

    while(coinValue>0) do
        local subtype, value = CoinSubType.COIN_PENNY, 1

        if(coinValue>=10 and rng:RandomFloat()<0.2) then
            subtype, value = CoinSubType.COIN_DIME, 10
        elseif(coinValue>=5 and rng:RandomFloat()<0.4) then
            subtype, value = CoinSubType.COIN_NICKEL, 5
        elseif(coinValue>=2 and rng:RandomFloat()<0.7) then
            subtype, value = CoinSubType.COIN_DOUBLEPACK, 2
        end

        table.insert(coinStack, subtype)
        coinValue = coinValue-value
    end

    local numCoins = #coinStack
    for i, subtype in ipairs(coinStack) do
        local dir = Vector.FromAngle(360*(i+ToyboxMod:randomRange(rng,-0.5,0.5))/numCoins)*3

        local coin = Isaac.Spawn(5,PickupVariant.PICKUP_COIN,subtype,slot.Position,dir,nil):ToPickup()
    end

    return false
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_SLOT_CREATE_EXPLOSION_DROPS, slotExplosionDrops, ToyboxMod.SLOT_PYRAMID_DONATION)