# New File

A tiny, invisible macOS helper app that creates a new empty file in the folder you right-clicked — wired into [Finder's](https://support.apple.com/guide/mac-help/finder-mchlp1618/mac) right-click menu via [OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal).

It has no window, no Dock icon, and no UI of its own. It's launched, does its one job, and quits.

## How it works

[OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal) adds a right-click context menu to Finder and the Desktop, and lets you register arbitrary apps under **Preferences → Custom → Custom Menu Options**. When you pick one of those apps from the menu, OpenInTerminal simply runs:

```sh
open -a "New File" /path/to/whatever/you/right-clicked
```

This app receives that path via the standard macOS "open" delegate callback, and:

- if the path is a **folder** (or you right-clicked empty space in Finder/Desktop) — creates a new file inside it
- if the path is a **file** — creates the new file in that file's parent folder

The new file is named `untitled.txt`, incrementing to `untitled 2.txt`, `untitled 3.txt`, etc. if a name is already taken. It then reveals and selects the new file in Finder so you can immediately rename it — except when the file lands on the Desktop, since Desktop icons are already visible without opening a Finder window.

## Requirements

- [OpenInTerminal](https://github.com/Ji4n1ng/OpenInTerminal) installed and running

## Install

> ⚠️ This app is currently **unsigned and not notarized**, so macOS Gatekeeper needs a couple of manual overrides before it'll run.

1. Download the latest release from the [Releases page](https://github.com/ashuvssut/new-file-context-menu/releases/latest) and unzip it.
2. Move `New File.app` to your `Applications` folder.
3. If you see an error saying **"New File" is damaged and can't be opened**, run:

   ```sh
   sudo xattr -rd com.apple.quarantine "/Applications/New File.app"
   ```

4. The first time it needs to create a file on your Desktop or in Documents/Downloads, macOS will prompt you for permission — approve it. To make sure that approval sticks across future updates instead of prompting again, give the app a stable local signature:

   ```sh
   sudo codesign --deep --force --sign - "/Applications/New File.app"
   ```

5. Open **OpenInTerminal → Preferences → Custom** tab.
6. Under **Custom Menu Options**, click **+**, select `New File.app` from `/Applications`, choose the **Editor** type, and confirm.
7. Make sure **Apply to Finder Context Menu** (and/or **Apply to Finder Toolbar Menu**) is checked.

## Building from source

Quickest way — run the release build script with `--skip-zip` to get the built app directly at `dist/New File.app`:

```sh
./scripts/build-release.sh --skip-zip
```

Move it to `/Applications` and follow steps 3–7 from **Install** above.

(Maintainers cutting an actual GitHub Release should omit `--skip-zip` — that produces `dist/New File.app.zip`, ready to attach as a release asset.)

Alternatively, build via Xcode directly:

1. Open `newfile.xcodeproj` in Xcode and build (**Product → Build**, or **Cmd+B**).
2. Locate the built app: **Product → Show Build Folder in Finder**, then open the `Debug` (or `Release`) folder inside it — you'll find `New File.app`.
3. Follow steps 2–7 from **Install** above.

## Usage

Right-click anywhere on the Desktop, in an empty area of a Finder window, or directly on a file or folder, then choose **New File** from the context menu.

## Releasing (maintainers)

```sh
./scripts/cut-release.sh v1.0.1 "Fix Desktop reveal bug"
```

Builds a fresh unsigned release, tags it, pushes the tag, and publishes a GitHub Release with the zip attached — requires a clean working tree and the [`gh` CLI](https://cli.github.com/) authenticated.

## Notes

- App Sandbox is intentionally disabled. A sandboxed app only gets a temporary, URL-scoped write permission for the exact path it's opened with — enough to write into a selected folder, but not into a selected file's parent directory. Since this app needs to create files anywhere the user can right-click, it can't run sandboxed.

## License

[MIT](LICENSE)
