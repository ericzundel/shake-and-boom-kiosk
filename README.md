# shake-and-boom-kiosk
Backup for the Drew shake and boom kiosk

This repository contains some scripts that I used to setup a kiosk to display
data from our Raspberry Shake and Boom device installed at our school.

I  followed the Raspberry Pi Foundation's guidelines for [setting up
a kiosk on a Raspberry Pi](https://www.raspberrypi.com/tutorials/how-to-use-a-raspberry-pi-in-kiosk-mode/). 
I modified the script to fetch the configuration URLs from a file using curl and launch chromium (instead of doing that in wayfire.ini).  
I also set the machine to reboot every night using an 
entry in the root crontab.

If you are a part of the Drew Charter School community, there is an internal 
writeup about the earthquake monitor saved on the STEAM shared drive under 
Makerspaces/Exhibits/JA Exhibits/Georgia Tech EAS Seismograph
