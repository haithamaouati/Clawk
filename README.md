# Clawk
This bash script allows you to fetch detailed information about TikTok users by their username or user ID, without requiring logins or API keys. It extracts various user data such as follower counts, video counts, likes, and more.

## Features

- Fetch user information by TikTok username or user ID.
- Works without logins and without using APIs.
- Extracts:
  - User ID
  - Unique ID
  - Nickname
  - Follower count
  - Following count
  - Likes count
  - Video count
  - Biography (signature)
  - Verified status
  - SecUid
  - Comment settings
  - Private account status
  - Region
  - Heart count
  - Digg count
  - Friend count
  - Profile picture URL
- Downloads the profile picture to your local machine.

![preview]()

## Install

To use the Clawk script, follow these steps:

1. Clone the repository:

    ```
    git clone https://github.com/haithamaouati/Clawk.git
    ```

2. Change to the Clawk directory:

    ```
    cd Clawk
    ```
    
3. Change the file modes
    ```
    chmod +x clawk.sh
    ```
    
5. Run the script:

    ```
    ./clawk.sh
    ```
Usage
Usage: `./clawk.sh <@username>` or `[username]`

## Dependencies

The script requires the following dependencies:

- **curl**: `pkg install curl - y`
- **jq**: `pkg install jq -y`

> [!IMPORTANT]  
> Make sure to install these **dependencies** before running the script.

> [!NOTE]  
> Ensure that the TikTok user account is public to access their information.

> The scraping technique relies on the current structure of the TikTok website, which may change.

## Environment
- Tested on [Termux](https://termux.dev/en/)

## Disclaimer
> [!WARNING]
> We are not responsible for any misuse or damage caused by this program. use this tool at your own risk!

## License

Clawk is licensed under [WTFPL license](LICENSE).
