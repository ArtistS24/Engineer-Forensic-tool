#!/bin/bash

# Script by Denis Albin
# Student Code: S24
# Lecturer: Natalie Erez/David Shiffman
# Class Code: TMagen773634

# Define colors and formatting
{
    #colors
    black='\033[0;30m'
    red='\033[0;31m'
    green='\033[0;32m'
    yellow='\033[0;33m'
    blue='\033[0;34m'
    cyan='\033[0;36m'
    white='\033[0;37m'
    purple='\033[0;35m'

    #bold colors
    bold_black='\033[1;30m'
    bold_red='\033[1;31m'
    bold_green='\033[1;32m'
    bold_yellow='\033[1;33m'
    bold_blue='\033[1;34m'
    bold_cyan='\033[1;36m'
    bold_white='\033[1;37m'
    bold_purple='\033[1;35m'

    #nc
    nc='\033[0m'  # No Color
}

# Root check
function root_check() {
    clear
    if [ "$(whoami)" != "root" ]; then
        echo -e "${red}Please run this script as root.${nc}"
        exit 1
    fi
}

# Tool check
function tool_check() {
    echo -e "${yellow}Loading...${nc}"
    apt-get update &>/dev/null
    tools="bulk_extractor exiftool stegseek foremost strings binwalk scalpel figlet hexdump dd"
    
    for tool in $tools; do
        if ! command -v "$tool" &>/dev/null; then
            echo -e "${red}[-] $tool is not installed. Installing now...${nc}"
            if ! apt-get install -y "$tool" &>/dev/null; then
                echo -e "${bold_red}[-] Error: Failed to install $tool${nc}"
                echo -e "${bold_red}[*] Please install it manually with: sudo apt-get install $tool${nc}"
                exit 1
            fi
        fi
    done
    
}

# Volatility 3 Installation Check
function vol_check() {
    if ! command -v vol 2>/dev/null; then
        echo -e "${red}[-] Volatility 3 is not installed. Installing now...${nc}"
        
        # Update package lists
        sudo apt update -y &>/dev/null
        
        # Install Python and pip
        sudo apt install python3 python3-pip -y &>/dev/null
        
        # Install Volatility 3
        sudo pip3 install volatility3 --break-system-packages &>/dev/null

        # Check if Volatility 3 installed successfully
        if command -v vol 2>/dev/null; then
            return 0
        else
            echo -e "${bold_red}[-] Installation failed.${nc}"
        fi
    else
        return 0
    fi
}


# Banner
function banner() {
    clear
    echo -e "${bold_yellow}
⠀⠀⠀⢀⣴⣾⣦⣀⣀⣠⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣾⣿⣿⠋⠁⠈⠙⢿⣿⣷⣶⣶⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⢸⣿⣿⣿⣿⡇⠀⠀⠀⠀⢸⣿⣿⣿⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠘⠛⠛⠻⣿⣷⣤⣀⣀⣴⣿⣿⠏⢀⣀⠀⠀⠀⠀⣾⣿⣿⡇⠀⠀⠀⠀⣀⠀
⠀⠀⠀⠀⠀⣾⣿⣿⡿⠿⢿⣿⣿⣷⣿⣿⣧⠀⣀⣀⣿⣿⣿⣇⣀⡀⠀⣼⣿⠀
⠀⠀⠀⠀⠸⠿⣿⡿⠀⠀⠀⠻⠿⠋⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀
          ⢀⣴⣤⣀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿  ______            _                     
⠀⠀⠀⠀⠀⠀⠀⠀⠺⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀ / ____/___  ____ _(_)___  ___  ___  _____
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⣿⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⠿⠿⣿⣿⣿⣿⣿⣿/ __/ / __ \/ __  / / __ \/ _ \/ _ \/ ___/
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⣿⣿⣿⣿⣿⣿⣿⡟⠀⠀⠀⠀⠀⠈⢻⣿⣿ / /___/ / / / /_/ / / / / /  __/  __/ /    
⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿/_____/_/ /_/\__, /_/_/ /_/\___/\___/_/     
⠀⠀⠀⠀⠀⠀⠘⠛⠛⠻⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⠀⠀⠀⠀⣠⣿⣿⣿⠀         /____/
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠛⠛⠛⠛⠛⠛⠛⠛⠂⠀⠀⠀⠀⠒⠛⠛⠛⠛⠀
${nc}"
}

# File check function
function file_check() {
    local ls_visible=false
    filename=""

    while [ -z "$filename" ]; do
        banner
        echo -e "${bold_white}$(uptime | awk '{print $(NF-4), $(NF-3), $(NF-2), $(NF-1), $(NF)}')${nc}"
        echo -e "${bold_white}Engineer Version 1.0${nc}"
        echo -e "${bold_white}The current working directory is: ${bold_yellow}$(pwd)${nc}"
        echo
        echo -e "${bold_purple}To exit the program, type 'exit'${nc}"
        echo -e "${bold_purple}To move to a different directory, type the name of the directory. <directory>'${nc}" 

        if [ "$ls_visible" = true ]; then
            echo -e "${bold_white}You're viewing the content of the directory: ${bold_yellow}$(pwd)${nc}"
            echo -e "${bold_cyan}$(ls)${nc}"
            echo -e "${bold_purple}To hide directory content, type 'ls'${nc}"
        else
            echo -e "${bold_purple}To show directory content, type 'ls'${nc}"
        fi

        read -p "$(echo -e "${bold_cyan}[INPUT]${nc} ${bold_cyan}Specify the file to examine: ${nc}")" choice

        if [ "$choice" = "ls" ]; then
            ls_visible=$(! $ls_visible && echo true || echo false)
        elif [ -f "$choice" ]; then
            filename="$choice"
            echo -e "${bold_green}[SUCCESS] File found: $filename${nc}"
            echo -e "${bold_green}[INFO] Starting analysis...${nc}"
            sleep 1
        elif [ -d "$choice" ]; then
            if cd "$choice"; then
                echo -e "${bold_green}[SUCCESS] Changed to: $choice${nc}"
            else
                echo -e "${bold_red}[ERROR] Failed to enter: $choice${nc}"
            fi
        elif [ "$choice" = "exit" ]; then
            clear
            echo -e "${bold_red}[EXIT] Exiting...${nc}"
            exit 0
        else
            echo -e "${bold_red}[ERROR] Invalid input or file not found: $choice${nc}"
            sleep 1
        fi
    done
}

