-- Description:
a Simple rofi menu for different ways to screenshot and screenrecord with a simple i3blocks indicator script

-- Requirements:
rofi
slop
scrot
ffmpreg

-- How to use:
make sure you
	chmod +x rofi_print_screen.sh
	chmod +x record.sh 

add a shortcut for rofi_print_screen.sh

add this to your i3blocks.conf to make the indicator work
	[screen-record]
	# write the path for record.sh
	command=/record.sh
	interval=1

