#!/bin/bash
set -e

source /etc/lsb-release

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

    cp vim/.vimrc ~/.vimrc
}

setup_rofi(){
    
    case "$DISTRIB_ID" in
        "Arch")
            sudo pacman -Sy rofi dconf --noconfirm
        ;;

        "Ubuntu")
            sudo apt install rofi dconf-tools --yes
        ;;
    esac

    mkdir -p ~/.config/rofi/config
    cp rofi/config ~/.config/rofi/config

# set up key bindings for rofi
    case "$XDG_SESSION_DESKTOP" in
        "mate" | "gnome-xorg")
            dconf write /org/mate/desktop/keybindings/custom0/name "'rofi'"
            dconf write /org/mate/desktop/keybindings/custom0/action "'rofi -show drun -display-drun \"\"'"
            dconf write /org/mate/desktop/keybindings/custom0/binding "'<Mod4>space'"

        *)
            # do nothing
        ;;
    esac
}

setup_vim
setup_rofi