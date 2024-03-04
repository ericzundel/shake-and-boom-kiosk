##!/bin/bash
#
# This script is intended to run either from the command line, or from .xsession
# to run a web browser in full screen mode and then flip through URLs.
#

# We aren't using these right now
SAVED_URLS="
  https://www.clockfaceonline.co.uk/clocks/digital/
"

# *EDIT* The list of URLs to load into each tab
URLS="
  https://steamatdrew.weebly.com/georgia-tech-earth-quake.html
  https://stationview.raspberryshake.org/#/?lat=33.76163&lon=-84.34700&zoom=11.140&sta=R755E&streaming=on
  https://dataview.raspberryshake.org/#/AM/R755E/00/EHZ?streaming=on
  https://dataview.raspberryshake.org/#/AM/R755E/00/EHZ
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

export XDG_RUNTIME_DIR=/run/user/1000

# Loop to switch through the open tabs
while true; do
  # Send Ctrl+Tab using `wtype` command
  wtype -M ctrl -P Tab

  # Send Ctrl+Tab using `wtype` command
  wtype -m ctrl -p Tab

  sleep "$TAB_SWITCH_SECONDS"
  check_time
done


