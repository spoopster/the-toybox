local INTERNAL_ACTIVE_CHARGE = 10000

local DMG_TO_CHARGE = 300
local DMG_SOFT_CAP = 50
local SOFT_CAP_POW = 1--0.5

local DMG_MULT_PER_FLOOR = 0.2
--[[] ]
local DMG_REQ_PER_FLOOR = 60
local CAP_SCALE_PER_FLOOR = 10
--]]

local STAT_UPS = 2
local STAT_DOWNS = 1
local POSSIBLE_MODIFIERS = {
    "Damage",
    "FireDelay",
    "Luck",
    "ShotSpeed",
    "Speed",
    "TearRange",
}

---@param player EntityPlayer
---@param slot ActiveSlot
local function useXenotransfusion(_, _, rng, player, flags, slot)
    local usedModifiers = {}

    for i=1, STAT_UPS+STAT_DOWNS do
        local pickModifier
        while(not pickModifier) do
            pickModifier = rng:RandomInt(1, #POSSIBLE_MODIFIERS)
            if(usedModifiers[pickModifier]) then
                pickModifier = nil
            end
        end
        usedModifiers[pickModifier] = true

        local modifString = POSSIBLE_MODIFIERS[pickModifier].."Modifier"
        player["Set"..modifString](player, player["Get"..modifString](player)+(i<=STAT_UPS and 1 or -1))
    end
    player:AddCacheFlags(CacheFlag.CACHE_ALL, true)

    player:AddHearts(2)

    ToyboxMod.SFX:Play(SoundEffect.SOUND_HEARTOUT)

    local poof = Isaac.Spawn(1000,16,5,player.Position,Vector.Zero,nil)
    poof.SpriteScale = Vector(1,1)*0.5
    poof.DepthOffset = -80
    poof.SpriteOffset = Vector(0,-12*player.SpriteScale.Y)
    poof.Color = Color(0,0,0,1,200/255,0,0,2)
    poof:GetSprite().PlaybackSpeed = 1.25
    poof:GetSprite():SetCustomShader("shaders_tb/pixelate")

    local poof2 = Isaac.Spawn(1000,16,0,player.Position,Vector.Zero,nil)
    poof2.SpriteScale = Vector(1,1)*0.5
    poof2.DepthOffset = 10
    poof2.SpriteOffset = Vector(0,-12*player.SpriteScale.Y)
    poof2.Color = Color(1,0,0,1,255/255,0,0,2)
    poof2:GetSprite().PlaybackSpeed = 1.25
    poof2:GetSprite():SetCustomShader("shaders_tb/pixelate")

    return {
        Discharge = true,
        Remove = false,
        ShowAnim = true,
    }
end
ToyboxMod:AddCallback(ModCallbacks.MC_USE_ITEM, useXenotransfusion, ToyboxMod.COLLECTIBLE_XENOTRANSFUSION)

---@param dmg number
---@return integer
local function getValueToCharge(dmg)
    local level = ToyboxMod.GAME:GetLevel()
    local stage = level:GetAbsoluteStage()

    local dmgcap = DMG_SOFT_CAP*(1+DMG_MULT_PER_FLOOR*(stage-1))
    local dmgreq = DMG_TO_CHARGE*(1+DMG_MULT_PER_FLOOR*(stage-1))

    local data = ToyboxMod:getExtraDataTable().XENOTRANSFUSION_DAMAGE_COUNTER
    data = data or {}

    local idx = tostring(level:GetCurrentRoomDesc().SafeGridIndex)
    data[idx] = data[idx] or 0

    local olddmg = math.min(dmgcap, data[idx])+math.max(0, data[idx]-dmgcap)^SOFT_CAP_POW
    local newdmg = math.min(dmgcap, data[idx]+dmg)+math.max(0, data[idx]+dmg-dmgcap)^SOFT_CAP_POW

    data[idx] = data[idx]+dmg
    ToyboxMod:setExtraData("XENOTRANSFUSION_DAMAGE_COUNTER", data)

    return ((newdmg-olddmg)/dmgreq*INTERNAL_ACTIVE_CHARGE)//1
end

local function addChargeOnDmg(_, ent, dmg, _, _, _)
    if(ToyboxMod:isValidEnemy(ent)) then
        local charge = getValueToCharge(dmg)

        for _, player in ipairs(PlayerManager.GetPlayers()) do
            if(player and player:HasCollectible(ToyboxMod.COLLECTIBLE_XENOTRANSFUSION)) then
                local slot = player:GetActiveItemSlot(ToyboxMod.COLLECTIBLE_XENOTRANSFUSION)
                player:AddActiveCharge(charge, slot, false, false, true)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, addChargeOnDmg)


local function markRoomSubtypes(_)
    if(not ToyboxMod.GAME:GetRoom():IsFirstVisit()) then return end

    ToyboxMod:setExtraData("XENOTRANSFUSION_DAMAGE_COUNTER", {})
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, markRoomSubtypes)


---@param player EntityPlayer
---@param slot ActiveSlot
---@param offset Vector
---@param a number
---@param scale Vector
---@param chargeOffset Vector
local function renderUnder(_, player, slot, offset, a, scale, chargeOffset)
    if(slot==-1) then return end

    local chargeSprite = ToyboxMod.GAME:GetHUD():GetChargeBarSprite()
    local ogAnim = chargeSprite:GetAnimation() -- should usually be the charge overlay animation

    local charges = {player:GetActiveCharge(slot), player:GetBatteryCharge(slot)}
    local colors = {Color(1.5,1,1,a,0,0,0,1.5,0.4,0.3,1), Color(1.5,1.33,1,a,0,0,0,1.5,1,0.3,1)}

    for i, charge in ipairs(charges) do
        if(charge~=0) then
            local maxCharges = player:GetActiveMaxCharge(slot)
            local currentCharges = charge

            local topRightClamp = Vector(0,3+(maxCharges-currentCharges)*23/maxCharges)
            local botrightClamp = Vector(0,6)

            chargeSprite:Play("BarFull", true)

            chargeSprite.Color = colors[i]
            chargeSprite:Render(chargeOffset, topRightClamp, botrightClamp)

            chargeSprite.Color = Color(0,0,0,a*0.33,0,0,0,40*player.FrameCount/30,0,0)
            chargeSprite:SetCustomShader("shaders_tb/ripple")
            chargeSprite:Render(chargeOffset, topRightClamp, botrightClamp)
            chargeSprite:ClearCustomShader()
        end
    end

    chargeSprite.Color = Color(1,1,1,a)

    chargeSprite:Play(ogAnim, true)
    chargeSprite:Render(chargeOffset)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_ACTIVE_ITEM, renderUnder, ToyboxMod.COLLECTIBLE_XENOTRANSFUSION)