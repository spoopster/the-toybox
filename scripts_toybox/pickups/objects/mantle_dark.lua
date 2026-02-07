
local sfx = SFXManager()

local BLACKHEART_CHANCE = 0.1
local DMG_TODEAL = 10
local DMG_TO_DEAL_FLOOR = 0.5

local CARBATTERY_BLACKHEART_CHANCE = 0.15

local function hurtAllEnemies(dmg, higherChance)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent:ToNPC() and ToyboxMod:isValidEnemy(ent:ToNPC())) then
            ent:TakeDamage(dmg,0,EntityRef(nil),0)

            local rng = ent:GetDropRNG()
            if(ent:HasMortalDamage() and Game():GetRoom():IsFirstVisit() and rng:RandomFloat()<(higherChance and CARBATTERY_BLACKHEART_CHANCE or BLACKHEART_CHANCE)) then
                local smoke = Isaac.Spawn(1000,15,2,ent.Position,Vector.Zero,ent):ToEffect()
                smoke.Color = Color(0.25,0.25,0.25,1)
                sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.8)

                local bHeart = Isaac.Spawn(5,10,HeartSubType.HEART_BLACK,ent.Position,Vector.Zero,ent):ToPickup()
            end
        end
    end

    Game():ShakeScreen(10)
    sfx:Play(SoundEffect.SOUND_BLACK_POOF)
end

---@param player EntityPlayer
---@param flags UseFlag
local function useMantle(_, _, player, flags)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CONGLOMERATE) and flags & UseFlag.USE_CARBATTERY == 0) then return end

    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.DARK.ID)
    else
        local rng = player:GetCardRNG(ToyboxMod.CARD_MANTLE_DARK)

        local data = ToyboxMod:getExtraDataTable()
        data.MANTLEDARK_USES = (data.MANTLEDARK_USES or 0)+1
        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            if(data.MANTLEDARK_USES==data.MANTLEDARK_USES//1) then
                data.MANTLEDARK_USES = data.MANTLEDARK_USES+0.5
            end
        end

        if(flags & UseFlag.USE_CARBATTERY ~= 0) then
            player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, UseFlag.USE_NOANIM)
        end
        hurtAllEnemies(DMG_TODEAL+Game():GetLevel():GetAbsoluteStage()*DMG_TO_DEAL_FLOOR, flags & UseFlag.USE_CARBATTERY ~= 0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CARD_MANTLE_DARK)

local function hurtNewRoomEnemies(_)
    if(Game():GetRoom():IsClear()) then return end
    if((ToyboxMod:getExtraData("MANTLEDARK_USES") or 0)==0) then return end

    local uses = (ToyboxMod:getExtraData("MANTLEDARK_USES") or 0)

    local dmgToDeal = (DMG_TODEAL+Game():GetLevel():GetAbsoluteStage()*DMG_TO_DEAL_FLOOR)*(uses//1)
    if(dmgToDeal<=0) then return end

    hurtAllEnemies(dmgToDeal, (uses ~= uses//1))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, hurtNewRoomEnemies)

local function removeMantleUses(_)
    ToyboxMod:setExtraData("MANTLEDARK_USES", 0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, removeMantleUses)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CARD_MANTLE_DARK] = true end