#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

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
echo -e "    /     \\   ${bold_green}$0${nc}${bold_yellow} v3.5${nc}${bold}"
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
    echo -e "Usage: $0 <username>\n"
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
createTime=$(extract '"createTime":\d+' 's/"createTime"://')
uniqueIdModifyTime=$(extract '"uniqueIdModifyTime":\d+' 's/"uniqueIdModifyTime"://')
nickNameModifyTime=$(extract '"nickNameModifyTime":\d+' 's/"nickNameModifyTime"://')

# Convert Unix timestamps to human-readable
to_date() {
    if [[ -n "$1" && "$1" =~ ^[0-9]+$ ]]; then
        date -d @"$1" +"%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "$1"
    else
        echo "N/A"
    fi
}

createTime_human=$(to_date "$createTime")
uniqueIdModifyTime_human=$(to_date "$uniqueIdModifyTime")
nickNameModifyTime_human=$(to_date "$nickNameModifyTime")

# Resolve language
if [[ -n ${language_code:-} && -f languages.json ]]; then
    language_name=$(jq -r --arg lang "$language_code" '.[] | select(.code == $lang) | .name' languages.json)
    language="${language_name:-Unknown (Code: $language_code)}"
else
    language="N/A"
fi

# Resolve region
region_code=$(echo "$source_code" | grep -oP '"ttSeller":false,"region":"\K[^"]+')

if [[ -n "$region_code" && -f countries.json ]]; then
    country_name=$(jq -r --arg region "$region_code" '.[] | select(.code == $region) | .name')
    region="${country_name:-Unknown (Code: $region_code)}"
else
    region="N/A"
fi

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
    echo "Account Created: $createTime_human"
    echo "Last Username Change: $uniqueIdModifyTime_human"
    echo "Last Nickname Change: $nickNameModifyTime_human"
    echo
    echo -e "TikTok profile: ${underline}https://tiktok.com/@$uniqueId${nc}\n"
else
    echo "Failed to fetch account details. TikTok might block the request or username doesn't exist."
    exit 1
fi