function analysis_header () {
        echo -e "${bold_cyan}┌────────────────────────────(${bold_red}FORENSIC ANALYSIS MODE${bold_cyan})─────────────────────────────────┐"
        echo -e "│ ${bold_white}File: ${bold_yellow}${filename}${nc} │ ${bold_white}Size:${nc} ${bold_green}$(exiftool "${filename}" | grep -i "file size" | awk '{print $(NF-1),$(NF)}')${nc} │ ${bold_white}Modified: ${bold_purple}$(exiftool "${filename}" | grep -i "file modification date" | awk '{print $(NF-1)}')${bold_white} │ File type: $(exiftool "${filename}" | grep -i "File Type" | grep -vi "extension" | awk -F': ' '{print $2}')"
        echo -e "├─────────────────────────────────────────────────────────────────────────────────────┤"
}

# Main menu function
function main_menu() {
    while true; do
        banner
        analysis_header
        
        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Binwalk            │ Lists embedded files and their offsets              │"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Exiftool           │ View metadata                                       │"
        echo -e "│ ${cyan}[0x03]${yellow} | 3${nc} ${bold_white}Bulk Extractor     │ Recover passwords/artifacts                         │"
        echo -e "│ ${cyan}[0x04]${yellow} | 4${nc} ${bold_white}Hexdump            │ View hex dump                                       │"
        echo -e "│ ${cyan}[0x05]${yellow} | 5${nc} ${bold_white}Foremost           │ File carving                                        │"
        echo -e "│ ${cyan}[0x06]${yellow} | 6${nc} ${bold_white}Scalpel            │ File carving                                        │"
        echo -e "│ ${cyan}[0x07]${yellow} | 7${nc} ${bold_white}Strings            │ Extract human-readable text                         │"
        echo -e "│ ${cyan}[0x08]${yellow} | 8${nc} ${bold_white}DD                 │ Extract specific file using decimal offsets         │ "
        echo -e "│ ${cyan}[0x09]${yellow} | 9${nc} ${bold_white}Stegseek           │ Find steganography                                  │"
        echo -e "│ ${cyan}[0x0A]${yellow} | 10${nc} ${bold_white}Volatility 3      │ Memory analysis using Volatility 3                  │"
        echo -e "│ ${cyan}[0x0B]${yellow} | 11${nc} ${bold_white}Automation        │ Run automated analysis on the file                  │" 
        echo -e "│ ${cyan}[0x0C]${yellow} | 12${nc} ${bold_white}Switch the file   │ Change the file to analyze                          │" 
        echo -e "│ ${cyan}[0x0D]${yellow} | 13${nc} ${bold_white}Exit              │ Exit the program                                    │"              
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"
  
        read -p "$(echo -e "${bold_yellow}Select an option (1-13): ${nc}")" option_choice
        
        case $option_choice in
            1) binwalk_menu ;;
            2) exiftool_function ;;
            3) bulk_extractor_menu ;;
            4) hexdump_function ;;
            5) foremost_function ;;
            6) scalpel_function ;;
            7) strings_function ;;
            8) dd_function ;;
            9) stegseek_function ;;
            10) vol_function ;;
            11) automation_function ;; 
            12) file_check ;; 
            13) clear; echo -e "${bold_red}Exiting...${nc}"; exit ;;
            *) echo -e "${bold_red}[ERROR] Invalid option! Please choose a number from 1 to 13.${nc}"; sleep 1 ;;
        esac
    done
}


# 1
# Binwalk function
function binwalk_menu() {
    while true; do
        banner
        analysis_header
    
        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Quick Scan           ${nc}│ Basic signature scan (fastest)                    │"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Extract Files        ${nc}│ Auto-extract all detectable files                 │"
        echo -e "│ ${cyan}[0x03]${yellow} | 3${nc} ${bold_white}Entropy Graph        ${nc}│ Generate an entropy visualization graph           │"
        echo -e "│ ${cyan}[0x04]${yellow} | 4${nc} ${bold_white}Main Menu            ${nc}│ Return to main menu                               │"
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"
        echo -e "${bold_yellow}Note: Add '-s' after the option number to save results (e.g., '1 -s' or '2 -s').${nc}"
        
        read -p "$(echo -e "${bold_yellow}Select option (1-4) and optionally add '-s': ${nc}")" choice flag

        save=false
        if [ "$flag" = "-s" ]; then
            save=true
        fi

        output_dir="Engineer/${filename}/Binwalk"
        if $save; then
            mkdir -p "$output_dir"
        fi

        start_time=$(date +%s) # Start timer
        case $choice in
            1)
                if $save; then
                    echo -e "${bold_green}[INFO] Running Quick Scan and saving results...${nc}"
                    binwalk -B "$filename" | tee "$output_dir/quick_scan_${filename}.log"
                    echo -e "${bold_green}[SUCCESS] Results saved to: ${bold_yellow}$output_dir/quick_scan_${filename}.log${nc}"
                else
                    echo -e "${bold_green}[INFO] Running Quick Scan...${nc}"
                    binwalk -B "$filename"
                fi
                ;;
            2)
                
                    echo -e "${bold_green}[INFO] Extracting files and saving results...${nc}"
                    original_dir=$(pwd)
                    full_filename=$(realpath "$filename")
                    cd "$output_dir" || exit
                    binwalk -e --run-as=root "$full_filename" | tee "binwalk_extracted_${filename}.log"
                    cd "$original_dir" || exit
                    echo -e "${bold_green}[SUCCESS] Extracted files saved to: ${bold_yellow}$output_dir${nc}"
            
                
                ;;
            3)
                if $save; then
                    echo -e "${bold_green}[INFO] Generating Entropy Graph and saving results...${nc}"
                    binwalk -E "$filename" | tee "$output_dir/entropy_graph_${filename}.log"
                    echo -e "${bold_green}[SUCCESS] Entropy graph saved to: ${bold_yellow}$output_dir/entropy_graph_${filename}.log${nc}"
                else
                    echo -e "${bold_green}[INFO] Generating Entropy Graph...${nc}"
                    binwalk -E "$filename"
                fi
                ;;
            4)
                return
                ;;
            *)
                echo -e "${bold_red}[ERROR] Invalid option! Please choose a number from 1 to 4.${nc}"
                sleep 1
                ;;
        esac
        end_time=$(date +%s) # End timer
        elapsed_time=$((end_time - start_time))
        echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"

        read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
    done
}

