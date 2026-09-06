-- ChoomAssist CET overlay UI
-- Copyright (C) 2021-2026 Jon West <electrikjesus@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

local Compat = require("compat.lua")
local Assists = require("assists.lua")
local Graphics = require("graphics.lua")
local QoL = require("qol.lua")

local UI = {
    overlayOpen = false,
    saveHandler = nil,
}

function UI.setSaveHandler(fn)
    UI.saveHandler = fn
end

local function save()
    if UI.saveHandler then
        UI.saveHandler()
    end
end

local function tooltip(text)
    if text and text ~= "" and ImGui.IsItemHovered() then
        ImGui.SetTooltip(text)
    end
end

local function beginDisabled(disabled)
    if disabled then
        pcall(function()
            ImGui.BeginDisabled()
        end)
    end
end

local function endDisabled(disabled)
    if disabled then
        pcall(function()
            ImGui.EndDisabled()
        end)
    end
end

local function drawAssist(spec)
    local state = Assists.state[spec.id]
    if state == nil then
        return
    end

    if Assists.unavailable[spec.id] then
        ImGui.TextDisabled(spec.label .. " (doesn't work on this patch)")
        tooltip(spec.tooltip)
        return
    end

    local enabled, toggled = ImGui.Checkbox(spec.label, state.enabled)
    tooltip(spec.tooltip)
    if toggled then
        state.enabled = enabled
        Assists.commit(spec.id)
        save()
    end

    ImGui.TextWrapped(spec.tooltip)

    if spec.kind ~= "slider" then
        return
    end

    local inactive = not state.enabled
    beginDisabled(inactive)
    ImGui.PushItemWidth(-8)
    local value, changed = ImGui.SliderFloat("##" .. spec.id, state.value, spec.min, spec.max, spec.format)
    ImGui.PopItemWidth()
    state.value = value

    local shouldCommit = false
    local hasDeactivate, deactivated = pcall(function()
        return ImGui.IsItemDeactivatedAfterEdit()
    end)
    if hasDeactivate then
        shouldCommit = deactivated
    else
        shouldCommit = changed
    end
    if shouldCommit then
        Assists.commit(spec.id)
        save()
    end
    endDisabled(inactive)
end

local function drawAssistTab(tab, intro)
    ImGui.TextWrapped(intro)
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()
    if not Compat.inSession() then
        ImGui.TextDisabled("Load a save to apply these. Values are still saved.")
        ImGui.Spacing()
    end
    if ImGui.Button("Turn off all assists on this character") then
        Assists.resetAll()
        save()
    end
    tooltip("Turns off every Play Assist and Combat Comfort row, including crit.")
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()
    local order, groups = Assists.groupedDefsForTab(tab)
    for _, groupName in ipairs(order) do
        ImGui.Separator()
        ImGui.Text(groupName)
        ImGui.Spacing()
        for _, spec in ipairs(groups[groupName]) do
            drawAssist(spec)
            ImGui.Spacing()
        end
    end
end

local function drawGraphicsOption(graphicsOption)
    Graphics.syncFromGame(graphicsOption)
    local value, toggled = ImGui.Checkbox(graphicsOption.name, graphicsOption.defaultvalue)
    tooltip(graphicsOption.note)
    if graphicsOption.note ~= "" then
        ImGui.TextWrapped(graphicsOption.note)
    end
    if toggled then
        Graphics.applyOption(graphicsOption, value)
        save()
    end
end

local function drawPresetButton(label, applyFn)
    if ImGui.Button(label, 0, 0) then
        applyFn()
        save()
        Compat.status("Applied graphics preset: " .. label)
    end
end

local function drawVisualTab()
    ImGui.TextWrapped("Turn off effects that blur, smear, or flash the screen. Unchecked = that effect is off. Bigger fonts and HUD size are still in the game's Settings > Accessibility tab.")
    ImGui.Spacing()
    drawPresetButton("Visual Comfort preset", Graphics.applyVisualComfort)
    ImGui.SameLine()
    drawPresetButton("Reset visual to vanilla", function()
        for _, graphicsOption in ipairs(Graphics.VisualComfort) do
            Graphics.applyOption(graphicsOption, true)
        end
    end)
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()
    for _, graphicsOption in ipairs(Graphics.VisualComfort) do
        drawGraphicsOption(graphicsOption)
    end
