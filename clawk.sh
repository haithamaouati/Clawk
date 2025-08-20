#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

set -euo pipefail

# Colors
nc="\e[0m"
bold="\e[1m"
underline="\e[4m"
bold_green="\e[1;32m"
bold_red="\e[1;31m"
bold_yellow="\e[1;33m"

# Dependency check
for cmd in curl jq; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: $cmd is required but not installed." >&2
        exit 1
    fi
done

# Banner
print_banner() {
clear
echo -e "${bold}"
echo -e "    /\\___/\\"
echo -e "    )     ("
echo -e "   =\     /="
echo -e "     )   ("
echo -e "    /     \\   ${bold_green}$0${nc}${bold_yellow} v3.0${nc}${bold}"
echo -e "    )     (   ${nc}Scrape TikTok info by username.${bold}"
echo -e "   /       \\  ${nc}Author: Haitham Aouati${bold}"
echo -e "   \       /  ${nc}GitHub: ${underline}github.com/haithamaouati${nc}${bold}"
echo -e "    \__ __/"
echo -e "       ))"
echo -e "      //"
echo -e "     (("
echo -e "      \)${nc}\n"
}

print_banner

# Get username from argument
username="${1:-}"
username="${username/@/}"  # Remove @ if included

if [[ -z "$username" ]]; then
    echo "Usage: $0 <username>"
    exit 1
fi

echo -e "Scraping TikTok info for ${bold}@$username${nc}"

# Fetch source
url="https://www.tiktok.com/@$username?isUniqueId=true&isSecured=true"
source_code=$(curl -sL -A "Mozilla/5.0" "$url")

# Helper to extract JSON fields
extract() {
    echo "$source_code" | grep -oP "$1" | head -n 1 | sed "$2"
}

# Extract main fields
id=$(extract '"id":"\d+"' 's/"id":"//;s/"//')
uniqueId=$(extract '"uniqueId":"[^"]*"' 's/"uniqueId":"//;s/"//')
nickname=$(extract '"nickname":"[^"]*"' 's/"nickname":"//;s/"//')
avatarLarger=$(extract '"avatarLarger":"[^"]*"' 's/"avatarLarger":"//;s/"//')
signature=$(extract '"signature":"[^"]*"' 's/"signature":"//;s/"//')
privateAccount=$(extract '"privateAccount":[^,]*' 's/"privateAccount"://')
secret=$(extract '"secret":[^,]*' 's/"secret"://')
language_code=$(extract '"language":"[^"]*"' 's/"language":"//;s/"//')
secUid=$(extract '"secUid":"[^"]*"' 's/"secUid":"//;s/"//')
diggCount=$(extract '"diggCount":[^,]*' 's/"diggCount"://')
followerCount=$(extract '"followerCount":[^,]*' 's/"followerCount"://')
followingCount=$(extract '"followingCount":[^,]*' 's/"followingCount"://')
heartCount=$(extract '"heartCount":[^,]*' 's/"heartCount"://')
videoCount=$(extract '"videoCount":[^,]*' 's/"videoCount"://')
friendCount=$(extract '"friendCount":[^,}]*' 's/"friendCount"://')  # fix trailing }

# Resolve language
if [[ -n ${language_code:-} && -f languages.json ]]; then
    language_name=$(jq -r --arg lang "$language_code" '.[] | select(.code == $lang) | .name' languages.json)
    language="${language_name:-Unknown (Code: $language_code)}"
else
    language="Not Found"
fi

# Robust region detection: grab all "region" codes and find the first valid one
region="Not Found"
region_codes=($(echo "$source_code" | grep -o '"region":"[^"]*"' | sed 's/"region":"//;s/"//'))
for code in "${region_codes[@]}"; do
    if [[ -f countries.json ]]; then
        country_name=$(jq -r --arg region "$code" '.[] | select(.code == $region) | .name' countries.json)
        if [[ -n "$country_name" && "$country_name" != "null" ]]; then
            region="$country_name"
            break
        fi
    fi
done

# Output
if [[ -n $id ]]; then
    echo
    echo "User ID: $id"
    echo "Username: $uniqueId"
    echo "Nickname: $nickname"
    echo "Verified: $secret"
    echo "Private Account: $privateAccount"
    echo "Language: $language"
    echo "Region: $region"
    echo "Followers: $followerCount"
    echo "Following: $followingCount"
    echo "Likes: $heartCount"
    echo "Videos: $videoCount"
    echo "Friends: $friendCount"
    echo "Heart: $heartCount"
    echo "Digg Count: $diggCount"
    echo "SecUid: $secUid"
    echo
    echo "Biography:"
    echo -e "$signature"
    echo
    echo "TikTok Profile: https://www.tiktok.com/@$uniqueId"
    echo

    # Download avatar
    if [[ -n "$avatarLarger" ]]; then
        filename="${uniqueId}_profile_pic.jpg"
        curl -sL "$avatarLarger" -o "$filename" && echo "Profile picture downloaded as $filename"
    fi
else
    echo "Failed to fetch account details. TikTok might block the request or username doesn't exist."
    exit 1
fi
