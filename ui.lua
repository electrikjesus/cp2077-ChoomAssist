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
    tooltip("Turns off Play Assist, Combat Comfort, and the classic bundle extras.")
    ImGui.Spacing()
    ImGui.Separator()
    ImGui.Spacing()
    for _, spec in ipairs(Assists.defsForTab(tab)) do
        drawAssist(spec)
        ImGui.Spacing()
    end
end

local function drawGraphicsOption(graphicsOption)
    Graphics.syncFromGame(graphicsOption)
    local value, toggled = ImGui.Checkbox(graphicsOption.name, graphicsOption.defaultvalue)
    tooltip(graphicsOption.note)
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
    ImGui.TextWrapped("Blur, grain, and other effects that can make the game harder to look at. Unchecked = off. Font and HUD size are still in the game's Settings > Accessibility.")
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
    ImGui.TextWrapped("Graphics toggles for slower PCs (same kind of GameOptions Potato uses). Crowd and weather may need a time skip or a new area.")
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
    ImGui.TextWrapped("Skip grind and shopping. Items go to inventory. Equip cyberware at a ripper; this mod won't slot it for you. Big grants can bloat a save.")
    ImGui.Spacing()
    if not sessionGate() then
        ImGui.Spacing()
    end

    if ImGui.CollapsingHeader("Eddies") then
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
        ImGui.TextWrapped("Grab capacity first. Anything missing on this patch gets skipped. Equip at a ripper.")
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
        ImGui.TextWrapped("Short lists only, not every item in the game. This can still bloat a save.")
        for _, group in ipairs(QoL.itemGrants) do
            if ImGui.Button(group.label) then
                QoL.grantCategory(group)
            end
        end
    end

    if ImGui.CollapsingHeader("Classic bundle and stealth") then
        ImGui.TextWrapped("Classic all-assists is the old EZGodMode one-click pack, high crit included. Play Assist and Combat Comfort stay on their own sliders.")
        if ImGui.Button("Apply classic all-assists") then
            QoL.classicAllAssists()
            save()
        end
        if ImGui.Button("Turn off all assists") then
            Assists.resetAll()
            save()
        end
        local critState = Assists.state.classicCrit
        if critState then
            local critOn, critToggled = ImGui.Checkbox("Classic high crit (from classic bundle)", critState.enabled)
            tooltip("Old EZGodMode crit values. Stays off unless you hit classic all-assists.")
            if critToggled then
                critState.enabled = critOn
                Assists.commit("classicCrit")
                save()
            end
        end
        local stealth, toggled = ImGui.Checkbox("Full stealth assist", QoL.state.fullStealth)
        tooltip("Very low detection and faster optical camo.")
        if toggled then
            QoL.state.fullStealth = stealth
            QoL.applyFullStealth()
            save()
        end
    end
end

function UI.draw()
    if not UI.overlayOpen then
        return
    end

    ImGui.SetNextWindowPos(80, 80, ImGuiCond.FirstUseEver)
    ImGui.SetNextWindowSize(560, 640, ImGuiCond.FirstUseEver)
    local visible = ImGui.Begin("ChoomAssist")
    if visible then
        ImGui.TextWrapped("Accessibility / QoL for Cyberpunk 2077. This window opens with the CET overlay. Hotkeys are optional.")
        ImGui.Spacing()
        if ImGui.BeginTabBar("ChoomAssistTabs") then
            if ImGui.BeginTabItem("Play Assist") then
                drawAssistTab("play", "Carry weight, timers, stamina, and similar. Tick a row, then set how much. Untick to turn it off.")
                ImGui.EndTabItem()
            end
            if ImGui.BeginTabItem("Combat Comfort") then
                drawAssistTab("combat", "Easier fights without the old one-shot crit pack. Harder to detect is not full stealth.")
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
