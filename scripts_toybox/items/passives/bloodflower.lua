local sfx = SFXManager()

local NUM_BOSS_HEALS = 1
local RED_HEAL = 2
local SOUL_HEAL = 1

local REVISIT_LENIENCY = 3

---@param npc EntityNPC
local function tryHeal(_, npc)
    local numFlowers = PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_BLOODFLOWER)
    if(numFlowers==0) then return end
    numFlowers = numFlowers*NUM_BOSS_HEALS+1

    local desc = Game():GetLevel():GetCurrentRoomDesc()
    local visitCount = desc.VisitedCount
    if((visitCount>REVISIT_LENIENCY+1) or (visitCount>1 and ToyboxMod:generateRng(desc.SpawnSeed):RandomFloat()<(visitCount-1)/REVISIT_LENIENCY)) then return end

    local barFill = Game():GetHUD():GetBossHPBarFill()
    local data = ToyboxMod:getExtraDataTable(npc)

    if(barFill<0 or not math.tointeger(barFill//1)) then
        data.BLOODFLOWER_LASTHP = nil
        return
    else
        data.BLOODFLOWER_LASTHP = data.BLOODFLOWER_LASTHP or 1

        local curThres = math.max(1, math.ceil(barFill*numFlowers))
        local lastThres = math.ceil(data.BLOODFLOWER_LASTHP*numFlowers)

        if(curThres<lastThres) then
            local healAmount = lastThres-curThres
            for i=0, Game():GetNumPlayers()-1 do
                local pl = Isaac.GetPlayer(i)

                local healGfx = 0
                local missingHp = math.ceil((pl:GetEffectiveMaxHearts()-pl:GetHearts())/RED_HEAL)
                if(missingHp>0) then
                    pl:AddHearts(missingHp*RED_HEAL)
                    healGfx = 0
                end
                if(missingHp<healAmount) then
                    pl:AddSoulHearts((healAmount-missingHp)*SOUL_HEAL)
                    healGfx = 4
                end

                local notif = Isaac.Spawn(1000, EffectVariant.HEART, healGfx, pl.Position, Vector.Zero, pl):ToEffect()
                notif.SpriteOffset = Vector(0, -38)
                --notif:FollowParent(pl)

                sfx:Play(SoundEffect.SOUND_VAMP_GULP)
            end
        end

        data.BLOODFLOWER_LASTHP = barFill
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, tryHeal)