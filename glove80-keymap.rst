===================================
Glove80 Atreus-Style Keymap Reference
===================================

Only the 3 alpha rows and 3 thumb keys per side are active.
Top 2 rows and outer pinky columns are disabled.

Home row mods use **balanced** flavor (280ms tapping term, 150ms prior idle).
Layer-tap thumb keys use **quick-tap** (200ms) so tap-tap-hold repeats the key.

Behaviors
=========

``hm`` — Home Row Mods
  Hold for modifier, tap for letter. Quick-tap at 175ms for fast repeated typing.

``lt_rep`` — Layer-Tap with Repeat
  Hold for layer, tap for key. Tap-tap-hold repeats the tap key (e.g. backspace).


Layer 0: BASE
=============

::

  ╭─────┬─────┬─────┬─────┬─────┬─────╮                 ╭─────┬─────┬─────┬─────┬─────┬─────╮
  │ Tab │  Q  │  W  │  E  │  R  │  T  │                 │  Y  │  U  │  I  │  O  │  P  │  \  │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │ Esc │A/Gui│S/Alt│D/Ctl│F/Sft│  G  │                 │  H  │J/Sft│K/Ctl│L/Alt│;/Gui│  '  │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │     │  Z  │  X  │  C  │  V  │  B  │                 │  N  │  M  │  ,  │  .  │  /  │     │
  ╰─────┴─────┴─────┴─────┴─────┴─────╯                 ╰─────┴─────┴─────┴─────┴─────┴─────╯

                Thumb Cluster                                     Thumb Cluster
          ╭───────┬───────┬─────╮                           ╭─────┬───────┬───────╮
    row4: │ Shift │       │     │                           │     │       │ Shift │
          ├───────┼───────┼─────┤                           ├─────┼───────┼───────┤
    row5: │BSP/NAV│DEL/NUM│     │                           │     │RET/SYM│ Space │
          ╰───────┴───────┴─────╯                           ╰─────┴───────┴───────╯

  Hold thumb keys to activate layers:
    BSP/NAV  — tap: Backspace, hold: NAV layer  (tap-tap-hold repeats bksp)
    DEL/NUM  — tap: Delete,    hold: NUM layer  (tap-tap-hold repeats del)
    RET/SYM  — tap: Enter,     hold: SYM layer


Layer 1: NAV (hold left inner thumb)
=====================================

Left hand provides modifiers for selection (e.g. Shift+Arrow).
Right hand provides navigation.

::

  ╭─────┬─────┬─────┬─────┬─────┬─────╮                 ╭─────┬─────┬─────┬─────┬─────┬─────╮
  │     │     │     │     │     │     │                 │Home │Pg Dn│Pg Up│ End │     │     │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │     │ Gui │ Alt │ Ctrl│Shift│     │                 │  ←  │  ↓  │  ↑  │  →  │Caps │     │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │     │Undo │ Cut │Copy │Paste│     │                 │ Ins │Bksp │ Del │     │     │     │
  ╰─────┴─────┴─────┴─────┴─────┴─────╯                 ╰─────┴─────┴─────┴─────┴─────┴─────╯

                Thumb Cluster                                     Thumb Cluster
          ╭───────┬───────┬─────╮                           ╭─────┬───────┬───────╮
          │       │       │     │                           │     │       │       │
          ├───────┼───────┼─────┤                           ├─────┼───────┼───────┤
          │ ▓▓▓▓▓ │       │     │                           │     │  Ret  │ Space │
          ╰───────┴───────┴─────╯                           ╰─────┴───────┴───────╯

  ▓▓▓▓▓ = layer hold key (transparent)


Layer 2: NUM (hold left middle thumb)
======================================

Left hand provides F-keys.
Right hand provides numpad.

