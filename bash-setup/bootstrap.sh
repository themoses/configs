#!/bin/bash
set -e

source /etc/lsb-release

install_vim(){
    
    case $DISTRIB_ID in
        "Arch")
            sudo pacman -Sy vim --noconfirm
        ;;

        "Ubuntu")
            sudo apt install vim --yes
        ;;
    esac

    cp vim/.vimrc ~/.vimrc
}

install_vim