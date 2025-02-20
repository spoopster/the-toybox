local mod = MilcomMOD

function mod:unlock(unlock, force)
    local pgd = Isaac.GetPersistentGameData()
    if(not force) then
        if(not Game():AchievementUnlocksDisallowed()) then
            if(not pgd:Unlocked(unlock)) then
                pgd:TryUnlock(unlock)
            end
        end
    else
        pgd:TryUnlock(unlock)
    end
end

function mod:cloneTable(t)
    local tClone = {}
    for key, val in pairs(t) do
        if(type(val)=="table") then
            tClone[key]={}
            for key2, val2 in pairs(mod:cloneTable(val)) do
                tClone[key][key2]=val2
            end
        else
            tClone[key]=val
        end
    end
    return tClone
end
function mod:cloneTableWithoutDeleteing(table1, table2)
    for key, val in pairs(table2) do
        if(type(val)=="table") then
            table1[key] = {}
            mod:cloneTableWithoutDeleteing(table1[key], table2[key])
        else
            table1[key]=val
        end
    end
end

---@param v Vector
function mod:vectorToVectorTable(v)
    return
    {
        X = v.X,
        Y = v.Y,
        IsVectorTable = true,
    }
end
---@param t table
function mod:vectorTableToVector(t)
    return Vector(t.X, t.Y)
end

---@param c Color
function mod:colorToColorTable(c)
    return
    {
        R = c.R,
        G = c.G,
        B = c.B,
        A = c.A,
        RO = c.RO,
        GO = c.GO,
        BO = c.BO,
        IsColorTable = true,
    }
end
---@param t table
function mod:colorTableToColor(t)
    return Color(t.R, t.G, t.B, t.A, t.RO, t.GO, t.BO)
end

---@param player EntityPlayer
function mod:isMilcom(player)
    if(player:GetPlayerType()==mod.PLAYER_MILCOM_A) then return true end
    if(player:GetPlayerType()==mod.PLAYER_MILCOM_B) then return true end
    return false
end

---@param player EntityPlayer
function mod:isAtlas(player)
    if(mod:isAtlasA(player)) then return true end
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_B) then return true end
    return false
end

---@param val number Value to clamp
---@param upper number Upper bound of the range
---@param lower number Lower bound of the range
---@return number clampedVal The clamped value
---Clamps a given value into a range
function mod:clamp(val, lower, upper)
    return math.min(upper, math.max(val, lower))
end

function mod:lerp(a, b, f)
    return a*(1-f)+b*f
end

function mod:sign(a)
    if(a<0) then return -1 end
    return 1
end

---@param t table The table to count
---@return number count The number of elements in the table
---Counts the number of elements in a table
function mod:countElements(t)
    local count = 0
    for _, _ in pairs(t) do count = count+1 end

    return count
end

---@param player EntityPlayer
---@return number num
function mod:getPlayerNumFromPlayerEnt(player)
    for i=0, Game():GetNumPlayers()-1 do
        if(GetPtrHash(player)==GetPtrHash(Isaac.GetPlayer(i))) then return i end
    end
    return 0
end

function mod:getScreenCenter()
    return (Game():GetRoom():GetRenderSurfaceTopLeft()*2+Vector(442,286))/2
end
function mod:getScreenBottomRight()
    return Game():GetRoom():GetRenderSurfaceTopLeft()*2+Vector(442,286)
end

function mod:addCustomStrawman(playerType, cIndex)
    playerType=playerType or 0
    cIndex=cIndex or 0
    local LastPlayerIndex=Game():GetNumPlayers()-1
    if LastPlayerIndex>=63 then return nil else
        Isaac.ExecuteCommand('addplayer '..playerType..' '..cIndex)
        local strawman=Isaac.GetPlayer(LastPlayerIndex+1)
        strawman.Parent=Isaac.GetPlayer(0)
        Game():GetHUD():AssignPlayerHUDs()
        return strawman
    end
end

---true players just means they're not strawman-like characters
function mod:isTruePlayer(player)
    return (player.Parent==nil)
end

function mod:getNumberOfTruePlayers()
    local c = 0
    for _, player in ipairs(Isaac.FindByType(1)) do
        if(mod:isTruePlayer(player)) then c=c+1 end
    end
    return c
end

