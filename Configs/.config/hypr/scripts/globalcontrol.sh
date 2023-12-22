#!/usr/bin/env sh

# wallpaper var
EnableWallDcol=0
ConfDir="${XDG_CONFIG_HOME:-$HOME/.config}"
CloneDir="$HOME/Hyprdots"
ThemeCtl="$ConfDir/hypr/theme.ctl"
cacheDir="$HOME/.cache/hyprdots"

# theme var
gtkTheme=`gsettings get org.gnome.desktop.interface gtk-theme | sed "s/'//g"`
gtkMode=`gsettings get org.gnome.desktop.interface color-scheme | sed "s/'//g" | awk -F '-' '{print $2}'`

# hypr var
hypr_border=`hyprctl -j getoption decoration:rounding | jq '.int'`
hypr_width=`hyprctl -j getoption general:border_size | jq '.int'`

# notification var
#ncolor="-h string:bgcolor:#191724 -h string:fgcolor:#faf4ed -h string:frcolor:#56526e"
#
#if [ "${gtkMode}" == "light" ] ; then
#    ncolor="-h string:bgcolor:#f4ede8 -h string:fgcolor:#9893a5 -h string:frcolor:#908caa"
#fi

# dnf fns
pkg_installed()
{
    local PkgIn=$1

    if dnf info installed $PkgIn &> /dev/null
    then
        #echo "${PkgIn} is already installed..."
        return 0
    else
        #echo "${PkgIn} is not installed..."
        return 1
    fi
}

check(){
    local Pkg_Dep=$(for PkgIn in "$@"; do ! pkg_installed $PkgIn && echo "$PkgIn"; done)

if [ -n "$Pkg_Dep" ]; then echo -e "$0 Dependencies:\n$Pkg_Dep"
    read -p "ENTER to install  (Other key: Cancel): " ans
    if [ -z "$ans" ]; then sudo dnf install -y $Pkg_Dep
    else echo "Skipping installation of packages" ;exit 1
    fi
fi
}
