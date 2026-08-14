local NUM_ROTTEN_HEARTS = 1

local HITS_PER_REVIVE = 3
local MAX_HITS = 9

local COUNTER_FONT = Font()
COUNTER_FONT:Load("font/pftempestasevencondensed.fnt")

---@param player EntityPlayer
---@return integer
local function getFrankencatHits(player)
    local numHits = player:GetExtraLives()*HITS_PER_REVIVE
    if(player:HasChanceRevive()) then
        local rng = ToyboxMod:generateRng(ToyboxMod.GAME:GetSeeds():GetStageSeed(ToyboxMod.GAME:GetLevel():GetStage()))
        numHits = numHits+rng:RandomInt(0,HITS_PER_REVIVE)
    end

    return math.min(MAX_HITS, numHits)
end

---@param player EntityPlayer
---@param firstTime boolean
local function postAddFrankencat(_, _, _, firstTime, _, _, player)
    if(firstTime) then
        player:AddRottenHearts(NUM_ROTTEN_HEARTS*2)

        local data = ToyboxMod:getEntityDataTable(player)
        data.FRANKENCAT_MAXHITS = 0
        data.FRANKENCAT_HITS = 0
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddFrankencat, ToyboxMod.COLLECTIBLE_FRANKENCAT)

---@param player EntityPlayer
---@param firstTime boolean
local function addCollectibleCheckForRevives(_, _, _, firstTime, _, _, player)
    if(firstTime and player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKENCAT)) then
        local revives = getFrankencatHits(player)

        local data = ToyboxMod:getEntityDataTable(player)
        if((data.FRANKENCAT_MAXHITS or 0)<revives) then
            data.FRANKENCAT_HITS = (data.FRANKENCAT_HITS or 0)+revives-(data.FRANKENCAT_MAXHITS or 0)
            data.FRANKENCAT_MAXHITS = revives
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addCollectibleCheckForRevives)

---@param player EntityPlayer
local function refreshFreeHits(_, player)
    if(player.FrameCount==0) then return end
    if(not player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKENCAT)) then return end

    local revives = getFrankencatHits(player)

    local data = ToyboxMod:getEntityDataTable(player)
    data.FRANKENCAT_HITS = revives
    data.FRANKENCAT_MAXHITS = revives
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_LEVEL, refreshFreeHits)

---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param countdown integer
local function makeFakeDamage(_, ent, amount, flags, _, countdown)
    if(flags & DamageFlag.DAMAGE_FAKE == DamageFlag.DAMAGE_FAKE) then return end

    local player = (ent and ent:ToPlayer())
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKENCAT))) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    if((data.FRANKENCAT_HITS or 0)>0) then
        data.FRANKENCAT_BLOCKED = player.FrameCount

        return {
            Damage = amount,
            DamageFlags = flags | DamageFlag.DAMAGE_FAKE,
            DamageCountdown = countdown
        }
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, CallbackPriority.EARLY, makeFakeDamage, EntityType.ENTITY_PLAYER)

---@param ent Entity
local function checkIfFaked(_, ent, _, _, _, _)
    local player = (ent and ent:ToPlayer())
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKENCAT))) then return end

    local data = ToyboxMod:getEntityDataTable(player)
    if(data.FRANKENCAT_BLOCKED==player.FrameCount) then
        data.FRANKENCAT_BLOCKED = nil
        data.FRANKENCAT_HITS = math.max(0, (data.FRANKENCAT_HITS or 0)-1)

        local poof = Isaac.Spawn(1000,16,5,player.Position,Vector.Zero,nil)
        poof.SpriteScale = Vector(1,1)*0.5
        poof.Color = Color(0,0,0,1,200/255,0,0,2)
        poof.DepthOffset = poof.DepthOffset+5
        poof.SpriteOffset = poof.SpriteOffset+Vector(0,-12)*player.SpriteScale.Y
        poof:GetSprite().PlaybackSpeed = 1.25
        poof:GetSprite():SetCustomShader("shaders_tb/pixelate")

        ToyboxMod.SFX:Play(SoundEffect.SOUND_DEATH_BURST_SMALL)
        ToyboxMod.SFX:Play(ToyboxMod.SFX_MEOW, 0.7, nil, nil, 1.1-0.25*(1-data.FRANKENCAT_HITS/(data.FRANKENCAT_MAXHITS or 1)))
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, checkIfFaked, EntityType.ENTITY_PLAYER)

---@param player EntityPlayer
local function cancelAllRevives(_, player)
    if(player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKENCAT)) then
        return false
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_REVIVE, cancelAllRevives)

---@param player EntityPlayer
---@param pos Vector
---@param offset Vector
local function renderFrankencatHits(_, offset, sprite, pos, x, player)
    if(not (player and player:HasCollectible(ToyboxMod.COLLECTIBLE_FRANKENCAT))) then return end
    if(ToyboxMod.GAME:GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN == LevelCurse.CURSE_OF_THE_UNKNOWN) then return end

    local pIdx = player:GetPlayerIndex()
    if(pIdx==-1) then return end

    local pHud = nil
    local hud = ToyboxMod.GAME:GetHUD()
    for i=0, 7 do
        local tempPl = hud:GetPlayerHUD(i):GetPlayer()
        if(tempPl and tempPl:GetPlayerIndex()==pIdx) then
            pHud = hud:GetPlayerHUD(i)
            break
        end
    end
    if(not pHud) then return end
    ---@cast pHud PlayerHUD

    local data = ToyboxMod:getEntityDataTable(player)

    local maxIdx = -1
    for i, heart in ipairs(pHud:GetHearts()) do
        if(heart:IsVisible()) then
            maxIdx = math.max(maxIdx, i)
        end
    end
    local hasMantle = (maxIdx==(player:GetHeartLimit()//2)) and player:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)

    offset = offset-Vector(2,0)+(hasMantle and Vector(12, 0) or Vector(0, 0))-Vector(0,6)*((maxIdx-1)//6-1)
    local isOnRight = (pos.X>Isaac.GetScreenWidth()/2)
    local rpos = pos+offset*(isOnRight and Vector(-1,1) or Vector(1,1))-Vector(0,26)
    rpos = rpos+ToyboxMod.GAME.ScreenShakeOffset

    --Isaac.RenderText(tostring(offset.Y), rpos.X, rpos.Y+20, 1,1,1,1)

    local baseStr = "x"..tostring(player:GetExtraLives())..(player:HasChanceRevive() and "?" or "")
    local newStr = "x"..tostring(data.FRANKENCAT_HITS or 0)
    local finalColor = 1-0.5*(1-(data.FRANKENCAT_HITS or 0)/(data.FRANKENCAT_MAXHITS or 1))

    local boxWidth = (isOnRight and 100 or 0)

    COUNTER_FONT:DrawString(baseStr, rpos.X-boxWidth, rpos.Y, KColor(0,0,0,1), boxWidth)
    COUNTER_FONT:DrawString(newStr, rpos.X-boxWidth, rpos.Y, KColor(1,finalColor,finalColor,1), boxWidth)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_PLAYERHUD_RENDER_HEARTS, renderFrankencatHits)