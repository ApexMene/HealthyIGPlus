#!/bin/bash

################################################################################
# HealthyIG v4 — surgical endpoint blocking + stories fix + parser patch
# Feed works, reels dead, ads dead, story ads dead, STORIES WORK
# Diff vs v3: UNBLOCKED feed/reels_media/, feed/reels_media_stream/,
#             feed/get_latest_reel_media/ (needed for story playback from home)
################################################################################

script_name=$(basename "$0")
target_directory="."

declare -A replacements

### ── Explore ──────────────────────────────────────────────────────────────────
replacements["\"discover/topical_explore/\""]="\"\""

### ── Reels tab ────────────────────────────────────────────────────────────────
replacements["\"clips/discover/\""]="\"\""
replacements["\"clips/discover/social/\""]="\"\""
replacements["\"clips/discover/stream/\""]="\"\""
replacements["\"clips/homecoming/\""]="\"\""
replacements["\"clips/trend/\""]="\"\""
replacements["\"clips/home/\""]="\"\""
replacements["\"clips/chaining/\""]="\"\""
replacements["\"clips/recommended_label/\""]="\"\""
replacements["\"discover/explore_clips/\""]="\"\""
replacements["\"discover/discover_similar_clips/\""]="\"\""
replacements["\"/suggested_content/\""]="\"\""
replacements["\"/clips_media_feed/\""]="\"\""

### ── Reels injection IN feed (kills reels appearing in timeline) ───────────────
### NOTE: feed/reels_media/, feed/reels_media_stream/, feed/get_latest_reel_media/
###       are UNBLOCKED — needed for story playback from home tray
replacements["\"feed/injected_reels_media/\""]="\"\""
replacements["\"feed/injected_reels_media_www/\""]="\"\""

### ── Stories injection (kills ads between stories) ────────────────────────────
replacements["\"feed/stories_injection_tray/\""]="\"\""

### ── Ads — surgical (NO broad /ads/ catch-all) ────────────────────────────────
replacements["\"ads/async_ads/\""]="\"\""
replacements["\"ads/async_ads/ads_only_lane/\""]="\"\""
replacements["\"ads/intent_aware_ads/reels/\""]="\"\""
replacements["\"ads/comment_sheet_ads/\""]="\"\""
replacements["\"ads/pbia_info/\""]="\"\""
replacements["\"ads/validate_story_ad_eligibility_existing_media/\""]="\"\""
replacements["\"feed/async_ads_ranking/\""]="\"\""
replacements["\"feed/contextual_multi_ads/\""]="\"\""
replacements["\"feed/user_interests_contextual_feed_of_ads/\""]="\"\""
replacements["\"feed/shop_everything_feed_of_ads_v2/\""]="\"\""
replacements["\"feed/shop_everything_feed_of_ads_v3/\""]="\"\""
replacements["\"ads/async_get_ondemand_carousel_cards/\""]="\"\""
replacements["\"ads/async_get_ondemand_carousel_cards_stories/\""]="\"\""
replacements["\"profile_ads/get_profile_ads/\""]="\"\""
replacements["\"clips/ad_preview/\""]="\"\""
replacements["\"clips/ads_discover_sync_flow/\""]="\"\""
replacements["\"discover/chaining_experience_contextual_ads/\""]="\"\""
replacements["\"discover/chaining_experience_notification_ads/\""]="\"\""
replacements["\"discover/feed_style_feed_of_ads/\""]="\"\""

### ── KEEP ALIVE (NOT blocked) ─────────────────────────────────────────────────
# feed/timeline/        — main feed (followed accounts)
# feed/timeline_stream/ — feed stream
# feed/text_post_app_timeline* — text posts
# feed/reels_tray/      — stories tray (stories must work)
# feed/reels_media/     — story playback (UNBLOCKED in v4!)
# feed/reels_media_stream/ — story streaming (UNBLOCKED in v4!)
# feed/get_latest_reel_media/ — latest story media (UNBLOCKED in v4!)
# feed/liked/           — liked posts
# feed/saved/           — saved posts
# feed/user/            — user feeds
# feed/collection/      — collections
# clips/item/           — DM'd reels from friends

echo "Patching v4: surgical reels + injection + ads blocks (stories fixed)..."

mapfile -t files < <(find "$target_directory" -type f ! -name "$script_name" ! -name "*.apk")
file_count=${#files[@]}

sed_script=$(mktemp)
for old in "${!replacements[@]}"; do
    new="${replacements[$old]}"
    echo "s|$old|$new|g" >> "$sed_script"
done

if command -v tqdm &> /dev/null; then
    printf "%s\n" "${files[@]}" | tqdm --total=$file_count --desc "Patching v4" | xargs -I {} sed -i -f "$sed_script" "{}"
else
    xargs -a <(printf "%s\n" "${files[@]}") -I {} sed -i -f "$sed_script" "{}"
fi

rm "$sed_script"
echo "Done v4: feed alive, reels dead, ads dead, story ads dead, STORIES WORK!"
