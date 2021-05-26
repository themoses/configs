#!/bin/bash
set -e

source /etc/lsb-release

ABSOLUTE_PATH="$(pwd)/$(dirname "${BASH_SOURCE[0]}")"

setup_vim(){
    
    case "$DISTRIB_ID" in
        "Arch")
            sudo pacman -Sy vim --noconfirm
        ;;

        "Ubuntu")
            sudo apt install vim --yes
        ;;

        *)
            # do nothing
        ;;
    esac

    cp "$ABSOLUTE_PATH/vim/.vimrc" ~/.vimrc
}

setup_rofi(){
    
    case "$DISTRIB_ID" in
        "Arch")
            sudo pacman -Sy rofi dconf --noconfirm
        ;;

        "Ubuntu")
            sudo apt install rofi dconf-cli --yes
        ;;

        *)
            # do nothing
        ;;
    esac

    mkdir -p ~/.config/rofi/config
    cp "$ABSOLUTE_PATH/rofi/config" ~/.config/rofi/config

# set up key bindings for rofi
    case "$XDG_SESSION_DESKTOP" in
        "mate")
            dconf write /org/mate/desktop/keybindings/custom0/name "'rofi'"
            dconf write /org/mate/desktop/keybindings/custom0/action "'rofi -show drun -display-drun \"\"'"
            dconf write /org/mate/desktop/keybindings/custom0/binding "'<Mod4>space'"
        ;;

        "gnome-xorg")
            dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/name "'rofi'"
            dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/action "'rofi -show drun -display-drun \"\"'"
            dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/binding "'<Mod4>space'"
        ;;
        
        *)
            # do nothing
        ;;
    esac
}

setup_vim
setup_rofi
