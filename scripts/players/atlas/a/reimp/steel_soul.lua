local mod = MilcomMOD
local sfx = SFXManager()

local SHIELD_CHANCE = 1--0.25

local function addMantle(_, idx, mtype, pl)
    if(mtype==mod.MANTLE_DATA.NONE.ID) then return end
    if(not pl:HasCollectible(mod.COLLECTIBLE.STEEL_SOUL)) then return end
    local adata = mod:getAtlasATable(pl)
    idx = math.min(idx, adata.HP_CAP)
    if(adata.MANTLES[idx].HP<adata.MANTLES[idx].MAXHP) then return end

    mod:setMantleHeartData(pl, idx, "SOUL_SHIELD", (pl:GetCollectibleRNG(mod.COLLECTIBLE.STEEL_SOUL):RandomFloat()<SHIELD_CHANCE and 1 or nil))
end
mod:AddCallback(mod.CUSTOM_CALLBACKS.POST_ATLAS_ADD_MANTLE, addMantle)

---@param pl EntityPlayer
local function destroySoulShields(_, pl, dmg, flags, source, frames)
    pl = pl:ToPlayer()
    if(not mod:isAtlasA(pl)) then return end

    local adata = mod:getAtlasATable(pl)
    local disposableDmg = dmg
    local numDamageRemoved = 0
    local rightIdx = mod:getRightmostMantleIdx(pl)
    if(rightIdx<=0) then return end

    while(disposableDmg>0 and rightIdx>0) do
        local soulBit = mod:getMantleHeartData(pl, rightIdx, "SOUL_SHIELD")
        if(soulBit==1) then
            disposableDmg = disposableDmg-1
            numDamageRemoved = numDamageRemoved+1
            mod:setMantleHeartData(pl, rightIdx, "SOUL_SHIELD", nil)
        end
        disposableDmg = disposableDmg-adata.MANTLES[rightIdx].HP
        rightIdx = rightIdx-1
    end
    
    if(numDamageRemoved>0) then
        sfx:Play(mod.SOUND_EFFECT.ATLASA_METALBLOCK)
        Game():ShakeScreen(5)

        return {
            Damage=dmg-numDamageRemoved,
            DamageFlags=flags,
            DamageCountdown=frames,
        }
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, 1e12-2+(CustomHealthAPI and (-1e12-1e3) or 0), destroySoulShields, EntityType.ENTITY_PLAYER)