# ReaMenu Helper

![Status](https://img.shields.io/badge/status-beta-orange)

Drag-and-drop editor for REAPER's menus (main menu and context menus), replacing REAPER's native editor (impractical for complex menus).

> ⚠️ **Project in Beta.** Working and tested against REAPER's 21 default context menus, but may contain bugs or change structure without notice. Report issues via this repository's [Issues](../../issues).

## What it does

- Build and edit REAPER's menus visually (contexts: Main menu, Track context, Item context, Mixer, etc.) by dragging items instead of hand-editing `.ini` files.
- Import an existing `ReaperMenuSet` and keep editing it.
- Automatically fills a context with REAPER's default items.
- Groups reusable blocks of items across multiple menus.
- Live preview of how the menu will look inside REAPER, before exporting.
- Exports a `ReaperMenuSet` ready to load into REAPER (Options → Customize menus/toolbars → Import/Export).

## Requirements

- A **Chromium**-based browser with File System Access API support (needed to read/write REAPER's folders) — e.g. **Google Chrome**, **Microsoft Edge**, **Opera**. Firefox and Safari are not supported.
- REAPER installed (to locate the `MenuSets` folder and test the result).

## Installation

Install via **ReaPack**:

1. In REAPER: Extensions → ReaPack → Import a repository...
2. Paste this URL:
   ```
   https://raw.githubusercontent.com/Jay-JayDev/ReaMenuHelper/main/index.xml
   ```
3. Extensions → ReaPack → Browse packages, search for "ReaMenu Helper" and install.
4. The script appears in the Action List as **"Jay-JayDev_Open ReaMenuHelper"**: run it to open the app in your browser.

## How to use it

1. Set the REAPER folder from the button at the top (required on first launch).
2. Create a context, add items/groups/separators, export.

For the full list of features, check the **❓ Help** button inside the app.

## Repository structure

```
ReaMenuHelper.html                     ← the app (open this file)
Jay-JayDev_Open ReaMenuHelper.lua      ← optional launcher from REAPER
Data/                                  ← data used by the app at runtime
dev-tools/                             ← internal dev tools, not needed for regular use
```
