#!/bin/bash

# Hyprland Wallpaper Changer using wal and swww
# This script changes your wallpaper and generates a matching color scheme

# Check if required tools are installed
if ! command -v wal &>/dev/null; then
  echo "Error: pywal (wal) is not installed"
  echo "Install with: pip install pywal"
  exit 1
fi

if ! command -v swww &>/dev/null; then
  echo "Error: swww is not installed"
  echo "Install from: https://github.com/LGFae/swww"
  exit 1
fi

# Default wallpaper directory
WALLPAPER_DIR="${HOME}/Pictures/wallpapers"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
  echo "Wallpaper directory not found: $WALLPAPER_DIR"
  read -p "Enter wallpaper directory path: " WALLPAPER_DIR
  if [ ! -d "$WALLPAPER_DIR" ]; then
    echo "Error: Directory does not exist"
    exit 1
  fi
fi

# Function to select wallpaper
select_wallpaper() {
  if [ -n "$1" ]; then
    # Use provided wallpaper path
    WALLPAPER="$1"
  else
    # Select random wallpaper
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | shuf -n 1)
  fi

  if [ -z "$WALLPAPER" ]; then
    echo "Error: No wallpaper found"
    exit 1
  fi

  echo "Selected wallpaper: $WALLPAPER"
}

# Function to set wallpaper with swww
set_wallpaper() {
  # Check if swww daemon is running, start if not
  if ! pgrep -x swww-daemon >/dev/null; then
    echo "Starting swww daemon..."
    swww-daemon &
    sleep 1
  fi

  # Set wallpaper with transition effect
  swww img "$WALLPAPER" \
    --transition-type wipe \
    --transition-duration 2 \
    --transition-fps 60 \
    --transition-angle 30

  echo "Wallpaper set successfully"
}

# Function to generate color scheme with pywal
generate_colors() {
  echo "Generating color scheme with pywal..."
  wal -i "$WALLPAPER" -n -q

  # Source the colors
  source "${HOME}/.cache/wal/colors.sh"

  echo "Color scheme generated"
}

# Function to reload Hyprland colors (optional)
reload_hyprland() {
  # You can add commands here to reload your Hyprland config
  # For example, if you have pywal templates for Hyprland:

  if [ -f "${HOME}/.cache/wal/colors-hyprland.conf" ]; then
    # Reload Hyprland config
    hyprctl reload
    echo "Hyprland config reloaded"
  fi
}

# Main execution
main() {
  echo "=== Hyprland Wallpaper Changer ==="

  # Select wallpaper (random or specified)
  select_wallpaper "$1"

  # Set wallpaper with swww
  set_wallpaper

  # Generate color scheme with pywal
  generate_colors

  # Optional: reload Hyprland
  # reload_hyprland

  echo "=== Done! ==="
}

# Run main function with argument if provided
main "$@"