function mod:getTruePlayers()
    local idx = 0
    local p = {}
    for i=0, Game():GetNumPlayers()-1 do
        local player = Isaac.GetPlayer(i)
        if(mod:isTruePlayer(player)) then
            p[idx] = player
            idx=idx+1
        end
    end

    return p
end

function mod:getTruePlayerNumFromPlayerEnt(player)
    for pIdx, p in pairs(mod:getTruePlayers()) do
        if(GetPtrHash(player)==GetPtrHash(p)) then return pIdx end
    end

    return -1
end

---@param f Font
---@param str string
---@param maxlength number
function mod:separateStringIntoLines(f, str, maxlength)
    local fStrings = {}
    local splitStrings = {}

    for s in str:gmatch("([^ ]+)") do
        splitStrings[#splitStrings+1] = s
    end

    local st = ""

    for _, s in ipairs(splitStrings) do
        if(f:GetStringWidth(st.." "..s)>maxlength) then
            fStrings[#fStrings+1] = st
            st=s
        else
            st=st.." "..s
        end
    end

    fStrings[#fStrings+1] = st

    return fStrings
end

---@param pos Vector
function mod:closestPlayer(pos)
	local entities = Isaac.FindByType(1)
	local closestEnt = Isaac.GetPlayer()
	local closestDist = 2^32
	for i = 1, #entities do
		if not entities[i]:IsDead() then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]:ToPlayer()
			end
		end
	end
	return closestEnt
end

function mod:toTps(n)
    return 30/(n+1)
end
function mod:toFireDelay(n)
    return (30/n)-1
end
function mod:getTps(player)
    return 30/(player.MaxFireDelay+1)
end

function mod:addTps(player, n)
    return (30/(30/(player.MaxFireDelay+1)+n))-1
end

function mod:renderingAboveWater()
    return Game():GetRoom():GetRenderMode()==RenderMode.RENDER_NORMAL or Game():GetRoom():GetRenderMode()==RenderMode.RENDER_WATER_ABOVE
end

function mod:getKeyFromVal(table, val)
    for key, v in pairs(table) do
        if(v==val) then return key end
    end
    return nil
end

function mod:setBaited(e, s, d)
    e:AddBaited(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_BAITED)
    e:SetBaitedCountdown(d)
end
function mod:getBaitedFrames(e) return e:GetBaitedCountdown() end
function mod:setBleeding(e, s, d)
    e:AddBleeding(EntityRef(s), 1)
    e:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
    e:SetBleedingCountdown(d)
end
function mod:getBleedingFrames(e) return e:GetBaitedCountdown() end
function mod:setBrimstoneMark(e, s, d)
    e:AddBrimstoneMark(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_BRIMSTONE_MARKED)
    e:SetBrimstoneMarkCountdown(d)
end
function mod:getBrimstoneMarkFrames(e) return e:GetBaitedCountdown() end
function mod:setBurn(e, s, d, dmg)
    e:AddBurn(EntityRef(s),1, dmg)
    e:AddEntityFlags(EntityFlag.FLAG_BURN)
    e:SetBurnCountdown(d)
end
function mod:getBurnFrames(e) return e:GetBleedingCountdown() end
function mod:setCharmed(e, s, d)
    e:AddCharmed(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_CHARM)
    e:SetCharmedCountdown(d)
end
function mod:getCharmedFrames(e) return e:GetCharmedCountdown() end
function mod:setConfusion(e, s, d, ignoreBoss)
    e:AddConfusion(EntityRef(s),1,ignoreBoss or false)
    e:AddEntityFlags(EntityFlag.FLAG_CONFUSION)
    e:SetConfusionCountdown(d)
end
function mod:getConfusionFrames(e) return e:GetConfusionCountdown() end
function mod:setFear(e, s, d)
    e:AddFear(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_FEAR)
    e:SetFearCountdown(d)
end
function mod:getFearFrames(e) return e:GetFearCountdown() end
function mod:setFreeze(e, s, d)
    e:AddFreeze(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_FREEZE)
    e:SetFreezeCountdown(d)
end
function mod:getFreezeFrames(e) return e:GetFreezeCountdown() end
function mod:setIce(e, s, d)
    e:AddIce(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_ICE)
    e:SetIceCountdown(d)
end
function mod:getIceFrames(e) return e:GetIceCountdown() end
function mod:setKnockback(e, s, d, direction, takeImpact)
    e:AddKnockback(s,direction,1,takeImpact)
    e:SetKnockbackCountdown(d)
end
function mod:getKnockbackFrames(e) return e:GetKnockbackCountdown() end
function mod:setMagnetized(e, s, d)
    e:AddMagnetized(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_MAGNETIZED)
    e:SetMagnetizedCountdown(d)
end
function mod:getMagnetizedFrames(e) return e:GetMagnetizedCountdown() end
function mod:setMidasFreeze(e, s, d)
    e:AddMidasFreeze(EntityRef(s),d-e:GetMidasFreezeCountdown())
end
function mod:getMidasFreezeFrames(e) return e:GetMidasFreezeCountdown() end
function mod:setPoison(e, s, d, dmg)
    e:AddPoison(EntityRef(s), 1, dmg)
    e:AddEntityFlags(EntityFlag.FLAG_POISON)
    e:SetPoisonCountdown(d)
end
function mod:getPoisonFrames(e) return e:GetPoisonCountdown() end
function mod:setShrink(e, s, d)
    e:AddShrink(EntityRef(s),1)
    e:AddEntityFlags(EntityFlag.FLAG_SHRINK)
    e:SetShrinkCountdown(d)
end
function mod:getShrinkFrames(e) return e:GetShrinkCountdown() end
function mod:setSlowing(e, s, d, val, color)
    e:AddSlowing(EntityRef(s), 1, val, color)
    e:SetSlowingCountdown(d)
end
function mod:getSlowingFrames(e) return e:GetSlowingCountdown() end
function mod:setWeakness(e, s, d)
    e:AddWeakness(EntityRef(s), 1)
    e:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
    e:SetWeaknessCountdown(d)
end
function mod:getWeaknessFrames(e) return e:GetWeaknessCountdown() end

function mod:getHeartHudPosition(playerNum)
    if(playerNum==0) then
        return Vector(48,11)+Vector(20,12)*Options.HUDOffset
    elseif(playerNum==1) then
        return Vector(-111+Isaac.GetScreenWidth(), 11)+Vector(-24,12)*Options.HUDOffset
    elseif(playerNum==2) then
        return Vector(58,-28+Isaac.GetScreenHeight())+Vector(22,-6)*Options.HUDOffset
    elseif(playerNum==3) then
        return Vector(-111+Isaac.GetScreenWidth(),-28+Isaac.GetScreenHeight())+Vector(-24,-6)*Options.HUDOffset
    end
    return Vector(-100,-100)
end

---@param entity Entity
function mod:isValidEnemy(entity)
    return (entity:IsEnemy() and entity:IsVulnerableEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY))
end
function mod:getAllValidEnemies()
    local t = {}
    for i, e in ipairs(Isaac.GetRoomEntities()) do
        if(mod:isValidEnemy(e)) then table.insert(t, e:ToNPC()) end
    end
    return t
end

function mod:closestEnemy(pos)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		if mod:isValidEnemy(entities[i]) then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]
			end
		end
	end
	return closestEnt
