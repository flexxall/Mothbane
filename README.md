# MothBane

Hides Glowing Moth treasures from the minimap in Harandar. Choose what appears over each moth: nothing, a shadow, or a moth icon. No dependencies. World of Warcraft Retail.

---

## Installation

1. Download the latest release (zip) from [CurseForge](https://www.curseforge.com/wow/addons/mothbane) or clone this repo.
2. Extract so the `MothBane` folder (containing `MothBane.toc`, `MothBane.lua`, etc.) is inside `World of Warcraft\_retail_\Interface\AddOns\`.
3. Restart WoW or run `/reload`.

---

## Slash commands

| Command | Description |
|--------|-------------|
| **/mothbane** | Open or close the settings window. Use this when the minimap button is hidden. |
| **/mothbane on** or **/mothbane 1** | Enable MothBane. |
| **/mothbane off** or **/mothbane 0** | Disable MothBane. |
| **/mothbane debug** | Toggle debug logging. Only available in the developer build. |

---

## Opening the UI

- **Minimap:** Left-click the moth icon to open options. Right-click and drag to move the icon. You can hide the button in settings and use **/mothbane** instead.
- **Slash:** Type **/mothbane** to open or close the settings window (works when the minimap button is hidden).

---

## Settings

- **Enable MothBane** – Master on/off.
- **Show minimap button** – Show or hide the moth icon on the minimap.
- **Replace Blizzard treasure with:** Nothing / Shadow / Moth – What to show at each moth on the minimap. Default is Moth.

---

## Publishing

See [CURSEFORGE.md](CURSEFORGE.md) for CurseForge upload steps, packaging the zip, and Git setup.
