
local sfx = SFXManager()

local NUM_HEARTS = 24

---@param pl EntityPlayer
---@param pickup EntityPickup
local function canCollectPickup(pl, pickup)
    if(pickup.Wait>0) then return false end
    if(pickup:IsShopItem()) then
        if(not pl:IsExtraAnimationFinished()) then return false end

        if(pickup.Price>0) then
            return pl:GetNumCoins()>=pickup.Price
        end
    end

    return true
end

---@param pl EntityPlayer
---@param pickup EntityPickup
local function tryCollectPickup(pl, pickup)
    if(pickup:IsShopItem()) then
        local price = pickup.Price
        if(price>=0 or price==PickupPrice.PRICE_FREE or price==PickupPrice.PRICE_SPIKES) then
            if(price==PickupPrice.PRICE_SPIKES) then
                local tookDmg = pl:TakeDamage(2, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(nil), 30)
                if(not tookDmg) then
                    return false
                end
            elseif(price>=0) then
                pl:AddCoins(-price)
            elseif(price==PickupPrice.PRICE_FREE and PlayerManager.AnyoneHasTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                local creditOwner = pl
                if(not pl:HasTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                    for i=0, Game():GetNumPlayers()-1 do
                        local otherPl = Isaac.GetPlayer(i)
                        if(otherPl:HasTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                            creditOwner = otherPl
                            break
                        end
                    end
                end

                if(creditOwner:HasGoldenTrinket(TrinketType.TRINKET_STORE_CREDIT)) then
                    local goldSub = TrinketType.TRINKET_STORE_CREDIT | TrinketType.TRINKET_GOLDEN_FLAG
                    if(creditOwner:GetTrinketRNG(TrinketType.TRINKET_STORE_CREDIT):RandomFloat()<0.25) then
                        local isSmelted = not (creditOwner:GetTrinket(0)==goldSub or creditOwner:GetTrinket(1)==goldSub)

                        local removed = creditOwner:TryRemoveTrinket(goldSub)
                        if(removed) then
                            if(isSmelted) then
                                creditOwner:AddSmeltedTrinket(TrinketType.TRINKET_STORE_CREDIT, false)
                            else
                                creditOwner:AddTrinket(TrinketType.TRINKET_STORE_CREDIT, false)
                            end
                        end
                    end
                else
                    creditOwner:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
                end
            end

            pl:AnimatePickup(pickup:GetSprite(), true)
            pickup:Remove()
            --restock function later
        end
    else
        pickup:GetSprite():Play("Collect", true)
        pickup:Die()
    end

    if(pickup.OptionsPickupIndex~=0) then
        for _, other in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
            other = other:ToPickup()

            if(other.OptionsPickupIndex==pickup.OptionsPickupIndex and GetPtrHash(other)~=GetPtrHash(pickup)) then
                local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT,14,0, other.Position, Vector.Zero, nil):ToEffect()
                other:Remove()
            end
        end
    end

    return true
end

local function moundUpdate(_, pickup)
    if(pickup:GetSprite():IsEventTriggered("DropSound")) then
        sfx:Play(SoundEffect.SOUND_MEAT_FEET_SLOW0)
    end
    if(pickup:GetSprite():IsEventTriggered("HeartBeat")) then
        sfx:Play(SoundEffect.SOUND_HEARTBEAT)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, moundUpdate, ToyboxMod.PICKUP_VARIANT.ETERNAL_MOUND)

---@param pickup EntityPickup
---@param coll Entity
local function preMoundCollision(_, pickup, coll, low)
    if(not (coll and coll:ToPlayer())) then return end
    if(not canCollectPickup(coll:ToPlayer(), pickup)) then return pickup:IsShopItem() end

    local pl = coll:ToPlayer() ---@type EntityPlayer

    if(not tryCollectPickup(pl, pickup)) then
        return pickup:IsShopItem()
    end

    pl:AddEternalHearts(NUM_HEARTS)
    sfx:Play(SoundEffect.SOUND_SUPERHOLY)

    Game():GetLevel():SetHeartPicked()
    Game():ClearStagesWithoutHeartsPicked()
    Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)

    return true
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, preMoundCollision, ToyboxMod.PICKUP_VARIANT.ETERNAL_MOUND)