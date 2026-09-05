-- ChoomAssist Quality of Life grants (inventory, level, attributes, stealth)
-- Copyright (C) 2021-2026 Jon West <electrikjesus@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

local Compat = require("compat.lua")
local Assists = require("assists.lua")

local QoL = {
    state = {
        moneyAmount = 100000,
        skillbookCount = 1,
        levelTarget = 60,
        streetCredTarget = 50,
        attributePoints = 5,
        perkPoints = 5,
        fullStealth = false,
    },
    stealthHandles = {},
}

QoL.skillbooks = {
    { label = "Solo (Body)", ids = { "Items.BodySkill_Skillbook", "Items.BodySkill_Skillbook_Legendary" } },
    { label = "Headhunter (Cool)", ids = { "Items.CoolSkill_Skillbook", "Items.CoolSkill_Skillbook_Legendary" } },
    { label = "Netrunner (Intelligence)", ids = { "Items.IntelligenceSkill_Skillbook", "Items.IntelligenceSkill_Skillbook_Legendary" } },
    { label = "Shinobi (Reflexes)", ids = { "Items.ReflexesSkill_Skillbook", "Items.ReflexesSkill_Skillbook_Legendary" } },
    { label = "Engineer (Technical Ability)", ids = { "Items.TechnicalAbilitySkill_Skillbook", "Items.TechnicalAbilitySkill_Skillbook_Legendary" } },
    { label = "Relic points", ids = { "Items.Espionage_Skillbook" } },
    { label = "Perk points", ids = { "Items.PerkPointSkillbook" } },
    { label = "Attribute points", ids = { "Items.AttributePointSkillbook" } },
}

QoL.cyberware = {
    {
        label = "Cyberware capacity",
        note = "Raises the 2.0+ capacity cap so you can equip more implants.",
        ids = { "Items.CWCapacityPermaReward_Legendary", "Items.CapacityBoosterLegendary" },
    },
    {
        label = "Operating systems",
        ids = {
            "Items.AdvancedSandevistanC4MK5",
            "Items.AdvancedSandevistanApogee",
            "Items.AdvancedBerserkC4MK5",
            "Items.AdvancedCyberdeckC4MK5",
            "Items.AdvancedCyberdeckC5MK5",
        },
    },
    {
        label = "Arms",
        ids = {
            "Items.AdvancedMantisBladesLegendaryPlusPlus",
            "Items.AdvancedGorillaArmsLegendaryPlusPlus",
            "Items.AdvancedMonowireLegendaryPlusPlus",
            "Items.AdvancedProjectileLauncherLegendaryPlusPlus",
            "Items.MantisBladesLegendary",
            "Items.GorillaArmsLegendary",
            "Items.MonoWireLegendary",
            "Items.ProjectileLauncherLegendary",
        },
    },
    {
        label = "Legs",
        ids = {
            "Items.AdvancedBoostedTendonsLegendaryPlusPlus",
            "Items.AdvancedReinforcedMusclesLegendaryPlusPlus",
            "Items.AdvancedLynxPawsLegendaryPlusPlus",
            "Items.BoostedTendonsLegendary",
            "Items.ReinforcedMusclesLegendary",
            "Items.LynxPawsLegendary",
        },
    },
    {
        label = "Circulatory",
        ids = {
            "Items.AdvancedBioconductorLegendaryPlusPlus",
            "Items.AdvancedBloodPumpLegendaryPlusPlus",
            "Items.AdvancedSecondHeart",
            "Items.AdvancedSynLungsLegendaryPlusPlus",
            "Items.BioConductorLegendary",
            "Items.BloodPumpLegendary",
            "Items.SecondHeart",
        },
    },
    {
        label = "Frontal cortex",
        ids = {
            "Items.AdvancedMemoryBoostLegendaryPlusPlus",
            "Items.AdvancedRamUpgradeLegendaryPlusPlus",
            "Items.AdvancedKerenzikovLegendaryPlusPlus",
            "Items.AdvancedMechatronicCoreLegendaryPlusPlus",
            "Items.MemoryBoostLegendary",
            "Items.RamUpgradeLegendary",
            "Items.KerenzikovLegendary",
        },
    },
    {
        label = "Integumentary / camo",
        ids = {
            "Items.AdvancedSubdermalArmorLegendaryPlusPlus",
            "Items.AdvancedOpticalCamoLegendaryPlusPlus",
            "Items.AdvancedPainEditor",
            "Items.SubdermalArmorLegendary",
            "Items.OpticalCamoLegendary",
            "Items.PainEditor",
        },
    },
    {
        label = "Nervous system",
        ids = {
            "Items.AdvancedReflexTunerLegendaryPlusPlus",
            "Items.ReflexTunerLegendary",
            "Items.SynapticAcceleratorLegendary",
        },
    },
    {
        label = "Skeleton",
        ids = {
            "Items.AdvancedBionicJointsLegendaryPlusPlus",
            "Items.AdvancedDenseMarrowLegendaryPlusPlus",
            "Items.BionicJointsLegendary",
            "Items.DenseMarrowLegendary",
        },
    },
    {
        label = "Hands / smart-link",
        ids = {
            "Items.AdvancedSmartLinkLegendaryPlusPlus",
            "Items.AdvancedMicroGeneratorLegendaryPlusPlus",
            "Items.SmartLinkLegendary",
            "Items.MicroGeneratorLegendary",
        },
    },
}