end

local function drawPerformanceTab()
    ImGui.TextWrapped("Turn off expensive lighting and world details to raise FPS on slower PCs. Unchecked = off. Crowd and weather may need a time skip or walking into a new area before they fully apply.")
    ImGui.Spacing()
    drawPresetButton("Low-End", Graphics.applyLowEnd)
    ImGui.SameLine()
    drawPresetButton("Balanced", Graphics.applyBalanced)
    ImGui.SameLine()
    drawPresetButton("Reset to Vanilla", Graphics.applyVanilla)
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()
    for _, group in ipairs(Graphics.groups()) do
        if group.id ~= "visual" then
            if ImGui.CollapsingHeader(group.title) then
                for _, graphicsOption in ipairs(group.list) do
                    drawGraphicsOption(graphicsOption)
                end
            end
        end
    end
end

local function sessionGate()
    if Compat.inSession() then
        return true
    end
    ImGui.TextDisabled("Load a save to use Quality of Life grants.")
    return false
end

local function drawQoLTab()
    ImGui.TextWrapped("One-shot buttons that add money, XP, skillbooks, or items. They do not stay toggled. Items go to inventory. Equip cyberware at a ripper; this mod will not slot it. Big grants can bloat a save.")
    ImGui.Spacing()
    if not sessionGate() then
        ImGui.Spacing()
    end

    if ImGui.CollapsingHeader("Eddies") then
        ImGui.TextWrapped("Adds eurodollars to your inventory. Set the amount, then press Add eddies. This is a one-time grant, not infinite money.")
        local amount, changed = ImGui.SliderInt("Eddie amount", QoL.state.moneyAmount, 1000, 10000000, "%d")
        QoL.state.moneyAmount = amount
        if changed then
            local hasDeactivate, deactivated = pcall(function()
                return ImGui.IsItemDeactivatedAfterEdit()
            end)
            if (hasDeactivate and deactivated) or (not hasDeactivate) then
                save()
            end
        end
        if ImGui.Button("Add eddies") then
            QoL.addMoney()
            save()
        end
    end

    if ImGui.CollapsingHeader("Level and attributes") then
        ImGui.TextWrapped("Set Level (1-60) and Street Cred (1-50) to the slider values. Set attributes to 20 fills Body, Reflexes, Technical, Intelligence, and Cool. Point grants add unspent points you still spend on the character screen.")
        local level, levelChanged = ImGui.SliderInt("Level target", QoL.state.levelTarget, 1, 60, "%d")
        QoL.state.levelTarget = level
        if ImGui.Button("Set level") then
            QoL.setPlayerLevel()
        end
        local cred, credChanged = ImGui.SliderInt("Street Cred target", QoL.state.streetCredTarget, 1, 50, "%d")
        QoL.state.streetCredTarget = cred
        if ImGui.Button("Set Street Cred") then
            QoL.setStreetCred()
        end
        if ImGui.Button("Set attributes to 20") then
            QoL.maxAttributes()
        end
        local ap, apChanged = ImGui.SliderInt("Attribute points to grant", QoL.state.attributePoints, 1, 50, "%d")
        QoL.state.attributePoints = ap
        if ImGui.Button("Grant attribute points") then
            QoL.grantAttributePoints()
        end
        local pp, ppChanged = ImGui.SliderInt("Perk points to grant", QoL.state.perkPoints, 1, 50, "%d")
        QoL.state.perkPoints = pp
        if ImGui.Button("Grant perk points") then
            QoL.grantPerkPoints()
        end
        if levelChanged or credChanged or apChanged or ppChanged then
            save()
        end
    end

    if ImGui.CollapsingHeader("Skillbooks") then
        ImGui.TextWrapped("Puts skillbooks in inventory. Use them from the inventory to add XP toward Solo, Headhunter, Netrunner, Shinobi, Engineer, relic, perk, or attribute points. Count is how many of each you get.")
        local count, countChanged = ImGui.SliderInt("Skillbook count", QoL.state.skillbookCount, 1, 20, "%d")
        QoL.state.skillbookCount = count
        if countChanged then
            save()
        end
        if ImGui.Button("Grant all skillbooks") then
            QoL.grantAllSkillbooks()
        end
        for _, group in ipairs(QoL.skillbooks) do
            if ImGui.Button(group.label) then
                QoL.grantSkillbookGroup(group)
            end
        end
    end

    if ImGui.CollapsingHeader("Cyberware (inventory only)") then
        ImGui.TextWrapped("Adds cyberware items to inventory only. Start with capacity so you can actually equip more implants. Missing IDs on this patch are skipped. Go to a ripper to install them.")
        for _, group in ipairs(QoL.cyberware) do
            if ImGui.Button(group.label) then
                QoL.grantCategory(group)
            end
            if group.note and group.note ~= "" then
                tooltip(group.note)
            end
        end
    end

    if ImGui.CollapsingHeader("Items") then
        ImGui.TextWrapped("Adds a short list (ammo, crafting mats, consumables, or a handful of iconic weapons). Not every item in the game. Can still bloat a save.")
        for _, group in ipairs(QoL.itemGrants) do
            if ImGui.Button(group.label) then
                QoL.grantCategory(group)
            end
        end
    end

    if ImGui.CollapsingHeader("Classic all-assists and stealth") then
        ImGui.TextWrapped("Classic all-assists turns on every Play Assist and Combat Comfort row at maximum, except Full stealth extras (optical camo recharge, evasion, quickhack immunity, quickhack shield). Crit chance goes to 100% with One-shot crit damage. Those live on Combat Comfort if you want them without the rest of the pack. It does not add money, items, or level.")
        if ImGui.Button("Apply classic all-assists") then
            QoL.classicAllAssists()
            save()
        end
        tooltip("Maxes Play Assist + Combat Comfort, including 100% crit chance and one-shot crit damage. See the Help tab for the full list.")
        if ImGui.Button("Turn off all assists") then
            Assists.resetAll()
            save()
        end
        local stealth, toggled = ImGui.Checkbox("Full stealth assist", QoL.state.fullStealth)
        tooltip("Cuts detection, visibility, and TBH cooldown further, and turns on optical camo, evasion, and hack immunity/shield. Those rows also live on Combat Comfort if you want them one at a time.")
        if toggled then
            QoL.state.fullStealth = stealth
            QoL.applyFullStealth()
            save()
        end
        ImGui.TextDisabled("Full stealth is separate. Classic all-assists does not turn it on.")
    end
