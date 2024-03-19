local mod = MilcomMOD
--! USELESS!!!!!

local HP_SPRITE = Sprite()
HP_SPRITE:Load("gfx/ui/atlas_a/ui_mantle_hp.anm2", true)
HP_SPRITE:Play("RockMantle", true)
HP_SPRITE.Scale = Vector(0.75,0.75)

local TRANSF_SPRITE = Sprite()
TRANSF_SPRITE:Load("gfx/ui/atlas_a/ui_mantle_transformations.anm2", true)
TRANSF_SPRITE.Color = Color(1,1,1,0.75)
TRANSF_SPRITE:Play("RockMantle", true)
TRANSF_SPRITE.Offset = Vector(0,-0.5)
TRANSF_SPRITE.Scale = Vector(0.5,0.5)

---@param player EntityPlayer
local function addMantleForHealth(_, player)
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)

    if(player:GetGoldenHearts()>0) then
        if(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE) then mod:giveMantle(player, mod.MANTLES.GOLD)
        else mod:addMantleHp(player, 2) end
    end
    if(player:GetRottenHearts()>0) then
        if(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE) then mod:giveMantle(player, mod.MANTLES.POOP)
        else mod:addMantleHp(player, 2) end
    end
    if(player:GetBoneHearts()>0) then
        if(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE) then mod:giveMantle(player, mod.MANTLES.BONE)
        else mod:addMantleHp(player, 2) end
    end
    if(player:GetEternalHearts()>0) then
        if(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE) then mod:giveMantle(player, mod.MANTLES.HOLY)
        else mod:addMantleHp(player, 2) end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.IMPORTANT, addMantleForHealth, 0)

---@param player EntityPlayer
local function postAddItem(_, item, _, firstTime, _, _, player)
    if(firstTime~=true) then return end
    if(player:GetPlayerType()~=mod.PLAYER_ATLAS_A) then return end
    local data = mod:getAtlasATable(player)

    local config = Isaac.GetItemConfig():GetCollectible(item)
    if(config==nil) then return end
    
    if(config.AddHearts>0) then mod:addMantleHp(player, config.AddHearts) end
    if(config.AddBlackHearts>0) then
        local heartNum = config.AddBlackHearts
        while(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE and heartNum>0) do
            mod:giveMantle(player, mod.MANTLES.DARK)
            heartNum = heartNum-2
        end
        if(heartNum>0) then mod:addMantleHp(player, heartNum) end
    end
    if(config.AddSoulHearts>0) then
        local heartNum = config.AddSoulHearts
        while(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE and heartNum>0) do
            mod:giveMantle(player, mod.MANTLES.METAL)
            heartNum = heartNum-2
        end
        if(heartNum>0) then mod:addMantleHp(player, heartNum) end
    end
    if(config.AddMaxHearts>0) then
        local heartNum = config.AddMaxHearts
        while(data.MANTLES[data.HP_CAP].TYPE==mod.MANTLES.NONE and heartNum>0) do
            mod:giveMantle(player, mod.MANTLES.DEFAULT)
            heartNum = heartNum-2
        end
        if(heartNum>0) then mod:addMantleHp(player, heartNum) end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, postAddItem)

local HP_WIDTH = 8

local function calcPos(idx, linesize)
    return Vector(HP_WIDTH*(idx-(linesize+1)/2),0)
end

local function postCollectibleRender(_, pickup, offset)
    if(not PlayerManager.AnyoneIsPlayerType(mod.PLAYER_ATLAS_A)) then return end
    if(Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_BLIND ~= 0) then return end

    local config = Isaac.GetItemConfig():GetCollectible(pickup.SubType)
    if(config==nil) then return end

    local hpToRender = {DarkMantle=0, MetalMantle=0, RockMantle=0}

    if(config.AddBlackHearts>0) then hpToRender["DarkMantle"] = math.ceil(config.AddBlackHearts/2) end
    if(config.AddSoulHearts>0) then hpToRender["MetalMantle"] = math.ceil(config.AddSoulHearts/2) end
    if(config.AddMaxHearts>0) then hpToRender["RockMantle"] = math.ceil(config.AddMaxHearts/2) end

    local renderPos = Isaac.WorldToScreen(pickup.Position)+Vector(0,7)
    local lineSize = hpToRender["DarkMantle"]+hpToRender["MetalMantle"]+hpToRender["RockMantle"]

    if(lineSize==0) then return end

    TRANSF_SPRITE:Render(renderPos+calcPos(0, lineSize))

    if(hpToRender["DarkMantle"]>0) then
        HP_SPRITE:Play("DarkMantle", true)
        for i=1, hpToRender["DarkMantle"] do
            HP_SPRITE:Render(renderPos+calcPos(i, lineSize))
        end
    end
    if(hpToRender["MetalMantle"]>0) then
        HP_SPRITE:Play("MetalMantle", true)
        for i=1, hpToRender["MetalMantle"] do
            HP_SPRITE:Render(renderPos+calcPos(hpToRender["DarkMantle"]+i, lineSize))
        end
    end
    if(hpToRender["RockMantle"]>0) then
        HP_SPRITE:Play("RockMantle", true)
        for i=1, hpToRender["RockMantle"] do
            HP_SPRITE:Render(renderPos+calcPos(hpToRender["DarkMantle"]+hpToRender["MetalMantle"]+i, lineSize))
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_RENDER, CallbackPriority.LATE, postCollectibleRender, PickupVariant.PICKUP_COLLECTIBLE)