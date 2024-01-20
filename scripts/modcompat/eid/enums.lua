local mod = MilcomMOD

local ITEMS = {
    -- add descs for bloody needle, condensed milk, goat milk and slickwater lol
    [mod.COLLECTIBLE_NOSE_CANDY] = {
        Name = "Nose Candy",
        Description = {
            "\1 Every floor, you get +0.2 speed",
            "{{Blank}}  \7 If this bonus would make your speed higher than 2, the overflowing speed becomes a bonus to a non-speed stat",
            "\1 Every floor, you get a small stat-up to a non-speed stat",
            "\2 Every floor, you get a small stat-down to a non-speed stat",
        }
    }
}

local TRINKETS = {}

return {
    ["ITEMS"] = ITEMS,
    ["TRINKETS"] = TRINKETS,
}