local sfx = SFXManager()

local COUNTER_CHANCE = 0.15

local MAX_COUNTERS = 20
local EXTRA_COUNTER_MULT = 0.5

local COUNTER_FONT = Font()
COUNTER_FONT:Load("font/pftempestasevencondensed.fnt")
local COUNTER_SPRITE = Sprite()
COUNTER_SPRITE:Load("gfx_tb/ui/ui_blood_money.anm2")
COUNTER_SPRITE:Play("Idle", true)

local EID_OFFSET = "KnifeBloodMoney"
local EID_POS_OFFSET = Vector(0,8)

---@param num integer
function ToyboxMod:addBloodMoney(num)
    local maxNum = MAX_COUNTERS*math.max(1,(PlayerManager.GetNumCollectibles(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)-1)*EXTRA_COUNTER_MULT+1)//1
    ToyboxMod:setExtraData("BLOOD_MONEY_COUNTERS", math.min(maxNum, (ToyboxMod:getExtraData("BLOOD_MONEY_COUNTERS") or 0)+num)//1)

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)
        if(pl:HasCollectible(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)) then
            local eff = pl:GetEffects()
            local numToAdd = (ToyboxMod:getExtraData("BLOOD_MONEY_COUNTERS") or 0)--*pl:GetCollectibleNum(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)
            eff:RemoveCollectibleEffect(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE, -1)
            eff:AddCollectibleEffect(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE, nil, numToAdd)
        end
    end
end

local ignoreCollision = false

---@param pl EntityPlayer
---@param coll Entity
---@param low boolean
local function tryUseBloodCoins(_, pl, coll, low)
    if(ignoreCollision) then return end
    if(not pl:HasCollectible(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)) then return end

    local pickup = coll:ToPickup()
    if(pickup and pickup.Price>0) then
        local counters = ToyboxMod:getExtraData("BLOOD_MONEY_COUNTERS") or 0
        if(counters>0 and pickup.Price<=pl:GetNumCoins()+counters and pickup.Price<=pl:GetMaxCoins()) then
            local numCountersToRemove = 0
            if(pickup.Price<=counters) then
                numCountersToRemove = pickup.Price
            else
                numCountersToRemove = counters
            end

            local remainder = pl:GetNumCoins()-(pickup.Price-numCountersToRemove)

            local priceOverCoinNum = pickup.Price-pl:GetNumCoins()
            if(priceOverCoinNum>0) then
                pl:AddCoins(priceOverCoinNum)
            end

            local coinsHad = pl:GetNumCoins()

            ignoreCollision = true
            local worked = pl:ForceCollide(coll, low)
            ignoreCollision = false

            if(coinsHad~=pl:GetNumCoins()) then
                ToyboxMod:addBloodMoney(-numCountersToRemove)
                pl:AddCoins(remainder-pl:GetNumCoins())
            elseif(priceOverCoinNum>0) then
                pl:AddCoins(-priceOverCoinNum)
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, tryUseBloodCoins)

---@param npc EntityNPC
local function giveBloodCoin(_, npc)
    local pl = PlayerManager.FirstCollectibleOwner(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)
    if(not pl) then return end

    if(pl:GetCollectibleRNG(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE):RandomFloat()<COUNTER_CHANCE) then
        ToyboxMod:addBloodMoney(1)

        local maxdist = npc.Position:Distance(pl.Position)
        local dir = (pl.Position-npc.Position):Normalized()
        local pos = npc.Position
        while(pos:Distance(pl.Position)>20) do
            local particle = Isaac.Spawn(1000,111,0,pos,Vector.Zero,nil):ToEffect()
            particle.SpriteScale = Vector.One*((1-pos:Distance(pl.Position)/maxdist)*0.6+0.1)
            particle.Color = Color(0,0,0,1,200/255,0,0,2)
            particle:GetSprite():SetCustomShader("spriteshaders/pixelateshader")

            pos = pos+dir*20
        end

        local eff = Isaac.Spawn(1000,ToyboxMod.EFFECT_BLOOD_COLLECT,0,npc.Position,Vector.Zero,nil)
        
        local poof = Isaac.Spawn(1000,16,5,pl.Position,Vector.Zero,nil)
        poof.SpriteScale = Vector(1,1)*0.5
        poof.Color = Color(0,0,0,1,200/255,0,0,2)
        poof:GetSprite().PlaybackSpeed = 1.25
        poof:GetSprite():SetCustomShader("spriteshaders/pixelateshader")

        sfx:Play(SoundEffect.SOUND_PENNYPICKUP,nil,nil,nil,0.7)
        sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, giveBloodCoin)

---@param pl EntityPlayer
local function addKnife(_, pl)
    ToyboxMod:addBloodMoney(0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, addKnife, ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)

---@param pl EntityPlayer
local function removeKnife(_, pl)
    ToyboxMod:addBloodMoney(0)
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_TRIGGER_COLLECTIBLE_REMOVED, removeKnife, ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)

---@param player EntityPlayer
local function checkHasModifier(_, player)
    if(EID) then
        if(PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)) then
            EID:addTextPosModifier(EID_OFFSET, EID_POS_OFFSET)
        else
            EID:removeTextPosModifier(EID_OFFSET)
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_UPDATE, checkHasModifier)

---@param player EntityPlayer
local function renderStat(_, player, offset)
    if(not PlayerManager.AnyoneHasCollectible(ToyboxMod.COLLECTIBLE_ETZNAB_KNIFE)) then return end

    local maxnum = MAX_COUNTERS
    local num = (ToyboxMod:getExtraData("BLOOD_MONEY_COUNTERS") or 0)//1

    local rPos = Vector(35,34)+ToyboxMod:getExtraHudOffset()

    COUNTER_SPRITE:Render(rPos)

    local str = tostring(math.tointeger(num))
    for _=math.log(math.max(num,1),10)//1+1,math.log(math.max(maxnum,1),10)//1 do
        str = "0"..str
    end
    COUNTER_FONT:DrawString(str, rPos.X+16, rPos.Y+1, KColor(1,1,1,1))
end
ToyboxMod:AddCallback(ModCallbacks.MC_HUD_RENDER, renderStat)