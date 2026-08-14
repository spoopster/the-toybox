local DMG_UP = 0.5
local DMG_UP_MULT = 0.5

---@param type CollectibleType
---@param firstTime boolean
---@param pl EntityPlayer
local function preAddCollectible(_, type, _, firstTime, _, _, pl)
    if(not firstTime) then return end
    if(not pl:HasTrinket(ToyboxMod.TRINKET_PINK_DONUT)) then return end

    ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE", true)
    Isaac.CreateTimer(function()
        ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE", nil)
    end, 1,1, true)
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_PRE_ADD_COLLECTIBLE, CallbackPriority.IMPORTANT-1, preAddCollectible)

local function postAddCollectible(_, type, _, firstTime, _, _, pl)
    ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE", nil)

    if(ToyboxMod:getEntityData(pl, "PINK_DONUT_WORKED")) then
        ToyboxMod.SFX:Play(ToyboxMod.SFX_CRUNCH, nil, nil, nil, 0.95+math.random()*0.1)
        
        ToyboxMod:setEntityData(pl, "PINK_DONUT_WORKED", nil)

        ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE_CHAPI", true)
        Isaac.CreateTimer(function()
            ToyboxMod:setEntityData(pl, "PINK_DONUT_ACTIVE_CHAPI", nil)
        end, 1,1, true)
    end
end
ToyboxMod:AddPriorityCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, CallbackPriority.LATE, postAddCollectible)

---@param pl EntityPlayer
---@param amount integer
local function preAddHearts(_, pl, amount)
    if(ToyboxMod:getEntityData(pl, "PINK_DONUT_ACTIVE") and amount~=0) then
        local data = ToyboxMod:getEntityDataTable(pl)
        data.PINK_DONUT_DAMAGE = (data.PINK_DONUT_DAMAGE or 0)+(amount*DMG_UP/2)*(1+DMG_UP_MULT*(pl:GetTrinketMultiplier(ToyboxMod.TRINKET_PINK_DONUT)-1))
        data.PINK_DONUT_WORKED = true

        pl:AddCacheFlags(CacheFlag.CACHE_DAMAGE, true)

        return 0
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, preAddHearts, AddHealthType.MAX)

if(CustomHealthAPI) then
    local function cancelChapiHeal(p, k, n)
        if(k=="EMPTY_HEART" and ToyboxMod:getEntityData(p, "PINK_DONUT_ACTIVE_CHAPI")) then
            return true
        end
    end
    CustomHealthAPI.Library.AddCallback(ToyboxMod, CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, 0, cancelChapiHeal)
end

---@param pl EntityPlayer
---@param val number
local function evaluateDamage(_, pl, _, val)
    local dmg = (ToyboxMod:getEntityData(pl, "PINK_DONUT_DAMAGE") or 0)
    return val+dmg
end
ToyboxMod:AddCallback(ModCallbacks.MC_EVALUATE_STAT, evaluateDamage, EvaluateStatStage.DAMAGE_UP)

local SPECIAL_TOOLTIP_REPLACEMENTS = {
    [CollectibleType.COLLECTIBLE_STIGMATA] = "DMG up",
    [CollectibleType.COLLECTIBLE_MEAT] = "DMG up",
    [CollectibleType.COLLECTIBLE_BLACK_LOTUS] = "HP up x2 + DMG up",

    [CollectibleType.COLLECTIBLE_CANCER] = false,
    [CollectibleType.COLLECTIBLE_MARROW] = false,

    [ToyboxMod.COLLECTIBLE_BODYBAG] = "DMG up",
}

local DONUT_TOOLTIP = {}

local function loadReplacedTooltips(_)
    DONUT_TOOLTIP = {}

    if(AccurateBlurbs) then
        SPECIAL_TOOLTIP_REPLACEMENTS[CollectibleType.COLLECTIBLE_BLACK_LOTUS] = nil
    end

    local conf = Isaac.GetItemConfig()
    for i=1, conf:GetCollectibles().Size-1 do
        local item = conf:GetCollectible(i)
        if(item) then
            local localizedName = Isaac.GetString("Items", item.Name)
            local name = (localizedName=="StringTable::InvalidKey" and item.Name or localizedName)

            local localizedDesc = Isaac.GetString("Items", item.Description)
            local desc = (localizedDesc=="StringTable::InvalidKey" and item.Description or localizedDesc)

            if(string.find(desc, "HP up") and SPECIAL_TOOLTIP_REPLACEMENTS[i]~=false) then
                DONUT_TOOLTIP[name.."*"..desc] = {
                    ID = i,
                    NewDesc = SPECIAL_TOOLTIP_REPLACEMENTS[i] or string.gsub(desc, "HP up", "DMG up")
                }
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_MODS_LOADED, loadReplacedTooltips)

loadReplacedTooltips(ToyboxMod)

local ALREADY_REPLACING = false

local function replaceDescription(_, title, subtitle, sticky, curse)
    if(ALREADY_REPLACING) then return end
    if(not PlayerManager.AnyoneHasTrinket(ToyboxMod.TRINKET_PINK_DONUT)) then return end

    local data = DONUT_TOOLTIP[title.."*"..subtitle]
    if(not data) then return end

    Isaac.CreateTimer(function()
        ALREADY_REPLACING = true

        local idToSearch = data.ID
        local hasTrinket = false
        for i=0, ToyboxMod.GAME:GetNumPlayers()-1 do
            local pl = Isaac.GetPlayer(i)
            if(pl.QueuedItem and pl.QueuedItem.Item and pl.QueuedItem.Item.ID==idToSearch and pl:HasTrinket(ToyboxMod.TRINKET_PINK_DONUT)) then
                hasTrinket = true
                break
            end
        end

        if(hasTrinket) then
            ToyboxMod.GAME:GetHUD():ShowItemText(title, data.NewDesc, curse, true)
        else
            ToyboxMod.GAME:GetHUD():ShowItemText(title, subtitle, curse, true)
        end

        ALREADY_REPLACING = false
    end, 1,1, true)

    return false
end
ToyboxMod:AddCallback(ModCallbacks.MC_PRE_ITEM_TEXT_DISPLAY, replaceDescription)