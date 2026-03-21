local KANYE_TIME_LIMIT = 3600*30
local KANYE_STARTROOM_SPAWN = 30*2

local KANYE_SPIN_FREQ = 40

local function trySpawnKanye(_)
    if(Game():GetFrameCount()>=KANYE_TIME_LIMIT) then
        local room = Game():GetRoom()
        if(room:GetFrameCount()==KANYE_STARTROOM_SPAWN) then
            local doorpos = room:GetDoorSlotPosition(Game():GetLevel().EnterDoor)
            local kanye = Isaac.Spawn(1000, ToyboxMod.EFFECT_KANYE, 0, doorpos, Vector.Zero, nil)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_UPDATE, trySpawnKanye)

---@param effect EntityEffect
local function kanyeInit(_, effect)
    effect.SpriteOffset = Vector(0, -27)

    local sp = effect:GetSprite()
    sp:SetCustomShader("spriteshaders/sphereshader")
    sp:Play("Idle", true)
    sp.Color = Color(1,0,0,1,0,0,0,1,1,1,(Game():GetFrameCount()/KANYE_SPIN_FREQ)%1)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, kanyeInit, ToyboxMod.EFFECT_KANYE)

---@param effect EntityEffect
local function kanyeUpdate(_, effect)
    local sp = effect:GetSprite()
    sp.Color = Color(1,0,0,1,0,0,0,1,1,1,(Game():GetFrameCount()/KANYE_SPIN_FREQ)%1)

    for _, ent in ipairs(Isaac.FindInRadius(effect.Position, effect.Size, EntityPartition.PLAYER)) do
        if(ent:ToPlayer() and not ent:IsDead()) then
            for _=1, 30 do
                ent:TakeDamage(100, DamageFlag.DAMAGE_INVINCIBLE, EntityRef(effect),0)
                ent:ToPlayer():ResetDamageCooldown()
            end
        end
    end

    local closest = ToyboxMod:closestPlayer(effect.Position)
    if(closest) then
        local dir = (closest.Position-effect.Position)
        local maxlen = 1
        local len = dir:Length()

        local maxfastdist = 40*5
        local fastdist = 40*3
        local fastspeed = 7

        local regspeed = 1
        
        if(len>fastdist) then
            if(len<=maxfastdist) then
                dir:Resize(regspeed+(fastspeed-regspeed)*(len-fastdist)/(maxfastdist-fastdist))
            else
                dir:Resize(fastspeed)
            end
            
        elseif(len>regspeed) then
            dir:Resize(regspeed)
        end

        effect.Velocity = dir
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, kanyeUpdate, ToyboxMod.EFFECT_KANYE)