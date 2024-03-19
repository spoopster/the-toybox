local mod = MilcomMOD

if(not ImGui.ElementExists("ToyboxMenu")) then
    ImGui.CreateMenu("ToyboxMenu", "\u{f552} Toybox")

    ImGui.AddElement("ToyboxMenu", "ToyboxOptionsTab", ImGuiElement.MenuItem, "\u{f7d9} Options")
    ImGui.CreateWindow("ToyboxOptionsWindow", "Options")
    ImGui.LinkWindowToElement("ToyboxOptionsWindow", "ToyboxOptionsTab")

	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped, "GENERAL OPTIONS")
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)



	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
	ImGui.AddText("ToyboxOptionsWindow", "", true, "")

    ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped, "ATLAS OPTIONS")
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

    --ATLAS ALT TRANSFORMATION
    ImGui.AddCheckbox("ToyboxOptionsWindow", "ToyboxOptionsAtlasPersistentTransformation", "Persistent Mantles", nil, false)
    ImGui.AddCallback("ToyboxOptionsAtlasPersistentTransformation", ImGuiCallback.Render,
    function()
        ImGui.UpdateData("ToyboxOptionsAtlasPersistentTransformation", ImGuiData.Value, mod.CONFIG.ATLAS_PERSISTENT_TRANSFORMATIONS)
    end)
    ImGui.AddCallback("ToyboxOptionsAtlasPersistentTransformation", ImGuiCallback.Edited,
    function(v)
        mod.CONFIG.ATLAS_PERSISTENT_TRANSFORMATIONS = v
    end)
    ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
        "Atlas' transformations persist until you become Tar or get a different non-default transformation. If disabled, you revert to default form when you lose a mantle."
    )
    ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	--ATLAS STRONGER BASE TAR
	ImGui.AddCheckbox("ToyboxOptionsWindow", "ToyboxOptionsStrongerBaseTar", "Stronger Tar", nil, false)
	ImGui.AddCallback("ToyboxOptionsStrongerBaseTar", ImGuiCallback.Render,
	function()
		ImGui.UpdateData("ToyboxOptionsStrongerBaseTar", ImGuiData.Value, mod.CONFIG.ATLAS_BASE_STRONGER_TAR)
	end)
	ImGui.AddCallback("ToyboxOptionsStrongerBaseTar", ImGuiCallback.Edited,
	function(v)
		mod.CONFIG.ATLAS_BASE_STRONGER_TAR = v
	end)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
		"Atlas' Tar form has higher base stats."
	)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	--ATLAS TEMP STRONGER BASE TAR
	ImGui.AddCheckbox("ToyboxOptionsWindow", "ToyboxOptionsTempStrongerBaseTar", "Temporary Tar Boost", nil, false)
	ImGui.AddCallback("ToyboxOptionsTempStrongerBaseTar", ImGuiCallback.Render,
	function()
		ImGui.UpdateData("ToyboxOptionsTempStrongerBaseTar", ImGuiData.Value, mod.CONFIG.ATLAS_TEMP_STRONGER_TAR)
	end)
	ImGui.AddCallback("ToyboxOptionsTempStrongerBaseTar", ImGuiCallback.Edited,
	function(v)
		mod.CONFIG.ATLAS_TEMP_STRONGER_TAR = v
	end)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
		"Atlas' Tar form gets a fading stats up when transformed into."
	)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	--ATLAS LEAVE TAR CREEP
	ImGui.AddCheckbox("ToyboxOptionsWindow", "ToyboxOptionsTarCreep", "Tar Creep", nil, false)
	ImGui.AddCallback("ToyboxOptionsTarCreep", ImGuiCallback.Render,
	function()
		ImGui.UpdateData("ToyboxOptionsTarCreep", ImGuiData.Value, mod.CONFIG.ATLAS_TAR_CREEP)
	end)
	ImGui.AddCallback("ToyboxOptionsTarCreep", ImGuiCallback.Edited,
	function(v)
		mod.CONFIG.ATLAS_TAR_CREEP = v
	end)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
		"Atlas' Tar form leaves slowing black creep when walking."
	)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
end