# 2
# Exiftool function
function exiftool_function() {
    banner
    echo -e "${bold_cyan}$(figlet -f small "Exiftool")${nc}"
    analysis_header

    start_time=$(date +%s) # Start timer
    exiftool "$filename"
    end_time=$(date +%s) # End timer

    elapsed_time=$((end_time - start_time))
    echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"
    
    read -p "$(echo -e "${bold_yellow}To save $filename's metadata type \"-s\" or press Enter to continue...${nc}")" exiftool_choice
    
    if [ "$exiftool_choice" = "-s" ]; then
        output_dir="Engineer/${filename}/Exiftool"
        mkdir -p "$output_dir"
        exiftool "$filename" > "$output_dir/exiftool_${filename}.log"
        echo -e "${green}Results saved to $output_dir/exiftool_${filename}.log${nc}"
        read -p "$(echo -e "${bold_yellow}Press Enter to continue...${nc}")"
    fi
}

# 3
# Function bulk_extractor
function bulk_extractor_menu() {
    while true; do
        banner
        echo -e "${bold_cyan}$(figlet -f small "Bulk Extractor")${nc}"
        analysis_header

        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Extract Everything   ${nc}│ Run all extractions with default settings         │"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu            ${nc}│ Return to main menu                               │"
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"

        read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" bulk_choice

        case $bulk_choice in
            1)
                output_dir="Engineer/${filename}/Bulk_Extractor"
                mkdir -p "$output_dir"
                start_time=$(date +%s)
                echo -e "${bold_green}[INFO] Running Extract Everything Automation...${nc}"
                bulk_extractor -o "$output_dir" "$filename" | tee "$output_dir/bulk_extractor_${filename}.log"

                # Display results
                echo -e "${bold_cyan}┌───────────────────────────────(${bold_red}RESULTS${bold_cyan})────────────────────────────────┐"

                # Emails
                if [ -f "$output_dir/email.txt" ]; then
                    email_count=$(grep -o '@' "$output_dir/email.txt" | wc -l)
                    if [ "$email_count" -gt 0 ]; then
                        echo -e "│ ${bold_green}[EMAILS] Found: ${bold_yellow}$email_count${nc} ${bold_cyan}(saved in $output_dir/email.txt)${nc}"
                    else
                        echo -e "│ ${bold_red}[EMAILS] None found.${nc}"
                    fi
                else
                    echo -e "│ ${bold_red}[EMAILS] None found.${nc}"
                fi

                # Credit Cards
                if [ -f "$output_dir/ccn.txt" ]; then
                    cc_count=$(wc -l < "$output_dir/ccn.txt" | awk '{print $1}')
                    if [ "$cc_count" -gt 0 ]; then
                        echo -e "│ ${bold_green}[CREDIT CARDS] Found: ${bold_yellow}$cc_count${nc} ${bold_cyan}(saved in $output_dir/ccn.txt)${nc}"
                    else
                        echo -e "│ ${bold_red}[CREDIT CARDS] None found.${nc}"
                    fi
                else
                    echo -e "│ ${bold_red}[CREDIT CARDS] None found.${nc}"
                fi

                # URLs
                if [ -f "$output_dir/url.txt" ]; then
                    url_count=$(wc -l < "$output_dir/url.txt" | awk '{print $1}')
                    if [ "$url_count" -gt 0 ]; then
                        echo -e "│ ${bold_green}[URLS] Found: ${bold_yellow}$url_count${nc} ${bold_cyan}(saved in $output_dir/url.txt)${nc}"
                    else
                        echo -e "│ ${bold_red}[URLS] None found.${nc}"
                    fi
                else
                    echo -e "│ ${bold_red}[URLS] None found.${nc}"
                fi

                # PCAP (Network Traffic)
                if [ -f "$output_dir/packets.pcap" ]; then
                    echo -e "│ ${bold_green}[PCAP] File Found: ${bold_yellow}$output_dir/packets.pcap${nc}"
                else
                    echo -e "│ ${bold_red}[PCAP] None found.${nc}"
                fi

                # EXIF Data
                if [ -f "$output_dir/exif.txt" ]; then
                    exif_count=$(wc -l < "$output_dir/exif.txt" | awk '{print $1}')
                    if [ "$exif_count" -gt 0 ]; then
                        echo -e "│ ${bold_green}[EXIF DATA] Found: ${bold_yellow}$exif_count entries${nc} ${bold_cyan}(saved in $output_dir/exif.txt)${nc}"
                    else
                        echo -e "│ ${bold_red}[EXIF DATA] None found.${nc}"
                    fi
                else
                    echo -e "│ ${bold_red}[EXIF DATA] None found.${nc}"
                fi

                # Base64 Encoded Data
                if [ -f "$output_dir/base64.txt" ]; then
                    base64_count=$(wc -l < "$output_dir/base64.txt" | awk '{print $1}')
                    if [ "$base64_count" -gt 0 ]; then
                        echo -e "│ ${bold_green}[BASE64 DATA] Found: ${bold_yellow}$base64_count entries${nc} ${bold_cyan}(saved in $output_dir/base64.txt)${nc}"
                    else
                        echo -e "│ ${bold_red}[BASE64 DATA] None found.${nc}"
                    fi
                else
                    echo -e "│ ${bold_red}[BASE64 DATA] None found.${nc}"
                fi

                # AES Keys
                if [ -f "$output_dir/aes.txt" ]; then
                    aes_count=$(wc -l < "$output_dir/aes.txt" | awk '{print $1}')
                    if [ "$aes_count" -gt 0 ]; then
                        echo -e "│ ${bold_green}[AES KEYS] Found: ${bold_yellow}$aes_count${nc} ${bold_cyan}(saved in $output_dir/aes.txt)${nc}"
                    else
                        echo -e "│ ${bold_red}[AES KEYS] None found.${nc}"
                    fi
                else
                    echo -e "│ ${bold_red}[AES KEYS] None found.${nc}"
                fi

                # JSON Data
                if [ -f "$output_dir/json.txt" ]; then
                    json_count=$(wc -l < "$output_dir/json.txt" | awk '{print $1}')
                    if [ "$json_count" -gt 0 ]; then
                        echo -e "│ ${bold_green}[JSON DATA] Found: ${bold_yellow}$json_count entries${nc} ${bold_cyan}(saved in $output_dir/json.txt)${nc}"
                    else
                        echo -e "│ ${bold_red}[JSON DATA] None found.${nc}"
                    fi
                else
                    echo -e "│ ${bold_red}[JSON DATA] None found.${nc}"
                fi

                echo -e "${bold_cyan}└─────────────────────────────────────────────────────────────────────────────────────┘"

                end_time=$(date +%s)
                elapsed_time=$((end_time - start_time))
                echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"
                ;;
            2)
                return
                ;;
            *)
                echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
                sleep 1
                ;;
        esac

        read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
    done
}

