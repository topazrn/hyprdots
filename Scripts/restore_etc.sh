#!/bin/bash
#|---/ /+-------------------------+---/ /|#
#|--/ /-| Script to configure etc |--/ /-|#
#|-/ /--| Prasanth Rangan         |-/ /--|#
#|/ /---+-------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname $(realpath $0))..."
    exit 1
fi


# sddm
if pkg_installed sddm
    then

    if [ ! -d /etc/sddm.conf.d ] ; then
        sudo mkdir -p /etc/sddm.conf.d
    fi

    if [ ! -f /etc/sddm.conf.d/kde_settings.t2.bkp ] ; then
        echo "configuring sddm..."
        sudo tar -xzf ${CloneDir}/Source/arcs/Sddm_Corners.tar.gz -C /usr/share/sddm/themes/
        sudo touch /etc/sddm.conf.d/kde_settings.conf
        sudo cp /etc/sddm.conf.d/kde_settings.conf /etc/sddm.conf.d/kde_settings.t2.bkp
        sudo cp /usr/share/sddm/themes/corners/kde_settings.conf /etc/sddm.conf.d/
        sudo systemctl set-default graphical.target
    fi

    if [ ! -f /usr/share/sddm/faces/${USER}.face.icon ] && [ -f ${CloneDir}/Source/misc/${USER}.face.icon ] ; then
        sudo cp ${CloneDir}/Source/misc/${USER}.face.icon /usr/share/sddm/faces/
        echo "avatar set for ${USER}..."
    fi

else
    echo "WARNING: sddm is not installed..."
fi


# grub
if pkg_installed grub2-common
    then

    if [ ! -f /etc/default/grub.backup ] && [ ! -f /etc/grub2.cfg.backup ]
        then
        echo "configuring grub..."
        sudo cp /etc/default/grub /etc/default/grub.backup
        sudo mkdir /usr/share/grub/themes/
        sudo tar -xzf ${CloneDir}/Source/arcs/Grub_Pochita.tar.gz -C /usr/share/grub/themes/

        if nvidia_detect
            then
            sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"rootflags=subvol=root loglevel=3 quiet splash nvidia_drm.modeset=1\"" /etc/default/grub
        fi

        if apple_detect
            then
            sudo sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/c\GRUB_CMDLINE_LINUX_DEFAULT=\"rootflags=subvol=root loglevel=3 quiet splash apple_dcp.show_notch=1\"" /etc/default/grub
        fi

        sudo sh -c "echo 'GRUB_THEME=\"/usr/share/grub/themes/pochita/theme.txt\"' >> /etc/default/grub"

        sudo cp /etc/grub2.cfg /etc/grub2.cfg.backup
        sudo grub2-mkconfig -o /etc/grub2.cfg
        sudo sh -c "cat /etc/grub2.cfg > /etc/grub2-efi.cfg"
    fi

else
    echo "WARNING: grub is not installed..."
fi


# dolphin
if pkg_installed dolphin && pkg_installed xdg-utils
    then

    xdg-mime default org.kde.dolphin.desktop inode/directory
    echo "setting" `xdg-mime query default "inode/directory"` "as default file explorer..."

else
    echo "WARNING: dolphin is not installed..."
fi


# zsh
if pkg_installed zsh
    then

    if [ "$SHELL" != "/usr/bin/zsh" ] ; then
        echo "changing shell to zsh..."
        sudo chsh -s $(which zsh) $(whoami)
    fi

else
    echo "WARNING: zsh is not installed..."
fi

