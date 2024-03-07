##!/bin/bash
#
# This is an older version of the run-kiosk.sh script I wrote when
# trying to get the kiosk running on a Raspberry Pi 3.  That device just
# didn't have enough RAM, so I started to use a Raspberry pi 4. The big 
# difference between the devices is that the RPI3 has X11 installed to 
# run the display and RPI4 has Wayland.
#
# This script is intended to run either from the command line, or from .xsession
# to run a web browser in full screen mode and then flip through URLs.
#

# We aren't using these right now
SAVED_URLS="
  https://www.clockfaceonline.co.uk/clocks/digital/
  https://dataview.raspberryshake.org/#/AM/R755E/00/EHZ?streaming=on
"

# *EDIT* The list of URLs to load into each tab
URLS="
  https://steamatdrew.weebly.com/georgia-tech-earth-quake.html
  https://stationview.raspberryshake.org/#/?lat=33.76163&lon=-84.34700&zoom=11.140&sta=R755E&streaming=on
  https://stationview.raspberryshake.org/#/?lat=15.47241&lon=-14.92133&zoom=2.5&sta=R755#
"

# *EDIT* the number of seconds to wait before switching screens.
TAB_SWITCH_SECONDS=30

RESTART_INTERVAL=$((3600*4))  # 4 hours
#RESTART_INTERVAL=600  # 10 minutes
# ---------------------------------------------------------------------------------

# Record the start time in seconds since the Unix epoch
start_time=$(date +%s)
chromium_pid=999999

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

# Function to check elapsed time
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

# Loop to switch through the open tabs
while true; do
  windowid=`wmctrl -l | grep -i chromium | awk  '{print $1}' `
  echo "Window ID is $windowid"
  echo "Bringing chrome into focus and Sending ctrl-Tab"
  xdotool windowactivate $windowid
  xdotool keydown ctrl key Tab keyup ctrl
  sleep "$TAB_SWITCH_SECONDS"
  check_time
done

