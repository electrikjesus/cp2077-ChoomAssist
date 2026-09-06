# ChoomAssist

A Cyberpunk 2077 accessibility / QoL overlay for Cyber Engine Tweaks.

Open the CET overlay and you'll get a ChoomAssist window. You don't have to bind hotkeys. Optional CET hotkeys are still there if you want them.

The game already has Settings > Accessibility for bigger fonts, bigger HUD, and HUD chromatic aberration. This mod covers the rest: gameplay assists, extra visual toggles, low-end graphics options, and inventory / level shortcuts.

## Requirements

- Cyberpunk 2077 **2.31**
- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107) **1.37.0** or newer (the CET build that supports 2.31)

No other mods. No Native Settings, redscript, or ArchiveXL.

## Install

1. Remove older copies if you still have them:
   `.../mods/EZGodMode`, `.../mods/ez_godmode`, or `.../mods/ezAccess`
2. Copy this mod to:
   `Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/mods/ChoomAssist`
3. Launch the game, open the CET overlay, and use the **ChoomAssist** window.

Don't run an old copy and ChoomAssist at the same time.

## Tabs

- **Play Assist**: carry, falls, healing (speed / charges), stamina, oxygen, breach time and loot, Body / Intelligence / Technical skill checks, RAM, RAM on takedown, ultimate / device / stealth hack costs, grenades, launcher, camo mask, overclock, apartment buffs, movement flags. Tick a row, then use the slider.
- **Combat Comfort**: armor, explosion / DoT, adrenaline, detection, visibility, TBH cooldown, mitigation chance / strength, crit chance, crit damage, one-shot crits, quickhack spread distance / targets. Optical camo, evasion, and hack immunity / shield are Full stealth extras on this tab.
- **Visual Comfort**: motion blur, film grain, chromatic aberration, depth of field, bloom, flares, heat haze, and similar.
- **Performance**: shadows, GI, fog, screen-space, crowds, async compute. Low-End, Balanced, and Reset to Vanilla presets.
- **Quality of Life**: eddies, level / Street Cred / attributes, skillbooks, cyberware and item grants, Classic all-assists, full stealth. Cyberware goes to inventory; equip it at a ripper.
- **Help**: what Classic all-assists actually turns on, and how to set crit without that button.

Settings save to `settings.json` in this folder. Play Assist and Combat Comfort come back when you load a save.

Classic all-assists maxes every Play Assist and Combat Comfort row that has its own control. It does not turn on Full stealth extras (optical camo recharge, evasion, quickhack immunity, quickhack shield). Crit is not hidden: after you press Classic, Combat Comfort shows Crit chance at 100% and One-shot crit damage on. You can set any row yourself without using Classic.

## Out of scope (CET-only)

This mod can't change vanilla HUD font size, skip breach minigames, or add a pause-menu Mods tab. Use the game's own Accessibility settings for fonts and HUD scale.

## References

- Predecessor hotkey mod: [cp2077-ezGodMode](https://github.com/electrikjesus/cp2077-ezGodMode) (this repo). Uninstall any leftover `EZGodMode` / `ez_godmode` folder before using ChoomAssist.
- Graphics toggle approach follows [Potato](https://www.nexusmods.com/cyberpunk2077/mods/11878) (CET `GameOptions` / FeatureToggles). Potato is not required.

## License

GNU GPL v3. See the source headers. Copyright 2021-2026 Jon West.
