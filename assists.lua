-- ChoomAssist gameplay assists (Play Assist + Combat Comfort)
-- Copyright (C) 2021-2026 Jon West <electrikjesus@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

local Compat = require("compat.lua")

local Assists = {
    defs = {},
    byId = {},
    state = {},
    handles = {},
    unavailable = {},
}

local function define(spec)
    table.insert(Assists.defs, spec)
    Assists.byId[spec.id] = spec
end

local function times(value)
    return value - 1
end

define({
    id = "carryCapacity",
    tab = "play",
    kind = "slider",
    label = "Extra carry capacity",
    tooltip = "Inventory weight multiplier. Fewer trips to stash or vendors.",
    min = 1, max = 20, default = 3, classic = 20,
    format = "Carry %.0fx",
    modifiers = function(value)
        return { { "CarryCapacity", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "fallDamage",
    tab = "play",
    kind = "slider",
    label = "Fall damage remaining",
    tooltip = "How much fall damage you still take. 100% is vanilla. 0% is none.",
    min = 0, max = 100, default = 50, classic = 0,
    format = "Fall damage %.0f%%",
    modifiers = function(value)
        if value >= 99.5 then
            return {}
        end
        return { { "FallDamageReduction", "Additive", 100 - value } }
    end,
})

define({
    id = "healSpeed",
    tab = "play",
    kind = "slider",
    label = "Faster healing item recharge",
    tooltip = "How quickly inhaler / injector charges come back.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Heal recharge %.0fx faster",
    modifiers = function(value)
        return { { "HealingItemsRechargeDuration", "Multiplier", 1 / value } }
    end,
})

define({
    id = "healCharges",
    tab = "play",
    kind = "slider",
    label = "Extra healing charges",
    tooltip = "More charges on healing items.",
    min = 1, max = 20, default = 2, classic = 20,
    format = "Heal charges %.0fx",
    modifiers = function(value)
        return {
            { "HealingItemMaxCharges", "AdditiveMultiplier", times(value) },
            { "HealingItemsCharges", "AdditiveMultiplier", times(value) },
        }
    end,
})

define({
    id = "stamina",
    tab = "play",
    kind = "slider",
    label = "Extra stamina",
    tooltip = "Stamina multiplier. Turn off if you use Infinite stamina.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Stamina %.0fx",
    modifiers = function(value)
        return { { "Stamina", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "infiniteStamina",
    tab = "play",
    kind = "toggle",
    label = "Infinite stamina",
    tooltip = "Sprint, jump, and melee without draining stamina. Don't use this with Extra stamina.",
    default = 1, classic = 1,
    applySpecial = function(enabled)
        if enabled then
            if Compat.infiniteStamina(true) then
                return true
            end
            local handle = Compat.addModifier("Stamina", "Additive", 99999999)
            return handle ~= nil, { handle }
        end
        Compat.infiniteStamina(false)
        return true, {}
    end,
})

define({
    id = "oxygen",
    tab = "play",
    kind = "slider",
    label = "Extra oxygen",
    tooltip = "Longer breath while underwater or in smoke.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Oxygen %.0fx",
    modifiers = function(value)
        return { { "Oxygen", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "breachTime",
    tab = "play",
    kind = "slider",
    label = "Extra breach time",
    tooltip = "More time on breach protocol minigames.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Breach time %.0fx",
    modifiers = function(value)
        return {
            { "MinigameTimeLimitExtension", "AdditiveMultiplier", times(value) },
            { "MinigameMaterialsEarned", "AdditiveMultiplier", times(value) },
        }
    end,
})

define({
    id = "skillCheck",
    tab = "play",
    kind = "slider",
    label = "Skill-check assist",
    tooltip = "Bonus on Body / Intelligence / Technical Ability checks.",
    min = 0, max = 20, default = 5, classic = 20,
    format = "Skill-check +%.0f",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        return {
            { "StrengthSkillcheckBonus", "Additive", value },
            { "IntelligenceSkillcheckBonus", "Additive", value },
            { "TechnicalAbilitySkillcheckBonus", "Additive", value },
        }
    end,
})

define({
    id = "memory",
    tab = "play",
    kind = "slider",
    label = "Extra RAM",
    tooltip = "More cyberdeck memory for quickhacks.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "RAM %.0fx",
    modifiers = function(value)
        return {
            { "Memory", "AdditiveMultiplier", times(value) },
            { "RestoreMemoryOnDefeat", "AdditiveMultiplier", times(value) },
        }
    end,
})

define({
    id = "hackCost",
    tab = "play",
    kind = "slider",
    label = "Quickhack cost reduction",
    tooltip = "Lower RAM cost for hacks. 0% is vanilla.",
    min = 0, max = 90, default = 25, classic = 90,
    format = "Hack cost -%.0f%%",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        return {
            { "UltimateMemoryCostReduction", "Additive", value },
            { "DeviceMemoryCostReduction", "Additive", value },
            { "StealthHacksCostReduction", "Additive", value },
        }
    end,
})

define({
    id = "gadgetRecharge",
    tab = "play",
    kind = "slider",
    label = "Faster gadget recharge",
    tooltip = "Grenades, projectile launcher, optical camo mask, and overclock recharge faster.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Gadget recharge %.0fx faster",
    modifiers = function(value)
        local duration = 1 / value
        return {
            { "GrenadesRechargeDuration", "Multiplier", duration },
            { "GrenadesMaxCharges", "AdditiveMultiplier", times(value) },
            { "ProjectileLauncherRechargeDuration", "Multiplier", duration },
            { "ProjectileLauncherMaxCharges", "AdditiveMultiplier", times(value) },
            { "CWMaskRechargeDuration", "Multiplier", duration },
            { "CWMaskMaxCharges", "AdditiveMultiplier", times(value) },
            { "CyberdeckOverclockCooldown", "Multiplier", duration },
            { "HousingBuffsDurationBonus", "AdditiveMultiplier", times(value) },
        }
    end,
})

local movementFlags = {
    { id = "canCrouch", label = "Always allow crouch", stat = "CanCrouch" },
    { id = "canSprint", label = "Always allow sprint", stat = "CanSprint" },
    { id = "canJump", label = "Always allow jump", stat = "CanJump" },
    { id = "hasDodge", label = "Always allow dodge", stat = "HasDodge" },
    { id = "hasDoubleJump", label = "Always allow double jump", stat = "HasDoubleJump" },
    { id = "hasSmartLink", label = "Always allow smart-link", stat = "HasSmartLink" },
}

for _, flag in ipairs(movementFlags) do
    local statName = flag.stat
    define({
        id = flag.id,
        tab = "play",
        kind = "toggle",
        label = flag.label,
        tooltip = "Keeps this movement option available if gear or a status would block it.",
        default = 1, classic = 1,
        modifiers = function()
            return { { statName, "Additive", 1 } }
        end,
    })
end

define({
    id = "armor",
    tab = "combat",
    kind = "slider",
    label = "Armor",
    tooltip = "Armor multiplier for taking fewer hits.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Armor %.0fx",
    modifiers = function(value)
        return { { "Armor", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "explosionReduction",
    tab = "combat",
    kind = "slider",
    label = "Explosion damage reduction",
    tooltip = "Reduce explosion damage. 0% is vanilla.",
    min = 0, max = 90, default = 25, classic = 90,
    format = "Explosion -%.0f%%",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        return { { "DamageReductionExplosion", "Additive", value } }
    end,
})

define({
    id = "dotReduction",
    tab = "combat",
    kind = "slider",
    label = "Damage-over-time reduction",
    tooltip = "Reduce burn, poison, and similar damage over time.",
    min = 0, max = 90, default = 25, classic = 90,
    format = "DoT -%.0f%%",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        return { { "DamageReductionDamageOverTime", "Additive", value } }
    end,
})

define({
    id = "adrenaline",
    tab = "combat",
    kind = "slider",
    label = "Adrenaline",
    tooltip = "Extra adrenaline / second-wind comfort.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Adrenaline %.0fx",
    modifiers = function(value)
        return { { "Adrenaline", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "detection",
    tab = "combat",
    kind = "slider",
    label = "Harder to detect",
    tooltip = "Lower enemy detection. This isn't full stealth.",
    min = 0, max = 90, default = 25, classic = 90,
    format = "Detection -%.0f%%",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        local remaining = 1 - (value / 100)
        if remaining < 0.05 then
            remaining = 0.05
        end
        return {
            { "Detection", "Multiplier", remaining },
            { "Visibility", "Multiplier", remaining },
            { "TBHsVisibilityCooldown", "Multiplier", remaining },
        }
    end,
})

define({
    id = "mitigation",
    tab = "combat",
    kind = "slider",
    label = "Mitigation chance",
    tooltip = "Chance to mitigate incoming hits.",
    min = 0, max = 90, default = 10, classic = 50,
    format = "Mitigation %.0f%%",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        return {
            { "MitigationChance", "Additive", value },
            { "MitigationStrength", "AdditiveMultiplier", value / 100 },
        }
    end,
})

define({
    id = "classicCrit",
    tab = "hidden",
    kind = "toggle",
    label = "Classic crit",
    tooltip = "",
    default = 1, classic = 1,
    modifiers = function()
        return {
            { "CritChance", "Additive", 100 },
            { "CritDamage", "Additive", 999999 },
            { "QuickHackSpreadDistance", "AdditiveMultiplier", 8 },
            { "QuickHackSpreadNumber", "AdditiveMultiplier", 4 },
        }
    end,
})

function Assists.ensureState()
    for _, spec in ipairs(Assists.defs) do
        if Assists.state[spec.id] == nil then
            Assists.state[spec.id] = {
                enabled = false,
                value = spec.default or 1,
            }
        else
            if Assists.state[spec.id].value == nil then
                Assists.state[spec.id].value = spec.default or 1
            end
            if Assists.state[spec.id].enabled == nil then
                Assists.state[spec.id].enabled = false
            end
        end
    end
end

function Assists.defsForTab(tab)
    local list = {}
    for _, spec in ipairs(Assists.defs) do
        if spec.tab == tab then
            table.insert(list, spec)
        end
    end
    return list
end

function Assists.remove(id)
    local list = Assists.handles[id]
    if list then
        for _, handle in ipairs(list) do
            Compat.removeModifier(handle)
        end
    end
    Assists.handles[id] = nil
    local spec = Assists.byId[id]
    if spec and spec.id == "infiniteStamina" then
        Compat.infiniteStamina(false)
    end
end

local function mutexStamina(id)
    if id == "infiniteStamina" and Assists.state.infiniteStamina and Assists.state.infiniteStamina.enabled then
        if Assists.state.stamina then
            Assists.state.stamina.enabled = false
        end
        Assists.remove("stamina")
    elseif id == "stamina" and Assists.state.stamina and Assists.state.stamina.enabled then
        if Assists.state.infiniteStamina then
            Assists.state.infiniteStamina.enabled = false
        end
        Assists.remove("infiniteStamina")
    end
end

function Assists.apply(id)
    Assists.remove(id)
    local spec = Assists.byId[id]
    local state = Assists.state[id]
    if spec == nil or state == nil or not state.enabled then
        return
    end
    if spec.applySpecial then
        local ok, handles = spec.applySpecial(true)
        if ok then
            Assists.unavailable[id] = false
            Assists.handles[id] = handles or {}
        else
            Assists.unavailable[id] = true
            Compat.status(spec.label .. " doesn't work on this patch")
        end
        return
    end
    if not Compat.inSession() then
        return
    end
    local maps = spec.modifiers(state.value or spec.default)
    local handles = {}
    local any = false
    local failed = 0
    for _, map in ipairs(maps) do
        local handle = Compat.addModifier(map[1], map[2], map[3])
        if handle then
            table.insert(handles, handle)
            any = true
        else
            failed = failed + 1
        end
    end
    Assists.handles[id] = handles
    if failed > 0 and not any then
        Assists.unavailable[id] = true
        Compat.status(spec.label .. " doesn't work on this patch")
    else
        Assists.unavailable[id] = false
    end
end

function Assists.commit(id)
    Assists.ensureState()
    mutexStamina(id)
    Assists.apply(id)
end

function Assists.reapplyAll()
    Assists.ensureState()
    if not Compat.inSession() then
        return
    end
    for _, spec in ipairs(Assists.defs) do
        Assists.apply(spec.id)
    end
end

function Assists.clearHandles()
    local ids = {}
    for id, _ in pairs(Assists.handles) do
        table.insert(ids, id)
    end
    for _, id in ipairs(ids) do
        Assists.remove(id)
    end
    Assists.handles = {}
    Compat.infiniteStamina(false)
end

function Assists.exportState()
    Assists.ensureState()
    return Assists.state
end

function Assists.loadState(saved)
    if type(saved) == "table" then
        Assists.state = saved
    else
        Assists.state = {}
    end
    Assists.ensureState()
end

function Assists.resetAll()
    Assists.ensureState()
    for _, spec in ipairs(Assists.defs) do
        Assists.state[spec.id].enabled = false
        Assists.state[spec.id].value = spec.default or 1
    end
    Assists.reapplyAll()
    Compat.status("All play and combat assists turned off.")
end

function Assists.applyClassicBundle()
    Assists.ensureState()
    for _, spec in ipairs(Assists.defs) do
        if spec.tab == "play" or spec.tab == "combat" or spec.tab == "hidden" then
            Assists.state[spec.id].enabled = true
            if spec.kind == "slider" then
                Assists.state[spec.id].value = spec.classic or spec.max or spec.default
            end
        end
    end
    -- Classic bundle used infinite stamina, not both stamina boosts stacked.
    Assists.state.stamina.enabled = false
    Assists.state.infiniteStamina.enabled = true
    Assists.reapplyAll()
    Compat.status("Classic all-assists on (old EZGodMode pack).")
end

return Assists
