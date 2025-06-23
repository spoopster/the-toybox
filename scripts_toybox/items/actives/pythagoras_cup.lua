local sfx = SFXManager()

local ITEM_CLONES = 2
local ITEMS_BEFORE_LOSS = 3

---@param rng RNG
---@param pl EntityPlayer
local function turnToPassive(_, _, rng, pl, flags, slot, vdata)
    if(flags & UseFlag.USE_CARBATTERY == UseFlag.USE_CARBATTERY) then return end

    pl:AddCollectible(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE)

    return {
        Discharge = true,
        ShowAnim = true,
        Remove = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, turnToPassive, ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP)

---@param pl EntityPlayer
---@param flag CacheFlag
local function giveCup(_, pl, flag)
    pl:CheckFamiliar(
        ToyboxMod.FAMILIAR_VARIANT.PYTHAGORAS_CUP,
        (pl:HasCollectible(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE) and 1 or 0),
        pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE),
        Isaac.GetItemConfig():GetCollectible(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE)
    )

    --print(pl:HasCollectible(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE))
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, giveCup, CacheFlag.CACHE_FAMILIARS)

local NO_DUPE = false

local MORPHED_ITEMS = {}
local DIDDY_BLUD = {}

---@param pickup EntityPickup
local function dupeItem(_, pickup)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE)) then return end

    if(NO_DUPE) then
        pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)

        return
    end

    if(MORPHED_ITEMS[GetPtrHash(pickup)]~=nil) then return end

    if(Game():GetLevel():GetDimension()==Dimension.DEATH_CERTIFICATE) then return end

    local room = Game():GetRoom()
    if(room:GetFrameCount()==-1 and not room:IsFirstVisit()) then return end

    local conf = Isaac.GetItemConfig()
    local iConf = conf:GetCollectible(pickup.SubType)
    if(not (iConf and not iConf:HasTags(ItemConfig.TAG_QUEST))) then return end

    Isaac.CreateTimer(function()
        NO_DUPE = true

        --local centerPos = pickup.Position
        --local offsetDist = 30

        local optionsIndex = pickup.OptionsPickupIndex
        if(optionsIndex==0) then
            optionsIndex = pickup:SetNewOptionsPickupIndex()
        end

        local rng = pickup:GetDropRNG()
 
        for _=1, ITEM_CLONES do
            local item = Game():GetItemPool():GetCollectible(room:GetItemPool(rng:RandomInt(2^32-1)+1), true)
            pickup:AddCollectibleCycle(item)

            --[[
            local spawnPos = centerPos+offsetDist*Vector.FromAngle(360*i/ITEM_CLONES-45)
            spawnPos = room:FindFreePickupSpawnPosition(spawnPos)

            local newItem = Isaac.Spawn(5,100,0,spawnPos,Vector.Zero,nil):ToPickup()
            newItem.OptionsPickupIndex = optionsIndex
            
            if(pickup.Price<0 and pickup.Price~=PickupPrice.PRICE_FREE) then
                newItem:MakeShopItem(-2)
            elseif(pickup:IsShopItem()) then
                newItem:MakeShopItem(-1)
                if(pickup.Price==PickupPrice.PRICE_FREE) then
                    newItem.Price = PickupPrice.PRICE_FREE
                end
            end
            --]]
        end

        NO_DUPE = false
    end,2,1,false)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, dupeItem, PickupVariant.PICKUP_COLLECTIBLE)

---@param pickup EntityPickup
local function invalidateMorphedItem(_, pickup)
    MORPHED_ITEMS[GetPtrHash(pickup)] = true
    Isaac.CreateTimer(function ()
        MORPHED_ITEMS[GetPtrHash(pickup)] = nil
    end,0,1,false)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, CallbackPriority.LATE, invalidateMorphedItem)

---@param firstTime boolean
---@param pl EntityPlayer
local function increaseCupState(_, _, _, firstTime, _, _, pl)
    if(not firstTime) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE)) then return end

    local plHash = GetPtrHash(pl)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_VARIANT.PYTHAGORAS_CUP)) do
        fam = fam:ToFamiliar()
        if(GetPtrHash(fam.Player)==plHash) then
            fam.Coins = fam.Coins+1
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, increaseCupState)

---@param pl EntityPlayer
local function stopHoldingThePlaces(_, pl)
    if(pl.FrameCount==0) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE)) then return end

    local plHash = GetPtrHash(pl)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_VARIANT.PYTHAGORAS_CUP)) do
        fam = fam:ToFamiliar()
        if(GetPtrHash(fam.Player)==plHash) then
            fam.Coins = 1
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, stopHoldingThePlaces)

---@param fam EntityFamiliar
local function cupFamiliarInit(_, fam)
    fam:AddToFollowers()
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, cupFamiliarInit, ToyboxMod.FAMILIAR_VARIANT.PYTHAGORAS_CUP)

---@param fam EntityFamiliar
local function cupFamiliarUpdate(_, fam)
    fam:FollowParent()
    fam:GetSprite():SetAnimation("Idle"..tostring(math.min(fam.Coins-1, ITEMS_BEFORE_LOSS)), false)

    if(fam.Coins-1>ITEMS_BEFORE_LOSS) then
        Isaac.Spawn(EntityType.ENTITY_EFFECT, ToyboxMod.EFFECT_VARIANT.PYTHAGORAS_CUP_SPILL, 0, fam.Position, Vector.Zero, nil):ToEffect()

        local pl = fam.Player
        pl:AnimateSad()

        local h = pl:GetHistory()
        local iH = h:GetCollectiblesHistory()
        local idx

        for i=1, #iH do
            if(iH[i]:GetItemID()==ToyboxMod.COLLECTIBLE_PYTHAGORAS_CUP_PASSIVE) then
                idx=i
                break
            end
        end

        for i=#iH, idx, -1 do
            pl:RemoveCollectibleByHistoryIndex(i-1)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, cupFamiliarUpdate, ToyboxMod.FAMILIAR_VARIANT.PYTHAGORAS_CUP)

---@param effect EntityEffect
local function cupSpillUpdate(_, effect)
    local sp = effect:GetSprite()

    if(sp:IsEventTriggered("Bounce")) then
        sfx:Play(SoundEffect.SOUND_SHOVEL_DROP)
        local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TEAR_POOF_SMALL, 0, effect.Position, Vector.Zero, nil):ToEffect()
        poof.DepthOffset = 10
        poof.SpriteOffset = Vector(0,-20)
        for _=1,3 do poof:Update() end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, cupSpillUpdate, ToyboxMod.EFFECT_VARIANT.PYTHAGORAS_CUP_SPILL)