end

function mod:closestVisibleEnemy(pos)
	local entities = Isaac.GetRoomEntities()
	local closestEnt = nil
	local closestDist = 2^32

	for i = 1, #entities do
		if(mod:isValidEnemy(entities[i]) and Game():GetRoom():CheckLine(pos, entities[i].Position, 1)) then
			local dist = (entities[i].Position - pos):LengthSquared()
			if dist < closestDist then
				closestDist = dist
				closestEnt = entities[i]
			end
		end
	end
	return closestEnt
end

function mod:getEntFromPtrHash(entity)
	if entity then
		if entity.Entity then entity = entity.Entity end
		for _, e in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType)) do
			if GetPtrHash(entity) == GetPtrHash(e) then
				return e
			end
		end
	end
	return nil
end

function mod:getPlayerFromTear(tear)
	local pEnt = tear.Parent or tear.SpawnerEntity
	if(pEnt) then
		if(pEnt.Type==EntityType.ENTITY_PLAYER) then
			return mod:getEntFromPtrHash(pEnt):ToPlayer(), false
		elseif(pEnt.Type==EntityType.ENTITY_FAMILIAR and pEnt.Variant==FamiliarVariant.INCUBUS) then
            if(pEnt.Variant==FamiliarVariant.INCUBUS) then
                return pEnt:ToFamiliar().Player:ToPlayer(), true
            elseif(pEnt.Variant==FamiliarVariant.TWISTED_BABY) then
                return pEnt:ToFamiliar().Player:ToPlayer(), true
            end
		end
	end
	return nil, false
