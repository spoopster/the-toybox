local mod = ToyboxMod
local sfx = SFXManager()

local SPIN_RESULT_DELAY = 30

local SPIN_COSTUME = Isaac.GetCostumeIdByPath("gfx/characters/tb_costume_gambling_addiction_spin.anm2")

local ROLL_CHANCE = 0.25

local NOTHING_CHANCE = 0.5
local NOTHING_CHANCE_FOOT = 0.33

local DROP_SPREAD = 45

local FLY_SPREAD = 2
local HEART_SPREAD = 2
local COIN_SPREAD = 3

local RESULTS = {
    FLY = 1,
    BOMB = 2,
    KEY = 3,
    HEARTS = 4,
    COINS = 5,
    PILL = 6,
}
local RESULT_PICKER = WeightedOutcomePicker()
RESULT_PICKER:AddOutcomeFloat(RESULTS.BOMB, 1)
RESULT_PICKER:AddOutcomeFloat(RESULTS.KEY, 1)
RESULT_PICKER:AddOutcomeFloat(RESULTS.HEARTS, 2)
RESULT_PICKER:AddOutcomeFloat(RESULTS.COINS, 3)
RESULT_PICKER:AddOutcomeFloat(RESULTS.PILL, 0.5)
RESULT_PICKER:AddOutcomeFloat(RESULTS.FLY, 1)

local function dir2Angle(x)
    if(x==Direction.DOWN) then return 90
    elseif(x==Direction.LEFT) then return 180
    elseif(x==Direction.UP) then return 270
    else return 0 end
end

---@param pl EntityPlayer
function mod:rollForReward(pl)
    local data = mod:getEntityDataTable(pl)
    data.GAMBLING_ADDICTION_QUEUED_SPINS = (data.GAMBLING_ADDICTION_QUEUED_SPINS or 0)+1
end

---@param pl EntityPlayer
local function updateAddictionRoll(_, pl)
    if(not pl:HasCollectible(mod.COLLECTIBLE.GAMBLING_ADDICTION)) then return end

    local data = mod:getEntityDataTable(pl)

    if(data.GAMBLING_ADDICTION_TIMER==0) then
        data.GAMBLING_ADDICTION_QUEUED_SPINS = data.GAMBLING_ADDICTION_QUEUED_SPINS or 0
        if(data.GAMBLING_ADDICTION_QUEUED_SPINS>0 and pl:IsExtraAnimationFinished()) then
            data.GAMBLING_ADDICTION_TIMER = SPIN_RESULT_DELAY
            data.GAMBLING_ADDICTION_QUEUED_SPINS = data.GAMBLING_ADDICTION_QUEUED_SPINS-1

            pl:AddNullCostume(SPIN_COSTUME)

            pl:SetHeadDirection(Direction.DOWN, SPIN_RESULT_DELAY, true)
            pl:SetCanShoot(false)
            --pl:TryRemoveCollectibleCostume(mod.COLLECTIBLE.GAMBLING_ADDICTION)
            sfx:Play(SoundEffect.SOUND_COIN_SLOT)
        end
    else
        data.GAMBLING_ADDICTION_TIMER = (data.GAMBLING_ADDICTION_TIMER or 1)-1
        if(data.GAMBLING_ADDICTION_TIMER==1) then
            pl:TryRemoveNullCostume(SPIN_COSTUME)
            pl:UpdateCanShoot()

            local rng = pl:GetCollectibleRNG(mod.COLLECTIBLE.GAMBLING_ADDICTION)
            local nothingChance = (pl:HasCollectible(CollectibleType.COLLECTIBLE_LUCKY_FOOT) and NOTHING_CHANCE_FOOT or NOTHING_CHANCE)

            if(rng:RandomFloat()<nothingChance) then
                --pl:AnimateSad()
                sfx:Play(SoundEffect.SOUND_SCAMPER)
            else
                local outcome = RESULT_PICKER:PickOutcome(rng)

                local aimDir = pl:GetHeadDirection()
                if(aimDir==Direction.NO_DIRECTION) then aimDir = Direction.DOWN end

                local aimVector = Vector.FromAngle(dir2Angle(aimDir))*3

                if(outcome==RESULTS.BOMB) then
                    local dir = aimVector:Rotated(rng:RandomInt(-DROP_SPREAD,DROP_SPREAD))
                    local bomb = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_BOMB,0,pl.Position,dir,pl):ToPickup()
                elseif(outcome==RESULTS.KEY) then
                    local dir = aimVector:Rotated(rng:RandomInt(-DROP_SPREAD,DROP_SPREAD))
                    local key = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_KEY,0,pl.Position,dir,pl):ToPickup()
                elseif(outcome==RESULTS.COINS) then
                    local num = rng:RandomInt(COIN_SPREAD)+1
                    for _=1,num do
                        local dir = aimVector:Rotated(rng:RandomInt(-DROP_SPREAD,DROP_SPREAD))
                        local coin = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COIN,0,pl.Position,dir,pl):ToPickup()
                    end
                elseif(outcome==RESULTS.HEARTS) then
                    local num = rng:RandomInt(HEART_SPREAD)+1
                    for _=1,num do
                        local dir = aimVector:Rotated(rng:RandomInt(-DROP_SPREAD,DROP_SPREAD))
                        local heart = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_HEART,0,pl.Position,dir,pl):ToPickup()
                    end
                elseif(outcome==RESULTS.FLY) then
                    local num = rng:RandomInt(FLY_SPREAD)+1
                    pl:AddBlueFlies(num, pl.Position, nil)
                elseif(outcome==RESULTS.PILL) then
                    local dir = aimVector:Rotated(rng:RandomInt(-DROP_SPREAD,DROP_SPREAD))
                    local pill = Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_PILL,0,pl.Position,dir,pl):ToPickup()
                end

                --pl:AnimateHappy()
                sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, updateAddictionRoll)

