local MANTLE_FREQ = 60*30
local STACK_FREQ_REDUCE = 10*30
local MIN_FREQ = 15*30

local function postAddCollectible(_, _, _, firstTime, _, _, player)
    if(firstTime) then
        player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddCollectible, ToyboxMod.COLLECTIBLE_NANOMACHINES)

local function postPeffectUpdate(_, player)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_NANOMACHINES)) then
        if(player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)) then return end

        local freq = math.max(MIN_FREQ, MANTLE_FREQ-STACK_FREQ_REDUCE*(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_NANOMACHINES)-1))
        if(ToyboxMod.GAME.TimeCounter%freq==0) then
            ToyboxMod.SFX:Play(ToyboxMod.SFX_SHATTER_REVERSE)
            Isaac.CreateTimer(function()
                if(not player) then return end
                local mantlePoof = Isaac.Spawn(1000,16,11,player.Position,player.Velocity,player):ToEffect()
                mantlePoof:FollowParent(player)

                local sp = mantlePoof:GetSprite()
                sp:Load("gfx_tb/effects/effect_holy_mantle_poof_reverse.anm2", true)
                sp:Play("Idle", true)
                mantlePoof.DepthOffset = player.DepthOffset+10
            end, 15, 1, true)
            Isaac.CreateTimer(function()
                if(not player) then return end
                player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true)
                player:AddNullItemEffect(NullItemID.ID_HOLY_CARD, true)
            end, 25, 1, true)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, postPeffectUpdate)