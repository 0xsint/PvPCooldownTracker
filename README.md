# PvPCooldownTracker

**Version 1.2.1** · Elder Scrolls Online addon · PC and console

PvPCooldownTracker shows an on-screen countdown for set procs whose
cooldowns are hard to track by eye. Equip a supported set and its tracker
appears on its own. When the proc fires, the tracker counts down. When the
proc can fire again, the tracker shows that it is ready and can play a sound.

If a proc you care about isn't in the built-in list, you can add it from the
settings menu after it goes off once. You don't need to look up ability IDs.

## What's new in 1.2

- **Add your own procs.** The addon keeps a list of the procs that recently
  went off on you. Pick one in **Settings > Add a Proc**, set its cooldown,
  and it is tracked from then on.
- **New tracker look.** Each tracker is a card with the icon, name,
  countdown, and a progress bar. It flashes when the proc fires and gives a
  glow pulse when it is ready again.
- **Appearance options.** Six colour themes, individual colour pickers, an
  icon-only layout, and toggles for the background card, name, and
  announcements.
- **Layout helpers.** **Arrange In A Column** stacks all trackers so they
  don't overlap. **Preview Cooldown** fakes a proc so you can check the look
  and sounds without fighting anything.
- **1.2.1: console fix.** On console, the Recent Procs, Your Procs, and
  Tracked Cooldown lists stayed empty or out of date. They now update while
  you play.

## Installation

