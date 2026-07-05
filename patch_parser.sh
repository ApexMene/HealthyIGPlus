#!/bin/bash
# patch_parser.sh — Filter suggested posts + suggested reels from feed
# Patches 5bd.smali:A00 to return true (skip) for MIXED_UNCONNECTED and CLIPS_NETEGO
# Run from ig_plain/ directory

set -e

FILE="smali/X/5bd.smali"
if [ ! -f "$FILE" ]; then
    echo "ERROR: $FILE not found. Run from ig_plain/ directory."
    exit 1
fi

# Check if already patched
if grep -q "cond_pmu" "$FILE"; then
    echo "Already patched."
    exit 0
fi

# Insert filter block at :cond_0 — before invoke-virtual {p0}, LX/3vm;->A09()
sed -i '/:cond_0/a\
    sget-object v1, LX/3eh;->A0c:LX/3eh;\
    if-eq v2, v1, :cond_pmu\
    const/4 v0, 0x1\
    return v0\
    :cond_pmu\
    sget-object v1, LX/3eh;->A0C:LX/3eh;\
    if-eq v2, v1, :cond_pri\
    const/4 v0, 0x1\
    return v0\
    :cond_pri' "$FILE"

echo "Parser patch applied: MIXED_UNCONNECTED (A0c) + CLIPS_NETEGO (A0C) → filtered"
