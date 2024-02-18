MilcomMOD = RegisterMod("milcomMod", 1)
local mod = MilcomMOD

--! INCLUDE SHIT
local mod_files = {
    "scripts.enums",

    "scripts.custom.data",
    "scripts.custom.callbacks",
    "scripts.custom.bombflags",
    "scripts.custom.ludo_trigger",

    "scripts.helper",

    "scripts.config",
    "scripts.savedata.save_data",

    "scripts.chapi_compat",

    "scripts.players.milcom.toinclude",
    "scripts.players.atlas.toinclude",

    "scripts.items.toinclude",

    "scripts.modcompat.eid.eid",

    "scripts.toybox_imgui",

    --"scripts.test",
}
for _, path in ipairs(mod_files) do
    include(path)
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end)