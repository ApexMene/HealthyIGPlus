# HealthyIGPlus — Instagram Reels, Ads & Suggested Posts Blocker

> Patch Instagram APK to remove: Reels tab, suggested posts, suggested reels, ads, explore tab, story ads. Keep: home feed (followed accounts), stories, DMs.

## What's New in V4

**V4** adds a **parser-level filter** on top of endpoint blocking:
- `5bd.smali:A00` patched to filter out `MIXED_UNCONNECTED` (suggested posts) and `CLIPS_NETEGO` (RIFU / suggested reels) from feed display
- This means even if server sends suggested content in the `feed/timeline/` response, it gets filtered client-side before display
- Stories from home tray now work (V3 had a bug blocking `feed/reels_media*`)

## Features

| Feature | Status |
|---------|--------|
| Home feed (posts from followed accounts) | ✅ Works |
| Stories from home tray | ✅ Works |
| Stories from profile | ✅ Works |
| DMs | ✅ Works |
| DM'd reels from friends | ✅ Works |
| Search | ✅ Works |
| Reels tab | ❌ Blocked |
| Explore/discover | ❌ Blocked |
| "Suggested posts" in feed | ❌ Filtered (parser) |
| "Suggested reels" carousel | ❌ Filtered (parser) |
| Ads in feed | ❌ Blocked (endpoints) |
| Ads in stories | ❌ Blocked (`feed/stories_injection_tray/`) |
| Reels injection in feed | ❌ Blocked (`feed/injected_reels_media/`) |

## Build Instructions

### Prerequisites
- Java 11+
- apktool (v2.11.1+)
- Android SDK build-tools (zipalign + apksigner)
- ADB (for installing)

### Steps

```bash
# 1. Decompile
java -jar apktool.jar d -r -f -o ig_plain ig.apk

# 2. Apply endpoint patches
cd ig_plain && bash ../script_v4.sh && cd ..

# 3. Apply parser patch (filters suggested posts/reels from feed)
cd ig_plain && bash ../patch_parser.sh && cd ..

# 4. Recompile
java -Xmx3g -jar apktool.jar b -f -o install_v4.apk ig_plain/

# 5. Zipalign
zipalign -v 4 install_v4.apk install_v4_aligned.apk

# 6. Sign
apksigner sign --ks ./keystore.jks --ks-pass pass:YOUR_PASS install_v4_aligned.apk

# 7. Install
adb uninstall com.instagram.android
adb install install_v4_aligned.apk
```

### APK Source
Download the standalone APK (not bundle) for your device architecture from [APKMirror](https://www.apkmirror.com/). 
- Pixel 9a / modern phones: arm64-v8a, nodpi

## What Each Script Does

### `script_v4.sh` (RECOMMENDED)
- Blocks: reels tab, explore, reels injection into feed, story ad injection, surgical ads endpoints
- **Does NOT block:** `feed/timeline/`, `feed/reels_media*` (stories), `feed/get_latest_reel_media/`
- Combined with parser patch, this gives you a clean feed of only followed accounts

### `script_v3.sh`
- Same as V4 but blocks `feed/reels_media*` — breaks stories from home tray
- Use V4 instead

### `script.sh` (UPSTREAM)
- Original from HealthyIG repo
- Blocks EVERYTHING including `feed/timeline/` — no home feed at all

### Other scripts
- `script_no_reels_no_ads.sh` — V2 variant, no parser patch
- `script_with_ads.sh` — adds ad blocks to original
- `script_minimal.sh` — minimal reel-only blocks

## Known Limitations

- **Inline ads in `feed/timeline/` response**: Server mixes ads into the feed JSON. The parser patch filters items by type (AD, MIXED_UNCONNECTED, CLIPS_NETEGO) but some ads disguised as MEDIA posts may slip through
- **Instagram version**: Tested on 436.0.0.41.73. Newer versions may change endpoint strings
- **Re-login required**: After install, you'll need to log in again
- **Updates**: Instagram auto-updates will overwrite the patch. You'll need to re-patch

## Credits

- [HealthyIG](https://github.com/AlessandroBonomo28/HealthyIG) by AlessandroBonomo28 — original project
- Parser patch research: reverse-engineering of `LX/3eh` enum and `LX/5bd;->A00()` filter

## License

Educational purposes only. This project is not affiliated with Instagram/Meta.
