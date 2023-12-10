#!/bin/bash
#|---/ /+--------------------------+---/ /|#
#|--/ /-| Main installation script |--/ /-|#
#|-/ /--| Prasanth Rangan          |-/ /--|#
#|/ /---+--------------------------+/ /---|#

# Function to install packages
install_packages() {
    cat <<EOF

 _         _       _ _ _         
|_|___ ___| |_ ___| | |_|___ ___ 
| |   |_ -|  _| .'| | | |   | . |
|_|_|_|___|_| |__,|_|_|_|_|_|_  |
                            |___|

EOF

    # Prepare package list
    shift $((OPTIND - 1))
    cust_pkg=$1
    cp custom_hypr.lst install_pkg.lst

    if [ -f "$cust_pkg" ] && [ ! -z "$cust_pkg" ]; then
        cat "$cust_pkg" >>install_pkg.lst
    fi

    # Add Nvidia drivers to the list
    if nvidia_detect; then
        cat /usr/lib/modules/*/pkgbase | while read krnl; do
            echo "${krnl}-headers" >>install_pkg.lst
        done
        IFS=$' ' read -r -d '' -a nvga < <(lspci -k | grep -E "(VGA|3D)" | grep -i nvidia | awk -F ':' '{print $NF}' | tr -d '[]()' && printf '\0')
        for nvcode in "${nvga[@]}"; do
            awk -F '|' -v nvc="${nvcode}" '{if ($3 == nvc) {split(FILENAME,driver,"/"); print driver[length(driver)],"\nnvidia-utils"}}' .nvidia/nvidia*dkms >>install_pkg.lst
        done
    else
        echo "Nvidia card not detected, skipping Nvidia drivers..."
    fi

    # Install packages from the list
    ./install_pkg.sh install_pkg.lst
    rm install_pkg.lst
}

# Function to restore configurations
restore_configs() {
    cat <<EOF

             _           _         
 ___ ___ ___| |_ ___ ___|_|___ ___ 
|  _| -_|_ -|  _| . |  _| |   | . |
|_| |___|___|_| |___|_| |_|_|_|_  |
                              |___|

EOF

    ./restore_fnt.sh
    ./restore_cfg.sh
}

# Function to enable system services
enable_services() {
    cat <<EOF

                 _             
 ___ ___ ___ _ _|_|___ ___ ___ 
|_ -| -_|  _| | | |  _| -_|_ -|
|___|___|_|  \_/|_|___|___|___|

EOF

    while read service ; do
        service_ctl "$service"
    done < system_ctl.lst
}

# Main script
cat <<EOF

-----------------------------------------------------------------
 _     _                      _                             
(_)   (_)                    | |       _             
 _______ _   _ ____   ____ __| | ___ _| |_  ___    
|  ___  | | | |  _ \ / ___) _  |/ _ (_   _)/___)  
| |   | | |_| | |_| | |  ( (_| | |_| || |_|___ |   
|_|   |_|\__  |  __/|_|   \____|\___/  \__|___/            
        (____/|_|                                               
                       _   
                     _| |_ 
                    (_   _)
                      |_|  
                 ..........     
              ........-+##+...  
             .......-###+++--.. 
            ........+#+....---..
            ........+#+....---..
            ...--+#######----...
            ..-----+###---......
            .---....+#+.........
            .---...-##-........ 
            ..--#####-........  
            ....----.......            
-----------------------------------------------------------------

EOF

# Import variables and functions
source global_fn.sh

# Evaluate options
flg_Install=0
flg_Restore=0
flg_Service=0

while getopts "idrs" RunStep; do
    case $RunStep in
        i) flg_Install=1 ;;
        d) flg_Install=1; use_default="-y" ;;
        r) flg_Restore=1 ;;
        s) flg_Service=1 ;;
        *) echo "Valid options are: i, d, r, s"; exit 1 ;;
    esac
done

if [ $OPTIND -eq 1 ]; then
    flg_Install=1
    flg_Restore=1
    flg_Service=1
fi

# Perform actions based on options
if [ $flg_Install -eq 1 ]; then
    install_packages
fi

if [ $flg_Restore -eq 1 ]; then
    restore_configs
fi

if [ $flg_Install -eq 1 ] && [ $flg_Restore -eq 1 ]; then
    ./restore_etc.sh
fi

if [ $flg_Service -eq 1 ]; then
    enable_services
fi
