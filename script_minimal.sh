#!/bin/bash

################################################################################
# Description: Instagram — reels + explore + ads (surgical, no broad /ads/)
################################################################################

script_name=$(basename "$0")
target_directory="."

declare -A replacements

### Explore
replacements["\"discover/topical_explore/\""]="\"\""

### Reels — block specific clips endpoints
replacements["\"clips/discover/\""]="\"\""
replacements["\"clips/discover/social/\""]="\"\""
replacements["\"clips/discover/stream/\""]="\"\""
replacements["\"clips/trend/\""]="\"\""
replacements["\"clips/home/\""]="\"\""
replacements["\"clips/chaining/\""]="\"\""
replacements["\"clips/recommended_label/\""]="\"\""

### Ads — surgical blocks (NO broad /ads/ catch-all)
replacements["\"ads/async_ads/\""]="\"\""
replacements["\"ads/async_ads/ads_only_lane/\""]="\"\""
replacements["\"feed/async_ads_ranking/\""]="\"\""
replacements["\"ads/comment_sheet_ads/\""]="\"\""
replacements["\"ads/pbia_info/\""]="\"\""

echo "Patching: reels + explore + surgical ads blocks..."

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
echo "Done: reels + explore blocked, feed + ads untouched!"