local function tryRollMachine(_, npc)
    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)

        if(pl:HasCollectible(mod.COLLECTIBLE.GAMBLING_ADDICTION)) then
            local rng = pl:GetCollectibleRNG(mod.COLLECTIBLE.GAMBLING_ADDICTION)

            if(rng:RandomFloat()<ROLL_CHANCE) then
                mod:rollForReward(pl)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, tryRollMachine)


---@param pickup EntityPickup
local function replaceItemSprite(_, pickup)
    if(pickup.SubType~=mod.COLLECTIBLE.GAMBLING_ADDICTION) then return end

    local sp = pickup:GetSprite()
    if(sp:GetLayer(1):GetSpritesheetPath()=="gfx/items/collectibles/tb_gambling_addiction.png") then
        local anim, oAnim, oFrame = sp:GetAnimation(), sp:GetOverlayAnimation(), sp:GetOverlayFrame()

        sp:Load("gfx/pickups/tb_pickup_gambling_addiction.anm2", true)
        sp:Play(anim, true)
        sp:PlayOverlay(oAnim, true)
        sp:SetOverlayFrame(oFrame)
        sp:StopOverlay()
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, replaceItemSprite, PickupVariant.PICKUP_COLLECTIBLE)

---@param pl EntityPlayer
local function updateAddictionSprite(_, pl)
    if(not pl:IsHeldItemVisible()) then return end

    local sp = pl:GetHeldSprite()
    if(sp:GetFilename()=="gfx/005.100_Collectible.anm2") then
        if(sp:GetLayer(1):GetSpritesheetPath()=="gfx/items/collectibles/tb_gambling_addiction.png") then
            local anim, oAnim, oFrame = sp:GetAnimation(), sp:GetOverlayAnimation(), sp:GetOverlayFrame()

            sp:Load("gfx/pickups/tb_pickup_gambling_addiction.anm2", true)
            sp:Play(anim, true)
            sp:PlayOverlay(oAnim, true)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, updateAddictionSprite)