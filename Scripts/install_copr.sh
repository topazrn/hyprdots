#!/bin/bash
#|---/ /+-----------------------------------+---/ /|#
#|--/ /-| Script to enable copr             |--/ /-|#
#|-/ /--| Prasanth Rangan                   |-/ /--|#
#|/ /---+-----------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname "$(realpath "$0")")..."
    exit 1
else
    # swww & swaylock-effects
    sudo dnf copr enable -y trs-sod/swaylock-effects
    sudo dnf copr enable -y alebastr/sway-extras
    sudo dnf copr enable -y aeiro/nwg-shell

    # grimblast
    sudo wget https://raw.githubusercontent.com/hyprwm/contrib/main/grimblast/grimblast -O /usr/bin/grimblast
    sudo chmod +x /usr/bin/grimblast

    # cliphist
    case $(uname -m) in
        x86_64) 
            sudo wget "https://github.com/sentriz/cliphist/releases/download/v0.4.0/v0.4.0-linux-amd64" -O "/usr/bin/cliphist"
            sudo chmod +x /usr/bin/cliphist
            ;;
        aarch64) 
            mkdir cliphist
            cd cliphist
            wget -O "cliphist.pkg.tar.xz" "http://mirror.archlinuxarm.org/aarch64/extra/cliphist-1:0.5.0-1-aarch64.pkg.tar.xz"
            tar -xf cliphist.pkg.tar.xz
            sudo install -Dm0755 -t "/usr/bin/" "usr/bin/cliphist"
            cd ..
            rm -rf cliphist 
            ;;
        *)
            echo "TODO: install cliphist for other archs"
            ;;
    esac

    # vscode
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
fi