end

function mod:addInvincibility(player, amount)
    player:SetMinDamageCooldown(player:GetDamageCooldown()+amount)
end

---@param seed integer?
---@return RNG
function mod:generateRng(seed)
    seed = seed or Random()
    if(seed<=0) then seed=1 end

    local rng = RNG()
    rng:SetSeed(seed)

    return rng
end

function mod:getLuckAffectedChance(luck, baseChance, maxLuck, maxChance)
    local f = luck/maxLuck
    f = mod:clamp(f, -1, 1)

    if(f==0) then return baseChance;
    elseif(f<0) then return mod:lerp(baseChance,0,-f)
    else return mod:lerp(baseChance,maxChance or 1,f) end
end

function mod:getTearPoofVariantFromTear(tear)
    local s = tear:ToTear().Scale
    local h = tear:ToTear().Height

	if(s > 0.8) then
		if(h < -5) then
			return EffectVariant.TEAR_POOF_A    -- Wall impact
		else
			return EffectVariant.TEAR_POOF_B    -- Floor impact
		end
	elseif(s > 0.4) then
		return EffectVariant.TEAR_POOF_SMALL
	else
		return EffectVariant.TEAR_POOF_VERYSMALL
	end
end

function mod:getRandomFreePos()
    local r = Game():GetRoom()
    local p
    local failsafe = 1000

    repeat
        p = r:GetRandomPosition(80)
        failsafe = failsafe-1
    until(failsafe<=0 or r:GetGridCollisionAtPos(p)==GridCollisionClass.COLLISION_NONE)

    return p
end

function mod:isRoomClear()
    return (Game():GetRoom():IsClear() and not Game():GetRoom():IsAmbushActive())
end

function mod:isTearCopyingFamiliar(fam)
    local copyFam = {
        [FamiliarVariant.INCUBUS]=true,
        [FamiliarVariant.SPRINKLER]=true,
        [FamiliarVariant.TWISTED_BABY]=true,
        [FamiliarVariant.BLOOD_BABY]=true, --clot
        [FamiliarVariant.UMBILICAL_BABY]=true, --gello
        [FamiliarVariant.CAINS_OTHER_EYE]=true,
    }

    return (copyFam[fam.Variant]==true)
end

function mod:trinketIsTrinketType(pickup, trinkettype)
    return (pickup.SubType==trinkettype) or (pickup.SubType==trinkettype+TrinketType.TRINKET_GOLDEN_FLAG)
end

---@param player EntityPlayer
function mod:isInHallowedAura(player)
    local hallowedAuraNums = 0
    local starAuraNums = 0

    for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND)) do
        if(effect.Parent and (effect.Parent.Type == EntityType.ENTITY_POOP or (effect.Parent.Type == EntityType.ENTITY_FAMILIAR and effect.Parent.Variant == FamiliarVariant.DIP))) then
            local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 70 / 2) + player.Size
            if(player.Position:Distance(effect.Position) < scale) then
                hallowedAuraNums = hallowedAuraNums+1
            end
        elseif(effect.Parent and effect.Parent.Type == EntityType.ENTITY_FAMILIAR and effect.Parent.Variant == FamiliarVariant.STAR_OF_BETHLEHEM) then
            local scale = 70 + player.Size
            if(player.Position:Distance(effect.Position) < scale) then
                starAuraNums = starAuraNums + 1
            end
        end
    end

    return {hallowedAuraNums,starAuraNums}
end
---@param player EntityPlayer
function mod:isInHallowedCreep(player)
    local auranum = 0
    for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.CREEP_LIQUID_POOP)) do
        effect = effect:ToEffect()
        local scale = ((effect.SpriteScale.X + effect.SpriteScale.Y) * 36 / 2)
        if effect.State == 64 and player.Position:Distance(effect.Position) <= scale then
            auranum = auranum + 1
        end
    end
    return auranum
