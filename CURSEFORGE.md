# CurseForge release checklist

Use this when publishing or updating MothBane on CurseForge.

---

## First-time setup

1. **Create the project**
   - Go to [CurseForge WoW Addons](https://www.curseforge.com/wow/addons) → **Submit New Project**.
   - **Project name:** MothBane  
   - **Category:** Map & Minimap (or Interface Enhancements)  
   - **Game version:** World of Warcraft (Retail). Match what’s in `MothBane.toc` (e.g. **12.0.5** when `Interface` lists **120005**).

2. **Short description** (for listing/search):
   ```
   Customizes how Glowing Moth treasures appear on the minimap in Harandar. Replace the default treasure icon with a shadow or a moth icon so you can tell them apart from other treasures. No dependencies.
   ```

3. **Full description** (overview page)
   - **WYSIWYG (recommended when Markdown fails):** Open **`CURSEFORGE_DESCRIPTION.html`** in your editor. Copy everything from `<h1>MothBane</h1>` through the final `<p>Source: …</p>` (skip nothing—omit only a BOM if your editor adds one). In the CurseForge description field, switch to **WYSIWYG** (not Markdown). Look for **Source**, **HTML**, or a **`</>`** button on the toolbar—paste the HTML there and save. If there is **no** HTML mode: open **`CURSEFORGE_DESCRIPTION.html`** in Chrome or Edge (**File → Open file**), press **Ctrl+A**, **Ctrl+C**, then paste into the empty WYSIWYG body—many editors inherit headings, lists, and links from the clipboard.
   - **Markdown:** Still flaky vs GitHub; only use if you verify headings render after save.
   - **BBCode:** Copy **`CURSEFORGE_DESCRIPTION.bbcode`** if the editor exposes a BBCode tab instead.
   - **Hero image:** HTML/BBCode embed **`mothView.png`** directly under the title (`raw.githubusercontent.com/.../main/mothView.png`). Commit it on **`main`** or swap `src` / `[img]` for a URL from **Project → Images** after uploading.
   - Keep functional sections before donate/external promo—extras belong **below** the main description (see Moderation Policies).

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

CurseForge requires WoW addons to be packaged **with a root folder**. When you open the zip, the first thing you see must be the `MothBane` folder; inside it are the addon files:

```
MothBane/           ← root folder (required)
  MothBane.toc
  MothBane.lua
  MothBane_UI.lua
  Art/
    mothbane.blp
  README.md
  CHANGELOG.md
  etc.
```

- **Correct:** Zip the `MothBane` folder itself → open zip and you see one folder `MothBane`; open that to see the files.
- **Wrong:** Zip only the contents (so the zip root is `MothBane.toc`, `MothBane.lua`, etc.). CurseForge will reject: "WoW addons must be packaged so that all files are inside a root folder."

**Windows (PowerShell)** from the parent of your addon folder (e.g. `d:\AddOns\`):
```powershell
Compress-Archive -Path MothBane -DestinationPath MothBane-0.0.5.zip
```
Then rename so the zip is e.g. `MothBane-0.0.5.zip`. CurseForge will accept it.

**Manual:** Right‑click the `MothBane` folder → Send to → Compressed (zipped) folder, then rename the zip (e.g. `MothBane-0.0.5.zip`).

---

## Uploading a release

1. In your CurseForge project, go to **Files** → **Upload new file**.
2. Choose the zip you built.
3. **Game version:** Select the WoW Retail version(s) this release supports (e.g. 11.0.5).
4. **Release type:** Alpha / Beta / Release (use Release for stable drops).
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
   git commit -m "Release 0.0.5"
   git branch -M main
   git remote add origin https://github.com/flexxall/MothBane.git
   git push -u origin main
   ```
3. Confirm the remote is your personal repo: `git remote -v` should show **your** GitHub URL, not mysmartplanskc or any other org.
4. Add a **License** file in the repo if you want (e.g. MIT). Optional but recommended for open source.

Done. For future releases: bump version in the TOC and CHANGELOG, commit, tag (e.g. `v0.0.5`), push, then build the zip and upload to CurseForge.
