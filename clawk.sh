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
dependencies=(curl jq)
for cmd in "${dependencies[@]}"; do
    if ! command -v "$cmd" &>/dev/null; then
        echo -e "${bold_red}Error:${nc} '$cmd' is required but not installed. Please install it and try again.\n" >&2
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
echo -e "    /     \\   ${bold_green}$0${nc}${bold_yellow} v2.0${nc}${bold}"
echo -e "    )     (   ${nc}Scrape TikTok info by username.${bold}"
echo -e "   /       \\  ${nc}Author: Haitham Aouati${bold}"
echo -e "   \       /  ${nc}GitHub: ${underline}github.com/haithamaouati${nc}${bold}"
echo -e "    \__ __/"
echo -e "       ))"
echo -e "      //"
echo -e "     (("
echo -e "      \)${nc}\n"
}

# Help
print_help() {
    echo -e "Usage: $0 -u <username> [-o <file.json>]\n"
    echo "Options:"
    echo "  -u, --username   TikTok username (without @)"
    echo "  -o, --output     Save output as JSON file (optional)"
    echo -e "  -h, --help       Show this help message\n"
    exit 0
}

print_banner

# Parse args
username=""
output_file=""

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -u|--username)
            username="$2"
            shift 2
            ;;
        -o|--output)
            if [[ -n "${2:-}" && ! "$2" =~ ^- ]]; then
                output_file="$2"
                shift 2
            else
                output_file="__auto__"
                shift 1
            fi
            ;;
        -h|--help)
            print_help
            ;;
        *)
            echo "Unknown option: $1"
            print_help
            ;;
    esac
done

# Check required input
if [[ -z "$username" ]]; then
    echo -e "${bold_red}[!] Error:${nc} Username not provided.\n"
    print_help
fi

echo -e "Scraping TikTok info for ${bold}@$username${nc}"

# Request page
url="https://www.tiktok.com/@$username?isUniqueId=true&isSecured=true"
source_code=$(curl -sL -A "Mozilla/5.0" "$url")

# Extract helper
extract() {
    echo "$source_code" | grep -oP "$1" | head -n 1 | sed "$2"
}

# Extract data
id=$(extract '"id":"\d+"' 's/"id":"//;s/"//')
uniqueId=$(extract '"uniqueId":"[^"]*"' 's/"uniqueId":"//;s/"//')
nickname=$(extract '"nickname":"[^"]*"' 's/"nickname":"//;s/"//')
avatarLarger=$(extract '"avatarLarger":"[^"]*"' 's/"avatarLarger":"//;s/"//')
signature=$(extract '"signature":"[^"]*"' 's/"signature":"//;s/"//')
privateAccount=$(extract '"privateAccount":[^,]*' 's/"privateAccount"://')
secret=$(extract '"secret":[^,]*' 's/"secret"://')
language_code=$(extract '"language":"[^"]*"' 's/"language":"//;s/"//')
region_code=$(echo "$source_code" | grep -o '"region":"[^"]*"' | sed -n '2p' | sed 's/"region":"//;s/"//')

followerCount=$(extract '"followerCount":[^,]*' 's/"followerCount"://')
followingCount=$(extract '"followingCount":[^,]*' 's/"followingCount"://')
heartCount=$(extract '"heartCount":[^,]*' 's/"heartCount"://')
videoCount=$(extract '"videoCount":[^,]*' 's/"videoCount"://')

# Region name
if [[ -n ${region_code:-} && -f countries.json ]]; then
    country_name=$(jq -r --arg region "$region_code" '.[] | select(.code == $region) | .name' countries.json)
    region="${country_name:-Unknown (Code: $region_code)}"
else
    region="Not Found"
fi

# Language name
if [[ -n ${language_code:-} && -f languages.json ]]; then
    language_name=$(jq -r --arg lang "$language_code" '.[] | select(.code == $lang) | .name' languages.json)
    language="${language_name:-Unknown (Code: $language_code)}"
else
    language="Not Found"
fi

# Output to terminal
if [[ -n $id ]]; then
    echo -e "\nID: ${bold_green}$id${nc}"
    echo -e "Username: ${bold_green}$uniqueId${nc}"
    echo -e "Nickname: ${bold_green}$nickname${nc}"
    echo -e "Bio: ${bold_green}$signature${nc}\n"
    echo -e "Private Account: ${bold_green}$privateAccount${nc}"
    echo -e "Verified Badge: ${bold_green}$secret${nc}"
    echo -e "Language: ${bold_green}$language${nc}"
    echo -e "Region: ${bold_green}$region${nc}\n"
    echo -e "Followers: ${bold_green}$followerCount${nc}"
    echo -e "Following: ${bold_green}$followingCount${nc}"
    echo -e "Likes: ${bold_green}$heartCount${nc}"
    echo -e "Videos: ${bold_green}$videoCount${nc}\n"
    echo -e "Avatar: ${bold_green}$avatarLarger${nc}\n"
else
    echo -e "${bold_red}[!]${nc} Failed to fetch account details. TikTok might be blocking the request or the username doesn't exist.\n"
    exit 1
fi

# Save JSON output
if [[ -n "$output_file" ]]; then
    [[ "$output_file" == "__auto__" ]] && output_file="${username}.json"
    jq -n --arg id "$id" \
          --arg username "$uniqueId" \
          --arg nickname "$nickname" \
          --arg bio "$signature" \
          --arg avatar "$avatarLarger" \
          --arg private "$privateAccount" \
          --arg verified "$secret" \
          --arg language "$language" \
          --arg region "$region" \
          --arg followers "$followerCount" \
          --arg following "$followingCount" \
          --arg likes "$heartCount" \
          --arg videos "$videoCount" \
          '{
              id: $id,
              username: $username,
              nickname: $nickname,
              bio: $bio,
              avatar: $avatar,
              private_account: $private,
              verified_badge: $verified,
              language: $language,
              region: $region,
              followers: $followers | tonumber,
              following: $following | tonumber,
              likes: $likes | tonumber,
              videos: $videos | tonumber
          }' > "$output_file"
    echo -e "${bold_green}[✓] Saved to:${nc} $output_file\n"
fi
