local mod = MilcomMOD

local function getOptionID(name)
	return "ToyboxOption"..name
end

--[ [
if(not ImGui.ElementExists("ToyboxMenu")) then
    ImGui.CreateMenu("ToyboxMenu", "\u{f552} Toybox")

    ImGui.AddElement("ToyboxMenu", "ToyboxOptionsTab", ImGuiElement.MenuItem, "\u{f7d9} Options")
    ImGui.CreateWindow("ToyboxOptionsWindow", "Options")
    ImGui.LinkWindowToElement("ToyboxOptionsWindow", "ToyboxOptionsTab")

	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped, "GENERAL OPTIONS")
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	do
		local optionID = getOptionID("PEZDispenserDisplayName")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Candy Dispenser - Consumable name display"
		)
		ImGui.AddCombobox("ToyboxOptionsWindow", optionID, "", nil, {"While holding the Map button", "Always", "Never"}, 0, false)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, mod.CONFIG.PEZDISPENSER_DISPLAY_NAME)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				mod.CONFIG.PEZDISPENSER_DISPLAY_NAME = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Dictates when to display the name of Candy Dispenser's frontmost held consumable."
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	do
		local optionID = getOptionID("AlphabetBoxDescriptionPreview")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Alphabet Box - Description Previews"
		)
		ImGui.AddSliderInteger("ToyboxOptionsWindow", optionID, "", nil, 3, 0, 10)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, mod.CONFIG.ALPHABETBOX_EID_DISPLAYS)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				mod.CONFIG.ALPHABETBOX_EID_DISPLAYS = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"How many items should be previewed in item descriptions while Alphabet Box is held. (Only works if you have EID!)"
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end

	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
	ImGui.AddText("ToyboxOptionsWindow", "", true, "")

	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped, "FORTNITE FUNNIES")
	ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)

	do
		local optionID = getOptionID("PEZAntibirthKiller")

		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Text,
			"Candy Dispenser - Antibirth Killer"
		)
		ImGui.AddCheckbox("ToyboxOptionsWindow", optionID, "", nil, false)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Render,
			function()
				ImGui.UpdateData(optionID, ImGuiData.Value, mod.CONFIG.PEZDISPENSER_ANTIBIRTH_KILLER)
			end
		)
		ImGui.AddCallback(optionID,
			ImGuiCallback.Edited,
			function(v)
				mod.CONFIG.PEZDISPENSER_ANTIBIRTH_KILLER = v
			end
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.TextWrapped,
			"Turns Candy Dispenser into a (legally distinct) Pill Crusher."
		)
		ImGui.AddElement("ToyboxOptionsWindow", "", ImGuiElement.Separator)
	end
	--ImGui.AddCombobox("ToyboxOptionsWindow", "ToyboxOptionsPEZDispenserAntibirthKiller", )

	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
	ImGui.AddText("ToyboxOptionsWindow", "", true, "")
end
--]]

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