::

  ╭─────┬─────┬─────┬─────┬─────┬─────╮                 ╭─────┬─────┬─────┬─────┬─────┬─────╮
  │     │ F1  │ F2  │ F3  │ F4  │ F5  │                 │  +  │  7  │  8  │  9  │  *  │     │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │     │ F6  │ F7  │ F8  │ F9  │ F10 │                 │  -  │  4  │  5  │  6  │  0  │     │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │     │ F11 │ F12 │     │     │     │                 │  =  │  1  │  2  │  3  │  /  │     │
  ╰─────┴─────┴─────┴─────┴─────┴─────╯                 ╰─────┴─────┴─────┴─────┴─────┴─────╯

                Thumb Cluster                                     Thumb Cluster
          ╭───────┬───────┬─────╮                           ╭─────┬───────┬───────╮
          │       │       │     │                           │     │       │       │
          ├───────┼───────┼─────┤                           ├─────┼───────┼───────┤
          │       │ ▓▓▓▓▓ │     │                           │     │  .    │   0   │
          ╰───────┴───────┴─────╯                           ╰─────┴───────┴───────╯

  ▓▓▓▓▓ = layer hold key (transparent)


Layer 3: SYM (hold right middle thumb)
=======================================

Left hand provides symbols.
Right hand provides modifiers.

::

  ╭─────┬─────┬─────┬─────┬─────┬─────╮                 ╭─────┬─────┬─────┬─────┬─────┬─────╮
  │     │  !  │  @  │  #  │  $  │  %  │                 │  ^  │  &  │  *  │  `  │  ~  │     │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │     │  [  │  ]  │  (  │  )  │  \  │                 │  -  │Shift│ Ctrl│ Alt │ Gui │     │
  ├─────┼─────┼─────┼─────┼─────┼─────┤                 ├─────┼─────┼─────┼─────┼─────┼─────┤
  │     │  <  │  >  │  {  │  }  │  |  │                 │  _  │  +  │  =  │     │     │     │
  ╰─────┴─────┴─────┴─────┴─────┴─────╯                 ╰─────┴─────┴─────┴─────┴─────┴─────╯

                Thumb Cluster                                     Thumb Cluster
          ╭───────┬───────┬─────╮                           ╭─────┬───────┬───────╮
          │       │       │     │                           │     │       │       │
          ├───────┼───────┼─────┤                           ├─────┼───────┼───────┤
          │ Bksp  │  Del  │     │                           │     │ ▓▓▓▓▓ │       │
          ╰───────┴───────┴─────╯                           ╰─────┴───────┴───────╯

  ▓▓▓▓▓ = layer hold key (transparent)


Layer 4: MAGIC
==============

Accessed by tapping the Magic key (bottom-left corner on BASE layer).
Used for Bluetooth profiles, RGB, bootloader, and system reset.

::

  ╭─────────┬─────────┬─────────┬─────────┬─────────╮       ╭─────────┬─────────┬─────────┬─────────┬─────────╮
  │ BT CLR  │         │         │         │         │       │         │         │         │         │BT CLRALL│
  ├─────────┼─────────┼─────────┼─────────┼─────────┤       ├─────────┼─────────┼─────────┼─────────┼─────────┤
  │         │ RGB Spd+│ RGB Sat+│ RGB Hue+│ RGB Brt+│RGB Tog│         │         │         │         │         │
  ├─────────┼─────────┼─────────┼─────────┼─────────┤       ├─────────┼─────────┼─────────┼─────────┼─────────┤
  │Bootloadr│ RGB Spd-│ RGB Sat-│ RGB Hue-│ RGB Brt-│RGB Eff│         │         │         │         │Bootloadr│
  ├─────────┼─────────┼─────────┼─────────┼─────────┤       ├─────────┼─────────┼─────────┼─────────┼─────────┤
  │Sys Reset│         │         │         │         │       │         │         │         │         │Sys Reset│
  ╰─────────┴─────────┴─────────┴─────────┴─────────╯       ╰─────────┴─────────┴─────────┴─────────┴─────────╯

                  Thumb Cluster                                       Thumb Cluster
            ╭───────┬───────┬────────╮                          ╭────────┬───────┬───────╮
            │  BT 2 │  BT 3 │        │                          │        │       │       │
            ├───────┼───────┼────────┤                          ├────────┼───────┼───────┤
            │  BT 0 │  BT 1 │OUT USB │                          │        │       │       │
            ╰───────┴───────┴────────╯                          ╰────────┴───────┴───────╯
