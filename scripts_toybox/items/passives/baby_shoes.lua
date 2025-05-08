local mod = ToyboxMod

local SPEED_UP = 0.1
local ROOM_CLEAR_SPEED_UP = 0.5

---@param pl EntityPlayer
local function evalCache(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE.BABY_SHOES)) then return end

    local mult = pl:GetCollectibleNum(mod.COLLECTIBLE.BABY_SHOES)
    pl.MoveSpeed = pl.MoveSpeed+mult*SPEED_UP+(mod:isRoomClear() and ROOM_CLEAR_SPEED_UP or 0)
end
mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache, CacheFlag.CACHE_SPEED)

local function evalCacheOnNewRoom()
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(mod.COLLECTIBLE.BABY_SHOES)) then
            pl:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, evalCacheOnNewRoom)

local function evalCacheOnRoomClear()
    Isaac.CreateTimer(
        function()
            for i=0, Game():GetNumPlayers()-1 do
                local pl = Isaac.GetPlayer(i)
                if(pl:HasCollectible(mod.COLLECTIBLE.BABY_SHOES)) then
                    pl:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
                end
            end
        end,
        1, 1, false
    )
end
mod:AddCallback(ModCallbacks.MC_PRE_ROOM_TRIGGER_CLEAR, evalCacheOnRoomClear)