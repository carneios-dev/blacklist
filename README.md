# The Blacklist

A **retail** World of Warcraft addon that allows players to blacklist other players, enabling players to create an optimal and safe gaming environment for themselves.

This is a work-in-progress and is not officially available to use yet.

## Features

- Users have the ability to blacklist a player and assign an optional reason for the blacklist.
- Users have the ability to blacklist a player for a specific amount of time (or indefinitely), for specific types of content, and for specific roles.
- When a blacklisted player is invited to a group the user is a part of, a notification is given to the user that indicates that the blacklisted player is now in their group.
- When a blacklisted player is requesting to join a group where they are blacklisted and the user has invite permissions, the request to join is automatically declined.
  - This feature is optional, but is enabled by default.
- Players that have been blacklisted by the user can see if they are blacklisted in tooltips.
- If a player is blacklisted while in the group with the user and the user has invite permissions, the player is given a prompt to kick the player or not.
  - This feature is optional and has to be explicitly enabled by the user.

## Getting Started

1. Install the addon either manually from version control or through addon managers such as [WowUp](https://wowup.io/) or [CurseForge](https://www.curseforge.com/).
1. Enable the addon in WoW.
1. Optionally, open the in-game settings by typing `/blacklist` or `/bl`.
