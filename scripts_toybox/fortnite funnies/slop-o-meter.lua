Console.RegisterCommand(
    "sloprating",
    "rates enabled item mods",
    "calculates slop rating of enabled item mods, based on strength of their items",
    true,
    AutocompleteType.NONE
)

ToyboxMod:AddCallback(ModCallbacks.MC_EXECUTE_CMD, function(_, command)
    if command ~= "sloprating" then
        return
    end
    local MAX_ITEM = Isaac.GetItemConfig():GetCollectibles().Size-1
    local MAX_VANILLA_ITEM = CollectibleType.NUM_COLLECTIBLES - 1
    local mods = {}

    print("BOOTING UP THE SLOP-O-METER-3000")
    print("PLEASE WAIT")
    print("...")
    print("...")
    print("...")
    print("------")

    local vanillaSlopRating = 1
    local itemConfig = Isaac.GetItemConfig()
    local vanillaItemQualities = {}
    local vanillaPeakItems = 0
    local vanillaSlopItems = 0
    local vanillaTotalItems = 0

    for i = 1, MAX_VANILLA_ITEM do
        local item = itemConfig:GetCollectible(i)
        if not item or item.Hidden then
            goto continue
        end
        local quality = item.Quality
        vanillaItemQualities[quality] = (vanillaItemQualities[quality] or 0) + 1
        ::continue::
    end

    print("Vanilla's contents:")
    for quality, count in pairs(vanillaItemQualities) do
        local qualityNum = tonumber(quality)
        if qualityNum >= 3 then
            local mult = (qualityNum - 2)
            vanillaSlopItems = vanillaSlopItems + count * mult
        elseif qualityNum == 1 then
            vanillaPeakItems = vanillaPeakItems + count
        elseif qualityNum == 0 then
            vanillaPeakItems = vanillaPeakItems + (count * 2)
        end
        vanillaTotalItems = vanillaTotalItems + count
    end
    for quality = 0, 4 do
        local count = vanillaItemQualities[quality]
        print(string.format("Quality %d: %d items (%d%% of game's items)", quality, count, math.floor(100*count/vanillaTotalItems)))
    end
    print("a total of", vanillaTotalItems, "items")
    print("SLOP-O-METER-3000 reading:", vanillaSlopItems / vanillaPeakItems)
    print("------")
    vanillaSlopRating = vanillaSlopItems / vanillaPeakItems

    for i = MAX_VANILLA_ITEM + 1, MAX_ITEM do
        local item = XMLData.GetEntryById(XMLNode.ITEM, i)
        if item.hidden then
            goto continue
        end
        local mod = item.sourceid
        if not mods[mod] then
            mods[mod] = {}
        end
        local quality = tonumber(item.quality) or -1 --Because some mods ommit that apparently
        mods[mod][quality] = (mods[mod][quality] or 0) + 1

        ::continue::
    end

    for id, items in pairs(mods) do
        local name = XMLData.GetModById(id).name
        local totalItems = 0
        local peakItems = 1
        local slopItems = 1
        print(string.format("%s's contents:", name))
        for quality, count in pairs(items) do
            local qualityNum = tonumber(quality)
            if qualityNum >= 3 then
                local mult = (qualityNum - 2)
                slopItems = slopItems + count * mult
            elseif qualityNum == 1 then
                peakItems = peakItems + count
            elseif qualityNum == 0 then
                peakItems = peakItems + (count * 2)
            end
            totalItems = totalItems + count
        end

        local stuffToPrint = {}
        for quality, count in pairs(items) do
            local vanillaQualityCount = vanillaItemQualities[quality]
            if not vanillaQualityCount then
                vanillaQualityCount = math.huge
            end
            local vanillaRatioComparison = (count/totalItems)/(vanillaQualityCount/vanillaTotalItems)
            local line = string.format("Quality %d: %d items (%d%% of mod's items)(%fx of vanilla ratio)", quality, count, math.floor(100*count/totalItems), vanillaRatioComparison)
            table.insert(stuffToPrint, {quality, line})
        end

        table.sort(stuffToPrint, function (a, b)
            return a[1] < b[1]
        end)
        for _, line in ipairs(stuffToPrint) do
            print(line[2])
        end

        print("a total of", totalItems, "items")
        print("SLOP-O-METER-3000 reading:", slopItems / peakItems)
        print("Normalised value: " .. (slopItems / peakItems)/vanillaSlopRating )
        print("------")
    end
end)