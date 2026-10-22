---
slug: /apps/screen-time
description: Set daily play time limits
---

# Screen Time
<p><i>{frontMatter.description}</i></p>

## Presentation

Screen Time lets you set a daily play time limit for games launched through Onion. When the limit is reached, Onion blocks new game launches and closes active gameplay so the device returns to MainUI.

Screen Time uses Activity Tracker play sessions to calculate today's usage, so time spent in standby or in the GameSwitcher overlay is not counted while Activity Tracker is paused.

## Usage

Screen Time is configured from **Apps** > **Tweaks** > **System** > **Screen time...**.

Available settings:

- `Unlock settings`: unlock protected settings until you leave the Screen Time menu
- `State`: enable or disable daily play time limits
- `Daily limit`: choose the total game time allowed today
- `Extra time today`: grant temporary extra time for the current day
- `PIN`: set, change, or clear the PIN used to protect Screen Time changes
- `Today used`: show the game time counted for the current day
- `Time remaining`: show the remaining time before the limit is reached

When a PIN is configured, use `Unlock settings` once before disabling Screen Time, increasing the daily limit, adding extra time, or changing the PIN. Settings lock again when you leave the Screen Time menu.

When setting a PIN, Onion asks you to enter it twice before saving it.

## Limits

Screen Time applies to game launches handled by Onion's runtime. It does not limit general access to the SD card, shell, file transfer services, or other ways of modifying Onion files.

Someone with physical SD-card access or shell access can still remove or change Screen Time settings. Treat that level of access as administrator access.

Screen Time limits **how long** games can be played, not **what** can be opened. A child can still open Apps, the RetroArch menu, and other system tools. Keep these gaps in mind:

- **Guest Mode resets the counter.** Today's usage is read from the current profile's Activity Tracker data, so switching profile with [Guest Mode](./guest-mode) counts only that profile's own usage. The daily limit and PIN are shared by both profiles.
- **Changing the date or time resets the counter.** Usage is counted for the current local day, so moving the clock forward (for example with the [Clock](./clock) app) starts a new day.

For a stricter setup, remove the Guest Mode and Clock apps with the [Package Manager](./package-manager).

## Parental controls in Onion

Screen Time is the parental control mechanism included in this Onion fork. The upstream Kids Mode app proposal ([OnionUI/Onion#1910](https://github.com/OnionUI/Onion/pull/1910)), which locks the device into a restricted setup behind a PIN, overlaps with it and is not included.

## Related

- [Tweaks](./tweaks)
- [Activity Tracker](./activity-tracker)
- [Guest Mode](./guest-mode)
