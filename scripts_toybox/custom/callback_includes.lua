local mod = ToyboxMod
mod.CALLBACK_BOMBS_FIRED = {}

local t = {
    "scripts_toybox.custom.callbacks.post_player_bomb_detonate",
    "scripts_toybox.custom.callbacks.post_player_double_tap",
    "scripts_toybox.custom.callbacks.post_player_attack",
    "scripts_toybox.custom.callbacks.use_active_item",
    "scripts_toybox.custom.callbacks.reset_ludovico_data",
    "scripts_toybox.custom.callbacks.copy_scatter_bomb_data",
    "scripts_toybox.custom.callbacks.post_fire_tear",
    "scripts_toybox.custom.callbacks.post_fire_bomb",
    "scripts_toybox.custom.callbacks.post_player_extra_dmg",
    "scripts_toybox.custom.callbacks.post_fire_aquarius",
    "scripts_toybox.custom.callbacks.post_fire_rocket",
    "scripts_toybox.custom.callbacks.post_new_room",
    "scripts_toybox.custom.callbacks.post_room_clear",
    "scripts_toybox.custom.callbacks.post_custom_champion_death",
    "scripts_toybox.custom.callbacks.post_poop_destroy",
    "scripts_toybox.custom.callbacks.poop_spawn_drop",
}
for _, path in ipairs(t) do
    include(path)
end