#!/bin/bash

################################################################################
# Description: Instagram — posts only, no reels, no ads
################################################################################

script_name=$(basename "$0")
target_directory="."

declare -A replacements

### Explore
replacements["\"discover/topical_explore/\""]="\"\""

### Feed main screen — NOT BLOCKED (keep posts from followed accounts)
# replacements["feed/timeline/\""]="\""   # <-- REMOVED: user wants feed

### Reels — ALL BLOCKED
replacements["\"clips/discover/\""]="\"\""
replacements["\"clips/discover/social/\""]="\"\""
replacements["\"discover/explore_clips/\""]="\"\""
replacements["\"clips/discover/stream/\""]="\"\""
replacements["\"clips/suggested_template\""]="\"\""
replacements["\"clips/trend/\""]="\"\""
replacements["\"discover/discover_similar_clips/\""]="\"\""
replacements["\"/suggested_content/\""]="\"\""
replacements["\"clips/home/\""]="\"\""
replacements["\"clips/chaining/\""]="\"\""
replacements["\"clips/recommended_label/\""]="\"\""
replacements["\"/clips_media_feed/\""]="\"\""

### Ads — ALL BLOCKED
replacements["\"ads/async_ads/\""]="\"\""
replacements["\"ads/async_ads/ads_only_lane/\""]="\"\""
replacements["\"ads/intent_aware_ads/reels/\""]="\"\""
replacements["\"ads/validate_story_ad_eligibility_existing_media/\""]="\"\""
replacements["\"feed/async_ads_ranking/\""]="\"\""
replacements["\"ads/comment_sheet_ads/\""]="\"\""
replacements["\"ads/pbia_info/\""]="\"\""
replacements["\"/ads/\""]="\"\""

echo "Breaking reels + ads endpoints..."

mapfile -t files < <(find "$target_directory" -type f ! -name "$script_name" ! -name "*.apk")
file_count=${#files[@]}

sed_script=$(mktemp)
for old in "${!replacements[@]}"; do
    new="${replacements[$old]}"
    echo "s|$old|$new|g" >> "$sed_script"
done

if command -v tqdm &> /dev/null; then
    printf "%s\n" "${files[@]}" | tqdm --total=$file_count --desc "Patching" | xargs -I {} sed -i -f "$sed_script" "{}"
else
    xargs -a <(printf "%s\n" "${files[@]}") -I {} sed -i -f "$sed_script" "{}"
fi

rm "$sed_script"
echo "Done: reels + ads blocked, feed kept!"
