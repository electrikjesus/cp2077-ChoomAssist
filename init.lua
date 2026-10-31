-- ChoomAssist for Cyberpunk 2077
-- Accessibility overlay (CET-only).
--
-- Copyright (C) 2021-2026 Jon West <electrikjesus@gmail.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

local Compat = require("compat.lua")
local Assists = require("assists.lua")
local Graphics = require("graphics.lua")
local QoL = require("qol.lua")
local UI = require("ui.lua")

local SETTINGS_FILE = "settings.json"

local function encode(settings)
    if json and json.encode then
        return json.encode(settings)
    end
    return nil
end

local function decode(raw)
    if json and json.decode then
        local ok, settings = pcall(json.decode, raw)
        if ok then
            return settings
        end
    end
    return nil
end

local function collectSettings()
    return {
        assists = Assists.exportState(),
        graphics = Graphics.export(),
        qol = QoL.export(),
    }
end

local function saveSettings()
    local encoded = encode(collectSettings())
    if encoded == nil then
        return
    end
    local file = io.open(SETTINGS_FILE, "w")
    if file then
        file:write(encoded)
        file:close()
    end
end

local function loadSettings()
    local file = io.open(SETTINGS_FILE, "r")
    if not file then
        Assists.ensureState()
        return
    end
    local raw = file:read("*a")
    file:close()
    local settings = decode(raw)
    if type(settings) ~= "table" then
        Assists.ensureState()
        return
    end
    Assists.loadState(settings.assists)
    QoL.loadState(settings.qol)
    Graphics.applySaved(settings.graphics)
end

local function onPlayerAttached(self)
    if self == nil then
        return
    end
    local skip = false
    pcall(function()
        if self:IsReplacer() then
            skip = true
        end
    end)
    if skip then
        return
    end
    Compat.clearDeathMenuBlock()
    Assists.reapplyAll()
    QoL.reapplyStealth()
end

local function onPlayerDetach(self)
    if self == nil then
        return
    end
    local skip = false
    pcall(function()
        if self:IsReplacer() then
            skip = true
        end
    end)
    if skip then
        return
    end
    Assists.clearHandles()
    QoL.clearStealthHandles()
end

registerForEvent("onInit", function()
    UI.setSaveHandler(saveSettings)
    loadSettings()
    Observe("PlayerPuppet", "OnGameAttached", onPlayerAttached)
    Observe("PlayerPuppet", "OnDetach", onPlayerDetach)
    print("************************************************")
    print("* ChoomAssist loaded (CET overlay, no hotkeys required)")
    print("************************************************")
end)

registerForEvent("onUpdate", function(delta)
    Assists.tick(delta)
end)

registerForEvent("onOverlayOpen", function()
    UI.overlayOpen = true
end)

registerForEvent("onOverlayClose", function()
    UI.overlayOpen = false
end)

registerForEvent("onDraw", function()
    UI.draw()
end)

-- Optional hotkeys. Bind them in CET if you want; the overlay does not need them.
registerHotkey("ChoomAssist_classicAllAssists", "ChoomAssist: Classic all-assists", function()
    QoL.classicAllAssists()
    saveSettings()
end)

registerHotkey("ChoomAssist_addMoney", "ChoomAssist: Add eddies", function()
    QoL.addMoney()
end)

registerHotkey("ChoomAssist_fullStealth", "ChoomAssist: Toggle full stealth", function()
    QoL.state.fullStealth = not QoL.state.fullStealth
    QoL.applyFullStealth()
    saveSettings()
end)

registerHotkey("ChoomAssist_infiniteStamina", "ChoomAssist: Toggle infinite stamina", function()
    Assists.ensureState()
    local state = Assists.state.infiniteStamina
    state.enabled = not state.enabled
    Assists.commit("infiniteStamina")
    saveSettings()
end)