end

local function bullet(text)
    ImGui.TextWrapped("- " .. text)
end

local function drawHelpTab()
    ImGui.TextWrapped("How ChoomAssist works. Hover any control for the same text. Tick a checkbox to turn a row on, then use the slider if there is one. Untick to turn it off. Load a save before gameplay assists and Quality of Life buttons will apply.")
    ImGui.Spacing()

    if ImGui.CollapsingHeader("Tabs") then
        bullet("Play Assist: carry, falls, healing (speed / max charges / charges), stamina, oxygen, breach time and loot, Body/Int/Tech skill checks, RAM, RAM on takedown, ultimate/device/stealth hack costs, grenades, launcher, camo mask, overclock, apartment buffs, movement flags.")
        bullet("Combat Comfort: armor, explosion/DoT, adrenaline, detection, visibility, TBH cooldown, mitigation chance/strength, crit, quickhack spread distance/targets. Optical camo, evasion, and hack immunity/shield are Full stealth extras on this tab.")
        bullet("Visual Comfort: turn off blur, grain, chromatic aberration, and similar screen effects.")
        bullet("Performance: turn off shadows, fog, crowds, and other heavy graphics for slower PCs.")
        bullet("Quality of Life: one-shot grants (money, level, books, items) plus Classic all-assists and Full stealth.")
    end

    if ImGui.CollapsingHeader("Classic all-assists") then
        ImGui.TextWrapped("The button on Quality of Life maxes every Play Assist and Combat Comfort row that has its own slider or switch. It is not a hidden pack anymore. After you press it, those tabs show every classic row ticked at maximum. Crit chance will be 100% and One-shot crit damage will be on.")
        ImGui.Spacing()
        ImGui.TextWrapped("It turns on:")
        bullet("Play Assist at max (infinite stamina instead of Extra stamina), including each gadget, hack cost, and skill-check row separately.")
        bullet("Combat Comfort at max, including Crit chance 100%, One-shot crit damage, detection/visibility/TBH, mitigation chance and strength, and spread distance/targets.")
        ImGui.Spacing()
        ImGui.TextWrapped("It does not:")
        bullet("Add eddies, items, skillbooks, level, or Street Cred.")
        bullet("Set attributes or grant perk points.")
        bullet("Turn on Full stealth extras: optical camo recharge, evasion, quickhack immunity, or quickhack shield. Use the Full stealth checkbox or tick those Combat Comfort rows yourself.")
        bullet("Change Visual Comfort or Performance graphics.")
        ImGui.Spacing()
        ImGui.TextWrapped("Turn it off with Turn off all assists on Play Assist, Combat Comfort, or Quality of Life.")
    end

    if ImGui.CollapsingHeader("Full stealth extras") then
        ImGui.TextWrapped("Classic all-assists does not include these. They are on Combat Comfort, and the Full stealth checkbox turns them all on at once:")
        bullet("Faster optical camo recharge")
        bullet("Extra evasion")
        bullet("Quickhack immunity")
        bullet("Quickhack shield")
        ImGui.Spacing()
        ImGui.TextWrapped("Full stealth also pushes detection, visibility, TBH cooldown, and mitigation to strong values. Unticking Full stealth turns the four extras off and leaves the detection/mitigation sliders as they are.")
    end

    if ImGui.CollapsingHeader("How to get high crit without Classic") then
        ImGui.TextWrapped("Open Combat Comfort (not Play Assist, not the QoL sliders).")
        bullet("Tick Crit chance and drag it to 100% for always-crit.")
        bullet("Tick One-shot crit damage for the huge crit damage Classic uses.")
        bullet("Or tick Crit damage bonus and pick a smaller number if you do not want one-shots. One-shot and Crit damage bonus cannot both be on.")
    end

    if ImGui.CollapsingHeader("Vanilla game settings") then
        ImGui.TextWrapped("Settings > Accessibility in the game menu still handles bigger fonts, bigger HUD, and HUD chromatic aberration. ChoomAssist does not replace those.")
    end
