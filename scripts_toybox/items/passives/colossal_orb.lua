
local sfx = SFXManager()

local DMG_UP = 1
local SPEED_UP = -0.2
local SIZE_UP = 1.33

local TIMER_DUR = 30
local MAX_DIST = 40*40
local CONCUSS_DURATION = 30*4

---@param pl EntityPlayer
---@param flag CacheFlag
local function evalCache(_, pl, flag)
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_COLOSSAL_ORB)) then return end
    local mult = pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_COLOSSAL_ORB)

    if(flag==CacheFlag.CACHE_SPEED) then
        pl.MoveSpeed = pl.MoveSpeed+SPEED_UP*mult
    elseif(flag==CacheFlag.CACHE_DAMAGE) then
        ToyboxMod:addBasicDamageUp(pl, DMG_UP*mult)
    elseif(flag==CacheFlag.CACHE_SIZE) then
        pl.SpriteScale = pl.SpriteScale*(SIZE_UP^mult)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local function shockwaveOnEntry(_)
    local room = Game():GetRoom()
    if(room:IsClear()) then return end

    local isBoss = (Game():GetRoom():GetType()==RoomType.ROOM_BOSS)
    local bossTimeMod = 5

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_COLOSSAL_ORB)) then
            if(not isBoss) then
                sfx:Play(ToyboxMod.SOUND_EFFECT.COLOSSAL_ORB_SHOCKWAVE)
            end

            Isaac.CreateTimer(
                ---@param effect EntityEffect
                function(effect)
                    if(isBoss) then
                        if(effect.FrameCount==1) then
                            sfx:Play(ToyboxMod.SOUND_EFFECT.COLOSSAL_ORB_SHOCKWAVE)
                        end
                        if(effect.FrameCount<=bossTimeMod) then return end
                    elseif(effect.FrameCount~=1) then
                        return
                    end

                    Game():MakeShockwave(pl.Position, 0.075, 0.05, TIMER_DUR)
                    effect.Position = pl.Position

                    Isaac.CreateTimer(
                    ---@param timer EntityEffect
                    function(timer)
                        local prevDist = MAX_DIST*(timer.FrameCount-1)/TIMER_DUR
                        local curDist = MAX_DIST*(timer.FrameCount)/TIMER_DUR

                        local enemies = Isaac.FindInRadius(effect.Position, curDist, EntityPartition.ENEMY)
                        --print("A",timer.FrameCount, #enemies, prevDist, curDist)

                        for _, ent in pairs(enemies) do
                            --print("B", timer.FrameCount, ToyboxMod:getEntityData(ent, "ORB_CONCUSSED"), prevDist, ent.Position:Distance(effect.Position), curDist, "|", ent.Type, ent.Variant)

                            if(not ToyboxMod:getEntityData(ent, "ORB_CONCUSSED") and ent.Position:Distance(effect.Position)>=prevDist) then
                                ToyboxMod:setEntityData(ent, "ORB_CONCUSSED", true)
                                ent:AddConfusion(EntityRef(pl), CONCUSS_DURATION, true)
                            end
                        end

                    end, 1, TIMER_DUR, false
                    )
                end, 1, 2+bossTimeMod, false
            )
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, shockwaveOnEntry)