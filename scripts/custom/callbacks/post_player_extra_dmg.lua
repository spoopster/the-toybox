local mod = MilcomMOD

function mod:getPlayerFromKnifeEnt(knife)
    local sp = knife.SpawnerEntity
    if(sp==nil) then return nil end
    if(sp:ToPlayer()) then return sp:ToPlayer()
    elseif(sp:ToFamiliar() and sp:ToFamiliar().Player) then
        local fam = sp:ToFamiliar()
        if(mod.COPYING_FAMILIARS[fam.Variant]) then return fam.Player
        else return nil end
    end

    return nil
end

mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, countdown)
    if(not (flags & DamageFlag.DAMAGE_CLONES == 0 and ent:ToNPC() and source)) then return end

    local dmgType = -1
    local player

    if source.Type == EntityType.ENTITY_TEAR then
        dmgType = mod.DAMAGE_TYPE.TEAR
    elseif(source.Type==EntityType.ENTITY_BOMBDROP and flags & DamageFlag.DAMAGE_EXPLOSION ~= 0) then
        dmgType = mod.DAMAGE_TYPE.BOMB
    elseif(source.Type==EntityType.ENTITY_EFFECT and source.Variant==EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL) then
        dmgType = mod.DAMAGE_TYPE.AQUARIUS
    elseif(source.Type==EntityType.ENTITY_EFFECT and source.Variant==EffectVariant.ROCKET) then
        dmgType = mod.DAMAGE_TYPE.ROCKET
    elseif(source.Type==EntityType.ENTITY_KNIFE and (source.Variant==KnifeVariant.MOMS_KNIFE or source.Variant==KnifeVariant.SUMPTORIUM)) then
        player = mod:getPlayerFromKnifeEnt(source.Entity)
        if(player==nil) then return end
        dmgType = mod.DAMAGE_TYPE.KNIFE
    elseif(source.Type==EntityType.ENTITY_PLAYER and (flags & DamageFlag.DAMAGE_LASER ~= 0)) then
        player = source.Entity:ToPlayer()
        dmgType = mod.DAMAGE_TYPE.LASER
    elseif(source.Type==EntityType.ENTITY_EFFECT and source.Variant==EffectVariant.DARK_SNARE) then
        if(not (source.Entity and source.Entity.SpawnerEntity and source.Entity.SpawnerEntity:ToPlayer())) then return end
        player = source.Entity.SpawnerEntity:ToPlayer()
        dmgType = mod.DAMAGE_TYPE.DARK_ARTS
    elseif(source.Type==EntityType.ENTITY_FAMILIAR and source.Variant==FamiliarVariant.ABYSS_LOCUST) then
        if(not (source.Entity and source.Entity.SpawnerEntity and source.Entity.SpawnerEntity:ToPlayer())) then return end
        player = source.Entity.SpawnerEntity:ToPlayer()
        dmgType = mod.DAMAGE_TYPE.ABYSS_LOCUST
    end

    if(dmgType==-1) then return end

    Isaac.RunCallbackWithParam(mod.CUSTOM_CALLBACKS.POST_PLAYER_EXTRA_DMG, dmgType, dmgType, player, ent, damage, flags)
end)