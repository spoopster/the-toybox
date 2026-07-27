-- i hate mango

local ITEMS_TO_TAKE = 1/2
local TOTAL_HEALTH_TO_ADD = 6

local CLONE_COSTUME = Isaac.GetCostumeIdByPath("gfx_tb/characters/costume_clone.anm2")

---@param player EntityPlayer
local function triggerRevives(_, player)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_CLONE)) then
        player:Revive()

        player:AddHearts(-1)
        player:AddSoulHearts(-1)
        player:AddHearts(math.min(player:GetEffectiveMaxHearts(), TOTAL_HEALTH_TO_ADD))
        player:AddSoulHearts(math.max(0, TOTAL_HEALTH_TO_ADD-player:GetHearts()))
        player:RemoveCollectible(ToyboxMod.COLLECTIBLE_CLONE)

        local newPlayer = player:InitTwin(PlayerType.PLAYER_ESAU)
        newPlayer:TryRemoveNullCostume(NullItemID.ID_ESAU)
        newPlayer:AddNullCostume(CLONE_COSTUME)

        newPlayer:AddHearts(-99)
        newPlayer:AddMaxHearts(-99)
        newPlayer:AddSoulHearts(-99)
        newPlayer:AddMaxHearts(player:GetMaxHearts())
        newPlayer:AddHearts(player:GetHearts())
        newPlayer:AddSoulHearts(player:GetSoulHearts())

        local history = player:GetHistory():GetCollectiblesHistory()
        local conf = Isaac.GetItemConfig()
        local items = {}
        for i=1, #history do
            local iconf = conf:GetCollectible(history[i]:GetItemID())
            if(not history[i]:IsTrinket() and iconf and iconf.Type~=ItemType.ITEM_ACTIVE) then
                table.insert(items, {history[i]:GetItemID(), history[i]:GetItemPoolType()})
            end
        end

        local rng = player:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_CLONE)
        local numitems = (#items * ITEMS_TO_TAKE)//1
        for _=1, numitems do
            local idx = rng:RandomInt(1,#items)
            local picked = items[idx]
            
            newPlayer:AddCollectible(picked[1], nil, false, nil, nil, picked[2])
            table.remove(items, idx)
        end

        EntitySaveStateManager.GetEntityData(ToyboxMod, newPlayer).CLONE_PLAYER = true
        newPlayer:AddCacheFlags(CacheFlag.CACHE_COLOR, 1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_TRIGGER_PLAYER_DEATH_POST_CHECK_REVIVES, triggerRevives)

-- for the cosutme
---@param pl EntityPlayer
local function evalColorCache(_, pl)
    if(not (EntitySaveStateManager.GetEntityData(ToyboxMod, pl).CLONE_PLAYER)) then return end

    pl.Color = pl.Color*Color(0.65,1.05,0.5, 1, 0, 0, 0, 0.9, 1, 0.7, 0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalColorCache, CacheFlag.CACHE_COLOR)

-- for the cosutme
---@param pl EntityPlayer
local function plUpdate(_, pl)
    if(not (EntitySaveStateManager.GetEntityData(ToyboxMod, pl).CLONE_PLAYER)) then return end

    pl:TryRemoveNullCostume(NullItemID.ID_ESAU)
    local sp = pl:GetSprite()
    if(sp:GetLayer(0):GetSpritesheetPath()~="gfx_tb/characters/costumes/costume_clone.png") then
        for i=0, 14 do
            if(i~=13) then
                sp:ReplaceSpritesheet(i, "gfx_tb/characters/costumes/costume_clone.png", false)
            end
        end
        sp:LoadGraphics()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, plUpdate)

local function postNewRoom(_)
    for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(EntitySaveStateManager.GetEntityData(ToyboxMod, pl).CLONE_PLAYER) then
            local ogPos = pl.Position
            pl.Position = pl:GetMainTwin().Position+RandomVector()
            for _, ent in ipairs(Isaac.FindByType(3)) do
                local fam = ent:ToFamiliar()
                if(fam and GetPtrHash(fam.Player)==GetPtrHash(pl)) then
                    if(fam.IsFollower) then
                        fam.Position = pl.Position
                    else
                        fam.Position = fam.Position+(pl.Position-ogPos)
                    end
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, postNewRoom)