--[[
    return function()

	if not ImGui.ElementExists('remixMenu') then
		ImGui.CreateMenu('remixMenu', '\u{f5d1} CR')

		ImGui.AddElement('remixMenu', 'remixMenuOptions', ImGuiElement.MenuItem, '\u{f7d9} Options')
		ImGui.CreateWindow('remixWindowOptions', 'Options')
		ImGui.LinkWindowToElement('remixWindowOptions', 'remixMenuOptions')

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.SeparatorText, "Cosmetic")
		
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- apple streaks
			local id = 'remixMenuOptionsAppleStreaks'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Apple Streaks', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.apple_streaks)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.apple_streaks = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "The Apple displays which mode youre in on-screen when activated.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- hud papers
			local id = 'remixMenuOptionsHUDPapers'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Paper HUD', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.hud_papers)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.hud_papers = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Adds a paper backdrop to the HUD for visibility.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- tear sfx
			local id = 'remixMenuOptionsTearSFX'

			ImGui.AddCombobox('remixWindowOptions', id, 'Tear Sounds', function(i, v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.tear_sounds = i
				end
			end, {"Rebirth", "Remix", "Flash"}, 1, true)

			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.tear_sounds)
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.SeparatorText, "Tweaks")

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- flash movement
			local id = 'remixMenuOptionsFlashMovement'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Flash Movement', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.flash_movement)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.flash_movement = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Makes Isaac's movement work the way it does pre-rebirth. Does nothing with gamepad.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- hybrid cam
			local id = 'remixMenuOptionsHybridCamera'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Hybrid Camera', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.hybrid_cam)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.hybrid_cam = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "The camera moves quickly to view where you are firing, and only where youre firing. Does not work if active cam is enabled.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- faster pickups
			local id = 'remixMenuOptionsFasterPickups'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Faster Pickups', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.faster_pickups)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.faster_pickups = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Pickups appear faster.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- friction pickups
			local id = 'remixMenuOptionsFrictionPickups'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Pickup Friction', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.pickup_friction)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.pickup_friction = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Pickups slide less.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- bfast tweak
			local id = 'remixMenuOptionsBfast'
			ImGui.AddCheckbox('remixWindowOptions', id, 'No Breakfasting', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nobfast == nil then sd.cfg.nobfast = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.nobfast)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nobfast == nil then sd.cfg.nobfast = v end
					sd.cfg.nobfast = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Item pedestals which contain breakfast after emptying the item pool rapidly cycle between random items from the pool.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- disappearing pedestals
			local id = 'remixMenuOptionsNoPedestals'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Remove Empty Pedestals', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nopedestal == nil then sd.cfg.nopedestal = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.nopedestal)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.nopedestal == nil then sd.cfg.nopedestal = v end
					sd.cfg.nopedestal = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Item pedestals disappear immediately when emptied.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- eve buff
			local id = 'remixMenuOptionsEveBuff'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Eve Buff', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.eve_buff)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					sd.cfg.eve_buff = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Eve now has 'Curse Stacks' which activate themselves and give decaying damage ups the next time you activate Whore of Babylon, and are reset/lost upon deactivation. These are acquired by clearing rooms while Whore of Babylon is inactive.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- samson buff
			local id = 'remixMenuOptionsSamsonBuff'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Samson Buff', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.samson_buff == nil then sd.cfg.samson_buff = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.samson_buff)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.samson_buff == nil then sd.cfg.samson_buff = v end
					sd.cfg.samson_buff = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Starts with donkey jawbone after unlock.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Text, "\n")
		ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		do -- alt methods
			local id = 'remixMenuOptionsAltMethods'
			ImGui.AddCheckbox('remixWindowOptions', id, 'Alt Character Unlock Methods', nil, false)
			ImGui.AddCallback(id, ImGuiCallback.Render, function()
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.altmethods == nil then sd.cfg.altmethods = false end
					ImGui.UpdateData(id, ImGuiData.Value, sd.cfg.altmethods)
				end
			end)
			ImGui.AddCallback(id, ImGuiCallback.Edited, function(v)
				local sd = communityRemix.GetSaveData()
				if sd.cfg then
					if sd.cfg.altmethods == nil then sd.cfg.altmethods = v end
					sd.cfg.altmethods = v
				end
			end)
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.TextWrapped, "Lost's mantle, Eve's razor, Maggy's pill, etc. can now be unlocked by beating Mega Satan in Insane Mode with the respective character.")
			ImGui.AddElement('remixWindowOptions', '', ImGuiElement.Separator)
		end

    end
end
]]