# 4
# Hexdump function
function hexdump_function() {
    while true; do
        banner
        echo -e "${bold_cyan}$(figlet -f small "Hexdump")${nc}"
        analysis_header

        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Hexdump         ${nc}│ Display the hex dump of the file                       │"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu       ${nc}│ Return to main menu                                    │"
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"
        echo -e "${bold_yellow}Note: Add '-s' after the option number to save the hex dump to a file (e.g., '1 -s').${nc}"

        read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2) and optionally add '-s': ${nc}")" hexdump_choice flag

        save=false
        if [ "$flag" = "-s" ]; then
            save=true
        fi

        start_time=$(date +%s) # Start timer
        case $hexdump_choice in
            1)
                if $save; then
                    output_dir="Engineer/${filename}/Hexdump"
                    mkdir -p "$output_dir"
                    echo -e "${bold_green}[INFO] Saving Hexdump to file...${nc}"
                    hexdump -C "$filename" | tee "$output_dir/hexdump_${filename}.txt"
                    echo -e "${bold_green}[SUCCESS] Hexdump saved to: ${bold_yellow}$output_dir/hexdump_${filename}.txt${nc}"
                else
                    echo -e "${bold_green}[INFO] Displaying Hexdump...${nc}"
                    hexdump -C "$filename"
                fi
                ;;
            2)
                return
                ;;
            *)
                echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
                sleep 1
                ;;
        esac
        end_time=$(date +%s) # End timer
        elapsed_time=$((end_time - start_time))
        echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"

        read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
    done
}


# 5
# Function for foremost
function foremost_function() {
    while true; do
        banner
        echo -e "${bold_cyan}$(figlet -f small "Foremost")${nc}"
        analysis_header

        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Run Foremost         ${nc}│ Perform file carving using Foremost               │"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu            ${nc}│ Return to main menu                               │"
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"

        read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" foremost_choice

        case $foremost_choice in
            1)
                output_dir="Engineer/${filename}/Foremost"
                mkdir -p "$output_dir"
                start_time=$(date +%s)
                echo -e "${bold_green}[INFO] Running Foremost...${nc}"
                foremost -i "$filename" -o "$output_dir" &>/dev/null
                if [ $? -eq 0 ]; then
                    echo -e "${bold_green}[SUCCESS] Foremost completed. Results are in: ${bold_yellow}$output_dir${nc}"
                else
                    echo -e "${bold_red}[ERROR] Foremost failed to process the file.${nc}"
                fi
                ;;
            2)
                return
                ;;
            *)
                echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
                sleep 1
                ;;
        esac
        end_time=$(date +%s) # End timer
        elapsed_time=$((end_time - start_time))
        echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"

        read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
    done
}

# 6
# Function for scalpel
function scalpel_function() {
    while true; do
        banner
        echo -e "${bold_cyan}$(figlet -f small "Scalpel")${nc}"
        analysis_header

        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Run Scalpel          ${nc}│ Perform file carving using Scalpel                │"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu            ${nc}│ Return to main menu                               │"
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"

        read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" scalpel_choice

        case $scalpel_choice in
            1)
                output_dir="Engineer/${filename}/Scalpel"
                mkdir -p "$output_dir"
                start_time=$(date +%s)
                echo -e "${bold_green}[INFO] Running Scalpel...${nc}"
                if scalpel "$filename" -o "$output_dir" &>/dev/null; then
                    echo -e "${bold_green}[SUCCESS] Scalpel completed. Results saved in: ${bold_yellow}$output_dir${nc}"
                else
                    echo -e "${bold_red}[ERROR] Scalpel failed.${nc}"
                fi
                ;;
            2)
                return
                ;;
            *)
                echo -e "${bold_red}[ERROR] Invalid option. Please choose 1 or 2.${nc}"
                sleep 1
                ;;
        esac
        end_time=$(date +%s) # End timer
        elapsed_time=$((end_time - start_time))
        echo -e "${bold_yellow}[STATS] Completed in ${elapsed_time} seconds.${nc}"

        read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
    done
}


# 7
# Function for strings
function strings_function() {
    while true; do
        banner
        echo -e "${bold_cyan}$(figlet -f small "Strings")${nc}"
        analysis_header

        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Run Strings          ${nc}│ Extract human-readable text from the file           │"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu            ${nc}│ Return to main menu                                 │"
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"
        echo -e "${bold_yellow}Note: Add '-s' to save the output to a file (e.g., 'password -s').${nc}"

        read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" strings_choice

        case $strings_choice in
            1)
                while true; do
                    echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
                    echo -e "│ ${bold_white}You are now in the Strings prompt. Type your options for strings or type 'exit' to leave.${nc}"
                    echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"
                    read -p "$(echo -e "${bold_yellow}[INPUT] Enter strings options (or 'exit' to leave): ${nc}")" strings_options

                    if [ "$strings_options" = "exit" ]; then
                        break
                    fi

                    save=false
                    if [[ "$strings_options" == *"-s"* ]]; then
                        strings_options="${strings_options/-s/}"
                        save=true
                    fi

                    strings_options=$(echo "$strings_options" | xargs)

                    start_time=$(date +%s)
                    if $save; then
                        output_dir="Engineer/${filename}/Strings"
                        mkdir -p "$output_dir"
                        echo -e "${bold_green}[INFO] Running Strings with options and saving output...${nc}"

                        sanitized_strings_options=$(echo "$strings_options" | sed 's/[^a-zA-Z0-9]/_/g')
                        sanitized_strings_options=$(echo "$sanitized_strings_options" | sed 's/^_//;s/_$//')

                        if [ -z "$sanitized_strings_options" ]; then
                            sanitized_strings_options="all_strings"
                        fi

                        if [ -z "$strings_options" ]; then
                            strings "$filename" | tee "$output_dir/strings_${filename}_${sanitized_strings_options}.log"
                        else
                            strings "$filename" | grep -a "$strings_options" | tee "$output_dir/strings_${filename}_${sanitized_strings_options}.log"
                        fi

                        echo -e "${bold_green}[INFO] Strings output saved to: ${bold_yellow}$output_dir/strings_${filename}_${sanitized_strings_options}.log${nc}"
                    else
                        echo -e "${bold_green}[INFO] Running Strings...${nc}"
                        if [ -z "$strings_options" ]; then
                            strings "$filename"
                        else
                            strings "$filename" | grep -a "$strings_options"
                        fi
                    fi
                    end_time=$(date +%s)
                    elapsed_time=$((end_time - start_time))
                    echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"
                done
                ;;
            2)
                return
                ;;
            *)
                echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
                sleep 1
                ;;
        esac
    done
}

