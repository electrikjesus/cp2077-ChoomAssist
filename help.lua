-- ChoomAssist Help tab copy (longer than overlay tooltips)
-- Copyright (C) 2021-2026 Jon West <electrikjesus@gmail.com>
-- SPDX-License-Identifier: GPL-3.0-or-later

local Assists = require("assists.lua")
local Graphics = require("graphics.lua")

local Help = {}

local assists = {
    carryCapacity = "Multiplies the weight you can carry before the game treats you as overencumbered. Overencumbered V walks slowly and cannot sprint or climb well, so this is mainly so stash trips and looting are less of a chore. It does not add extra inventory slots or extra item types. 1x is the game default. Classic all-assists sets this to 20x. Untick the row to restore normal carry weight; the slider does nothing while the row is off.",
    fallDamage = "This slider is how much fall damage you still take, not a damage boost. 100% is vanilla. 50% is half. 0% means landing from a fall should not hurt you. It uses the game's fall-damage reduction stat, so vehicle crashes, explosions, and gunfire are separate. Very high drops in scripted scenes can still do other things (animation, death volumes). Classic sets this to 0%.",
    healSpeed = "Shortens the wait before inhaler and injector charges refill. It does not spawn extra healing items, does not raise max health, and does not make a single charge heal more. If you want more charges sitting on the item, use the two charge sliders below. 2x means they come back twice as fast. Classic sets 10x.",
    healMaxCharges = "Raises the cap on how many charges a healing item can hold. Separate from refill speed and from how many charges you currently have. If the current-charges slider is low, you can still wait for refill up to this cap. Classic sets 20x.",
    healCharges = "Raises how many healing charges you have ready to use right now. Separate from the max cap and from refill speed. Pair it with max charges if you want both a bigger cap and more charges already filled. Classic sets 20x.",
    stamina = "Multiplies maximum stamina for sprint, melee, jumps, and similar drains. Use this when you want a cushion but still want stamina as a resource. Do not combine with Infinite stamina: the overlay blocks both at once so they do not stack into weird values. Classic uses Infinite stamina instead of this slider.",
    infiniteStamina = "Stops sprint, jump, melee, and similar actions from draining stamina. Prefer this over Extra stamina if you do not want a stamina bar to manage at all. If the game command is missing on a patch, the mod falls back to a huge stamina pool. The overlay will turn Extra stamina off when you enable this.",
    oxygen = "Multiplies oxygen / breath. Helps underwater, in smoke, and anywhere the game uses the oxygen resource. It does not give water breathing as a status, and it does not change swimming speed. 1x is vanilla. Classic sets 10x.",
    breachTime = "Adds time to the breach-protocol (hacking minigame) timer so you are less rushed. It does not skip the minigame, solve it for you, or change daemon upload. Extra loot from the minigame is a different slider. Classic sets 10x time.",
    breachLoot = "Increases materials and similar rewards from finishing a breach minigame. It does not add extra time on the puzzle. If a breach has no material reward, this will not invent one. Classic sets 10x loot.",
    skillCheckBody = "Adds a bonus to Body (Strength) skill checks in dialogue, doors, and world interactions. It does not raise your Body attribute on the character screen, so perks and DPS that key off the attribute are unchanged. Intelligence and Technical checks have their own sliders. 20 is a large bump; Classic sets 20.",
    skillCheckInt = "Adds a bonus to Intelligence skill checks (terminals, some dialogue, netrunning-adjacent world checks). It does not raise the Intelligence attribute or give extra RAM. Body and Technical have their own sliders. Classic sets 20.",
    skillCheckTech = "Adds a bonus to Technical Ability skill checks (force open, some crafting/world interactions). It does not raise Technical Ability or unlock crafting specs. Body and Intelligence have their own sliders. Classic sets 20.",
    memory = "Multiplies cyberdeck RAM (memory) so you can queue more or costlier quickhacks before waiting to regen. It does not lower hack costs (those are the three cost sliders) and does not change how much RAM you get back on a takedown. Classic sets 10x.",
    memoryOnDefeat = "Restores extra RAM when you take someone down. Useful if you ram-dump during a chain of hacks. It does not raise your RAM cap; Extra RAM does that. Classic sets 10x.",
    hackCostUltimate = "Lowers RAM cost of ultimate quickhacks only. Device hacks (cameras, turrets) and stealth hacks have their own sliders. 0% is vanilla. 90% makes ultimates much cheaper but not always free, depending on the hack. Classic sets 90%.",
    hackCostDevice = "Lowers RAM cost of device quickhacks such as cameras, turrets, and other environment devices. Does not change ultimate or stealth-hack cost, and does not hack the device for you. Classic sets 90%.",
    hackCostStealth = "Lowers RAM cost of stealth-oriented quickhacks. It does not hide you, does not replace Full stealth, and does not change ultimate or device cost. Classic sets 90%.",
    grenadeRecharge = "Shortens how long you wait for grenade charges to refill. It does not add grenades to inventory if you have none, and it does not change the max number of charges (that is Grenade max charges). Classic sets 10x faster.",
    grenadeCharges = "Raises how many grenade charges you can hold. Refill speed is the slider above. You still need grenades equipped / in the grenade slot. Classic sets 10x.",
    launcherRecharge = "Shortens recharge on the arm projectile launcher cyberware. No effect if you do not have that implant installed. Max charges are a separate slider. Classic sets 10x faster.",
    launcherCharges = "Raises the projectile launcher's charge cap. No effect without the implant. Recharge speed is separate. Classic sets 10x.",
    camoMaskRecharge = "Shortens recharge on optical camo mask charges (the CW mask charge system). This is not the same as Combat Comfort > Faster optical camo recharge, which uses a different stat Full stealth also touches. Max mask charges are separate. Classic sets 10x faster.",
    camoMaskCharges = "Raises optical camo mask charge cap. Recharge speed is the slider above. Full stealth's optical camo row is still a different stat. Classic sets 10x.",
    overclockCooldown = "Shortens cyberdeck overclock cooldown so you can overclock again sooner. It does not raise overclock duration or RAM. No effect if your OS has no overclock. Classic sets 10x faster.",
    housingBuffs = "Lengthens buffs you get from apartments and similar housing. It does not grant those buffs if you have not used the shower, food, or other housing interact. Grenades and cyberware recharge are separate. Classic sets 10x.",
    canCrouch = "Forces crouch to stay available even if a status, animation, or restriction would block it. Tick this if crouch sometimes greys out and you need it for accessibility. It does not stealth you by itself.",
    canSprint = "Forces sprint to stay available. Useful when encumbrance, a status, or a restriction would otherwise block it. Extra carry capacity is the better fix for weight; this is the fallback so sprint still works.",
    canJump = "Forces jump to stay available. It does not add extra jump height. Pair with Always allow double jump if you want a second jump without the cyberware.",
    hasDodge = "Forces dodge / dash to stay available. It does not increase dodge distance or give i-frames beyond what the move already has.",
    hasDoubleJump = "Forces double jump even without the usual leg cyberware. Single jump is a different toggle. Some interiors still block jumping.",
    hasSmartLink = "Forces smart-link targeting as if you had the hand implant, so smart weapons can lock on. It does not install the cyberware item or change weapon stats. Equip a smart weapon to feel it.",
    armor = "Multiplies armor so bullets and melee chip less health. 10x is a large cushion, not invincibility: explosions, DoT, and one-shots can still hurt unless you also use those sliders. Classic sets 10x.",
    explosionReduction = "Cuts explosion damage only (grenades, cars, some environmental blasts). Gun and melee damage are unchanged. 90% means explosions do very little. Classic sets 90%.",
    dotReduction = "Cuts burn, poison, bleed, and other damage-over-time. Burst damage from a bullet or slash is unchanged. Classic sets 90%.",
    adrenaline = "Multiplies adrenaline, the second-wind / combat health resource. It does not refill health by itself and does not replace healing items. Classic sets 10x.",
    detection = "Slows how fast the detection meter fills when someone is onto you. Enemies can still see you (that is Lower visibility) and can still stay hostile after they have spotted you (TBH cooldown). This is not invisibility and will not skip scripted discoveries. Classic sets 90%. Full stealth pushes it to 95%.",
    visibility = "Makes you harder to see, separate from how fast the detection meter fills. Cameras and NPCs may take longer to pick you out of cover or shadow. Scripted scenes can still reveal you. Classic sets 90%. Full stealth pushes it to 95%.",
    tbhVis = "Stretches the cooldown after you leave someone's awareness (time-before-hostile style). Once they have fully spotted you, this will not make them forget instantly. Detection and visibility are the other two stealth sliders. Classic sets 90%.",
    opticalCamo = "Shortens optical camo recharge duration (the camo effect timer, not the Play Assist mask charge pool). Classic all-assists does not turn this on. Full stealth does, at 10x. You still need camo cyberware or an equivalent for the effect to exist.",
    evasion = "Adds evasion so incoming attacks miss more often. It is not a damage shield and not a dodge-move toggle. Classic all-assists does not turn this on. Full stealth sets a moderate bonus. Mitigation (below) is a different system that softens hits that do connect.",
    mitigationChance = "Chance that mitigation procs on an incoming hit. When it procs, Mitigation strength decides how much damage is removed. Raising chance without strength means more frequent but weaker procs. Classic sets 50%. Full stealth also sets 50%.",
    mitigationStrength = "How much damage a mitigation proc removes. Useless if chance is 0. Classic sets 50%. Full stealth sets 100%. Armor is still a separate cushion on hits that are not mitigated.",
    critChance = "Adds to critical hit chance. 100% means every hit can crit; that is what Classic all-assists sets. This row lives on Combat Comfort, not inside the Classic button. Crit still needs a damage bonus: either Crit damage bonus (mild) or One-shot crit damage (huge). They cannot both be on.",
    critDamage = "Adds a moderate extra crit damage amount. Use this if you want crits to hit harder without deleting most enemies. Classic all-assists does not use this slider; it turns on One-shot crit damage instead. Enabling this turns One-shot off so the two CritDamage modifiers do not stack.",
    overkillCrit = "Adds a huge crit damage bonus so crits drop most enemies in one hit. Classic turns this on together with Crit chance at 100%. You can tick it here without Classic. Bosses, vehicles, and some named enemies may still take more than one crit. Enabling this turns Crit damage bonus off.",
    hackSpreadDistance = "How far a spreading quickhack can jump to another target. It does not change RAM cost or how many extra targets (that is the next slider). 0 is no extra distance. Classic sets this high (8).",
    hackSpreadNumber = "How many extra targets a spreading quickhack can hit. Distance is the slider above. RAM cost is Play Assist. Classic sets 4 extra targets.",
    qhImmunity = "Raises resistance to incoming quickhacks aimed at you. It does not stop every netrunner in every scene. Classic all-assists does not turn this on. Full stealth does.",
    qhShield = "Raises quickhack shield, a related defense against being hacked. Pair with immunity if you want both layers. Classic does not turn this on. Full stealth does.",
}

