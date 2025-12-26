local sfx = SFXManager()

--- TODO : MAKE THEM NOT TWEAK OUT done!

local SHADOW_CAP = 5
local CAP_INCREASE_STACK = 1

local MOVE_DELAY = 15

---@param familiar EntityFamiliar
local function shadowInit(_, familiar)
    local idx = 1

    local pl = (familiar.SpawnerEntity and familiar.SpawnerEntity:ToPlayer() or Isaac.GetPlayer())
    local plHash = GetPtrHash(pl)
    for _, otherFam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_EVIL_SHADOW)) do
        otherFam = otherFam:ToFamiliar() ---@cast otherFam EntityFamiliar

        if(GetPtrHash(otherFam.Player)==plHash) then
            idx = idx+1
        end
    end

    familiar.SubType = idx
    familiar.Player = pl

    familiar:AddToDelayed()

    familiar:GetSprite():Play("WalkDown", true)
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, shadowInit, ToyboxMod.FAMILIAR_EVIL_SHADOW)

---@param familiar EntityFamiliar
local function shadowUpdate(_, familiar)
    familiar:MoveDelayed(MOVE_DELAY)

    local vLen = familiar.Velocity:Length()
    local standingStill = (vLen<1)
    local flying = familiar.Player:IsFlying()

    local dir = (standingStill and Direction.DOWN or math.floor((familiar.Velocity:GetAngleDegrees()+225)%360/90))
    local dirStr = ({"Left", "Up", "Right", "Down"})[dir+1]
    local finalMoveStr = (flying and "Fly" or "Walk") .. dirStr

    local sp = familiar:GetSprite()

    familiar.SpriteOffset = (flying and Vector(0,-4) or Vector.Zero)

    if(finalMoveStr ~= sp:GetAnimation()) then
        local fr = sp:GetFrame()
        sp:Play(finalMoveStr, true)
        sp:SetFrame(fr)
    end
    sp.PlaybackSpeed = (flying and 1 or (standingStill and 0 or vLen/10))

    if(not flying and standingStill and sp:GetFrame()>0) then
        sp:SetFrame(0)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, shadowUpdate, ToyboxMod.FAMILIAR_EVIL_SHADOW)

local function fixOnNewRoom(_)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_EVIL_SHADOW)) do
        fam = fam:ToFamiliar() ---@cast fam EntityFamiliar
        fam:SetMoveDelayNum(-1)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, fixOnNewRoom)

---@param player Entity
local function spawnShadow(_, player, _, flags, source)
    player = player:ToPlayer()
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_BLACK_SOUL)) then return end

    local numShadows = 0
    local plHash = GetPtrHash(player)
    for _, otherFam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_EVIL_SHADOW)) do
        otherFam = otherFam:ToFamiliar() ---@cast otherFam EntityFamiliar

        if(GetPtrHash(otherFam.Player)==plHash) then
            numShadows = numShadows+1
        end
    end

    local cap = SHADOW_CAP+(player:GetCollectibleNum(ToyboxMod.COLLECTIBLE_BLACK_SOUL)-1)*CAP_INCREASE_STACK

    if(numShadows<cap) then
        local shadow = Isaac.Spawn(3,ToyboxMod.FAMILIAR_EVIL_SHADOW,0,player.Position,Vector.Zero,player):ToFamiliar()
        shadow:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

        local evilEffect = Isaac.Spawn(1000,15,2,shadow.Position,Vector.Zero,shadow):ToEffect()
        evilEffect.Color = Color(0.25,0.25,0.25,1)
        sfx:Play(SoundEffect.SOUND_BEAST_FIRE_RING, 0.5, 2, false, 0.85)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, spawnShadow, EntityType.ENTITY_PLAYER)

---@param pl EntityPlayer
local function removeShadows(_, pl)
    if(pl.FrameCount==0) then return end

    local plHash = GetPtrHash(pl)
    for _, fam in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ToyboxMod.FAMILIAR_EVIL_SHADOW)) do
        fam = fam:ToFamiliar() ---@cast fam EntityFamiliar

        if(GetPtrHash(fam.Player)==plHash) then
            fam:Remove()
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, removeShadows, ToyboxMod.COLLECTIBLE_BLACK_SOUL)
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, removeShadows)