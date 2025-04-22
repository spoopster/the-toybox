local mod = ToyboxMod

local function slopOMeter()
    local itemQuals = {[0]=0, [1]=0, [2]=0, [3]=0, [4]=0}
    local minQual = 0
    local maxQual = 4
    local totalItems = 0

    for _, id in pairs(mod.COLLECTIBLE) do
        local conf = Isaac.GetItemConfig():GetCollectible(id)
        if(conf and not conf.Hidden) then
            itemQuals[conf.Quality] = (itemQuals[conf.Quality] or 0)+1
            minQual = math.min(minQual, conf.Quality)
            maxQual = math.max(maxQual, conf.Quality)
            totalItems = totalItems+1
        end
    end

    local slopVal = (1+itemQuals[4]*2+itemQuals[3])
    local peakVal = (1+itemQuals[0]*2+itemQuals[1])

    print("Toybox items:")
    for i=minQual, maxQual do
        print(" -", itemQuals[i] or 0, "items of quality", i)
    end
    print(totalItems, "total items")
    print("Final slop rating:", slopVal/peakVal)
end
slopOMeter()