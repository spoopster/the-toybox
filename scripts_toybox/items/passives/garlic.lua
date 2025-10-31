
local AURA_SIZE_MULT = 3

local LASER_AURA_RENDERS = 12
local LASER_AURA_ALPHA = 0.12

---@param player EntityPlayer
---@param flag CacheFlag
local function evalCache(_, player, flag)
    if(flag==CacheFlag.CACHE_TEARCOLOR) then
        player.TearColor = Color.TearScorpio
        player.LaserColor = Color.LaserPoison
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, evalCache)

local alreadyRendering = false

---@param laser EntityLaser
---@param offset Vector
local function renderLaserAura(_, laser, offset)
    if(alreadyRendering) then return end
    alreadyRendering = true

    local ogColor = laser.Color
    local ogScale = laser.SpriteScale

    local newCol = ToyboxMod:cloneColor(Color.LaserPoison)
    newCol.A = newCol.A*LASER_AURA_ALPHA
    laser.Color = newCol

    local maxscale = AURA_SIZE_MULT
    local numrenders = LASER_AURA_RENDERS
    for i=numrenders,1,-1 do
        local scl = maxscale*i/numrenders
        laser.SpriteScale = laser.SpriteScale*scl
        
        laser:Render(offset+Vector((math.random()*2-1)*1, (math.random()*2-1)*1))

        laser.SpriteScale = laser.SpriteScale/scl
    end

    laser.SpriteScale = ogScale

    ogColor.A = ogColor.A*0.5
    laser.Color = ogColor

    laser:Render(offset)

    ogColor.A = ogColor.A/0.5
    laser.Color = ogColor

    alreadyRendering = false
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, renderLaserAura)