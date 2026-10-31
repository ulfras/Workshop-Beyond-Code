---
name: app-demo-media
description: Make App Store-style screenshots and a short demo video of this iOS app running in the Simulator, using only Xcode's xcrun simctl (no installs needed), with optional framing and video editing when the app-store-screenshots, screenshot-automation or remotion-best-practices skills and Node.js are available. Use when the user asks for screenshots, a demo video, an app preview, or showcase material.
---

# App demo media

Written for the BRI x Swift Bali workshop (Oct 2026). Reply to the user in Bahasa Indonesia. Headlines on screenshots are in Bahasa Indonesia.

Output: 3 screenshots of the key moments of the main user flow, and one 20 to 30 second demo video of the same flow.

## Rules

- Dummy data only. Never show real names, account numbers or customer data, including in recordings.
- Do not upload anything to App Store Connect or any other service.
- Do not install global tools (`npm -g`, `brew`, `pip`) yourself. Name the command and let the user run it.
- Do not change app code, except dummy data or a screenshot-only launch argument, and ask first.

## 0. If you cannot run shell commands

Agents inside Xcode can only run commands the user has allowed (Xcode › Settings › Intelligence › Permissions › Allowed Commands). If `xcrun` is refused: stop, tell the user in one line to add `xcrun`, `mkdir` and `mdls` there, and wait. Do not look for another way to record. If the user cannot allow it, fall back to: run the app with Xcode tools, walk the flow with `DeviceInteraction` or MobileBuildMCP, and ask the user to press the record button and the screenshot button in the Simulator window (Device Hub) while you drive the flow; then write the report in section 5 with the files the user saved.

## 1. Prepare

1. Read `AGENTS.md` and `userflow.md` to find the main flow (for example: buat tagihan > pilih teman > kirim pengingat).
2. Find or boot a simulator. Use the one already booted from the last Xcode run; otherwise prefer the newest iPhone Pro in the list (iPhone 17 Pro or 18 Pro, 1206 x 2622, accepted by the App Store without resizing).

```bash
xcrun simctl list devices booted
xcrun simctl boot "iPhone 17 Pro"   # only if none is booted; use the newest iPhone Pro name from `xcrun simctl list devices available`
```

3. Build and run the app on that simulator (Xcode MCP tools, MobileBuildMCP, the `run-simulator` skill, or `xcodebuild`). If the build fails, stop and report the first error.
4. Clean the status bar and fix the appearance:

```bash
xcrun simctl status_bar booted override --time 9:41 \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 \
  --batteryState charged --batteryLevel 100 --operatorName ""
xcrun simctl ui booted appearance light
```

## 2. Navigate the flow with real tools

Use the accessibility tree, not guessed coordinates. In order of preference:

- MobileBuildMCP tools `snapshot_ui`, `tap`, `type_text`, `screenshot` (skill `mobilebuildmcp`)
- the `agent-device` CLI (skill `ios-simulator`), if the user has installed it
- an XCUITest UI test that walks the flow (skill `flow-walkthrough` or `screenshot-automation`)

If an element has no accessibility label and you have to guess, tell the user. That is a real accessibility finding.

## 3. Screenshots

```bash
mkdir -p marketing/raw marketing/framed marketing/video
xcrun simctl io booted screenshot --type=png marketing/raw/01-<momen>.png
```

Take 3 screenshots at the three most important moments. Open and look at every image. Retake if it shows an empty state by accident, an error, a loading spinner, or the keyboard covering content.

Framing (pick what is available):

- **Skill `app-store-screenshots`** (Node.js 20.9+): device frame, headline, export at official sizes.
- **Skill `screenshot-automation`**: Swift-only pipeline with captions and frames.
- **Neither available**: deliver the raw screenshots plus a proposed headline for each. Do not fake a frame.

Headlines: at most 5 words, sell the benefit, not the feature name. Example: "Tagih teman tanpa canggung", not "Fitur Split Bill".

## 4. Demo video

Record the same flow from the start, with short pauses on each screen:

```bash
xcrun simctl io booted recordVideo --codec=h264 --force marketing/video/demo-raw.mov &
REC=$!
sleep 1
# ... run the flow with the navigation tool ...
kill -INT "$REC"    # same as Ctrl+C; the file is only complete after this
wait "$REC"
```

Aim for 20 to 30 seconds. Check the duration (`mdls -name kMDItemDurationSeconds marketing/video/demo-raw.mov` on macOS). If it is much longer, record again with fewer pauses rather than cutting the flow.

Optional editing, only if available:

- **Remotion** (skill `remotion-best-practices`, Node.js): composition 886 x 1920, 30 fps, 2-second title card, the recording, a closing card with the app name. Render to `marketing/video/demo-final.mp4`. Remotion is free for evaluation; companies above 3 employees need a licence for real work.
- **ffmpeg** (if already installed) for resizing to App Store preview size:

```bash
ffmpeg -i marketing/video/demo-raw.mov -vf "scale=886:1920,fps=30" \
  -c:v libx264 -pix_fmt yuv420p -an marketing/video/demo-886x1920.mp4
```

If neither is available, `demo-raw.mov` is the deliverable.

## 5. Clean up and report

```bash
xcrun simctl status_bar booted clear
```

Report in Bahasa Indonesia:

```
File: marketing/raw/..., marketing/framed/..., marketing/video/...
Headline: 1) ... 2) ... 3) ...
Durasi video: .. detik
Yang gagal atau dilewati: ...
Catatan aksesibilitas: <elemen tanpa label, kalau ada>
```

Remind the user: the agent checked what is visible; whether the flow feels fast, clear and natural is for a human to judge.
