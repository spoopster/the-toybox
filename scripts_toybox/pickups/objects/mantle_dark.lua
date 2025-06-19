
local sfx = SFXManager()

local BLACKHEART_CHANCE = 0.1
local DMG_TODEAL = 10
local DMG_TO_DEAL_FLOOR = 0.5

local function hurtAllEnemies(dmg)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent:ToNPC() and ToyboxMod:isValidEnemy(ent:ToNPC())) and not ent:IsDead() then
            ent:TakeDamage(dmg,0,EntityRef(nil),0)

            local rng = ent:GetDropRNG()
            if(ent:HasMortalDamage() and Game():GetRoom():IsFirstVisit() and rng:RandomFloat()<BLACKHEART_CHANCE) then
                local smoke = Isaac.Spawn(1000,15,2,ent.Position,Vector.Zero,ent):ToEffect()
                smoke.Color = Color(0.25,0.25,0.25,1)
                sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.8)

                local bHeart = Isaac.Spawn(5,10,HeartSubType.HEART_BLACK,ent.Position,Vector.Zero,ent):ToPickup()
            end
        end
    end

    Game():ShakeScreen(10)
end

---@param player EntityPlayer
local function useMantle(_, _, player, _)
    if(ToyboxMod:isAtlasA(player)) then
        ToyboxMod:giveMantle(player, ToyboxMod.MANTLE_DATA.DARK.ID)
    else
        local rng = player:GetCardRNG(ToyboxMod.CONSUMABLE.MANTLE_DARK)

        ToyboxMod:setExtraData("MANTLEDARK_USES", (ToyboxMod:getExtraData("MANTLEDARK_USES") or 1)+1)
        hurtAllEnemies(DMG_TODEAL+Game():GetLevel():GetAbsoluteStage()*DMG_TO_DEAL_FLOOR)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, ToyboxMod.CONSUMABLE.MANTLE_DARK)

local function hurtNewRoomEnemies(_)
    local dmgToDeal = (DMG_TODEAL+Game():GetLevel():GetAbsoluteStage()*DMG_TO_DEAL_FLOOR)*(ToyboxMod:getExtraData("MANTLEDARK_USES") or 0)
    if(dmgToDeal<=0) then return end
    if(Game():GetRoom():IsClear()) then return end

    hurtAllEnemies(dmgToDeal)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, hurtNewRoomEnemies)

local function removeMantleUses(_)
    ToyboxMod:setExtraData("MANTLEDARK_USES", 0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, removeMantleUses)

if(ToyboxMod.ATLAS_A_MANTLESUBTYPES) then ToyboxMod.ATLAS_A_MANTLESUBTYPES[ToyboxMod.CONSUMABLE.MANTLE_DARK] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(ToyboxMod.CONSUMABLE.MANTLE_DARK).Weight = (ToyboxMod.CONFIG.MANTLE_WEIGHT or 0.5)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)