#8
# DD function
function dd_function() {
    banner
    echo -e "${bold_cyan}$(figlet -f small "DD")${nc}"
    analysis_header

    echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
    echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Extract File         ${nc}│ Extract a specific file using decimal offsets     │"
    echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu            ${nc}│ Return to main menu                               │"
    echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"

    read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" dd_choice

    case $dd_choice in
        1)  
            binwalk "$filename" 
            echo -e "${bold_green}[INFO] Please note the offsets from the hexdump above.${nc}"
            echo -e "${bold_yellow}[INFO] You can use the offsets to extract a specific file.${nc}"
            read -p "$(echo -e "${bold_yellow}[INPUT] Enter the start offset (in bytes): ${nc}")" start_offset
            read -p "$(echo -e "${bold_yellow}[INPUT] Enter the end offset (in bytes): ${nc}")" end_offset
            output_file="Engineer/${filename}/DD/extracted_file.bin"
            mkdir -p "$(dirname "$output_file")"
            start_time=$(date +%s)
            echo -e "${bold_green}[INFO] Extracting file from offset $start_offset to $end_offset...${nc}"
            dd if="$filename" of="$output_file" bs=1 skip="$start_offset" count=$((end_offset - start_offset + 1)) status=progress
            end_time=$(date +%s)
            elapsed_time=$((end_time - start_time))
            echo -e "${bold_green}[SUCCESS] File extracted to: ${bold_yellow}$output_file${nc}"
            echo -e "${bold_yellow}[STATS] Extraction completed in ${elapsed_time} seconds.${nc}"
            ;;
        2)
            return
            ;;
        *)
            echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
            sleep 1
            ;;
    esac

    read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
}

# 9
# Stegseek function
function stegseek_function() {
    banner
    echo -e "${bold_cyan}$(figlet -f small "Stegseek")${nc}"
    analysis_header

    echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
    echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Run Stegseek        ${nc}│ Search for steganography in the file               │"
    echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu           ${nc}│ Return to main menu                                │"
    echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"

    read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" stegseek_choice

    case $stegseek_choice in
        1)
            output_dir="Engineer/${filename}/Stegseek"
            mkdir -p "$output_dir"
            start_time=$(date +%s) # Start timer
            echo -e "${bold_green}[INFO] Running Stegseek...${nc}"
            stegseek "$filename" > "$output_dir/stegseek_${filename}.log"
            if [ $? -eq 0 ]; then
                echo -e "${bold_green}[SUCCESS] Stegseek completed. Results saved in: ${bold_yellow}$output_dir/stegseek_${filename}.log${nc}"
            else
                echo -e "${bold_red}[ERROR] Stegseek failed to process the file.${nc}"
            fi
            end_time=$(date +%s) # End timer
            elapsed_time=$((end_time - start_time))
            echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"
            ;;
        2)
            return
            ;;
        *)
            echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
            sleep 1
            ;;
    esac

    read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
}