end

function mod:getVanillaDamageMultAtPriority(player, priority)
    local mult = 1
    local auraData = mod:isInHallowedAura(player)
    if(priority<=1) then
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_ODD_MUSHROOM_THIN)) then mult = mult*0.9 end
    end
    if(priority<=4) then
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) and not (player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) or player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER))) then mult = mult*2 end
        if(player:GetPlayerType()==PlayerType.PLAYER_EVE and not player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_WHORE_OF_BABYLON)) then mult = mult*0.75 end
        local playerMults = {
            [PlayerType.PLAYER_MAGDALENE_B] = 0.75,
            [PlayerType.PLAYER_BLUEBABY] = 1.05,
            [PlayerType.PLAYER_KEEPER] = 1.2,
            [PlayerType.PLAYER_CAIN] = 1.2,
            [PlayerType.PLAYER_CAIN_B] = 1.2,
            [PlayerType.PLAYER_EVE_B] = 1.2,
            [PlayerType.PLAYER_JUDAS] = 1.35,
            [PlayerType.PLAYER_AZAZEL] = 1.5,
            [PlayerType.PLAYER_THEFORGOTTEN] = 1.5,
            [PlayerType.PLAYER_AZAZEL_B] = 1.5,
            [PlayerType.PLAYER_THEFORGOTTEN_B] = 1.5,
            [PlayerType.PLAYER_LAZARUS2_B] = 1.5,
            [PlayerType.PLAYER_LAZARUS2] = 1.4,
            [PlayerType.PLAYER_THELOST_B] = 1.3,
            [PlayerType.PLAYER_BLACKJUDAS] = 2,
        }
        mult = mult*(playerMults[player:GetPlayerType()] or 1)
    end
    if(priority<=6) then
        if(player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MEGA_MUSH)) then mult = mult*4 end
    end
    if(priority<=8) then
        if((player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE)>=2 and not player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA))) then mult=mult*1.2 end
        if((player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_CROWN_OF_LIGHT))) then mult=mult*2 end
        if((player:HasCollectible(CollectibleType.COLLECTIBLE_SACRED_HEART))) then mult=mult*2.3 end
    end
    if(priority<=10) then
        if((player:GetPlayerType()==PlayerType.PLAYER_JUDAS or player:GetPlayerType()==PlayerType.PLAYER_BLACKJUDAS) and player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) and player:HasCollectible(CollectibleType.COLLECTIBLE_DAMOCLES_PASSIVE)) then mult=mult*1.4 end
    end
    if(priority<=12) then
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_IMMACULATE_HEART) or auraData[1]>0 or auraData[2]>0) then mult=mult*1.2 end
    end
    if(priority<=14) then
        if((player:GetPlayerType()==PlayerType.PLAYER_AZAZEL or player:GetPlayerType()==PlayerType.PLAYER_AZAZEL_B) and player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE)) then mult=mult*0.5 end
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_HAEMOLACRIA) or (player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRIMSTONE)==1 and player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY))) then mult = mult*1.5 end
    end
    if(priority<=16) then
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then mult = mult*0.8 end
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)) then mult=mult*0.3 end
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_CRICKETS_HEAD) or (player:HasCollectible(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM) or player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM)) or (player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL) and player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_OF_THE_MARTYR))) then mult=mult*1.5 end
        mult = mult*player:GetD8DamageModifier()*(1+0.125*player:GetDeadEyeCharge())
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA)) then mult = mult*2 end
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) and not player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)) then mult=mult*0.2 end
        if(auraData[2]>0) then mult=mult*1.5 end
        local counter = 0
        for _, fam in ipairs(Isaac.FindByType(3, FamiliarVariant.SUCCUBUS)) do
            if(fam.Position:Distance(player.Position)<=97.5) then counter = counter+1 end
        end
        mult = mult*(1.5^counter)
    end
    if(priority<=17) then
        if(player.Damage>3.5) then
            local crownMult = player:GetTrinketMultiplier(TrinketType.TRINKET_CRACKED_CROWN)*0.2
            if(crownMult>0) then
                mult = mult*(1+crownMult)*(player.Damage/(player.Damage+crownMult*3.5))
            end
        end
    end
    return mult
