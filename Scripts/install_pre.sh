#!/bin/bash
#|---/ /+-------------------------------------+---/ /|#
#|--/ /-| Script to apply pre install configs |--/ /-|#
#|-/ /--| Prasanth Rangan                     |-/ /--|#
#|/ /---+-------------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname "$(realpath "$0")")..."
    exit 1
fi


# grub
if pkg_installed grub2-common
    then

    if [ ! -f /etc/default/grub.t2.bkp ] && [ ! -f /etc/grub2.cfg.t2.bkp ]
        then
        echo "configuring grub..."
        sudo cp /etc/default/grub /etc/default/grub.t2.bkp
        sudo cp /etc/grub2.cfg /etc/grub2.cfg.t2.bkp

        if nvidia_detect
            then
            echo "nvidia detected, setting nvidia_drm.modeset=1 in grub..."
            sudo sed -i "s/^\(GRUB_CMDLINE_LINUX=\".*\)\(\"\)$/\1 nvidia_drm.modeset=1\2/" /etc/default/grub
            sudo sed -i "s/^\(GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\(\"\)$/\1 nvidia_drm.modeset=1\2/" /etc/default/grub
        fi

        if apple_detect
            then
            sudo sed -i "s/^\(GRUB_CMDLINE_LINUX=\".*\)\(\"\)$/\1 apple_dcp.show_notch=1\2/" /etc/default/grub
            sudo sed -i "s/^\(GRUB_CMDLINE_LINUX_DEFAULT=\".*\)\(\"\)$/\1 apple_dcp.show_notch=1\2/" /etc/default/grub
        fi

        read -p "Apply grub theme? [Y/N] : " grubtheme
        case $grubtheme in
        Y|y) echo -e "Setting grub theme..."
            sudo mkdir /usr/share/grub/themes/
            sudo tar -xzf ${CloneDir}/Source/arcs/Grub_Pochita.tar.gz -C /usr/share/grub/themes/
            sudo sed -i "/^GRUB_TERMINAL_OUTPUT/d" /etc/default/grub
            sudo sh -c "echo 'GRUB_THEME=\"/usr/share/grub/themes/pochita/theme.txt\"' >> /etc/default/grub" ;;
        *) echo -e "Skippinng grub theme..." 
            sudo sed -i "s/^GRUB_THEME=/#GRUB_THEME=/g" /etc/default/grub ;;
        esac

        sudo grub2-mkconfig -o /etc/grub2.cfg
    else
        echo "grub is already configured..."
    fi

else
    echo "WARNING: grub is not installed..."
fi
