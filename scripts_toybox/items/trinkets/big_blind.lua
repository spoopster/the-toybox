

local FIRST_REQ = 10
local SUM_INCREASE = 6
local COIN_SPEED = 8
local godimkillingmyself = false

function ToyboxMod:getBigBlindDamageRequirement(pl)
    local data = ToyboxMod:getEntityDataTable(pl)
    data.BIG_BLIND_COUNTERS_FINISHED = (data.BIG_BLIND_COUNTERS_FINISHED or 0)

    local gaussSum = (data.BIG_BLIND_COUNTERS_FINISHED*(data.BIG_BLIND_COUNTERS_FINISHED+1)/2)

    return FIRST_REQ+SUM_INCREASE*gaussSum
end

---@param ent Entity
local function addToCounter(_, ent, amount, _, _, _)
    if(not (ent and ent:Exists() and ToyboxMod:isValidEnemy(ent))) then return end

    for i=0, Game():GetNumPlayers()-1 do
        local pl = Isaac.GetPlayer(i)

        if(pl:HasTrinket(ToyboxMod.TRINKET_BIG_BLIND)) then
            local rng = pl:GetTrinketRNG(ToyboxMod.TRINKET_BIG_BLIND)
            local data = ToyboxMod:getEntityDataTable(pl)
            data.BIG_BLIND_COUNTER = (data.BIG_BLIND_COUNTER or 0)+amount

            print(data.BIG_BLIND_COUNTER)

            local req = ToyboxMod:getBigBlindDamageRequirement(pl)/pl:GetTrinketMultiplier(ToyboxMod.TRINKET_BIG_BLIND)
            while(data.BIG_BLIND_COUNTER>=req) do
                local coin = Isaac.Spawn(5,20,1,ent.Position,Vector.FromAngle(rng:RandomInt(360)):Resized(COIN_SPEED),pl):ToPickup()

                data.BIG_BLIND_COUNTER = data.BIG_BLIND_COUNTER-req
                data.BIG_BLIND_COUNTERS_FINISHED = (data.BIG_BLIND_COUNTERS_FINISHED or 0)+1

                req = ToyboxMod:getBigBlindDamageRequirement(pl)/pl:GetTrinketMultiplier(ToyboxMod.TRINKET_BIG_BLIND)

                if(ToyboxMod:getPersistentData("IS_CONBOI")==1) then
                    ToyboxMod:setExtraData("BIGBLIND_CONBOI_ACTIVE", 1)
                end
            end
        end
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, addToCounter)

