#!/bin/bash
scrot /home/moses/.config/i3/temp.png
convert /home/moses/.config/i3/temp.png -blur "0x2" /home/moses/.config/i3/tempblur.png
i3lock -i /home/moses/.config/i3/tempblur.png
rm /home/moses/.config/i3/*.png