end
function mod:addBasicDamageUp(player, dmg)
    player.Damage = player.Damage+dmg*mod:getVanillaDamageMultAtPriority(player,0)
end

--thank you rat rat rat rat rat rat rat rat!!!!
---@param player EntityPlayer
function mod:getVanillaTearMultiplier(player)
    local mult = 1.0

    if player:HasWeaponType(2) then
        if(player:GetPlayerType() == PlayerType.PLAYER_AZAZEL and not player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE)) then mult = mult*0.267
        else mult = mult*0.33 end
    end
    if(player:HasWeaponType(5)) then mult = mult*0.4 end
    if(player:HasWeaponType(7)) then mult = mult*0.23 end
    if(player:HasWeaponType(9) and player:HasCollectible(CollectibleType.COLLECTIBLE_MONSTROS_LUNG)) then mult = mult*0.32 end
    if player:HasWeaponType(10) then mult = mult*0.5 end
    if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_IPECAC) > 0 then
        if not player:HasWeaponType(2) and
        not player:HasWeaponType(4) and
        not player:HasWeaponType(5) and
        not player:HasWeaponType(6) and
        not player:HasWeaponType(8) and
        not player:HasWeaponType(9) and
        not player:HasWeaponType(10) and
        not player:HasWeaponType(13) and
        not player:HasWeaponType(14) then
            mult = mult/3
        end
    end
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_ALMOND_MILK)) then mult = mult*4
    elseif(player:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK)) then mult = mult*5.5 end
    if(player:GetPlayerType() == PlayerType.PLAYER_EVE_B) then mult=mult*0.66 end
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_EVES_MASCARA)) then mult = mult*0.66 end
    if(player:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY_2)) then mult = mult*0.66 end
    if(not player:HasCollectible(CollectibleType.COLLECTIBLE_20_20)) then
        if(player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) or player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_HANGED_MAN)) then mult = mult*0.51
        elseif(player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER)) then mult = mult*0.42
        elseif(player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) and not player:HasWeaponType(14)) then mult = mult*0.42 end
    end
    if(player:GetEffects():HasNullEffect(NullItemID.ID_REVERSE_CHARIOT)) then mult = mult*4 end
    if(player:GetPlayerType() == PlayerType.PLAYER_JUDAS and player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BIRTHRIGHT) > 0 and player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_DECAP_ATTACK)) then mult = mult*3 end
    local epiphora = player:GetEpiphoraCharge()
    if(epiphora>=270) then mult = mult*2
    elseif(epiphora>=180) then mult = mult*(5/3)
    elseif(epiphora>=90) then mult = mult*(4/3) end
    mult = mult*player:GetD8FireDelayModifier()

    local creepdata = mod:isInHallowedCreep(player)
    local auraData = mod:isInHallowedAura(player)
    if(auraData[1]>0 or auraData[2]>0 or creepdata>0) then mult = mult*2.5 end

    return mult
end
function mod:addBasicTearsUp(player, tears)
    player.MaxFireDelay = mod:addTps(player, tears*mod:getVanillaTearMultiplier(player))
end

local SPEED_MULT = 10

---@param entity Entity
function mod:isScared(entity)
    return (entity:HasEntityFlags(EntityFlag.FLAG_FEAR) or entity:HasEntityFlags(EntityFlag.FLAG_SHRINK))
end

---@param entity Entity
function mod:isConfused(entity)
    return (entity:HasEntityFlags(EntityFlag.FLAG_CONFUSION))
end

function mod:getWalkAnimPlaybackSpeed(entity, speed, isMoving)
    if(not isMoving) then return 1 end

    return entity.Velocity:Length()/(speed)
end

---@param entity EntityNPC
---@param speed number
function mod:walkAnimLogic(entity, speed, walkAnimTb)
    local isWalking = mod:isNpcWalking(entity)
    if(isWalking and entity.Velocity:LengthSquared()>0.01) then
        local currAnim = entity:GetSprite():GetAnimation()

        local selAnim = ""

        if(math.abs(entity.Velocity.Y)>math.abs(entity.Velocity.X)) then
            if(entity.Velocity.Y>0) then selAnim=(walkAnimTb[1] or walkAnimTb)
            else selAnim=(walkAnimTb[3] or walkAnimTb[1] or walkAnimTb) end
        else
            if(entity.Velocity.X>0) then selAnim=(walkAnimTb[2] or walkAnimTb[1] or walkAnimTb)
            else selAnim=(walkAnimTb[4] or walkAnimTb[2] or walkAnimTb[1] or walkAnimTb) end
        end

        if(selAnim~=currAnim) then
            entity:GetSprite():Play(selAnim,true)
        end
    end

    entity:GetSprite().PlaybackSpeed = mod:getWalkAnimPlaybackSpeed(entity, speed, isWalking)