QoL.itemGrants = {
    {
        label = "Ammo (all types)",
        count = 500,
        ids = {
            "Ammo.HandgunAmmo",
            "Ammo.RifleAmmo",
            "Ammo.ShotgunAmmo",
            "Ammo.SniperRifleAmmo",
        },
    },
    {
        label = "Crafting components",
        count = 200,
        ids = {
            "Items.CommonMaterial1",
            "Items.UncommonMaterial1",
            "Items.RareMaterial1",
            "Items.EpicMaterial1",
            "Items.LegendaryMaterial1",
        },
    },
    {
        label = "Quickhack components",
        count = 100,
        ids = {
            "Items.QuickHackUncommonMaterial1",
            "Items.QuickHackRareMaterial1",
            "Items.QuickHackEpicMaterial1",
            "Items.QuickHackLegendaryMaterial1",
        },
    },
    {
        label = "Consumables",
        count = 10,
        ids = {
            "Items.FirstAidWhiffV0",
            "Items.FirstAidWhiffV1",
            "Items.BonesMcCoy70V0",
            "Items.CarryCapacityBooster",
            "Items.HealthBooster",
            "Items.StaminaBooster",
            "Items.MemoryBooster",
        },
    },
    {
        label = "Short iconic weapon list",
        count = 1,
        ids = {
            "Items.Preset_Nue_Jackie",
            "Items.Preset_Masamune_Rogue",
            "Items.Preset_Overture_Kerry",
            "Items.Preset_Overture_Cassidy",
            "Items.Preset_Lexington_Wilson",
            "Items.Preset_Grad_Panam",
            "Items.Preset_Achilles_Nash",
            "Items.Preset_Katana_Takemura",
            "Items.Preset_Katana_Saburo",
            "Items.Preset_Carnage_Mox",
            "Items.Preset_Igla_Sovereign",
            "Items.Preset_Copperhead_Genesis",
            "Items.Preset_Ajax_Moron",
            "Items.Preset_Unity_VooDoo",
        },
    },
}

local ATTRIBUTE_NAMES = { "Strength", "Reflexes", "TechnicalAbility", "Intelligence", "Cool" }

function QoL.needSession()
    if Compat.inSession() then
        return true
    end
    Compat.status("Load a save first.")
    return false
end

function QoL.addMoney()
    if not QoL.needSession() then
        return
    end
    local amount = math.floor(QoL.state.moneyAmount or 100000)
    if amount < 1 then
        amount = 1
    end
    local ok = Compat.addItem("Items.money", amount)
    if ok then
        Compat.status(string.format("Added %d eddies.", amount))
    else
        Compat.status("Couldn't add eddies.")
    end
end

function QoL.grantSkillbookGroup(group)
    if not QoL.needSession() then
        return
    end
    local count = math.floor(QoL.state.skillbookCount or 1)
    if count < 1 then
        count = 1
    end
    local added, skipped = Compat.grantItems(group.ids, count)
    Compat.status(string.format("%s: added %d, skipped %d missing on this patch.", group.label, added, skipped))
end

function QoL.grantAllSkillbooks()
    if not QoL.needSession() then
        return
    end
    local count = math.floor(QoL.state.skillbookCount or 1)
    if count < 1 then
        count = 1
    end
    local added = 0
    local skipped = 0
    for _, group in ipairs(QoL.skillbooks) do
        local a, s = Compat.grantItems(group.ids, count)
        added = added + a
        skipped = skipped + s
    end
    Compat.status(string.format("Skillbooks: added %d, skipped %d missing on this patch.", added, skipped))
