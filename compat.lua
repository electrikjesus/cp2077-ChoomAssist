-- ChoomAssist compatibility helpers for Cyberpunk 2077 2.31 / CET 1.37
-- Copyright (C) 2021-2026 Jon West <electrikjesus@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

local Compat = {
    lastMessage = "",
}

function Compat.status(message)
    Compat.lastMessage = message or ""
    if message and message ~= "" then
        print("[ChoomAssist] " .. message)
    end
end

function Compat.tryApply(fn)
    local ok, result = pcall(fn)
    if not ok then
        print("[ChoomAssist] skipped: " .. tostring(result))
        return false, result
    end
    return true, result
end

function Compat.player()
    local ok, player = pcall(function()
        return Game.GetPlayer()
    end)
    if not ok or player == nil then
        return nil
    end
    return player
end

function Compat.inSession()
    local player = Compat.player()
    if not player then
        return false
    end
    local ok, entityId = pcall(function()
        return player:GetEntityID()
    end)
    return ok and entityId ~= nil
end

function Compat.stat(name)
    local ok, value = pcall(function()
        return gamedataStatType[name]
    end)
    if ok and value ~= nil then
        return value
    end
    print("[ChoomAssist] unknown stat: " .. tostring(name))
    return nil
end

function Compat.modType(name)
    local ok, value = pcall(function()
        return gameStatModifierType[name]
    end)
    if ok and value ~= nil then
        return value
    end
    print("[ChoomAssist] unknown modifier type: " .. tostring(name))
    return nil
end

function Compat.addModifier(statName, modKind, amount)
    if not Compat.inSession() then
        return nil
    end
    local stat = Compat.stat(statName)
    local kind = Compat.modType(modKind)
    if stat == nil or kind == nil then
        return nil
    end
    local ok, handle = pcall(function()
        local player = Compat.player()
        local modifier = RPGManager.CreateStatModifier(stat, kind, amount)
        Game.GetStatsSystem():AddModifier(player:GetEntityID(), modifier)
        return modifier
    end)
    if not ok then
        print("[ChoomAssist] modifier failed " .. tostring(statName) .. ": " .. tostring(handle))
        return nil
    end
    return handle
end

function Compat.removeModifier(handle)
    if handle == nil or not Compat.inSession() then
        return
    end
    pcall(function()
        Game.GetStatsSystem():RemoveModifier(Compat.player():GetEntityID(), handle)
    end)
end

function Compat.hasRecord(tdbid)
    local ok, record = pcall(function()
        return TweakDB:GetRecord(tdbid)
    end)
    return ok and record ~= nil
end

function Compat.addItem(tdbid, count)
    count = count or 1
    if not Compat.inSession() then
        return false, "Load a save first."
    end
    if not Compat.hasRecord(tdbid) then
        print("[ChoomAssist] missing item: " .. tostring(tdbid))
        return false, "doesn't work on this patch"
    end
    local ok, err = pcall(function()
        Game.AddToInventory(tdbid, count)
    end)
    if not ok then
        print("[ChoomAssist] AddToInventory failed " .. tostring(tdbid) .. ": " .. tostring(err))
        return false, "doesn't work on this patch"
    end
    return true
end

function Compat.grantItems(list, count)
    local added = 0
    local skipped = 0
    for _, tdbid in ipairs(list) do
        local ok = Compat.addItem(tdbid, count or 1)
        if ok then
            added = added + 1
        else
            skipped = skipped + 1
        end
    end
    return added, skipped
end

function Compat.setLevel(statName, level)
    if not Compat.inSession() then
        return false, "Load a save first."
    end
    local ok, err = pcall(function()
        Game.SetLevel(statName, level, 1)
    end)
    if not ok then
        print("[ChoomAssist] SetLevel failed " .. tostring(statName) .. ": " .. tostring(err))
        return false, "doesn't work on this patch"
    end
    return true
end

function Compat.developmentData()
    if not Compat.inSession() then
        return nil
    end
    local ok, data = pcall(function()
        local player = Compat.player()
        return PlayerDevelopmentSystem.GetInstance(player):GetDevelopmentData(player)
    end)
    if not ok then
        print("[ChoomAssist] development data unavailable: " .. tostring(data))
        return nil
    end
    return data
end

function Compat.setAttribute(name, value)
    local data = Compat.developmentData()
    if not data then
        return false
    end
    local ok, err = pcall(function()
        data:SetAttribute(name, value)
    end)
    if not ok then
        print("[ChoomAssist] SetAttribute failed " .. tostring(name) .. ": " .. tostring(err))
        return false
    end
    return true
end

function Compat.addDevPoints(amount, pointTypeName)
    local data = Compat.developmentData()
    if not data then
        return false
    end
    local ok, err = pcall(function()
        local pointType = gamedataDevelopmentPointType[pointTypeName]
        data:AddDevelopmentPoints(amount, pointType)
    end)
    if not ok then
        print("[ChoomAssist] AddDevelopmentPoints failed " .. tostring(pointTypeName) .. ": " .. tostring(err))
        return false
    end
    return true
end

function Compat.infiniteStamina(enabled)
    local ok = pcall(function()
        Game.InfiniteStamina(enabled)
    end)
    return ok
end

return Compat
