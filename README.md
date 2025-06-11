# The Blacklist - Work In Progress

A **retail** World of Warcraft addon for The War Within expansion that allows players to blacklist other players, enabling players to create an optimal and safe gaming environment for themselves.

## Features

- **Player Blacklisting**: Add players to your blacklist with custom notes and durations
- **Auto-decline Invites**: Automatically decline party invites from blacklisted players
- **Group Monitoring**: Get notified when blacklisted players join your group
- **Tooltip Integration**: See blacklist status directly in player tooltips
- **Content & Role Filters**: Filter blacklisting by content type (M+, Raid, PvP, Questing) and roles (Tank, Healer, DPS)
- **Auto-Ignore Integration**: Optionally ignore players when adding them to the blacklist
- **Blacklist Management**: View, edit, and manage your blacklist entries
- **Import/Export**: Share your blacklist with friends or between characters
- **Minimap Button**: Quick access to all addon features

## Commands

- `/bl` or `/blacklist` - Open the main UI
- `/bl help` - Show help message with all commands
- `/bl add [player] [reason]` - Add a player to your blacklist
- `/bl remove [player]` - Remove a player from your blacklist
- `/bl list` - List all blacklisted players
- `/bl config` - Open the configuration panel
- `/bl target` or `/blt` - Add your current target to the blacklist
- `/bl note [player] [note]` - Add or update a note for a blacklisted player
- `/bl reset` - Reset all settings to default

## Getting Started

1. Install the addon either manually from version control or through addon managers such as [WowUp](https://wowup.io/) or [CurseForge](https://www.curseforge.com/).
2. Enable the addon in WoW.
3. Access the addon features through the minimap button or by typing `/bl` or `/blacklist`.

## Development

The addon is structured as follows:

- **Core**: Core functionality (init.lua, core.lua, db.lua)
- **Modules**: Feature-specific modules (tooltip.lua, group.lua, commands.lua, minimap.lua)
- **UI**: User interface components (config.lua, blacklist_manager.lua)
- **Localization**: Language support (localization.lua)

## License

This addon is released under the MIT License. See LICENSE file for details.
