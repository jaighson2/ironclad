#!/bin/bash

# Start the emulator in the background
echo "Starting emulator..."
emulator -avd test_avd -no-window -no-audio -no-boot-anim &

# Wait for the emulator to fully boot
echo "Waiting for emulator to boot..."
adb wait-for-device
boot_completed=$(adb shell getprop sys.boot_completed | tr -d '\r')
while [ "$boot_completed" != "1" ]; do
    sleep 2
    boot_completed=$(adb shell getprop sys.boot_completed | tr -d '\r')
done
echo "Emulator is fully booted."

# Execute the main Python test script
echo "Running the vulnerability test script..."
python3 /home/androiduser/work/test_vulnerability.py

# Keep the container running if needed for inspection, otherwise it will exit
echo "Test script finished. Container will now exit."
