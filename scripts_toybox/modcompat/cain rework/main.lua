
if(not TCainRework) then return function() end end

return function()
    TCainRework:loadRegistry({
        Namespace = "toybox",
        Name = "Toybox",
        Items = [[
            rainbow_poop
            prismstone
        ]]
    })

    --include("scripts_toybox.modcompat.cain rework.material")
    include("scripts_toybox.modcompat.cain rework.compressed_dice")
end
