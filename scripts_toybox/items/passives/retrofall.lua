local mod = ToyboxMod

local REPLACED_CHARGE = 6

local RENDER_RETROFALL = -1
local BOX_WIDTH = 10000
local LINE_HEIGHT = 10

local font = Font()
font:Load("font/pftempestasevencondensed.fnt")

local retrofallDescStrings = {
    "Bad news, tomorrow is retrofall, which is an 8-bit",
    "attack event on all classic gaming consoles",
    "including the Nintendo Entertainment System. There",
    "will be people trying to send you ray tracing,",
    "extreme graphics, 4K, Call of Duty, and there will",
    "also be pixel grabbers, moderners, and Unreal Engine",
    "4K Remasterers. I advise NO ONE to play video games",
    "from retro gamers you don't know, please stay safe.",
    "Please pass this on to any gaming console you own or",
    "have 1UP Mushroom and can level up to spread",
    "awareness. I wish you all safety. Also, make sure to",
    "be game over tomorrow, which gives you less chance",
    "for this to happen to you. It's also specifically",
    "against retro video gamers.",
}

local function renderRetrofallDesc(_)
    if(mod.CONFIG.EPIC_ITEM_MODE~=mod.ENUMS.ITEM_SHADER_RETRO) then return end

    if(RENDER_RETROFALL>=0) then
        local streakSprite = Game():GetHUD():GetStreakSprite()
        local baseCenterPos = Vector(Isaac.GetScreenWidth()/2, 40)

        local frameData = streakSprite:GetNullFrame("Center")
        local frameScale = frameData:GetScale()
        baseCenterPos = baseCenterPos+frameData:GetPos()+Vector(0,17)*frameScale

        for key, str in ipairs(retrofallDescStrings) do
            font:DrawStringScaled(str, baseCenterPos.X-BOX_WIDTH/2, baseCenterPos.Y, frameScale.X, frameScale.Y, KColor(1,1,1,1), BOX_WIDTH, true)

            baseCenterPos.Y = baseCenterPos.Y+LINE_HEIGHT*frameScale.Y
        end

        if(streakSprite:IsFinished("Text")) then RENDER_RETROFALL = -1 end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, renderRetrofallDesc)

local function replaceRetrofallDesc(_, title, subtitle, sticky, curse)
    if(mod.CONFIG.EPIC_ITEM_MODE~=mod.ENUMS.ITEM_SHADER_RETRO) then return end

    if(title=="RETROFALL") then
        RENDER_RETROFALL = 0

        if(subtitle~="") then
            Game():GetHUD():ShowItemText("RETROFALL", "", curse)
            return false
        end
    else
        RENDER_RETROFALL = -1
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, replaceRetrofallDesc)



local function canRetrofy(id)
    local conf = Isaac.GetItemConfig():GetCollectible(id)
    if(not (conf and conf.ChargeType==ItemConfig.CHARGE_NORMAL)) then return false end

    if(conf.MaxCharges==0) then return false end

    return true
end

---@param id CollectibleType
---@param pl EntityPlayer
local function replaceRetroCharge(_, id, pl, vardata, current)
    if(not pl:HasCollectible(mod.COLLECTIBLE.RETROFALL)) then return end

    if(canRetrofy(id)) then
        return REPLACED_CHARGE
    end
end
mod:AddCallback(ModCallbacks.MC_PLAYER_GET_ACTIVE_MAX_CHARGE, replaceRetroCharge)

---@param id CollectibleType
---@param pl EntityPlayer
local function postUseRetroActive(_, id, rng, pl, flags, slot, vardata)
    if(not pl:HasCollectible(mod.COLLECTIBLE.RETROFALL)) then return end

    if(not canRetrofy(id)) then return end

    for _, item in ipairs(Isaac.FindByType(5,100)) do
        item = item:ToPickup() ---@cast item EntityPickup
        if(item.SubType~=0 and item:CanReroll()) then
            item:Morph(5,100,0)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, postUseRetroActive)