end

---@param entity EntityNPC
function mod:isNpcWalking(entity)
    local anim = entity:GetSprite():GetAnimation()

    if(string.sub(anim,1,4)~="Walk" or entity.FrameCount==1) then return false end
    return true
end

---@param entity EntityNPC
---@param target Entity|Vector
---@param speed number
function mod:pathfindingEnemyLogic(entity, target, speed, lerpVal, shouldCheckDist, isConstantlyAfraid)
    if(mod:isNpcWalking(entity)) then
        local targetPos = ((target.X~=nil) and target) or target.Position
        local newPos = mod:getEntityData(entity, "targetPos")

        local isScared = mod:isScared(entity)
        local isConfused = mod:isConfused(entity)

        if(isConstantlyAfraid) then
            if(shouldCheckDist) then
                if(targetPos:Distance(entity.Position)<60) then
                    isScared=true
                else
                    isConfused=true
                    speed=speed*0.5
                end
            else
                isScared=true
            end
        end

        local gridCountdown = mod:getEntityData(entity, "gridCountdown") or 0

        if(isScared) then
            newPos = entity.Position+(entity.Position-targetPos)
        elseif(isConfused) then
            if(not newPos or entity:IsFrame(25, 0)) then
                newPos = Game():GetRoom():GetRandomPosition(0)
            end
        else
            newPos = target.Position
        end

        mod:setEntityData(entity, "targetPos", newPos)

        if(entity.Pathfinder:HasPathToPos(newPos, false) or (isScared or isConfused)) then
            local distCheck = true
            if(shouldCheckDist) then
                local dist = newPos:Distance(entity.Position)
                distCheck=((dist>=100) or (dist<100 and not Game():GetRoom():CheckLine(entity.Position, newPos, 0, 0, false, false)))
            end

            if((entity:CollidesWithGrid() or gridCountdown>0) and distCheck) then

                entity.Pathfinder:FindGridPath(newPos, speed, 1, false)
                mod:setEntityData(entity, "gridCountdown", gridCountdown)
            else return mod:lerp(entity.Velocity, (newPos - entity.Position):Resized(speed*SPEED_MULT), lerpVal) end
        else return entity.Velocity*0.5 end
    end

    mod:walkAnimLogic(entity, speed)
end

function mod:angleDifference(a1, a2)
    local dif = (a2-a1)%360
    if(dif>180) then return dif-360 end
    return dif
end

local SHOOT_ACTIONS = {
    ButtonAction.ACTION_SHOOTDOWN,
    ButtonAction.ACTION_SHOOTLEFT,
    ButtonAction.ACTION_SHOOTUP,
    ButtonAction.ACTION_SHOOTRIGHT,
}
function mod:isHoldingShootingInput(player)
    local idx = player.ControllerIndex
    for _, action in pairs(SHOOT_ACTIONS) do
        if(Input.IsActionPressed(action, idx)) then
            return true
        end
    end
    return false
end

function mod:isPlayerShooting(player)
    return (player:GetShootingInput():LengthSquared()>0.001) or mod:isHoldingShootingInput(player)
end

---@param bomb EntityBomb
function mod:getBombRadius(bomb)
    local radius
    if(bomb.Variant==BombVariant.BOMB_GIGA or bomb.Variant==BombVariant.BOMB_ROCKET_GIGA or bomb.Flags & TearFlags.TEAR_GIGA_BOMB ~= TearFlags.TEAR_NORMAL) then
        radius = 130.0
    else
        if(bomb.ExplosionDamage>=175.0) then
            radius = 105.0
        else
            if(bomb.ExplosionDamage<=140.0) then
                radius = 75.0
            else
                radius = 90.0
            end
        end
    end

    return radius*bomb.RadiusMultiplier
end