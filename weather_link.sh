#!/bin/bash
# create symbolic link of weather database
# Define the target file and destination folder
TARGET_FOLDER="/caldera/hovenweep/projects/usgs/centers/sbsc/DrylandEcologyTeam/stepwat/weather/" # where weather db lives
DESTINATION_FOLDER="/caldera/hovenweep/projects/usgs/centers/sbsc/DrylandEcologyTeam/stepwat/rSFSTEP2/inputs/" # inputs location, defined in Main.R
FILE="/dbWeatherData_STEPWAT2_200sites.sqlite3" # weather datebase

SYMLINK="$DESTINATION_FOLDER""$FILE"
TARGET_FILE="$TARGET_FOLDER""$FILE"
# Check if the symlink already exists
if [ -L "$SYMLINK" ]; then
    echo "Symbolic link $SYMLINK already exists."
else
    ln -s "$TARGET_FILE" "$SYMLINK"
    echo "Symbolic link created: $SYMLINK -> $TARGET_FILE"
fi
