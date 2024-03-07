##!/bin/bash
#
# Kiosk script for the Earth Quake station at Charles R. Drew Charter School
# Author: Eric Z. Ayers <ericzundel@gmail.com>
# Git Repo: https://github.com/ericzundel/shake-and-boom-kiosk
#
# This script is intended to run either from the command line, or 
# from  ~/.config/wayfire.ini to run a web browser in full screen 
# mode.  It launches a web browser and then flips through URLs on each tab.
#

# *EDIT* the number of seconds to wait before switching screens.
TAB_SWITCH_SECONDS=30

# If you rename this variable to "URLS" you can set the list of URLs in the script.
# Otherwise, it tries to load them off of a git repo
OLDURLS="
  https://steamatdrew.weebly.com/georgia-tech-earth-quake.html
  https://stationview.raspberryshake.org/#/?lat=33.76163&lon=-84.34700&zoom=11.140&sta=R755E&streaming=on
  https://dataview.raspberryshake.org/#/AM/R755E/00/EHZ?streaming=on
  https://dataview.raspberryshake.org/#/AM/R755E/00/EHZ
  https://stationview.raspberryshake.org/#/?lat=15.47241&lon=-14.92133&zoom=2.5&sta=R755#
"

RESTART_INTERVAL=$((3600*4))  # 4 hours
#RESTART_INTERVAL=600  # 10 minutes

# File to save url list in between invocations of this script
URLFILE=`echo ~/urls.txt`
# Online file that contains a list of URLs that will allow the kiosk to be maintained remotely
REPOURLFILE="https://raw.githubusercontent.com/ericzundel/shake-and-boom-kiosk/main/urls.txt"

# -----------------------------------------------------------------------------

# Create an empty file of urls if none exists
if [ ! -f $URLFILE ] ; then
    touch $URLFILE
fi

# Populate the list of URLs from a page on the web
if [ -z "$URLS" ] ; then
    TMPURLFILE=`echo /tmp/urls.$$`
    rm -f $TMPURLFILE
    curl $REPOURLFILE >$TMPURLFILE
    if cmp -s $TMPURLFILE $URLFILE ; then
      echo "URLs at $REPOURLFILE have not changed"
    else
      echo "URL files has been updated at $REPOURLFILE:"
      cat $TMPURLFILE
      cp -f $TMPURLFILE $URLFILE
    fi
    rm -f $TMPURLFILE
    URLS=`cat $URLFILE`
fi

echo "Displaying URLS: $URLS"

# Record the start time in seconds since the Unix epoch
start_time=$(date +%s)
chromium_pid=999999

# Launch the web browser
run_chromium() {
    echo "Main task is running..."
    echo "Invoking Chromium"
    # I tried --incognito, but the website puts up a bunch of prompts as if we are first time users
    chromium-browser $URLS  --kiosk --noerrdialogs --disable-infobars --no-first-run --enable-features=OverlayScrollbar --start-maximized &
    # Find Chromium browser process ID
    chromium_pid=$!
    echo "Chromium browser process ID: $chromium_pid"
    # Give Chromium time to startup
    sleep 10
}

# Function to check elapsed time and restart the web browser occasionally
check_time() {
    local current_time=$(date +%s) # Current time in seconds since the Unix epoch
    local elapsed=$(( (current_time - start_time))) # Elapsed hours

    if [ $elapsed -ge $RESTART_INTERVAL ]; then
        echo "Restart Interval ($RESTART_INTERVAL secs) have passed. Restarting kiosk"
        # Perform the action you want after 4 hours here

        echo "Killing Chromium"
        kill -TERM $chromium_pid

        sleep 10

        if kill -0 "$chromium_pid" 2>/dev/null ; then
          kill -9 $chromium_pid
          sleep 20
        fi

        run_chromium

        # Reset the timer if you want to repeat the process
        start_time=$(date +%s)
    else
        echo "$RESTART_INTERVAL seconds have not yet passed. Only $elapsed seconds elapsed."
    fi
}

run_chromium

export XDG_RUNTIME_DIR=/run/user/1000

# Loop to switch through the open tabs
while true; do
  # Send Ctrl+Tab using `wtype` command for Wayland display system
  wtype -M ctrl -P Tab

  sleep "$TAB_SWITCH_SECONDS"
  check_time
done
