# CurseForge release checklist

Use this when publishing or updating MothBane on CurseForge.

---

## First-time setup

1. **Create the project**
   - Go to [CurseForge WoW Addons](https://www.curseforge.com/wow/addons) → **Submit New Project**.
   - **Project name:** MothBane  
   - **Category:** Map & Minimap (or Interface Enhancements)  
   - **Game version:** World of Warcraft (Retail). Add the latest version(s) you support (e.g. 11.0.x).

2. **Short description** (for listing/search):
   ```
   Hides Glowing Moth treasures from the minimap in Harandar. Choose nothing, a shadow, or a moth icon. No dependencies.
   ```

3. **Full description**
   - Paste the contents of README.md, or a shorter version that includes: what it does, slash commands, how to open the UI, and main settings.

4. **Optional: link GitHub**
   - In project **Settings** or **Links**, add your repository URL so the "Source" link appears.

5. **After the project is created**
   - CurseForge may show a **Project ID**. You can add to `MothBane.toc` for their detection:
     ```
     ## X-Curse-Project-ID: 123456
     ```
   - Replace `X-Website` in the TOC with your real GitHub URL if different from the placeholder.

---

## Packaging the zip

The zip must contain the **contents** of the addon folder so that after extracting, users have:

```
MothBane/
  MothBane.toc
  MothBane.lua
  MothBane_UI.lua
  Art/
    mothbane.blp   (or .tga – your icon texture)
  README.md       (optional but nice)
  CHANGELOG.md    (optional)
```

**Do not** zip the parent folder so the zip root is `MothBane` (the folder name). So:

- **Correct:** Zip contents of `MothBane` → open zip and first thing you see is `MothBane.toc`, `MothBane.lua`, etc.
- **Wrong:** Zip the `MothBane` folder itself → open zip and you see one folder `MothBane`; that can break some installs.

**Windows (PowerShell)** from `Interface\AddOns\`:
```powershell
Compress-Archive -Path MothBane\* -DestinationPath MothBane-0.0.4.zip
```
Then rename or move so the zip is named e.g. `MothBane-0.0.4.zip`. CurseForge will accept it.

**Manual:** Select all files and folders inside `MothBane` (not the folder), right‑click → Send to → Compressed folder, then rename the zip.

---

## Uploading a release

1. In your CurseForge project, go to **Files** → **Upload new file**.
2. Choose the zip you built.
3. **Game version:** Select the WoW Retail version(s) this release supports (e.g. 11.0.5).
4. **Release type:** Alpha / Beta / Release (use Release for 0.0.4).
5. **Changelog:** Paste what changed (e.g. from CHANGELOG.md for this version).
6. Submit. CurseForge will scan the TOC and list the addon.

---

## Keywords / discoverability

CurseForge search uses your **title**, **short description**, and **full description**. No separate “keywords” field. Include terms like:

- Harandar  
- Glowing Moth  
- minimap  
- treasure  
- hide  
- moth  

---

## Git (GitHub)

Use your **personal** GitHub account (e.g. flexxall@live.com), not a shared/org repo like mysmartplanskc.

1. Create a new repo (e.g. `MothBane`) under your personal account. Do **not** init with a README if you already have one locally.
2. In your addon folder, set your identity for this repo (if needed) and push:
   ```bash
   git config user.email "flexxall@live.com"
   git init
   git add .
   git commit -m "Initial release 0.0.4"
   git branch -M main
   git remote add origin https://github.com/flexxall/MothBane.git
   git push -u origin main
   ```
3. Confirm the remote is your personal repo: `git remote -v` should show **your** GitHub URL, not mysmartplanskc or any other org.
4. Add a **License** file in the repo if you want (e.g. MIT). Optional but recommended for open source.

Done. For future releases: bump version in the TOC and CHANGELOG, commit, tag (e.g. `v0.0.5`), push, then build the zip and upload to CurseForge.
