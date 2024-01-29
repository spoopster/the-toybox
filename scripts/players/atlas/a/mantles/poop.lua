local mod = MilcomMOD
local sfx = SFXManager()

mod.ATLAS_A_MANTLESUBTYPES[mod.CONSUMABLE_MANTLE_POOP] = true

local function useMantle(_, _, player, _)
    if(player:GetPlayerType()==mod.PLAYER_ATLAS_A) then
        mod:giveMantle(player, mod.MANTLES.POOP)
    else

    end
end
mod:AddCallback(ModCallbacks.MC_USE_CARD, useMantle, mod.CONSUMABLE_MANTLE_POOP)

local ENUM_POOPFLIES_NUM = 2
local ENUM_POOPFLIES_CHANCE = 0.5

---@param player EntityPlayer
local function addPoopFlies(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    local data = mod:getAtlasATable(player)

    local numMantles = mod:getNumMantlesByType(player, mod.MANTLES.POOP)
    local rng = player:GetCardRNG(mod.CONSUMABLE_MANTLE_POOP)

    for _=1, numMantles do
        if(rng:RandomFloat()<ENUM_POOPFLIES_CHANCE) then player:AddBlueFlies(ENUM_POOPFLIES_NUM, player.Position, nil) end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TRIGGER_ROOM_CLEAR, addPoopFlies)

local function poopUpdate(_, poop)
    if(Game():IsPaused()) then return end
    if(poop:GetVariant()==GridPoopVariant.RED) then return end
    
    if(poop.State==1000 and poop.State~=mod:getData(poop, "POOP_DMG") and mod:getData(poop, "POOP_DMG")) then
        local shouldDoTransfEffect = false
        for _, player in ipairs(mod:getAllAtlasA()) do
            player = player:ToPlayer()
            if(mod:atlasHasTransformation(player, mod.MANTLES.POOP)) then
                local didHeal = mod:addMantleHp(player, 1)
                shouldDoTransfEffect = true

                if(didHeal) then
                    local gulpEffect = Isaac.Spawn(1000, 49, 0, player.Position, Vector.Zero, nil):ToEffect()
                    gulpEffect.SpriteOffset = Vector(0, -35)
                    gulpEffect.DepthOffset = 1000
                    gulpEffect:FollowParent(player)

                    sfx:Play(SoundEffect.SOUND_VAMP_GULP)
                end
            end
        end
        if(shouldDoTransfEffect) then
            local poof = Isaac.Spawn(1000,16,1,poop.Position,Vector.Zero,nil):ToEffect()
            local col = Color(1,1,1,1)
            col:SetColorize(0,0,0,1)
            col:SetColorize(124/255, 86/255, 52/255,1)

            poof.Color = col

            poof.SpriteScale = Vector(1,1)*0.75

            sfx:Play(SoundEffect.SOUND_FART)
        end
    end

    mod:setData(poop, "POOP_DMG", poop.State)
end
mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_POOP_UPDATE, poopUpdate)

---@param player EntityPlayer
local function playMantleSFX(_, player, mantle)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end

    sfx:Play(mod.SFX_ATLASA_ROCKBREAK)
end
mod:AddCallback("ATLAS_POST_LOSE_MANTLE", playMantleSFX, mod.MANTLES.POOP)