local graphics = {
    ["Motion Blur"] = "When on, the world smears if you or the camera move. That is a common nausea trigger and also hides fine detail while turning. The Visual Comfort preset turns this off. Unchecked = sharp motion. This is a CET feature toggle, not the in-game motion blur slider.",
    ["Film Grain"] = "When on, a grainy overlay sits on the whole image, including UI. That makes small text and distant markers harder to read. Visual Comfort turns it off. Unchecked = a cleaner picture.",
    ["Chromatic Aberration"] = "When on, colors split at the edges of objects (a camera-lens look). Some people find it painful or blurry. The game's Settings > Accessibility also has a HUD chromatic aberration toggle; that one is only the HUD. This toggle is the world/scene effect. Visual Comfort turns it off.",
    ["Depth of Field"] = "When on, things that are not the focus point go blurry (cinematics, ads, some gameplay cameras). Off keeps more of the scene readable, which helps if you lose targets in blur. Visual Comfort turns it off.",
    ["Bloom"] = "When on, bright neon and headlights glow and can wash out faces, signs, and UI. Off keeps lights tighter and contrast easier to read. Visual Comfort turns it off.",
    ["Distortion"] = "When on, heat, glass, and some abilities warp the image. That can be disorienting or look like a tracking problem. Visual Comfort turns it off.",
    ["Image Based Flares"] = "When on, bright sources throw lens flares across the screen. Off removes those flashes. Visual Comfort turns it off.",
    ["Heat Haze"] = "When on, hot surfaces shimmer, which makes distant NPCs and loot harder to track. Visual Comfort turns it off.",
    ["Eye Adaptation"] = "When on, the image can flash much brighter or darker when you step from a dark alley into neon (or the reverse). That can be painful. Off keeps brightness more stable. Visual Comfort turns it off. Interiors may look a bit flatter.",
    ["Tonemapping"] = "Maps lighting into what you see on screen. Leave this on. Turning it off can make colors and brightness look broken. Visual Comfort leaves it on. The Low-End preset also leaves it on.",
    ["Global Illumination"] = "Bounced lighting so interiors and neon feel filled-in. Heavy on GPU. Off is flatter lighting and often a large FPS gain. Low-End turns it off. Balanced leaves it on.",
    ["Distant Global Illumination"] = "GI out in the distance (skyline, far blocks). Off saves GPU far from V. Low-End and Balanced turn it off.",
    ["Distant Shadows"] = "Shadows on far geometry. Off means fewer distant shadows and more FPS; the city can look a bit flatter far away. Low-End and Balanced turn it off.",
    ["Cascade Shadows"] = "Detailed shadows near V. Off flattens nearby lighting a lot but can raise FPS. Low-End turns it off. Balanced leaves it on.",
    ["Distant Fog"] = "Haze in the distance. It can hide map markers and skyline. Off draws farther and can look harsher/clearer. Low-End and Balanced turn it off.",
    ["Volumetric Fog"] = "Thick shafts of light and fog. Very expensive. Off is clearer air and more FPS. Low-End and Balanced turn it off.",
    ["Distant Volumetric Fog"] = "Volumetric fog far away. Off is cheaper distant fog. Low-End and Balanced turn it off.",
    ["Volumetric Clouds"] = "3D clouds. Heavy. Off uses a simpler sky. Low-End and Balanced turn it off.",
    ["Screen Space Reflections"] = "Reflections on wet streets, puddles, and metal. Costly. Off looks duller on rainy Night City but often helps FPS. Low-End and Balanced turn it off.",
    ["Screen Space Reflections for Rain"] = "Extra reflection work while it rains. Off makes rain cheaper. Low-End turns it off.",
    ["Underwater Screen Space Reflections"] = "Reflections while swimming. Off is cheaper underwater. Low-End turns it off.",
    ["Screen Space Ambient Occlusion"] = "Soft contact shadows in corners (SSAO). Makes objects sit in the world. Costly. Off looks flatter. Low-End turns it off. Balanced leaves it on.",
    ["Screen Space Planar Reflections"] = "Extra planar reflections on some floors and mirrors. Off is cheaper. Low-End turns it off.",
    ["Antialiasing"] = "Smoothes jagged edges. Off can raise FPS; edges look harsher, which some people prefer for sharpness. Low-End turns it off. Balanced leaves it on.",
    ["Weather"] = "Rain and weather systems. Turning this off can break lighting or leave you stuck in a weather state until you skip time or reload. Leave it on unless you know you need it off. Low-End leaves weather on but turns Rain Map off.",
    ["Rain Map"] = "Wetness on surfaces when it rains. Off is a cheaper rain look. Low-End turns it off.",
    ["Dynamic Decals"] = "Bullet holes and similar marks that appear during play. Off means fewer decals and a bit more FPS. Low-End turns it off.",
    ["Static Decals"] = "Placed world decals (posters, stains, some signage). Off can make streets look emptier. Low-End turns it off.",
    ["Crowd"] = "Roaming pedestrians and traffic. Off is quieter streets and more FPS; Night City feels empty. May need a reload, a district change, or a time skip before the crowd fully comes back or goes away. Low-End turns it off. Balanced leaves it on.",
    ["Character Light Blockers"] = "Bodies blocking light correctly so shadows on characters look right. Off is cheaper character lighting. Usually a small FPS change.",
    ["Character Rim Enhancement"] = "Extra rim light on people. Off is flatter character lighting. Low-End turns it off.",
    ["Character Subsurface Scattering"] = "Skin lets light through (ears, faces). Costly. Off is cheaper faces. Low-End turns it off.",
    ["Hair"] = "Full hair rendering. Off is cheaper hair and can look thinner or flatter. Low-End turns it off. Balanced leaves it on.",
    ["Async Compute"] = "Lets the GPU overlap some work. Default on. If an old GPU hitches or crashes, try turning the Async Compute group off. Low-End turns the whole group off. Balanced leaves the main switch on.",
    ["Async Compute DPL"] = "One async-compute sub-toggle (DPL). Off with the rest of the group if you are chasing old-GPU stability.",
    ["Async Compute SSAO"] = "Async path for SSAO. Off may help old GPUs. You can also turn SSAO itself off in Screen Space.",
    ["Async Compute LUT Generation"] = "Async color LUT work. Off may help old GPUs.",
    ["Async Compute Dynamic Texture"] = "Async dynamic textures. Off may help old GPUs.",
    ["Async Compute Flatten Normals"] = "Async normals. Off may help old GPUs.",
    ["Async Compute Build Depth Chain"] = "Async depth chain. Off may help old GPUs.",
    ["Async Compute During SSR"] = "Async work during screen-space reflections. Off may help old GPUs. You can also disable SSR itself.",
    ["Water Async Compute FFT"] = "Async water simulation. Off may help old GPUs near water.",
}

