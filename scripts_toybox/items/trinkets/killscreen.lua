local KILLSCREEN_DMG = 1
local KILLSCREEN_FREQ = 15

local NUM_GLITCHES = 2

local function dealKillscreenDMG(_)
    local totalMult = PlayerManager.GetTotalTrinketMultiplier(ToyboxMod.TRINKET_KILLSCREEN)
    if(totalMult<=0) then return end

    local dv = 1+(totalMult-1)/2
    local freq = math.max(1, KILLSCREEN_FREQ//dv)
    if(Game():GetFrameCount()%freq~=0) then return end

    local room = Game():GetRoom()
    local centerX = Game():GetRoom():GetCenterPos().X

    local shouldSpawnGlitch = true
    if(shouldSpawnGlitch) then
        local topLeft = Vector(centerX, room:GetTopLeftPos().Y)+Vector(20,-60)
        local bottomRight = room:GetBottomRightPos()+Vector(80,80)

        local rng = PlayerManager.FirstTrinketOwner(ToyboxMod.TRINKET_KILLSCREEN):GetTrinketRNG(ToyboxMod.TRINKET_KILLSCREEN)

        for i=1,NUM_GLITCHES do
            local selPos = Vector(rng:RandomInt(topLeft.X, bottomRight.X), rng:RandomInt(topLeft.Y, bottomRight.Y))

            local gridSize = 24

            selPos.X = math.floor(selPos.X/gridSize)*gridSize
            selPos.Y = math.floor(selPos.Y/gridSize)*gridSize

            local sub = math.floor(freq*(i-1)/NUM_GLITCHES)
            local glitch = Isaac.Spawn(1000, ToyboxMod.EFFECT_VARIANT.KILLSCREEN_GLITCH, sub, selPos, Vector.Zero, nil):ToEffect()
            glitch.SpriteOffset = Vector(rng:RandomInt(0,1), rng:RandomInt(0,1))*8
        end
    end

    

    for _, ent in ipairs(Isaac.GetRoomEntities()) do
        local npc = ent:ToNPC()
        if(npc and ToyboxMod:isValidEnemy(npc)) then
            if(npc.Position.X>=centerX) then
                npc:TakeDamage(KILLSCREEN_DMG, 0, EntityRef(PlayerManager.FirstTrinketOwner(ToyboxMod.TRINKET_KILLSCREEN)), 0)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, dealKillscreenDMG)



---@param effect EntityEffect
local function glitchInit(_, effect)
    local rng = effect:GetDropRNG()

    local lifespan = 40+rng:RandomInt(30) -- approx lifespan
    local numChanges = rng:RandomInt(8)+2

    local changeFreq = math.ceil(lifespan/numChanges)

    effect.State = changeFreq
    effect:SetTimeout(changeFreq*numChanges+effect.SubType)

    if(effect.SubType~=0) then
        effect:SetColor(Color(1,1,1,0), effect.SubType, 1, false, false)
    end

    effect.DepthOffset = 10000

    local sp = effect:GetSprite()
    local len = sp:GetAnimationData("Idle"):GetLength()
    sp:SetFrame("Idle", rng:RandomInt(len))
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, glitchInit, ToyboxMod.EFFECT_VARIANT.KILLSCREEN_GLITCH)

---@param effect EntityEffect
local function glitchUpdate(_, effect)
    local sp = effect:GetSprite()
    local rng = effect:GetDropRNG()

    if((effect.FrameCount-effect.SubType)%effect.State==0) then
        local len = sp:GetCurrentAnimationData():GetLength()
        sp:SetFrame(rng:RandomInt(len))
    end

    if(effect.Timeout==0) then
        effect:Remove()
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, glitchUpdate, ToyboxMod.EFFECT_VARIANT.KILLSCREEN_GLITCH)