end

function UI.draw()
    if not UI.overlayOpen then
        return
    end

    ImGui.SetNextWindowPos(80, 80, ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSize(600, 700, ImGuiCond.FirstUseEver)
    local visible = ImGui.Begin("ChoomAssist")
    if visible then
        ImGui.TextWrapped("Accessibility and quality-of-life for Cyberpunk 2077. Opens with the CET overlay. The Help tab explains Classic all-assists and crit.")
        ImGui.Spacing()
        if ImGui.BeginTabBar("ChoomAssistTabs") then
            if ImGui.BeginTabItem("Play Assist") then
                drawAssistTab("play", "Tick a row to turn it on, then set how much with the slider. Untick to restore the game default. Rows are split so grenades, RAM, skill checks, and hack costs can be set one at a time. These persist in settings.json and come back when you load a save.")
                ImGui.EndTabItem()
            end
            if ImGui.BeginTabItem("Combat Comfort") then
                drawAssistTab("combat", "Easier fights. Crit chance and One-shot crit damage are on this tab (that is what Classic all-assists uses for crit). Detection, visibility, and mitigation are separate sliders. Optical camo, evasion, and hack immunity are Full stealth extras — Classic does not turn those on.")
                ImGui.EndTabItem()
            end
            if ImGui.BeginTabItem("Visual Comfort") then
                drawVisualTab()
                ImGui.EndTabItem()
            end
            if ImGui.BeginTabItem("Performance") then
                drawPerformanceTab()
                ImGui.EndTabItem()
            end
            if ImGui.BeginTabItem("Quality of Life") then
                drawQoLTab()
                ImGui.EndTabItem()
            end
            if ImGui.BeginTabItem("Help") then
                drawHelpTab()
                ImGui.EndTabItem()
            end
            ImGui.EndTabBar()
        end
        ImGui.Spacing()
        ImGui.Separator()
        if Compat.lastMessage ~= "" then
            ImGui.TextWrapped(Compat.lastMessage)
        end
    end
    ImGui.End()
end

return UI