# 10
# Volatility 3 function
function vol_function() {
    local os_type="" 
    local output_dir=""

    while true; do
        banner
        echo -e "${bold_cyan}$(figlet -f small "Volatility 3")${nc}"
        analysis_header

        # OS Detection Menu
        echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
        echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Check for OS and Load Menu${nc}│ Detect memory OS and proceed to analysis menu│"
        echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu                 ${nc}│ Return to the main application menu          │"
        echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"

        read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" initial_choice

        case $initial_choice in
            1)
                #  OS Detection 
                echo -e "${bold_green}[INFO] Attempting to detect the operating system type...${nc}"

                # Windows OS Detection
                if vol -f "$filename" windows.info &>/dev/null; then
                    os_type="Windows"
                    echo -e "${bold_green}[SUCCESS] Detected OS: ${bold_yellow}Windows${nc}"
                 
                 # Linux OS Detection
                 else
                    echo -e "${bold_red}[INFO] Windows OS not detected.${nc}"
                    echo -e "${bold_green}[INFO] Trying to detect Linux OS...${nc}"
                    if vol -f "$filename" linux.pslist &>/dev/null; then
                        os_type="Linux"
                        echo -e "${bold_green}[SUCCESS] Detected OS: ${bold_yellow}Linux${nc}"
                    else
                        # No OS detected
                        echo -e "${bold_red}[-] Unable to detect the operating system type with common plugins!${nc}"
                        echo -e "${bold_red}[-] This might not be a valid memory file or requires manual profile selection/inspection.${nc}"
                        read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to return to the main menu...${nc}")"
                        continue # Main Menu
                    fi
                fi

                # Set up the output directory now that OS is detected
                output_dir="Engineer/${filename}/Volatility"
                mkdir -p "$output_dir"
                echo -e "${bold_green}[INFO] Analysis output will be saved in: ${bold_yellow}$output_dir${nc}"

                # --- Analysis Menu (After OS detection) ---
                while true; do
                clear
                        echo -e "${bold_cyan}$(figlet -f small "Volatility 3")${nc}"

                    banner
                            echo -e "${bold_cyan}$(figlet -f small "Volatility 3")${nc}"

                    echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
                    echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Find Memory Profile     ${nc}│ Detect memory profile                          │"
                    echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}List Processes          ${nc}│ Display running processes                      │"
                    echo -e "│ ${cyan}[0x03]${yellow} | 3${nc} ${bold_white}Network Connections     ${nc}│ Display network connections                    │"
                    echo -e "│ ${cyan}[0x04]${yellow} | 4${nc} ${bold_white}Extract Registry        ${nc}│ Extract registry information                   │"
                    echo -e "│ ${cyan}[0x05]${yellow} | 5${nc} ${bold_white}Back to Volatility Main ${nc}│ Return to Volatility OS check menu             │"
                    echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"
                    echo -e "${bold_yellow}Note: Add '-s' after the option number to save results (e.g., '1 -s').${nc}"

                    read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-5) and optionally add '-s': ${nc}")" vol_choice flag

                    local save=false 
                    if [ "$flag" = "-s" ]; then
                        save=true
                        output_dir="Engineer/${filename}/Volatility"
                        mkdir -p "$output_dir"
                        echo -e "${bold_green}[INFO] Analysis output will be saved in: ${bold_yellow}$output_dir${nc}"
                    fi

                    start_time=$(date +%s) # Start timer
                    case $vol_choice in
                        1)
                            echo -e "${bold_green}[INFO] Detecting memory profile...${nc}"
                            local memory_profile=""
                            if [ "$os_type" = "Windows" ]; then
                                memory_profile=$(vol -f "$filename" windows.info 2>/dev/null)
                            elif [ "$os_type" = "Linux" ]; then
                                memory_profile=$(vol -f "$filename" linux.info 2>/dev/null)
                                if [ -z "$memory_profile" ]; then
                                    memory_profile=$(vol -f "$filename" linux.kallsyms 2>/dev/null)
                                fi
                            fi

                            if [ -n "$memory_profile" ]; then
                                if $save; then
                                    echo "$memory_profile" > "$output_dir/memory_profile_${filename}.txt"
                                    echo -e "${bold_green}[SUCCESS] Memory profile saved to: ${bold_yellow}$output_dir/memory_profile_${filename}.txt${nc}"
                                else
                                    echo -e "${bold_green}[SUCCESS] Memory profile detected: ${bold_yellow}$memory_profile${nc}"
                                fi
                            else
                                echo -e "${bold_red}[-] Could not determine specific memory profile. Manual inspection may be required.${nc}"
                            fi
                            ;;
                        2)
                            echo -e "${bold_green}[INFO] Listing running processes...${nc}"
                            local plugin=""
                            if [ "$os_type" = "Windows" ]; then
                                plugin="windows.pslist"
                            elif [ "$os_type" = "Linux" ]; then
                                plugin="linux.pslist"
                            fi

                            if [ -z "$plugin" ]; then
                                echo -e "${bold_red}[-] Unsupported OS type detected for this action!${nc}"
                            else
                                if $save; then
                                    vol -f "$filename" "$plugin" 2>/dev/null | tee "$output_dir/process_list_${filename}.txt"
                                    echo -e "${bold_green}[SUCCESS] Process list saved to: ${bold_yellow}$output_dir/process_list_${filename}.txt${nc}"
                                else
                                    vol -f "$filename" "$plugin" 2>/dev/null
                                fi
                            fi
                            ;;
                        3)
                            echo -e "${bold_green}[INFO] Displaying network connections...${nc}"
                            local plugin=""
                            if [ "$os_type" = "Windows" ]; then
                                plugin="windows.netscan"
                            elif [ "$os_type" = "Linux" ]; then
                                plugin="linux.sockstat"
                            fi

                            if [ -z "$plugin" ]; then
                                echo -e "${bold_red}[-] Unsupported OS type detected for this action!${nc}"
                            else
                                if $save; then
                                    vol -f "$filename" "$plugin" 2>/dev/null | sort | tee "$output_dir/network_connections_${filename}.txt"
                                    echo -e "${bold_green}[SUCCESS] Network connections saved to: ${bold_yellow}$output_dir/network_connections_${filename}.txt${nc}"
                                else
                                    vol -f "$filename" "$plugin" 2>/dev/null | sort
                                fi
                            fi
                            ;;
                        4)
                            echo -e "${bold_green}[INFO] Extracting registry information...${nc}"
                            local plugin=""
                            if [ "$os_type" = "Windows" ]; then
                                plugin="windows.registry.printkey"
                            elif [ "$os_type" = "Linux" ]; then
                                echo -e "${bold_red}[-] Registry extraction is not supported for Linux memory dumps. Registry is a Windows concept.${nc}"
                                echo -e "${bold_green}[INFO] For Linux, consider using plugins like 'linux.kmsg' (kernel messages) or 'linux.bash' (command history) for relevant artifacts.${nc}"
                            fi

                            if [ -n "$plugin" ]; then
                                if $save; then
                                    vol -f "$filename" "$plugin" 2>/dev/null | tee "$output_dir/registry_info_${filename}.txt"
                                    echo -e "${bold_green}[SUCCESS] Registry information saved to: ${bold_yellow}$output_dir/registry_info_${filename}.txt${nc}"
                                else
                                    vol -f "$filename" "$plugin" 2>/dev/null
                                fi
                            fi
                            ;;
                        5)
                            break # Exit the inner while loop to return to the initial menu
                            ;;
                        *)
                            echo -e "${bold_red}[ERROR] Invalid option! Please choose a number from 1 to 5.${nc}"
                            sleep 1
                            ;;
                    esac
                    end_time=$(date +%s) # End timer
                    elapsed_time=$((end_time - start_time))
                    echo -e "${bold_yellow}[STATS] Analysis completed in ${elapsed_time} seconds.${nc}"

                    read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
                done # End of inner analysis loop
                ;; # End of case 1 for initial_choice
            2)
                return # Exit the function and go back to the main menu
                ;;
            *)
                echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
                sleep 1
                ;;
        esac
    done # End of outer while loop
}


