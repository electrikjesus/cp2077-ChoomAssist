# ChoomAssist

A Cyberpunk 2077 accessibility / QoL overlay. This replaces the old EZGodMode hotkey mod.

Open the Cyber Engine Tweaks overlay and you'll get a ChoomAssist window. You don't have to bind hotkeys. Optional CET hotkeys are still there if you want them.

The game already has Settings > Accessibility for bigger fonts, bigger HUD, and HUD chromatic aberration. This mod covers the rest: gameplay assists, extra visual toggles, low-end graphics options, and inventory / level shortcuts.

## Requirements

- Cyberpunk 2077 **2.31**
- [Cyber Engine Tweaks](https://www.nexusmods.com/cyberpunk2077/mods/107) **1.37.0** or newer (the CET build that supports 2.31)

No other mods. No Native Settings, redscript, ArchiveXL, or Potato.

## Install

1. Uninstall old folders if you still have them:
   `.../mods/EZGodMode`, `.../mods/ez_godmode`, or `.../mods/ezAccess`
2. Copy this mod to:
   `Cyberpunk 2077/bin/x64/plugins/cyber_engine_tweaks/mods/ChoomAssist`
3. Launch the game, open the CET overlay, and use the **ChoomAssist** window.

Don't run EZGodMode and ChoomAssist at the same time.

## Tabs

- **Play Assist**: carry weight, fall damage, healing, stamina, oxygen, breach time, skill-check bonus, RAM / hack cost, gadget recharge, movement flags. Tick a row, then use the slider.
- **Combat Comfort**: armor, explosion / DoT reduction, adrenaline, harder to detect (not full stealth). High crit stays off this tab.
- **Visual Comfort**: motion blur, film grain, chromatic aberration, depth of field, bloom, flares, heat haze, and similar. Includes a Visual Comfort preset.
- **Performance**: shadows, GI, fog, screen-space, crowds, async compute. Low-End, Balanced, and Reset to Vanilla presets. A slow PC counts here too.
- **Quality of Life**: eddies, level / Street Cred / attributes, skillbooks, curated cyberware and item grants, classic all-assists (the old EZGodMode one-click pack), full stealth. Cyberware goes to inventory; equip it at a ripper.

Settings save to `settings.json` in this folder. Play Assist and Combat Comfort come back when you load a save.

## Out of scope (CET-only)

This mod can't change vanilla HUD font size, skip breach minigames, or add a pause-menu Mods tab. Use the game's own Accessibility settings for fonts and HUD scale.

## License

GNU GPL v3. See the source headers. This project replaces EZGodMode (2021-2026, Jon West).
