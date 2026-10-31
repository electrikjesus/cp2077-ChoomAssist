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
    group = "Carry and falls",
    kind = "slider",
    label = "Extra carry capacity",
    tooltip = "Multiplies how much you can carry. 1x is the game default. 3x means three times that weight before you are overencumbered. Untick to go back to normal.",
    min = 1, max = 20, default = 3, classic = 20,
    format = "Carry %.0fx",
    modifiers = function(value)
        return { { "CarryCapacity", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "fallDamage",
    tab = "play",
    group = "Carry and falls",
    kind = "slider",
    label = "Fall damage remaining",
    tooltip = "How much fall damage you still take. 100% is the game default. 50% is half. 0% means falls do not hurt you. Untick to restore default fall damage.",
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
    group = "Healing",
    kind = "slider",
    label = "Faster healing item recharge",
    tooltip = "Speeds up how fast inhaler and injector charges refill. 2x means they come back twice as fast. Does not spawn extra inhalers; it only shortens the wait.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Heal recharge %.0fx faster",
    modifiers = function(value)
        return { { "HealingItemsRechargeDuration", "Multiplier", 1 / value } }
    end,
})

define({
    id = "healMaxCharges",
    tab = "play",
    group = "Healing",
    kind = "slider",
    label = "Healing item max charges",
    tooltip = "Raises the maximum number of charges an inhaler or injector can hold. 2x is twice the usual cap. Separate from how fast they refill.",
    min = 1, max = 20, default = 2, classic = 20,
    format = "Max charges %.0fx",
    modifiers = function(value)
        return { { "HealingItemMaxCharges", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "healCharges",
    tab = "play",
    group = "Healing",
    kind = "slider",
    label = "Healing item charges",
    tooltip = "Raises current healing-item charges. 2x is twice as many charges ready to use. Separate from max charges and refill speed.",
    min = 1, max = 20, default = 2, classic = 20,
    format = "Charges %.0fx",
    modifiers = function(value)
        return { { "HealingItemsCharges", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "stamina",
    tab = "play",
    group = "Stamina and breath",
    kind = "slider",
    label = "Extra stamina",
    tooltip = "Multiplies max stamina. Use this for a boost, or use Infinite stamina instead. Both on at once is blocked so they do not stack.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Stamina %.0fx",
    modifiers = function(value)
        return { { "Stamina", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "infiniteStamina",
    tab = "play",
    group = "Stamina and breath",
    kind = "toggle",
    label = "Infinite stamina",
    tooltip = "Sprint, jump, melee, and similar actions do not drain stamina. If the game command is missing, a huge stamina pool is used instead. Do not combine with Extra stamina.",
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
    group = "Stamina and breath",
    kind = "slider",
    label = "Extra oxygen",
    tooltip = "Multiplies oxygen / breath. Helps underwater and in smoke. 1x is the game default.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Oxygen %.0fx",
    modifiers = function(value)
        return { { "Oxygen", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "breachTime",
    tab = "play",
    group = "Breach minigame",
    kind = "slider",
    label = "Extra breach time",
    tooltip = "Adds time to the breach-protocol minigame. 2x is twice the usual time budget. Does not change loot from the minigame.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Breach time %.0fx",
    modifiers = function(value)
        return { { "MinigameTimeLimitExtension", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "breachLoot",
    tab = "play",
    group = "Breach minigame",
    kind = "slider",
    label = "Extra breach loot",
    tooltip = "Increases materials earned from breach minigames. 2x is twice the usual loot. Does not add extra time.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Breach loot %.0fx",
    modifiers = function(value)
        return { { "MinigameMaterialsEarned", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "skillCheckBody",
    tab = "play",
    group = "Skill checks",
    kind = "slider",
    label = "Body skill-check bonus",
    tooltip = "Adds a bonus to Body (Strength) skill checks in dialogue and the world. 0 is no bonus. 20 is a large bump. Does not change Intelligence or Technical checks.",
    min = 0, max = 20, default = 5, classic = 20,
    format = "Body check +%.0f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "StrengthSkillcheckBonus", "Additive", value } }
    end,
})

define({
    id = "skillCheckInt",
    tab = "play",
    group = "Skill checks",
    kind = "slider",
    label = "Intelligence skill-check bonus",
    tooltip = "Adds a bonus to Intelligence skill checks. 0 is no bonus. 20 is a large bump. Does not change Body or Technical checks.",
    min = 0, max = 20, default = 5, classic = 20,
    format = "Int check +%.0f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "IntelligenceSkillcheckBonus", "Additive", value } }
    end,
})

define({
    id = "skillCheckTech",
    tab = "play",
    group = "Skill checks",
    kind = "slider",
    label = "Technical skill-check bonus",
    tooltip = "Adds a bonus to Technical Ability skill checks. 0 is no bonus. 20 is a large bump. Does not change Body or Intelligence checks.",
    min = 0, max = 20, default = 5, classic = 20,
    format = "Tech check +%.0f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "TechnicalAbilitySkillcheckBonus", "Additive", value } }
    end,
})

define({
    id = "memory",
    tab = "play",
    group = "Netrunning",
    kind = "slider",
    label = "Extra RAM",
    tooltip = "Multiplies cyberdeck RAM (memory) for quickhacks. 1x is the game default. Does not change RAM restored on takedown.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "RAM %.0fx",
    modifiers = function(value)
        return { { "Memory", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "memoryOnDefeat",
    tab = "play",
    group = "Netrunning",
    kind = "slider",
    label = "Restore RAM on takedown",
    tooltip = "Restores extra RAM when you take someone down. 1x is the game default. Does not raise max RAM.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "RAM on takedown %.0fx",
    modifiers = function(value)
        return { { "RestoreMemoryOnDefeat", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "hackCostUltimate",
    tab = "play",
    group = "Netrunning",
    kind = "slider",
    label = "Ultimate hack cost reduction",
    tooltip = "Lowers RAM cost of ultimate quickhacks. 0% is the game default. 90% makes them much cheaper. Does not change device or stealth hack cost.",
    min = 0, max = 90, default = 25, classic = 90,
    format = "Ultimate cost -%.0f%%",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "UltimateMemoryCostReduction", "Additive", value } }
    end,
})

define({
    id = "hackCostDevice",
    tab = "play",
    group = "Netrunning",
    kind = "slider",
    label = "Device hack cost reduction",
    tooltip = "Lowers RAM cost of device quickhacks (cameras, turrets, etc.). 0% is the game default. Does not change ultimate or stealth hack cost.",
    min = 0, max = 90, default = 25, classic = 90,
    format = "Device cost -%.0f%%",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "DeviceMemoryCostReduction", "Additive", value } }
    end,
})

define({
    id = "hackCostStealth",
    tab = "play",
    group = "Netrunning",
    kind = "slider",
    label = "Stealth hack cost reduction",
    tooltip = "Lowers RAM cost of stealth quickhacks. 0% is the game default. Does not make you invisible and does not change ultimate or device cost.",
    min = 0, max = 90, default = 25, classic = 90,
    format = "Stealth hack cost -%.0f%%",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "StealthHacksCostReduction", "Additive", value } }
    end,
})

local function gadgetSpeed(value)
    return 1 / value
end

define({
    id = "grenadeRecharge",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Faster grenade recharge",
    tooltip = "Shortens grenade recharge time. 2x means they refill twice as fast. Does not change how many grenade charges you can hold.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Grenade recharge %.0fx faster",
    modifiers = function(value)
        return { { "GrenadesRechargeDuration", "Multiplier", gadgetSpeed(value) } }
    end,
})

define({
    id = "grenadeCharges",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Grenade max charges",
    tooltip = "Raises how many grenade charges you can hold. 2x is twice the usual cap. Does not change refill speed.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Grenade charges %.0fx",
    modifiers = function(value)
        return { { "GrenadesMaxCharges", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "launcherRecharge",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Faster projectile launcher recharge",
    tooltip = "Shortens arm projectile-launcher recharge. 2x is twice as fast. Does not change max charges.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Launcher recharge %.0fx faster",
    modifiers = function(value)
        return { { "ProjectileLauncherRechargeDuration", "Multiplier", gadgetSpeed(value) } }
    end,
})

define({
    id = "launcherCharges",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Projectile launcher max charges",
    tooltip = "Raises projectile-launcher charge cap. 2x is twice the usual cap. Does not change refill speed.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Launcher charges %.0fx",
    modifiers = function(value)
        return { { "ProjectileLauncherMaxCharges", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "camoMaskRecharge",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Faster camo mask recharge",
    tooltip = "Shortens optical camo mask (CW mask) recharge. 2x is twice as fast. Does not change max charges.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Camo mask recharge %.0fx faster",
    modifiers = function(value)
        return { { "CWMaskRechargeDuration", "Multiplier", gadgetSpeed(value) } }
    end,
})

define({
    id = "camoMaskCharges",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Camo mask max charges",
    tooltip = "Raises optical camo mask charge cap. 2x is twice the usual cap. Does not change refill speed.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Camo mask charges %.0fx",
    modifiers = function(value)
        return { { "CWMaskMaxCharges", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "overclockCooldown",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Faster cyberdeck overclock cooldown",
    tooltip = "Shortens cyberdeck overclock cooldown. 2x means overclock comes back twice as fast.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Overclock cooldown %.0fx faster",
    modifiers = function(value)
        return { { "CyberdeckOverclockCooldown", "Multiplier", gadgetSpeed(value) } }
    end,
})

define({
    id = "housingBuffs",
    tab = "play",
    group = "Gadgets",
    kind = "slider",
    label = "Longer apartment buffs",
    tooltip = "Lengthens buffs from apartments / housing. 2x is twice as long. Does not change grenades or cyberware recharge.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Apartment buffs %.0fx",
    modifiers = function(value)
        return { { "HousingBuffsDurationBonus", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "reaperChipSafety",
    tab = "play",
    group = "Clampdown (Update 2.5)",
    kind = "toggle",
    inClassic = false,
    label = "Reaper chip safety",
    tooltip = "Stops the Night City Prison Reaper chip from flatlining you if guards activate it or the server countdown hits 100%. The Clampdown job still runs; you still deactivate chips at the Reaper Chip Server. Not included in Classic all-assists. Turn it off after the prison.",
    default = 1, classic = 1,
    applySpecial = function(enabled)
        local ok = Compat.setReaperSafety(enabled)
        return ok, {}
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
        group = "Movement",
        kind = "toggle",
        label = flag.label,
        tooltip = "Forces this move to stay available even if a status, item, or missing cyberware would block it. Tick only the moves you want guaranteed.",
        default = 1, classic = 1,
        modifiers = function()
            return { { statName, "Additive", 1 } }
        end,
    })
end

define({
    id = "armor",
    tab = "combat",
    group = "Survival",
    kind = "slider",
    label = "Armor",
    tooltip = "Multiplies armor so you take less damage from hits. 1x is the game default. 10x is a large cushion, not invincible.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Armor %.0fx",
    modifiers = function(value)
        return { { "Armor", "AdditiveMultiplier", times(value) } }
    end,
})

define({
    id = "explosionReduction",
    tab = "combat",
    group = "Survival",
    kind = "slider",
    label = "Explosion damage reduction",
    tooltip = "Cuts explosion damage. 0% is the game default. 90% means explosions do very little. Does not change gun or melee damage.",
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
    group = "Survival",
    kind = "slider",
    label = "Damage-over-time reduction",
    tooltip = "Cuts burn, poison, and other damage-over-time. 0% is the game default. Does not change burst damage from bullets.",
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
    group = "Survival",
    kind = "slider",
    label = "Adrenaline",
    tooltip = "Multiplies adrenaline (second-wind / health-related combat resource). 1x is the game default.",
    min = 1, max = 10, default = 2, classic = 10,
    format = "Adrenaline %.0fx",
    modifiers = function(value)
        return { { "Adrenaline", "AdditiveMultiplier", times(value) } }
    end,
})

local function remainingFromPercentCut(value)
    if value <= 0 then
        return nil
    end
    local remaining = 1 - (value / 100)
    if remaining < 0.05 then
        remaining = 0.05
    end
    return remaining
end

define({
    id = "detection",
    tab = "combat",
    group = "Stealth",
    kind = "slider",
    label = "Lower detection",
    tooltip = "Slows how fast the detection meter fills. 0% is the game default. 90% is very sneaky. Does not change visibility or TBH cooldown. This is not invisibility.",
    min = 0, max = 95, default = 25, classic = 90, stealth = 95,
    format = "Detection -%.0f%%",
    modifiers = function(value)
        local remaining = remainingFromPercentCut(value)
        if not remaining then return {} end
        return { { "Detection", "Multiplier", remaining } }
    end,
})

define({
    id = "visibility",
    tab = "combat",
    group = "Stealth",
    kind = "slider",
    label = "Lower visibility",
    tooltip = "Makes you harder to see. 0% is the game default. Does not change the detection meter or TBH cooldown.",
    min = 0, max = 95, default = 25, classic = 90, stealth = 95,
    format = "Visibility -%.0f%%",
    modifiers = function(value)
        local remaining = remainingFromPercentCut(value)
        if not remaining then return {} end
        return { { "Visibility", "Multiplier", remaining } }
    end,
})

define({
    id = "tbhVis",
    tab = "combat",
    group = "Stealth",
    kind = "slider",
    label = "Longer time-before-hostile cooldown",
    tooltip = "Stretches the cooldown after you leave a hostile's awareness. 0% is the game default. Separate from detection and visibility.",
    min = 0, max = 95, default = 25, classic = 90, stealth = 90,
    format = "TBH cooldown -%.0f%%",
    modifiers = function(value)
        local remaining = remainingFromPercentCut(value)
        if not remaining then return {} end
        return { { "TBHsVisibilityCooldown", "Multiplier", remaining } }
    end,
})

define({
    id = "opticalCamo",
    tab = "combat",
    group = "Stealth",
    kind = "slider",
    inClassic = false,
    inStealth = true,
    label = "Faster optical camo recharge",
    tooltip = "Shortens optical camo recharge duration. 2x is twice as fast. Classic all-assists does not turn this on; Full stealth does. Separate from camo mask charges on Play Assist.",
    min = 1, max = 10, default = 2, classic = 10, stealth = 10,
    format = "Optical camo %.0fx faster",
    modifiers = function(value)
        return { { "OpticalCamoRechargeDuration", "Multiplier", 1 / value } }
    end,
})

define({
    id = "evasion",
    tab = "combat",
    group = "Stealth",
    kind = "slider",
    inClassic = false,
    inStealth = true,
    label = "Extra evasion",
    tooltip = "Adds evasion so attacks miss more often. 0 is no bonus. Classic all-assists does not turn this on; Full stealth does.",
    min = 0, max = 200, default = 10, classic = 50, stealth = 50,
    format = "Evasion +%.0f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "Evasion", "Additive", value } }
    end,
})

define({
    id = "mitigationChance",
    tab = "combat",
    group = "Mitigation",
    kind = "slider",
    label = "Mitigation chance",
    tooltip = "Adds a chance to mitigate (soften) incoming hits. 0% is the game default. Does not change how strong mitigation is when it procs.",
    min = 0, max = 90, default = 10, classic = 50, stealth = 50,
    format = "Mitigation chance +%.0f%%",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "MitigationChance", "Additive", value } }
    end,
})

define({
    id = "mitigationStrength",
    tab = "combat",
    group = "Mitigation",
    kind = "slider",
    label = "Mitigation strength",
    tooltip = "How much damage mitigation removes when it procs. 0% is the game default. Separate from mitigation chance.",
    min = 0, max = 100, default = 10, classic = 50, stealth = 100,
    format = "Mitigation strength +%.0f%%",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "MitigationStrength", "AdditiveMultiplier", value / 100 } }
    end,
})

define({
    id = "critChance",
    tab = "combat",
    group = "Crit",
    kind = "slider",
    label = "Crit chance",
    tooltip = "Adds to your critical hit chance. 0 is no extra chance. 100 means every hit can crit (this is what Classic all-assists sets). Tick this row and move the slider; it is not hidden inside the classic button.",
    min = 0, max = 100, default = 25, classic = 100,
    format = "Crit chance +%.0f%%",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        return { { "CritChance", "Additive", value } }
    end,
})

define({
    id = "critDamage",
    tab = "combat",
    group = "Crit",
    kind = "slider",
    label = "Crit damage bonus",
    tooltip = "Adds extra critical hit damage. Use this for a milder boost. Classic all-assists does not use this slider; it turns on One-shot crit damage below instead. Do not combine both.",
    min = 0, max = 2000, default = 100, classic = 2000,
    format = "Crit damage +%.0f",
    modifiers = function(value)
        if value <= 0 then
            return {}
        end
        return { { "CritDamage", "Additive", value } }
    end,
})

define({
    id = "overkillCrit",
    tab = "combat",
    group = "Crit",
    kind = "toggle",
    label = "One-shot crit damage",
    tooltip = "Adds a huge crit damage bonus so crits drop most enemies in one hit. Classic all-assists turns this on together with Crit chance at 100%. You can tick this here without using Classic all-assists.",
    default = 1, classic = 1,
    modifiers = function()
        return { { "CritDamage", "Additive", 999999 } }
    end,
})

define({
    id = "hackSpreadDistance",
    tab = "combat",
    group = "Quickhacks",
    kind = "slider",
    label = "Quickhack spread distance",
    tooltip = "How far a quickhack can jump to another target. 0 is no extra distance. Classic all-assists sets this high. Does not change how many extra targets.",
    min = 0, max = 10, default = 2, classic = 8,
    format = "Spread distance +%.0f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "QuickHackSpreadDistance", "AdditiveMultiplier", value } }
    end,
})

define({
    id = "hackSpreadNumber",
    tab = "combat",
    group = "Quickhacks",
    kind = "slider",
    label = "Quickhack spread targets",
    tooltip = "How many extra targets a spreading quickhack can hit. 0 is no extra targets. Classic all-assists sets this to 4. Does not change RAM cost.",
    min = 0, max = 8, default = 1, classic = 4,
    format = "Spread targets +%.0f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "QuickHackSpreadNumber", "AdditiveMultiplier", value } }
    end,
})

define({
    id = "qhImmunity",
    tab = "combat",
    group = "Quickhacks",
    kind = "slider",
    inClassic = false,
    inStealth = true,
    label = "Quickhack immunity",
    tooltip = "Raises resistance to incoming quickhacks. 0 is no bonus. Classic all-assists does not turn this on; Full stealth does.",
    min = 0, max = 2, default = 1, classic = 1, stealth = 1,
    format = "Hack immunity +%.1f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "QuickHackImmunity", "AdditiveMultiplier", value } }
    end,
})

define({
    id = "qhShield",
    tab = "combat",
    group = "Quickhacks",
    kind = "slider",
    inClassic = false,
    inStealth = true,
    label = "Quickhack shield",
    tooltip = "Raises quickhack shield. 0 is no bonus. Classic all-assists does not turn this on; Full stealth does.",
    min = 0, max = 2, default = 1, classic = 1, stealth = 1,
    format = "Hack shield +%.1f",
    modifiers = function(value)
        if value <= 0 then return {} end
        return { { "QuickhackShield", "AdditiveMultiplier", value } }
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

function Assists.groupedDefsForTab(tab)
    local groups = {}
    local order = {}
    for _, spec in ipairs(Assists.defs) do
        if spec.tab == tab then
            local name = spec.group or "Other"
            if groups[name] == nil then
                groups[name] = {}
                table.insert(order, name)
            end
            table.insert(groups[name], spec)
        end
    end
    return order, groups
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
    if spec and spec.id == "reaperChipSafety" then
        Compat.setReaperSafety(false)
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

local function mutexCrit(id)
    if id == "overkillCrit" and Assists.state.overkillCrit and Assists.state.overkillCrit.enabled then
        if Assists.state.critDamage then
            Assists.state.critDamage.enabled = false
        end
        Assists.remove("critDamage")
    elseif id == "critDamage" and Assists.state.critDamage and Assists.state.critDamage.enabled then
        if Assists.state.overkillCrit then
            Assists.state.overkillCrit.enabled = false
        end
        Assists.remove("overkillCrit")
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
    mutexCrit(id)
    Assists.apply(id)
end

function Assists.reaperSafetyEnabled()
    Assists.ensureState()
    return Assists.state.reaperChipSafety ~= nil and Assists.state.reaperChipSafety.enabled == true
end

function Assists.shouldBlockReaperKill(entity)
    if not Assists.reaperSafetyEnabled() then
        return false
    end
    if entity == nil then
        return true
    end
    local ok, isPlayer = pcall(function()
        return entity:IsPlayer()
    end)
    return ok and isPlayer == true
end

local reaperTickAccum = 0

function Assists.tick(delta)
    if not Assists.reaperSafetyEnabled() then
        return
    end
    reaperTickAccum = reaperTickAccum + (delta or 0)
    if reaperTickAccum < 0.5 then
        return
    end
    reaperTickAccum = 0
    if not Compat.inSession() then
        return
    end
    Compat.setReaperSafety(true)
end

function Assists.installHooks()
    pcall(function()
        Override("PlayerPuppet", "OnForcedDeathEvent", function(this, evt, wrapped)
            if Assists.shouldBlockReaperKill(this) then
                Compat.refillHealth()
                return
            end
            if wrapped ~= nil then
                wrapped(evt)
            end
        end)
    end)
    pcall(function()
        Observe("PlayerPuppet", "SetWarningMessage", function(_, _, msgType)
            if not Assists.reaperSafetyEnabled() then
                return
            end
            local isReaper = false
            pcall(function()
                isReaper = msgType == SimpleMessageType.Reaper
            end)
            if isReaper then
                Compat.setReaperSafety(true)
                Compat.refillHealth()
            end
        end)
    end)
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
    Compat.setReaperSafety(false)
end

function Assists.exportState()
    Assists.ensureState()
    return Assists.state
end

local function copyIfMissing(fromId, toIds)
    local src = Assists.state[fromId]
    if type(src) ~= "table" then
        return
    end
    for _, toId in ipairs(toIds) do
        if Assists.state[toId] == nil then
            Assists.state[toId] = {
                enabled = src.enabled == true,
                value = src.value,
            }
        end
    end
end

local function migrateLegacyState()
    copyIfMissing("skillCheck", { "skillCheckBody", "skillCheckInt", "skillCheckTech" })
    Assists.state.skillCheck = nil

    copyIfMissing("hackCost", { "hackCostUltimate", "hackCostDevice", "hackCostStealth" })
    Assists.state.hackCost = nil

    copyIfMissing("gadgetRecharge", {
        "grenadeRecharge", "grenadeCharges", "launcherRecharge", "launcherCharges",
        "camoMaskRecharge", "camoMaskCharges", "overclockCooldown", "housingBuffs",
    })
    Assists.state.gadgetRecharge = nil

    copyIfMissing("healCharges", { "healMaxCharges" })
    copyIfMissing("memory", { "memoryOnDefeat" })
    copyIfMissing("breachTime", { "breachLoot" })
    copyIfMissing("detection", { "visibility", "tbhVis" })

    copyIfMissing("mitigation", { "mitigationChance", "mitigationStrength" })
    Assists.state.mitigation = nil

    local spread = Assists.state.hackSpread
    if type(spread) == "table" then
        if Assists.state.hackSpreadDistance == nil then
            Assists.state.hackSpreadDistance = {
                enabled = spread.enabled == true,
                value = (spread.enabled and 8) or 2,
            }
        end
        if Assists.state.hackSpreadNumber == nil then
            Assists.state.hackSpreadNumber = {
                enabled = spread.enabled == true,
                value = (spread.enabled and 4) or 1,
            }
        end
        Assists.state.hackSpread = nil
    end
end

function Assists.loadState(saved)
    if type(saved) == "table" then
        Assists.state = saved
    else
        Assists.state = {}
    end
    migrateLegacyState()
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
        if (spec.tab == "play" or spec.tab == "combat") and spec.inClassic ~= false then
            Assists.state[spec.id].enabled = true
            if spec.kind == "slider" then
                Assists.state[spec.id].value = spec.classic or spec.max or spec.default
            end
        end
    end
    Assists.state.stamina.enabled = false
    Assists.state.infiniteStamina.enabled = true
    Assists.state.critDamage.enabled = false
    Assists.state.overkillCrit.enabled = true
    Assists.state.critChance.enabled = true
    Assists.state.critChance.value = 100
    Assists.reapplyAll()
    Compat.status("Classic all-assists on. Every Play Assist and Combat Comfort row is on at max, except Full stealth extras.")
end

function Assists.applyStealthBundle(on)
    Assists.ensureState()
    local extras = { "opticalCamo", "evasion", "qhImmunity", "qhShield" }
    for _, id in ipairs(extras) do
        local spec = Assists.byId[id]
        if spec and Assists.state[id] then
            Assists.state[id].enabled = on == true
            if on then
                Assists.state[id].value = spec.stealth or spec.classic or spec.default
            end
        end
    end
    if on then
        local bump = { "detection", "visibility", "tbhVis", "mitigationChance", "mitigationStrength" }
        for _, id in ipairs(bump) do
            local spec = Assists.byId[id]
            if spec and Assists.state[id] then
                Assists.state[id].enabled = true
                Assists.state[id].value = spec.stealth or spec.classic or spec.default
            end
        end
    end
    Assists.reapplyAll()
    if on then
        Compat.status("Full stealth on. Combat Comfort now shows the stealth rows at strong values.")
    else
        Compat.status("Full stealth extras off. Detection and mitigation sliders are left as they are.")
    end
end

return Assists