end

function QoL.setPlayerLevel()
    if not QoL.needSession() then
        return
    end
    local level = math.floor(QoL.state.levelTarget or 60)
    if level < 1 then level = 1 end
    if level > 60 then level = 60 end
    local ok = Compat.setLevel("Level", level)
    if ok then
        Compat.status("Set level to " .. tostring(level) .. ".")
    else
        Compat.status("Couldn't set level on this patch.")
    end
end

function QoL.setStreetCred()
    if not QoL.needSession() then
        return
    end
    local level = math.floor(QoL.state.streetCredTarget or 50)
    if level < 1 then level = 1 end
    if level > 50 then level = 50 end
    local ok = Compat.setLevel("StreetCred", level)
    if ok then
        Compat.status("Set Street Cred to " .. tostring(level) .. ".")
    else
        Compat.status("Couldn't set Street Cred on this patch.")
    end
end

function QoL.maxAttributes()
    if not QoL.needSession() then
        return
    end
    local set = 0
    for _, name in ipairs(ATTRIBUTE_NAMES) do
        if Compat.setAttribute(name, 20) then
            set = set + 1
        end
    end
    -- Body is the display name for Strength on some patches.
    Compat.setAttribute("Body", 20)
    if set > 0 then
        Compat.status("Set attributes toward 20 (" .. tostring(set) .. " applied).")
    else
        Compat.status("Couldn't set attributes on this patch.")
    end
end

function QoL.grantAttributePoints()
    if not QoL.needSession() then
        return
    end
    local amount = math.floor(QoL.state.attributePoints or 5)
    if Compat.addDevPoints(amount, "Attribute") then
        Compat.status("Granted " .. tostring(amount) .. " attribute points.")
    else
        Compat.status("Couldn't grant attribute points.")
    end
end

function QoL.grantPerkPoints()
    if not QoL.needSession() then
        return
    end
    local amount = math.floor(QoL.state.perkPoints or 5)
    if Compat.addDevPoints(amount, "Primary") then
        Compat.status("Granted " .. tostring(amount) .. " perk points.")
    else
        Compat.status("Couldn't grant perk points.")
    end
end

function QoL.grantCategory(group)
    if not QoL.needSession() then
        return
    end
    local count = group.count or 1
    local added, skipped = Compat.grantItems(group.ids, count)
    Compat.status(string.format("%s: added %d, skipped %d missing on this patch.", group.label, added, skipped))
end

function QoL.clearStealthHandles()
    for _, handle in ipairs(QoL.stealthHandles) do
        Compat.removeModifier(handle)
    end
    QoL.stealthHandles = {}
end

function QoL.applyFullStealth()
    QoL.clearStealthHandles()
    if not QoL.state.fullStealth then
        return
    end
    if not Compat.inSession() then
        return
    end
    local maps = {
        { "Detection", "Multiplier", 0.05 },
        { "Visibility", "Multiplier", 0.05 },
        { "TBHsVisibilityCooldown", "Multiplier", 0.1 },
        { "OpticalCamoRechargeDuration", "Multiplier", 0.1 },
        { "Evasion", "Additive", 50 },
        { "MitigationChance", "Additive", 50 },
        { "MitigationStrength", "AdditiveMultiplier", 1 },
        { "QuickHackImmunity", "AdditiveMultiplier", 1 },
        { "QuickhackShield", "AdditiveMultiplier", 1 },
    }
    local any = false
    for _, map in ipairs(maps) do
        local handle = Compat.addModifier(map[1], map[2], map[3])
        if handle then
            table.insert(QoL.stealthHandles, handle)
            any = true
        end
    end
    if any then
        Compat.status("Full stealth assist on.")
    else
        Compat.status("Full stealth doesn't work on this patch.")
        QoL.state.fullStealth = false
    end
end

function QoL.reapplyStealth()
    if QoL.state.fullStealth then
        QoL.applyFullStealth()
    end
end

function QoL.classicAllAssists()
    if not QoL.needSession() then
        return
    end
    Assists.applyClassicBundle()
end

function QoL.export()
    return QoL.state
end

function QoL.loadState(saved)
    if type(saved) ~= "table" then
        return
    end
    for key, value in pairs(saved) do
        QoL.state[key] = value
    end
end

return QoL
