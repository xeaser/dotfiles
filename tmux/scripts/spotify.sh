#!/usr/bin/env bash
if ! pgrep -xq "Spotify"; then
  exit 0
fi

state=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)

if [ "$state" = "playing" ]; then
  artist=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
  track=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
  echo " ♫ ${artist}: ${track} "
elif [ "$state" = "paused" ]; then
  artist=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
  track=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
  echo " ⏸ ${artist}: ${track} "
fi