--* display
ToyboxMod.CONBOI_TEXT = {
    "ConBoi is bad at balatro  Very bad actually  Like unimaginable levels of throwing are happening  The",
    " most complex variables are being calculated in his head just to figure out the dumbest way to lose ",
    "                                                      :::::::::::                                   ",
    "                                                     -***********:                                  ",
    "                                                :****++++++++++++**-                                ",
    "                                              -**+++++++++++++++++++*+                              ",
    "                                            -==+++++++++++++++++++++++==                            ",
    "                                            +*++++++++++++++++++++++++**                            ",
    "                                         :**+++++++++++++++++++*********                            ",
    "                                       -**+++++++++++++++++++*+         +*-                         ",
    "                                     :-=+++++++++++++++++++++*+         +*-                         ",
    "                                     +*++++++++++++++++++++++*+         +*-                         ",
    "                                     +*++++++++++++++++++++++****:   :**                            ",
    "                                  :**++++++++++++++++++++++++++******+                              ",
    "                                  :**++++++++++++++++++++++++++**-::::                              ",
    "                ::::::::::::::   :-**++++++++++++++++++++++++++**-:   ::::::::::::::                ",
    "                =*************: -**++++++++++++++++++++++++++++++**- :*************=                ",
    "           -****=-------------+****++++++++++++++++++++++++++++++****+-------------=****-           ",
    "         =*+----------------------=++++++++++++++++++++++++++++++=----------------------+*=         ",
    "         =*+--------------------===++++++++++++++++++++++++++++++===--------------------+*=         ",
    "         =*+--------------------=++++++++++++++++++++++++++++++++++=--------------------+*=         ",
    "       **=----------------------=++++++++++++++++++++++++++++++++++=----------------------=**       ",
    "       **=--------------------=++++++++++++++++++++++++++++++++++++++=--------------------=**       ",
    "    :++===--------=**---------=++++++++++++++++++++++++++++++++++++++=---------**=--------===++:    ",
    "    -**=-----=++++===++=------=++++++++++++++++++++++++++++++++++++++=------=++===++++=-----=**-    ",
    "    -**=-----=****=  **=------=++++++++++++++++++++++++++++++++++++++=------=**  =****=-----=**-    ",
    "    -**=-----=**:      +*+-=++++++++++++++++++++++++++++++++++++++++++++=-+*+      :**=-----=**-    ",
    "    -**=---+**         +*+-=++++++++++++++++            ++++++++++++++++=-+*+         **+---=**-    ",
    "  -+=::  ---::++:      +*+==+++++++++:::::::            :::::::+++++++++==+*+      :++::---  ::=+-  ",
    "  =*=    :-:  **:      +*+++++++++=--                          --=+++++++++*+      :**  :-:    =*=  ",
    "  =*=         **:      +*+++++++++=                              =+++++++++*+      :**         =*=  ",
    "  =*=         **:    **+++++++++=------:                    :------=+++++++++**    :**         =*=  ",
    "    -**    -**       **+++++++=-------------            -------------=+++++++**       **-    **-    ",
    "     --====---       **+++++++=------:::::--::        ::--:::::------=+++++++**       ---====--     ",
    "       ++++=         **++++===-------:   :----:      :----:   :-------===++++**         =++++       ",
    "                     **++++=::::---  +***+  --:      :--  +***+  --:    =++++**                     ",
    "                     **++++=::::   ---------            ---------       =++++**                     ",
    "                       +*++=::::                                        =++*+                       ",
    "                       +*+--::::                                        :-+*+                       ",
    "                       +*=::::::            :-:      :-:                  =*+                       ",
    "                     **-::::::=+-             :------:             -+-      :**                     ",
    "                     **-::::::=++++++++-                    -++++++++-      :**                     ",
    "                     **-::::::=++++++++=--------------------=++++++++-      :**                     ",
    "                     ++--:::::--=++++++++++++++++++++++++++++++++++=--     :-++                     ",
    "                       +*=::::  :++++++++++++++++++++++++++++++++++:      =*+                       ",
    "                         -**::::   ++++++=                =++++++       +*-                         ",
    "                            **-:   +++++++++            +++++++++    :**                            ",
    "                            **-::  ::=++++++------------++++++=::    :**                            ",
    "                            ++-::::  -==++++++++++++++++++++==-      :++                            ",
    "                              +*=::::  :++++++++++++++++++++:      =*+                              ",
    "                       +******-::::::::     =++++++++++=            :-*********                     ",
    "                =+++++++++++++++-::::                          ::::-+++++++++--++++=                ",
    "           :----+******++++++++=-::::                          ::::-======+++==**++=----:           ",
    "           -*****+++++++++++++=----:::::::                :::::::---------=++++++=-=****-           ",
    "       *****+++++++++++=-----------  :-::::::::::::::::::::::------:    -------+++++++--+****       ",
    "    -**+++++++++++=-----------:    ----=++++++=----  :--++++=-------------: :------=++++++=--**-    ",
    "  -++**+++++++++==----------::::::-+++++++++==-----:::::==+++++++----------:---:::--====++++++*++-  ",
    "  =**+++++++++++----------::::---==+++++++++---------: :--=++++++==------------::::-----=++++++**=  ",
    "  =**++++++=-------------:  ----=+++++++++-----------: :----=++++++=-------------: :------=++++**=  ",
    "***++++++=-------------: :----+++++++++=---------------:  -----+++++++-------------:  -------++++***",
    "***++++******+-------  :----+++++++++-------+********=-:  -----+++++++++--------------+******--=+***",
    "***++*********+=-----::-----+++++++++--=====+********+====-----==+++++++------------=+*******+===+**",
    "***++***********=----------=+++++++++=-=******************=------+++++++=----------=***********=-=**",
    "***++*************=  ----=+++++++++--+**********************=----+++++++++=------+*************=-=**",
    "*********************--+++++++++=--***************************+----=+++++++++--******************=  ",
    "  =***************= :**+++++++++=--****************************++--=+++++++++**: =*************-    ",
    "--+++++*******====:  ***+++++++++==***********+======+***********--=++++++++***  :====*********=-:  ",
    "**+++++*******       ***+++++++++*************-      -***********--=++++++++***       ***********=  ",
    "**+++++++**=         ***+++++++++***********:          :***********+++++++++***         =********=  ",
    "**+++++++**=         ***+++++++++***********:          :***********+++++++++***         =********=  ",
    "::=******-::         ***+++++++++********+::            ::+********+++++++++***         ::=****=::  ",
    "  -++++++:           ***++++++++*******++=                =++*******++++++++***           :++++:    ",
    "                     ***++++++*********=                    =*********++++++***                     ",
    "                       +**++++*******:                        :*******++++**+                       ",
    "                     *************+                              +******+++++**                     ",
    "                     ***********+--                              --+**+++++++**                     ",
    "                     ***********=                                  =**+++++++**                     ",
    "                     ***********=                                  =**+++++++**                     ",
    "                       +******:                                      :******+                       ",
    "                                                                                                    ",
    "                                                                                                    ",
    "                                                                                                    ",
    "                                                                                                    ",
    "                                                                                                    ",
    "                                                                                                    ",
}
local EMPTY_STRING = "                                                                                                    "
local LINE_OFFSET = Vector(0,5)
local TEXT_SCALE = Vector(0.85,0.55)

