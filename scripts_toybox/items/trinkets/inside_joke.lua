local sfx = SFXManager()

local DMG_PER_MULT = 0.5
local ROOMS_TO_ADD = 3
local EXTRAROOMS_PER_MULT = 2

---@param player EntityPlayer
local function evalCache(_, player, _)
    if(not player:HasTrinket(ToyboxMod.TRINKET_INSIDE_JOKE)) then return end
    if((ToyboxMod:getEntityData(player, "INSIDE_JOKE_ROOMS") or 0)~=0) then return end

    local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_INSIDE_JOKE)
    player.Damage = player.Damage*(1+DMG_PER_MULT*mult)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE, evalCache, CacheFlag.CACHE_DAMAGE)

local function increaseLionMark(_)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasTrinket(ToyboxMod.TRINKET_INSIDE_JOKE)) then
            local data = ToyboxMod:getEntityDataTable(pl)
            if(data.INSIDE_JOKE_ROOMS==1) then
                sfx:Play(SoundEffect.SOUND_THUMBSUP)
            end
            data.INSIDE_JOKE_ROOMS = math.max(0, (data.INSIDE_JOKE_ROOMS or 0)-1)

            pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)
        end
    end
end
ToyboxMod:AddCallback(ToyboxMod.CUSTOM_CALLBACKS.POST_ROOM_CLEAR, increaseLionMark)

---@param ent Entity
local function applyPenalty(_, ent, _, flags, source)
    local player = ent:ToPlayer() ---@type EntityPlayer
    if(not player:HasTrinket(ToyboxMod.TRINKET_INSIDE_JOKE)) then return end
    if((ToyboxMod:getEntityData(player, "INSIDE_JOKE_ROOMS") or 0)~=0) then return end

    if(source.Type==6) then return end
    if(flags & (DamageFlag.DAMAGE_FAKE | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IV_BAG | DamageFlag.DAMAGE_CLONES | DamageFlag.DAMAGE_INVINCIBLE)~=0) then return end

    local mult = player:GetTrinketMultiplier(ToyboxMod.TRINKET_INSIDE_JOKE)

    local data = ToyboxMod:getEntityDataTable(player)
    data.INSIDE_JOKE_ROOMS = (data.INSIDE_JOKE_ROOMS or 0)+(ROOMS_TO_ADD+(mult-1)*EXTRAROOMS_PER_MULT)

    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

    sfx:Play(SoundEffect.SOUND_THUMBS_DOWN)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, applyPenalty, EntityType.ENTITY_PLAYER)