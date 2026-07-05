#!/bin/bash

################################################################################
# Description: Replaces Instagram feed endpoints + blocks ads
# Author: breakthescroll.com (modified)
################################################################################

script_name=$(basename "$0")
target_directory="."

declare -A replacements

### Explore
replacements["\"discover/topical_explore/\""]="\"\""

### Feed main screen
replacements["feed/timeline/\""]="\""

### Reels
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

### Ads
replacements["\"ads/async_ads/\""]="\"\""
replacements["\"ads/async_ads/ads_only_lane/\""]="\"\""
replacements["\"ads/intent_aware_ads/reels/\""]="\"\""
replacements["\"ads/validate_story_ad_eligibility_existing_media/\""]="\"\""
replacements["\"feed/async_ads_ranking/\""]="\"\""
replacements["\"ads/comment_sheet_ads/\""]="\"\""
replacements["\"ads/pbia_info/\""]="\"\""
replacements["\"/ads/\""]="\"\""

echo "Breaking endpoints + ads... This can take a few minutes"

mapfile -t files < <(find "$target_directory" -type f ! -name "$script_name" ! -name "*.apk")
file_count=${#files[@]}

sed_script=$(mktemp)
for old in "${!replacements[@]}"; do
    new="${replacements[$old]}"
    echo "s|$old|$new|g" >> "$sed_script"
done

if command -v tqdm &> /dev/null; then
    echo "Processing $file_count files with tqdm progress..."
    printf "%s\n" "${files[@]}" | tqdm --total=$file_count --desc "Replacing Endpoints" | xargs -I {} sed -i -f "$sed_script" "{}"
else
    echo "tqdm not installed. Running without progress bar."
    xargs -a <(printf "%s\n" "${files[@]}") -I {} sed -i -f "$sed_script" "{}"
fi

rm "$sed_script"

echo "Success: Endpoints + ads broken!"
