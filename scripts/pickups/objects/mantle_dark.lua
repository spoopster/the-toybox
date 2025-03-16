local mod = ToyboxMod
local sfx = SFXManager()

local BLACKHEART_CHANCE = 0.1
local DMG_TODEAL = 10
local DMG_TO_DEAL_FLOOR = 0.5

local function hurtAllEnemies(dmg)
    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        if(ent:ToNPC() and mod:isValidEnemy(ent:ToNPC())) and not ent:IsDead() then
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
    if(mod:isAtlasA(player)) then
        mod:giveMantle(player, mod.MANTLE_DATA.DARK.ID)
    else
        local rng = player:GetCardRNG(mod.CONSUMABLE.MANTLE_DARK)

        mod:setExtraData("MANTLEDARK_USES", (mod:getExtraData("MANTLEDARK_USES") or 1)+1)
        hurtAllEnemies(DMG_TODEAL+Game():GetLevel():GetAbsoluteStage()*DMG_TO_DEAL_FLOOR)
    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE.MANTLE_DARK)

local function hurtNewRoomEnemies(_)
    local dmgToDeal = (DMG_TODEAL+Game():GetLevel():GetAbsoluteStage()*DMG_TO_DEAL_FLOOR)*(mod:getExtraData("MANTLEDARK_USES") or 0)
    if(dmgToDeal<=0) then return end
    if(Game():GetRoom():IsClear()) then return end

    hurtAllEnemies(dmgToDeal)
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, hurtNewRoomEnemies)

local function removeMantleUses(_)
    mod:setExtraData("MANTLEDARK_USES", 0)
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, removeMantleUses)

if(mod.ATLAS_A_MANTLESUBTYPES) then mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE.MANTLE_DARK] = true end

local function decreaseWeight(_)
    Isaac.GetItemConfig():GetCard(mod.CONSUMABLE.MANTLE_DARK).Weight = (mod.CONFIG.MANTLE_WEIGHT or 0.5)
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, decreaseWeight)