#11
function automation_function() {
    banner
    echo -e "${bold_cyan}$(figlet -f small "Automation")${nc}"
    analysis_header

    local original_dir=$(pwd)

    echo -e "${bold_cyan}┌─────────────────────────────────────────────────────────────────────────────────────┐"
    echo -e "│ ${cyan}[0x01]${yellow} | 1${nc} ${bold_white}Run All Tools         ${nc}│ Run all tools in sequence                  │"
    echo -e "│ ${cyan}[0x02]${yellow} | 2${nc} ${bold_white}Main Menu           ${nc}│ Return to main menu                          │"
    echo -e "└─────────────────────────────────────────────────────────────────────────────────────┘"

    read -p "$(echo -e "${bold_yellow}[INPUT] Select an option (1-2): ${nc}")" automation_choice

    case $automation_choice in
    1)
        local base_file_name=$(basename "$filename")
        local base_file_name_no_ext=$(basename "$filename" | sed 's/\.[^.]*$//')

        local output_dir="Engineer/${filename}/Automation"
        mkdir -p "$output_dir"
        local total_start_time=$(date +%s)
        echo -e "${bold_green}[INFO] Running all tools in sequence...${nc}"

        # Binwalk
        echo -e "${bold_cyan}Running Binwalk...${nc}"
        local binwalk_log="$output_dir/binwalk_${base_file_name}.log"
        if binwalk "$filename" 2>&1 | tee "$binwalk_log"; then
            echo -e "${bold_green}[SUCCESS] Binwalk results saved to: ${bold_yellow}$binwalk_log${nc}"
        else
            echo -e "${bold_red}[ERROR] Binwalk failed.${nc}"
        fi
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        # Exiftool
        echo -e "${bold_cyan}Running Exiftool...${nc}"
        local exiftool_log="$output_dir/exiftool_${base_file_name}.log"
        if exiftool "$filename" 2>&1 | tee "$exiftool_log"; then
            echo -e "${bold_green}[SUCCESS] Exiftool results saved to: ${bold_yellow}$exiftool_log${nc}"
        else
            echo -e "${bold_red}[ERROR] Exiftool failed.${nc}"
        fi
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        # Bulk Extractor
        echo -e "${bold_cyan}Running Bulk Extractor...${nc}"
        local bulk_dir="$output_dir/bulk_extractor"
        if bulk_extractor -o "$bulk_dir" "$filename" 2>/dev/null; then
            echo -e "${bold_green}[SUCCESS] Bulk Extractor results saved to: ${bold_yellow}$bulk_dir${nc}"
            
            echo -e "${bold_cyan}┌──────────────────────────────────(${bold_red}RESULTS${bold_cyan})───────────────────────────────────────────────────────────┐"

            # Emails
            if [ -f "$bulk_dir/email.txt" ]; then
                local email_count=$(grep -o '@' "$bulk_dir/email.txt" | wc -l)
                if [ "$email_count" -gt 0 ]; then
                    echo -e "│ ${bold_green}[EMAILS] Found: ${bold_yellow}$email_count${nc} ${bold_cyan}(saved in $bulk_dir/email.txt)${nc}"
                else
                    echo -e "│ ${bold_red}[EMAILS] None found.${nc}"
                fi
            else
                echo -e "│ ${bold_red}[EMAILS] None found.${nc}"
            fi

            # Credit Cards 
            if [ -f "$bulk_dir/ccn.txt" ]; then
                local cc_count=$(wc -l < "$bulk_dir/ccn.txt" | awk '{print $1}')
                if [ "$cc_count" -gt 0 ]; then
                    echo -e "│ ${bold_green}[CREDIT CARDS] Found: ${bold_yellow}$cc_count${nc} ${bold_cyan}(saved in $bulk_dir/ccn.txt)${nc}"
                else
                    echo -e "│ ${bold_red}[CREDIT CARDS] None found.${nc}"
                fi
            else
                echo -e "│ ${bold_red}[CREDIT CARDS] None found.${nc}"
            fi

            # URLs
            if [ -f "$bulk_dir/url.txt" ]; then
                local url_count=$(wc -l < "$bulk_dir/url.txt" | awk '{print $1}')
                if [ "$url_count" -gt 0 ]; then
                    echo -e "│ ${bold_green}[URLS] Found: ${bold_yellow}$url_count${nc} ${bold_cyan}(saved in $bulk_dir/url.txt)${nc}"
                else
                    echo -e "│ ${bold_red}[URLS] None found.${nc}"
                fi
            else
                echo -e "│ ${bold_red}[URLS] None found.${nc}"
            fi

            # PCAP (Network Traffic)
            if [ -f "$bulk_dir/packets.pcap" ]; then
                echo -e "│ ${bold_green}[PCAP] File Found: ${bold_yellow}$bulk_dir/packets.pcap${nc}"
            else
                echo -e "│ ${bold_red}[PCAP] None found.${nc}"
            fi

            # EXIF Data
            if [ -f "$bulk_dir/exif.txt" ]; then
                local exif_count=$(wc -l < "$bulk_dir/exif.txt" | awk '{print $1}')
                if [ "$exif_count" -gt 0 ]; then
                    echo -e "│ ${bold_green}[EXIF DATA] Found: ${bold_yellow}$exif_count entries${nc} ${bold_cyan}(saved in $bulk_dir/exif.txt)${nc}"
                else
                    echo -e "│ ${bold_red}[EXIF DATA] None found.${nc}"
                fi
            else
                echo -e "│ ${bold_red}[EXIF DATA] None found.${nc}"
            fi

            # Base64 Encoded Data
            if [ -f "$bulk_dir/base64.txt" ]; then
                local base64_count=$(wc -l < "$bulk_dir/base64.txt" | awk '{print $1}')
                if [ "$base64_count" -gt 0 ]; then
                    echo -e "│ ${bold_green}[BASE64 DATA] Found: ${bold_yellow}$base64_count entries${nc} ${bold_cyan}(saved in $bulk_dir/base64.txt)${nc}"
                else
                    echo -e "│ ${bold_red}[BASE64 DATA] None found.${nc}"
                fi
            else
                echo -e "│ ${bold_red}[BASE64 DATA] None found.${nc}"
            fi

            # AES Keys
            if [ -f "$bulk_dir/aes.txt" ]; then
                local aes_count=$(wc -l < "$bulk_dir/aes.txt" | awk '{print $1}')
                if [ "$aes_count" -gt 0 ]; then
                    echo -e "│ ${bold_green}[AES KEYS] Found: ${bold_yellow}$aes_count${nc} ${bold_cyan}(saved in $bulk_dir/aes.txt)${nc}"
                else
                    echo -e "│ ${bold_red}[AES KEYS] None found.${nc}"
                fi
            else
                echo -e "│ ${bold_red}[AES KEYS] None found.${nc}"
            fi

            # JSON Data
            if [ -f "$bulk_dir/json.txt" ]; then
                local json_count=$(wc -l < "$bulk_dir/json.txt" | awk '{print $1}')
                if [ "$json_count" -gt 0 ]; then
                    echo -e "│ ${bold_green}[JSON DATA] Found: ${bold_yellow}$json_count entries${nc} ${bold_cyan}(saved in $bulk_dir/json.txt)${nc}"
                else
                    echo -e "│ ${bold_red}[JSON DATA] None found.${nc}"
                fi
            else
                echo -e "│ ${bold_red}[JSON DATA] None found.${nc}"
            fi

            echo -e "${bold_cyan}└─────────────────────────────────────────────────────────────────────────┘"

        else
            echo -e "${bold_red}[ERROR] Bulk Extractor failed.${nc}"
        fi
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        # Foremost
        echo -e "${bold_cyan}Running Foremost...${nc}"
        local foremost_dir="$output_dir/Foremost"
        if foremost -i "$filename" -o "$foremost_dir" &>/dev/null; then
            echo -e "${bold_green}[INFO] Foremost completed. Results are in: ${bold_yellow}$foremost_dir${nc}"
        else
            echo -e "${bold_red}[ERROR] Foremost failed to process the file.${nc}"
        fi
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        # Scalpel
        echo -e "${bold_cyan}Running Scalpel...${nc}"
        local scalpel_dir="$output_dir/Scalpel"
        if scalpel -o "$filename" -O "$scalpel_dir" 2>/dev/null; then
            echo -e "${bold_green}[INFO] Scalpel completed. Results saved in: ${bold_yellow}$scalpel_dir${nc}"
        else
            echo -e "${bold_red}[ERROR] Scalpel failed.${nc}"
        fi
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        # Strings
        echo -e "${bold_cyan}Running Strings for common keywords...${nc}"
        local strings_log="$output_dir/strings_${base_file_name}.log"
        if strings "$filename" | grep -E 'password|passwd|pwd|secret|key|token|credential|user|username|login|auth|authentication|dll|api|bearer|ssh|ssl|certificate|private|public|encrypt|decrypt|hash|salt|jwt|oauth|session|cookie|admin|root|sql|query|config|setting|env|environment|database|db|url|endpoint|proxy|vpn|ftp|smtp|ldap|krb|kerberos|access|privilege|permission|role|account|signin|signup|register|reset|forgot|change|update|modify|delete|remove|create|new|old|backup|restore|dump|load|import|export|execute|command|cmd|shell|script|batch|ps1|vbs|exe|dll|so|lib|library|binary|win32|syscall|hook|inject|migrate|bypass|disable|enable|debug|verbose|log|trace|audit|monitor|check|verify|validate|test|prod|dev|staging|qa|uat|sandbox' > "$strings_log"; then
            echo -e "${bold_green}[INFO] Strings output saved to: ${bold_yellow}$strings_log${nc}"
        else
            echo -e "${bold_red}[ERROR] Strings failed.${nc}"
        fi
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        # Stegseek
        echo -e "${bold_cyan}Running Stegseek...${nc}"
        local stegseek_log="$output_dir/stegseek_${base_file_name}.log"
        if stegseek "$filename" 2>&1 | tee "$stegseek_log"; then
            echo -e "${bold_green}[SUCCESS] Stegseek completed. Results saved in: ${bold_yellow}$stegseek_log${nc}"
        else
            echo -e "${bold_red}[ERROR] Stegseek failed to process the file.${nc}"
        fi
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        # Volatility 3 Automation
        echo -e "${bold_cyan}Running Volatility 3 Analysis...${nc}"
        local vol_dir="$output_dir/volatility"
        mkdir -p "$vol_dir"
            
        # OS Detection
        if vol -f "$original_dir/$filename" windows.info >/dev/null 2>&1; then
            local os_type="Windows"
            echo -e "${bold_green}[SUCCESS] Detected OS: ${bold_yellow}Windows${nc}"
            # Windows
            vol -f "$original_dir/$filename" windows.info | tee "$vol_dir/windows_info.txt"
            vol -f "$original_dir/$filename" windows.pslist | tee "$vol_dir/process_list.txt"
            vol -f "$original_dir/$filename" windows.netscan | tee "$vol_dir/network_connections.txt"
            vol -f "$original_dir/$filename" windows.registry.printkey | tee "$vol_dir/registry_info.txt"
            vol -f "$original_dir/$filename" windows.malfind | tee "$vol_dir/malware_findings.txt"
        elif vol -f "$original_dir/$filename" linux.pslist >/dev/null 2>&1; then
            local os_type="Linux"
            echo -e "${bold_green}[SUCCESS] Detected OS: ${bold_yellow}Linux${nc}"
            # Linux
            vol -f "$original_dir/$filename" linux.pslist | tee "$vol_dir/process_list.txt"
            vol -f "$original_dir/$filename" linux.bash | tee "$vol_dir/bash_history.txt"
            vol -f "$original_dir/$filename" linux.sockstat | tee "$vol_dir/network_connections.txt"
            vol -f "$original_dir/$filename" linux.check_modules | tee "$vol_dir/kernel_modules.txt"
            vol -f "$original_dir/$filename" linux.check_tty | tee "$vol_dir/tty_activity.txt"
        else
            echo -e "${bold_red}[-] Unable to detect OS type automatically.${nc}"
        fi

        echo -e "${bold_green}[SUCCESS] Volatility results saved to: ${bold_yellow}$vol_dir${nc}"
        echo -e "${bold_yellow}---------------------------------------------------------------------------------${nc}"

        local total_end_time=$(date +%s)
        local total_elapsed_time=$((total_end_time - total_start_time))

        echo -e "${bold_green}[INFO] Zipping the entire Automation folder...${nc}"
        local zip_target="Engineer/${base_file_name_no_ext}_Automation.zip"
        
        if [ -d "Engineer/${filename}/Automation" ]; then
            (cd "Engineer/${filename}" && zip -r "../../$zip_target" Automation &>/dev/null)
            
            if [ $? -eq 0 ]; then
                echo -e "${bold_green}[SUCCESS] Automation folder zipped to: ${bold_yellow}$zip_target${nc}"
            else
                echo -e "${bold_red}[ERROR] Failed to zip the Automation folder.${nc}"
            fi
        else
            echo -e "${bold_red}[ERROR] Directory to zip not found: Engineer/${filename}/Automation. Zipping skipped.${nc}"
        fi

        echo -e "${bold_yellow}[STATS] Total automation completed in ${total_elapsed_time} seconds.${nc}"
        echo -e "${bold_yellow}Full results available in: ${zip_target}${nc}"
        ;;
    2)
        return
        ;;
    *)
        echo -e "${bold_red}[ERROR] Invalid option! Please choose 1 or 2.${nc}"
        sleep 1
        ;;
    esac

    read -p "$(echo -e "${bold_yellow}[INFO] Press Enter to continue...${nc}")"
}

# Main script execution
root_check
tool_check
vol_check
file_check
main_menu
