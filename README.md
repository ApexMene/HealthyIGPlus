# HealthyIG

Patch Instagram to remove reels, suggested content, and ads from the home feed while keeping core functionality intact.

## Features

| Feature | Status |
|---------|--------|
| Home feed (followed accounts) | ✅ |
| Stories (tray + profile) | ✅ |
| DMs | ✅ |
| Search | ✅ |
| DM'd reels from friends | ✅ |
| Reels tab | ❌ blocked |
| Explore / discover | ❌ blocked |
| Suggested posts in feed | ❌ filtered |
| Suggested reels in feed | ❌ filtered |
| Ads / sponsored posts | ❌ filtered |
| Scroll past "all caught up" divider | ❌ halted |

## How it works

Three independent layers, each removable:

**1. Endpoint blocking** - `script_v4.sh` rewrites SMALI to intercept and short-circuit server endpoints for reels, explore, suggested content, and ads. Requests still reach Instagram's servers but the app ignores the responses.

**2. Client-side display filter** - `patches/5bd.A00.patch` adds enum checks to the `LX/5bd;->A00` method. Each feed item carries a type tag - the patch skips rendering for 7 types: mixed-unconnected (suggested posts), clips-netego (suggested reels), suggested users, suggested producers, suggested hashtags, stories netego, and ads.

**3. Pagination halt** - two patches force the home feed to stop at the "all caught up" divider (`LX/3eh;->A0G`):

- `patches/3lq.A03.patch` - the original pagination gate (`LX/3lq;->A03()Z`) checked whether the LAST displayed item was the end-of-feed bookmark. Instagram's response parser inserts replacement recommendations after the bookmark, so it was never last. The patch delegates to `LX/3vm;->A06()` which returns true when the bookmark appears ANYWHERE in the list.

- `patches/3eo.A01.patch` - Instagram has a server-controlled user preference `is_ifr_eligible` that overrides the pagination gate entirely. The patch forces it to false, so the end-of-feed path is always taken.

## Quick start

### Prerequisites

- Linux or WSL2
- Java 17+ (`java -version`)
- [apktool](https://apktool.org/) 2.11+ (`apktool.jar` in project root)
- Android SDK build-tools 34+ for `zipalign` and `apksigner`
- A stock Instagram APK (version 436.0.0.41.73 recommended)

### Build

```bash
# 1. Decompile
apktool d Instagram.apk -o ig_plain

# 2. Apply display filter (suggested posts, reels, ads)
patch -p1 < patches/5bd.A00.patch

# 3. Apply pagination halt
patch -p1 < patches/3lq.A03.patch
patch -p1 < patches/3eo.A01.patch

# 4. Apply endpoint blocker
./script_v4.sh ig_plain

# 5. Rebuild
apktool b ig_plain -o install_unsigned.apk

# 6. Align and sign
zipalign -p -f -v 4 install_unsigned.apk install_aligned.apk

# Generate keystore (first time only)
keytool -genkeypair -v -keystore healthyig.jks -alias key0 \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass password -keypass password \
  -dname "CN=HealthyIG, O=Android, C=IT"

apksigner sign --ks ./healthyig.jks --ks-pass pass:password \
  --key-pass pass:password --v1-signing-enabled true \
  --v2-signing-enabled true --v3-signing-enabled true \
  --min-sdk-version 21 --out install.apk install_aligned.apk

# 7. Install (uninstall first - signature changed)
adb uninstall com.instagram.android
adb install install.apk
```

### Verifying the patches

```bash
# Check display filter (should show 7 enum checks)
grep -c "sget-object.*LX/3eh;->A0" ig_plain/smali/X/5bd.smali
# Expected output: 7

# Check pagination halt (should be single-register delegation)
grep "invoke-static.*A06.*Collection" ig_plain/smali/X/3lq.smali
# Expected output: match on invoke-static

# Check isIfrEligible kill (should be return-false stub)
grep "const/4 v0, 0x0" ig_plain/smali/X/3eo.smali
# Expected output: one match
```

## File reference

| File | Purpose |
|------|---------|
| `script_v4.sh` | Endpoint blocker (smali regex rewrites) |
| `patch_parser.sh` | Additional parser-layer filter |
| `patches/5bd.A00.patch` | Display-level content type filter |
| `patches/3lq.A03.patch` | Pagination gate fix (any-A0G) |
| `patches/3eo.A01.patch` | isIfrEligible override (return-false) |
| `GUIDE_WSL.md` | WSL2 environment setup guide |

## Troubleshooting

| Symptom | Likely cause |
|---------|-------------|
| Infinite spinner at feed end | `3eo.A01` patch not applied - `is_ifr_eligible` still active |
| Feed keeps scrolling past divider | `3lq.A03` not applied - original last-item check still in use |
| Suggested posts still visible | `5bd.A00` not applied or enum mismatch (check grep count = 7) |
| App crashes on startup | Instagram version mismatch - use 436.0.0.41.73 |
| "App not installed" error | Signature mismatch - uninstall old version first |

## License

MIT