local RESET_TABLES = false
local UNFILLED_INDEXES
local FINALSTRINGS

local f = Font()
f:Load("font/terminus.fnt")

function ToyboxMod:triggerConboi(rng)
    local data = ToyboxMod:getExtraDataTable()
    if(data.BIGBLIND_CONBOI_ACTIVE~=1) then return end
    if(UNFILLED_INDEXES==nil or FINALSTRINGS==nil or RESET_TABLES==true) then return end
    if(#UNFILLED_INDEXES==0) then return end
    rng = rng or ToyboxMod:generateRng()

    local selectedIndex = rng:RandomInt(#UNFILLED_INDEXES)+1
    local charPos = UNFILLED_INDEXES[selectedIndex]
    table.remove(UNFILLED_INDEXES, selectedIndex)

    local linePos = 1
    while(charPos>0) do
        local selString = ToyboxMod.CONBOI_TEXT[linePos]
        local _, len = string.gsub(selString, "[^ ]", function() end)
        if(charPos-len<=0) then break end

        charPos = charPos-len
        linePos = linePos+1
    end

    local charsCounted = 0
    local str = ToyboxMod.CONBOI_TEXT[linePos]
    str = string.gsub(str, "[^ ]", function(c)
        charsCounted = charsCounted+1
        if(charsCounted<=charPos) then return nil
        else return " " end
    end)
    str = str.reverse(str)
    local finalPos = 101-string.find(str, "[^ ]")
    local finalChr = string.match(str, "[^ ]")

    local finalStr = FINALSTRINGS[linePos]
    finalStr = string.sub(finalStr, 1, finalPos-1)..finalChr..string.sub(finalStr,finalPos+1,100)
    FINALSTRINGS[linePos] = finalStr
end

local function postRender()
    local data = ToyboxMod:getExtraDataTable()
    if(data.BIGBLIND_CONBOI_ACTIVE~=1) then return end

    if(not Game():IsPaused()) then
        if(UNFILLED_INDEXES==nil or FINALSTRINGS==nil or RESET_TABLES==true) then
            UNFILLED_INDEXES = {}
            FINALSTRINGS = {}
    
            local numValidChars, charsInString = 0, 0
            for _, str in ipairs(ToyboxMod.CONBOI_TEXT) do
                _, charsInString = string.gsub(str, "[^ ]", " ")
                numValidChars = numValidChars+charsInString
            end
            for i=1, numValidChars do UNFILLED_INDEXES[i] = i end
            for i, _ in ipairs(ToyboxMod.CONBOI_TEXT) do FINALSTRINGS[i] = EMPTY_STRING end

            RESET_TABLES = false
        end

        for _=1, 6 do ToyboxMod:triggerConboi() end
    end

    if(not (FINALSTRINGS and FINALSTRINGS~=0)) then return end
    local RENDER_POS = Vector.Zero
    for _, str in ipairs(FINALSTRINGS) do
        f:DrawStringScaled(str, RENDER_POS.X, RENDER_POS.Y, TEXT_SCALE.X, TEXT_SCALE.Y, KColor(1,1,1,1))
        RENDER_POS = RENDER_POS+LINE_OFFSET
    end
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, postRender)

local function resetTables(_)
    RESET_TABLES = true
end
ToyboxMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, resetTables)