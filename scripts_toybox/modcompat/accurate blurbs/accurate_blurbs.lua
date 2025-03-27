local mod = ToyboxMod

local function loadBlurbs()
    if(not AccurateBlurbs) then return end

    local itemsData = include("scripts_toybox.modcompat.accurate blurbs.enums")

    local conf = Isaac.GetItemConfig()
    for item, desc in pairs(itemsData.ITEMS) do
        conf:GetCollectible(item).Description = desc
    end

    for item, desc in pairs(itemsData.TRINKETS) do
        conf:GetTrinket(item).Description = desc
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_MODS_LOADED, CallbackPriority.LATE, loadBlurbs)