local function para(text)
    ImGui.TextWrapped(text)
    ImGui.Spacing()
end

local function heading(text)
    ImGui.Separator()
    ImGui.Text(text)
    ImGui.Spacing()
end

local function option(title, body)
    ImGui.Text(title)
    ImGui.TextWrapped(body)
    ImGui.Spacing()
end

local function drawAssistHelp(tab, header, intro)
    if not ImGui.CollapsingHeader(header) then
        return
    end
    para(intro)
    local order, groups = Assists.groupedDefsForTab(tab)
    for _, groupName in ipairs(order) do
        heading(groupName)
        for _, spec in ipairs(groups[groupName]) do
            option(spec.label, assists[spec.id] or spec.tooltip)
        end
    end
end

local function drawGraphicsHelp(list)
    for _, graphicsOption in ipairs(list) do
        option(graphicsOption.name, graphics[graphicsOption.name] or graphicsOption.note)
    end
end

function Help.draw()
    para("This tab explains every ChoomAssist option in more detail than the short text on each control. Open a section below. Gameplay assists and Quality of Life buttons need a save loaded. Visual Comfort and Performance can be changed from the main menu overlay too.")
    para("How to use a Play Assist or Combat Comfort row: tick the checkbox to turn it on, then move the slider if there is one. Changes apply when you release the slider. Untick to restore the game default for that row only. Values save to settings.json in the mod folder and come back when you load a save. If a row says it does not work on this patch, that stat name is missing and the mod skipped it.")

    if ImGui.CollapsingHeader("Tabs at a glance") then
        para("Play Assist: exploration and quality-of-life while moving through the world (carry, healing, stamina, netrunning costs, gadgets, movement). Combat Comfort: taking and dealing damage, stealth, crit, and quickhack spread. Visual Comfort: turn off smear, grain, and flash. Performance: turn off heavy lighting and world detail for FPS. Quality of Life: one-shot grants (money, level, items) plus the Classic and Full stealth shortcuts. Help: this guide.")
        para("Hotkeys are optional. You can use the overlay alone. The game's own Settings > Accessibility still handles bigger fonts, bigger HUD, and HUD chromatic aberration. ChoomAssist does not replace those.")
    end

    drawAssistHelp(
        "play",
        "Play Assist",
        "These stay on until you untick them or press Turn off all assists. They are not cheats hidden behind Classic: Classic is only a shortcut that maxes these rows (infinite stamina instead of Extra stamina). Tick only what you need."
    )

    drawAssistHelp(
        "combat",
        "Combat Comfort",
        "Easier fights and milder stealth. Crit chance and One-shot crit damage are here, not inside the Classic button. Optical camo recharge, evasion, quickhack immunity, and quickhack shield are Full stealth extras: Classic does not enable them. Detection, visibility, and TBH cooldown are in Classic."
    )

    if ImGui.CollapsingHeader("Visual Comfort") then
        para("Each checkbox is an engine feature. Checked means that effect is on (vanilla-like). Unchecked means it is off. That is the opposite of a typical 'disable blur' mental model: you uncheck Motion Blur to stop the smear.")
        para("Visual Comfort preset turns off motion blur, film grain, chromatic aberration, depth of field, bloom, distortion, flares, heat haze, and eye adaptation. It leaves Tonemapping on. Reset visual to vanilla turns this list back on.")
        para("These are CET GameOptions (FeatureToggles), not the game's Graphics menu. If something disagrees with the in-game sliders, the last one you touched wins until you set it again.")
        drawGraphicsHelp(Graphics.VisualComfort)
    end

    if ImGui.CollapsingHeader("Performance") then
        para("Same checkbox rule: checked = feature on, unchecked = off. Use this for a slow PC or for fewer on-screen distractions (crowds, fog, distant clutter).")
        para("Low-End: Visual Comfort plus GI, most shadows, fog, clouds, screen-space effects, antialiasing, rain map, decals, crowd, some character lighting, hair, and async compute all off. Weather stays on because turning weather off can break lighting. Balanced: Visual Comfort, keep nearby GI/shadows/SSAO/AA/crowd/hair/async, drop distant GI, distant shadows, fog, clouds, and SSR. Reset to Vanilla turns every Performance and Visual toggle back on.")
        para("Crowd and weather often need a time skip, a fast travel, or walking into a new district before the street fully updates. If Night City looks empty after you re-enable Crowd, skip time or reload the save.")
        for _, group in ipairs(Graphics.groups()) do
            if group.id ~= "visual" then
                heading(group.title)
                drawGraphicsHelp(group.list)
            end
        end
    end

    if ImGui.CollapsingHeader("Quality of Life") then
        para("These are one-shot buttons, not toggles (except Full stealth). Press once, get items or a level change, done. They do not keep granting every frame. Missing item IDs on this patch are skipped; the status line at the bottom of the window tells you how many were added. Large grants can bloat a save: do not dump every category unless you want a stuffed inventory.")
        para("Load a save first. These call player systems that do not exist on the main menu.")

        heading("Eddies")
        para("Adds eurodollars to inventory. Set Eddie amount (1,000 to 10,000,000), then press Add eddies. This is not infinite money and does not change vendor prices. Repeat the button if you want more.")

        heading("Level and attributes")
        para("Set level: jumps your character level to the slider (1-60). It does not replay every level-up animation. Street Cred target is 1-50. These use the development system; if a patch renamed it, the status line will say it failed.")
        para("Set attributes to 20 fills Body, Reflexes, Technical Ability, Intelligence, and Cool toward 20. That is the cap, not extra points to spend. Grant attribute points and Grant perk points add unspent points you still assign on the character screen. Perk points use the primary development pool.")

        heading("Skillbooks")
        para("Puts skillbooks in inventory. You still have to use them from inventory to gain XP toward Solo (Body), Headhunter (Cool), Netrunner (Intelligence), Shinobi (Reflexes), Engineer (Technical Ability), relic points, perk points, or attribute points. Skillbook count is how many of each selected book you get. Grant all skillbooks walks the whole list. 2.0+ skill names are used; old 1.x book IDs are not.")

        heading("Cyberware (inventory only)")
        para("Adds high-tier cyberware items to inventory. This mod will not slot them into your body. Go to a ripperdoc. Start with Cyberware capacity so the 2.0+ capacity cap can actually fit more implants. Then grab a category: operating systems (Sandy / Berserk / decks), arms (mantis, gorilla, monowire, launcher), legs, circulatory, frontal cortex, integumentary / camo, nervous system, skeleton, hands / smart-link. Both legendary++ and older legendary IDs are included so one of them may exist on your patch. Duplicates in inventory are possible if you press twice.")

        heading("Items")
        para("Short curated lists, not the whole item dump. Ammo (all types) grants a stack of each ammo type. Crafting components and Quickhack components grant materials. Consumables are a handful of inhalers, boosters, and similar. Short iconic weapon list is a small set of named weapons (Jackie's pistol, some katanas, and similar), not every iconic. Pressing these a lot will clog stash and inventory.")

        heading("Classic all-assists")
        para("A shortcut, not a hidden mode. It ticks every Play Assist and Combat Comfort row that is marked for Classic, at that row's maximum. Infinite stamina on, Extra stamina off. Crit chance 100%, One-shot crit damage on, Crit damage bonus off. Gadget, hack cost, skill-check, detection, mitigation, and spread rows are included because they each have their own slider now.")
        para("It does not add eddies, items, skillbooks, level, Street Cred, attributes, or perk points. It does not change Visual Comfort or Performance. It does not turn on Full stealth extras: optical camo recharge, evasion, quickhack immunity, or quickhack shield. After you press it, go to Play Assist and Combat Comfort and you should see those rows ticked. Turn it off with Turn off all assists on Play Assist, Combat Comfort, or Quality of Life.")

        heading("Full stealth")
        para("A separate checkbox. While on, it enables Faster optical camo recharge, Extra evasion, Quickhack immunity, and Quickhack shield, and it pushes detection, visibility, TBH cooldown, and mitigation to strong values. Those same rows are on Combat Comfort if you want them one at a time. Unticking Full stealth turns the four extras off and leaves detection/mitigation as you left them.")
        para("This is not true invisibility. Scripted scenes, quest flags, and some cameras can still reveal you. Pair with Play Assist stealth hack cost if you also want cheaper stealth quickhacks.")
    end

    if ImGui.CollapsingHeader("What this mod cannot do") then
        para("It cannot change vanilla HUD font size, HUD scale, or the pause-menu Mods tab. Use Settings > Accessibility in the game for bigger fonts and HUD. It cannot skip breach minigames, auto-equip cyberware, or dump every TweakDB item. If a button does nothing, read the status line: many grants skip IDs that do not exist on 2.31.")
        para("Assists are stat modifiers on the player. They persist in settings.json and reapply when the player spawns. They clear when the player despawns so they should not leak onto the next save in the same session, but reload CET if a modifier feels stuck.")
    end
end

return Help
