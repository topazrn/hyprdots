#!/bin/bash
#|---/ /+----------------------------------------+---/ /|#
#|--/ /-| Script to install pkgs from input list |--/ /-|#
#|-/ /--| Prasanth Rangan                        |-/ /--|#
#|/ /---+----------------------------------------+/ /---|#

source global_fn.sh
if [ $? -ne 0 ] ; then
    echo "Error: unable to source global_fn.sh, please execute from $(dirname "$(realpath "$0")")..."
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
ofs=$IFS
IFS='|'

while read -r pkg deps
do
    pkg="${pkg// /}"
    if [ -z "${pkg}" ] ; then
        continue
    fi

    if [ ! -z "${deps}" ] ; then
        deps="${deps%"${deps##*[![:space:]]}"}"
        while read -r cdep
        do
            pass=$(cut -d '#' -f 1 ${install_list} | awk -F '|' -v chk="${cdep}" '{if($1 == chk) {print 1;exit}}')
            if [ -z "${pass}" ] ; then
                if pkg_installed ${cdep} ; then
                    pass=1
                else
                    break
                fi
            fi
        done < <(echo "${deps}" | xargs -n1)

        if [[ ${pass} -ne 1 ]] ; then
            echo -e "\033[0;33m[SKIP]\033[0m ${pkg} is missing (${deps}) dependency..."
            continue
        fi
    fi

    if pkg_installed ${pkg}
        then
        echo -e "\033[0;33m[SKIP]\033[0m ${pkg} is already installed..."

    elif pkg_available ${pkg}
        then
        repo=$(dnf info --available ${pkg} | awk -F ': ' '/Repository / {print $2}')
        echo -e "\033[0;32m[${repo}]\033[0m queueing ${pkg} from official dnf repo..."
        pkg_dnf=`echo ${pkg_dnf} ${pkg}`

    else
        echo "error: unknown package ${pkg}..."
    fi
done < <( cut -d '#' -f 1 $install_list )

IFS=${ofs}
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
