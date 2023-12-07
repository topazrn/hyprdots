#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install pkgs from input list |--/ /-|#
#|-/ /--| Prasanth Rangan                        |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname $(realpath $0))..."
    exit 1
fi

if ! pkg_installed git
    then
    echo "installing dependency git..."
    sudo dnf install -y git
fi

echo "installing copr..."
./install_copr.sh

install_list="${1:-install_pkg.lst}"

while read pkg
do
    if [ -z $pkg ]
        then
        continue
    fi

    if pkg_installed ${pkg}
        then
        echo "skipping ${pkg}..."

    elif pkg_available ${pkg}
        then
        echo "queueing ${pkg} from dnf..."
        pkg_dnf=`echo $pkg_dnf ${pkg}`

    else
        echo "error: unknown package ${pkg}..."
    fi
done < <( cut -d '#' -f 1 $install_list )

if [ `echo $pkg_dnf | wc -w` -gt 0 ]
    then
    echo "installing $pkg_dnf from dnf..."
    sudo dnf install ${use_default} $pkg_dnf
fi

# python-pyamdgpuinfo
if amd_detect
    then
    pip install pyamdgpuinfo
fi

# oh-my-zsh-git
git clone https://github.com/ohmyzsh/ohmyzsh.git
cd ohmyzsh
sudo mkdir -p /usr/share/oh-my-zsh
sudo install -D -m644 LICENSE.txt /usr/share/licenses/ohmyzsh/LICENSE
sudo cp -r * /usr/share/oh-my-zsh/
cd ..
sudo rm -rf ohmyzsh

# zsh-theme-powerlevel10k-git
sudo git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /usr/share/zsh-theme-powerlevel10k/

# pokemon-colorscropts
git clone https://gitlab.com/phoneybadger/pokemon-colorscripts.git
cd pokemon-colorscripts
sudo ./install.sh
cd ..
rm -rf pokemon-colorscripts
