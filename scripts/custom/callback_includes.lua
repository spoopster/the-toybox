local mod = MilcomMOD
mod.CALLBACK_BOMBS_FIRED = {}

local t = {
    "scripts.custom.callbacks.post_player_bomb_detonate",
    "scripts.custom.callbacks.post_player_double_tap",
    "scripts.custom.callbacks.post_player_attack",
    "scripts.custom.callbacks.use_active_item",
    "scripts.custom.callbacks.reset_ludovico_data",
    "scripts.custom.callbacks.copy_scatter_bomb_data",
    "scripts.custom.callbacks.post_fire_tear",
    "scripts.custom.callbacks.post_fire_bomb",
    "scripts.custom.callbacks.post_player_extra_dmg",
    "scripts.custom.callbacks.post_fire_aquarius",
    "scripts.custom.callbacks.post_fire_rocket",
    "scripts.custom.callbacks.post_new_room",
    "scripts.custom.callbacks.post_room_clear",
}
for _, path in ipairs(t) do
    include(path)
end