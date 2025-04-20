# Clawk
Scrape TikTok user info by username.

```
   ____   _                      _    
  / ___| | |   __ _  __      __ | | __
 | |     | |  / _` | \ \ /\ / / | |/ /
 | |___  | | | (_| |  \ V  V /  |   < 
  \____| |_|  \__,_|   \_/\_/   |_|\_\
```

## Usage

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

6. Scrape the user info:

   ```
   ./clawk.sh -u <username>
   ```
   ###### Exmaple
   ```
   ./clawk.sh -u haithamaouati
   ```
   ###### Help
   ```
   ./clawk.sh -h
   ```

## Dependencies

The script requires the following dependencies:

- [figlet](): Program for making large letters out of ordinary text
- [curl](https://curl.se/): Command line tool for transferring data with URL syntax
- [jq](https://stedolan.github.io/jq/): Command-line JSON processor

Make sure to install these dependencies before running the script.

## Author

Made with :coffee: by **Haitham Aouati**
  - GitHub: [github.com/haithamaouati](https://github.com/haithamaouati)

## License

Clawk is licensed under [MIT License](LICENSE).
