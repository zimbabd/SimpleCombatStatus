# SimpleCombatStatus

A lightweight World of Warcraft addon that displays a brief on-screen message when you enter or leave combat. The message fades out automatically after a few seconds.

## Features

- Shows an enter-combat message in red and a leave-combat message in green.
- Move the message frame and lock it in place.
- Adjust the font size and restore the default settings with slash commands.
- English, Russian, German, and French translations, with automatic client-locale detection.
- Remembers your frame position and preferences between sessions.

## Installation

1. Download or clone this repository.
2. Place the `SimpleCombatStatus` folder in your World of Warcraft `_retail_/Interface/AddOns` directory. For another game version, use that version's `Interface/AddOns` directory.
3. Make sure `SimpleCombatStatus.toc`, `SimpleCombatStatus.lua`, and `zba.tga` are directly inside the `SimpleCombatStatus` folder.
4. Enable **SimpleCombatStatus** from the AddOns list at character select.

## Commands

Run these commands in the in-game chat:

| Command | Description |
| --- | --- |
| `/scs` | Show the command list. |
| `/scs unlock` | Unlock the frame so it can be dragged. |
| `/scs lock` | Lock the frame in its current position. |
| `/scs size <number>` | Set the font size to a positive number. |
| `/scs reset` | Restore the default position and settings. |
| `/scs lang <code\|auto>` | Set the language (`enUS`, `ruRU`, `deDE`, `frFR`) or use the client locale with `auto`. |
<img width="673" height="384" alt="image" src="https://github.com/user-attachments/assets/f16903b8-f511-4d97-9eca-de31992e57ce" />

## Screenshots

<img width="1291" height="858" alt="image" src="https://github.com/user-attachments/assets/350d40c2-af7a-4591-b4ae-c41f790da1a5" />
<img width="1107" height="710" alt="image" src="https://github.com/user-attachments/assets/bc1ea902-1e0c-4b30-90e2-65223582a69d" />



<!-- Add screenshots to the screenshots/ directory and embed them here, for example:
![Combat status message](screenshots/combat-status.png)
-->

## Changelog

See [CHANGELOG.md](CHANGELOG.md).