**Requires:** [LibAddonMenu-2.0](https://www.esoui.com/downloads/info7-LibAddonMenu.html).

- **PC:** extract the zip into your `Elder Scrolls Online/live/AddOns` folder,
  so that the addon ends up at `AddOns/PvPCooldownTracker/`. Install
  LibAddonMenu-2.0 the same way, then enable both in the in-game add-on list.
- **Console (PlayStation / Xbox):** install PvPCooldownTracker and
  LibAddonMenu-2.0 from the in-game add-on browser. On console, LibAddonMenu
  shows its menus through **LibHarvensAddonSettings**. If the settings menu
  for this addon does not appear, install that library too.

## Using it

### Trackers

- Wear a supported set and its tracker turns on automatically. You can turn
  any tracker off for good under **Tracked Cooldowns > Enable Tracking**.
- While on cooldown, the tracker shows the time left and a shrinking bar.
  When the proc is ready, the bar turns to the ready colour and the tracker
  reads **READY**.
- Floating text announces "*Set* Cooling Down" when a proc fires and "*Set*
  Ready!" when it is back.
- By default, trackers show both in and out of combat. They hide while a
  menu is open.

### Adding your own procs

1. Let the proc go off in combat. The addon records buffs and effects by
   default. Switch **What To Record** to *Everything* for procs that only deal
   damage, heal, or restore resources (that list is much noisier).
2. Open **Settings > PvPCooldownTracker > Add a Proc** and pick the proc from
   **Recent Procs**. If it fired more than once, the cooldown is filled in from
   the shortest time seen between two procs.
3. Check the cooldown against the set or skill tooltip, optionally rename the
   tracker, and press **Track This Proc**.

Procs you add are tracked all the time, whatever gear you wear, and are
saved account-wide. They are listed under **Tracked Cooldowns** with an
*[added by you]* tag, where you can move, resize, and set their sounds like
any built-in set. To delete one, use **Add a Proc > Your Procs > Remove
Proc**. Built-in sets cannot be removed, only disabled.

## Settings

| Section | What it does |
| --- | --- |
| **General** | Unlock trackers to drag them, keep them visible in menus while you set things up, arrange them in a column, show them outside combat, lag compensation, and snap-to-grid. |
| **Appearance** | Colour theme (Ember, Frost, Venom, Blood, Gold, Mono, or Custom), bar or icon-only layout, background card, name, the individual colours, and the size, position, and colours of the floating announcements. |
| **Tracked Cooldowns** | Pick a tracker to turn it on or off, preview it, set its X/Y position and size, and choose its proc and ready sounds (101 game sounds, with a Test Sound button). |
| **Add a Proc** | Record recent procs, pick one, set its name and cooldown, and track it. Also lists the procs you added so you can remove them. |
| **Equipped Set Scanner** | Scan your worn gear against the catalog. Advanced: load, edit, or create catalog entries by hand (ability IDs, cooldown, result and event codes, icon). |

All settings are saved account-wide.

## Chat commands

| Command | What it does |
| --- | --- |
| `/pvpcooldowntracker procs` | Print the recently recorded procs to chat. |
| `/pvpcooldowntracker debug 0`–`3` | Set the debug output level (0 is off, 3 shows everything). |
| `/pvpcooldowntracker all on` / `all off` | Print every combat event you cause to chat. Useful for finding ability IDs by hand. |

## Built-in sets

The catalog in `src/Data.lua` covers 43 sets:

Aetheric Lancer, Archdruid Devyric, Armor of Truth, Bloodspawn,
Caluurion's Legacy, Claw of Yolnahkriin, Crest of Cyrodiil, Curse Eater,
Earthgore, Essence Thief, Gryphon's Ferocity, Hide of the Werewolf,
Icy Conjuror, Kjalnar's Nightmare, Maarselok, Magicka Furnace, Mara's Balm,
Mechanical Acuity, Meridia's Blessed Armor, Nazaray, Orpheon the Tactician,
Pirate Skeleton, Powerful Assault, Rallying Cry, Ravager,
Roaring Opportunist, Rush Of Agony, Seventh Legion Brute, Shroud of the Lich,
Slivers of the Null Arca, Steadfast Hero, Stonekeeper, Sul-Xan's Torment,
Symphony of Blades, The Juggernaut, Trappings of Invigoration,
Twice-Fanged Serpent, Vestment of Olorime, Vestments of the Warlock, Vykosa,
Wretched Vitality, Wyrd Tree's Blessing, and Zaan.

Perfected versions are matched to the same tracker. "Two-Fanged Snake" is
treated as Twice-Fanged Serpent. Set names are matched in English, so other
client languages only get procs added through **Add a Proc**.

## Code overview

| File | Role |
| --- | --- |
| `PvPCooldownTracker.addon` | Manifest: API version, SavedVariables, load order, and the LibAddonMenu-2.0 dependency. |
| `src/Main.lua` | Startup: creates, upgrades, and sanitises SavedVariables, then initialises every module. |
| `src/Data.lua` | The catalog of built-in sets (ability IDs, result codes, cooldowns, icons), plus notes on adding entries. |
| `src/Tracking.lua` | Listens for proc events, starts and stops cooldowns, and handles combat, death, and enable/disable state. |
| `src/Interface.lua` | Draws the trackers and announcements, colour themes, the column arrangement, and the slash commands. |
| `src/ProcCapture.lua` | Records recent procs and runs the **Add a Proc** menu. |
| `src/EquippedSets.lua` | Scans worn gear, restores custom catalog entries, and runs the **Equipped Set Scanner** menu. |
| `src/Settings.lua` | Builds the settings menu, and keeps its dropdown lists up to date on PC and console. |
| `src/Defaults.lua` | Default settings: style, layout, sounds, and per-set position. |
| `src/Sounds.lua` | The game sounds offered for proc and ready alerts. |
| `lib/LibEquipmentBonus/` | Bundled helper that reports which set bonuses are active. Replaces the keyboard-only LibSets dependency. |

## Credits / Origin

PvPCooldownTracker is a **console port** of the original **Cooldowns**
addon (https://github.com/inimicus/Cooldowns) created by **g4rr3t**
(a.k.a. **inimicus**). **@VixenHunny** reworked it to run on the console
versions of Elder Scrolls Online. The port replaces the keyboard-only
LibSets dependency with the bundled `LibEquipmentBonus` helper and removes
other parts that did not work with a controller. It also simplifies the
SavedVariables handling and restyles the UI.

All credit for the original concept, the tracked-set data, and the core
tracking/UI logic goes to **g4rr3t / inimicus** and the **Cooldowns**
contributors (including **Baertram** for multi-language assistance). See the
upstream project here: https://github.com/inimicus/Cooldowns

## License

This addon, like the original Cooldowns addon it is ported from, is
distributed under the **GNU General Public License (GPL)**. You are free to
use, study, modify, and redistribute this code under the same license,
provided that you retain attribution to the original authors.
