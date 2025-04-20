#!/bin/bash

# Author: Haitham Aouati
# GitHub: github.com/haithamaouati

# Text Format
normal="\e[0m"
bold="\e[1m"
faint="\e[2m"
italics="\e[3m"
underlined="\e[4m"

# Check dependencies
if ! command -v figlet &>/dev/null || ! command -v curl &>/dev/null || ! command -v jq &>/dev/null; then
    echo -e "Error: figlet, curl and jq are required but not installed. Please install them and try again."
    exit 1
fi

print_banner() {
    clear
    figlet -f standard "Clawk"
    echo -e "Scrape TikTok info by username\n"
    echo -e " Author: Haitham Aouati"
    echo -e " GitHub: ${underlined}github.com/haithamaouati${normal}\n"
}

print_help() {
    print_banner
    echo -e "Usage: $0 -u <username>\n"
    echo "Options:"
    echo "  -u, --username   TikTok username (without @)"
    echo -e "  -h, --help       Show this help message\n"
    exit 0
}

# Parse CLI args
username=""
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -u|--username)
            username="$2"
            shift 2
            ;;
        -h|--help)
            print_help
            ;;
        *)
            print_banner
            echo "Unknown option: $1"
            print_help
            ;;
    esac
done

if [[ -z "$username" ]]; then
    print_banner
    echo "Error: Username not provided."
    print_help
fi

print_banner
echo -e "Scraping TikTok info for @$username\n"

# Construct the URL
url="https://www.tiktok.com/@$username?isUniqueId=true&isSecured=true"

# Fetch the source code
source_code=$(curl -sL -A "Mozilla/5.0" "$url")

# Helper function to extract fields
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

# Match region code to country name if file exists
if [[ -n $region_code && -f countries.json ]]; then
    country_name=$(jq -r --arg region "$region_code" '.[] | select(.code == $region) | .name' countries.json)
    region="${country_name:-Unknown (Code: $region_code)}"
else
    region="Not Found"
fi

# Match language code to language name if file exists
if [[ -n $language_code && -f languages.json ]]; then
    language_name=$(jq -r --arg lang "$language_code" '.[] | select(.code == $lang) | .name' languages.json)
    language="${language_name:-Unknown (Code: $language_code)}"
else
    language="Not Found"
fi

# Display results
if [[ -n $id ]]; then
    echo -e "ID: $id"
    echo -e "Username: $uniqueId"
    echo -e "Nickname: $nickname"
    echo -e "Bio: $signature\n"
    echo -e "Profile Picture: $avatarLarger\n"
    echo -e "Private Account: $privateAccount"
    echo -e "Verified Badge: $secret"
    echo -e "Language: $language"
    echo -e "Region: $region\n"
    echo -e "Followers: $followerCount"
    echo -e "Following: $followingCount"
    echo -e "Likes: $heartCount"
    echo -e "Videos: $videoCount\n"
else
    echo -e "Failed to fetch account details. TikTok might be blocking the request or the username doesn't exist."
fi