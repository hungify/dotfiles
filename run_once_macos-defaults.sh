#!/usr/bin/env bash
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || exit 0

echo "Applying macOS defaults..."

# --- Global / System ---
# Feedback sound when changing volume via keyboard keys
defaults write -globalDomain com.apple.sound.beep.feedback -int 1
# Preferred system languages (English UK, Polish UK)
defaults write -globalDomain AppleLanguages -array en-GB pl-GB
# Don't automatically switch Light/Dark appearance based on time of day
defaults write -globalDomain AppleInterfaceStyleSwitchesAutomatically -bool false
# Clicking the scrollbar track jumps to that spot (instead of paging)
defaults write -globalDomain AppleScrollerPagingBehavior -bool true

# --- Trackpad ---
# Enable Tap to Click (built-in + Bluetooth + global)
# NOTE: on some macOS versions this only takes effect after toggling it
# once manually in System Settings > Trackpad post-reboot (known Apple bug).
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable "Dragging" (drag by holding after tap) — built-in + Bluetooth
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Dragging -bool false

# Enable three-finger drag — built-in + Bluetooth + global
# NOTE: on macOS 26 (Tahoe) this terminal-only approach is known to be
# unreliable (forces Drag Lock, or drag doesn't release on finger-lift).
# If it misbehaves after this script runs, set it manually via:
# System Settings > Accessibility > Pointer Control > Trackpad Options >
# "Use trackpad for dragging" > "Three Finger Drag"
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.threeFingerDragGesture -bool true

# --- Control Center / Menu Bar ---
# Hide Bluetooth icon from menu bar
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool false
# Hide AirPlay icon from menu bar (only shows if a device is present)
defaults write com.apple.airplay showInMenuBarIfPresent -bool false
# Hide Sound icon from menu bar
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool false
# Hide Now Playing icon from menu bar
defaults write com.apple.airplay "NSStatusItem Visible NowPlaying" -bool false
# Show date next to the clock
defaults write com.apple.menuextra.clock ShowDate -int 1
# Show day of week next to the clock
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
# Hide Spotlight icon from menu bar
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

# --- Siri ---
# Hide Siri status icon from menu bar
defaults write com.apple.Siri SiriPrefStashedStatusMenuVisible -bool false
# Disable "Hey Siri" voice trigger
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false

# --- Dock ---
# Icon size (pixels)
defaults write com.apple.dock tilesize -int 36
# Keep Dock icons aligned to the end (right/bottom side)
defaults write com.apple.dock pinning -string end
# Position Dock on the right edge of the screen
defaults write com.apple.dock orientation -string right
# Magnified icon size on hover (pixels)
defaults write com.apple.dock largesize -int 54
# Enable magnification on hover
defaults write com.apple.dock magnification -bool true
# Minimize/genie effect style ("suck" effect)
defaults write com.apple.dock mineffect -string suck
# Minimize windows into their app icon instead of the Dock
defaults write com.apple.dock minimize-to-application -bool true
# Auto-hide the Dock
defaults write com.apple.dock autohide -bool true
# Speed of the show/hide animation
defaults write com.apple.dock autohide-time-modifier -float 0.4
# Delay before the Dock appears/disappears (0 = instant)
defaults write com.apple.dock autohide-delay -float 0
# Don't show recently used apps in the Dock
defaults write com.apple.dock show-recents -bool false
# Merge all windows into a single tab bar when possible
defaults write -globalDomain AppleWindowTabbingMode -string always
# Don't rearrange Spaces based on most recently used
defaults write com.apple.dock mru-spaces -bool false
# Remove all default pinned apps from the Dock
defaults write com.apple.dock persistent-apps -array
# Show the running-app indicator dots under Dock icons
defaults write com.apple.dock show-process-indicators -bool true
# Group windows by app when using Mission Control / App Exposé
defaults write com.apple.dock expose-group-apps -bool true

# --- Screensaver ---
# Disable idle screensaver trigger (0 = never)
defaults -currentHost write com.apple.screensaver idleTime -int 0

# --- Keyboard / Input ---
# Enable full keyboard access (Tab moves between all controls)
defaults write -globalDomain AppleKeyboardUIMode -int 2
# Hide the Input/Text menu icon from the menu bar
defaults write com.apple.TextInputMenu visible -bool false
# Disable automatic spelling correction
defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# Disable automatic capitalization
defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false
# Disable automatic period substitution (double-space -> period)
defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
# Faster key repeat rate (lower = faster)
defaults write -globalDomain KeyRepeat -int 2
# Shorter delay before key repeat kicks in
defaults write -globalDomain InitialKeyRepeat -int 15
# Disable press-and-hold accent popup, allow key repeat instead
defaults write -globalDomain ApplePressAndHoldEnabled -bool false

# --- Finder (clean setup) ---
# Always show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Don't warn when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
# Don't warn when removing items from iCloud Drive
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
# Don't warn when emptying the Trash
defaults write com.apple.finder WarnOnEmptyTrash -bool false
# Default Finder view style (Nlsv = list view)
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
# Show the path bar at the bottom of Finder windows
defaults write com.apple.finder ShowPathbar -bool true
# Show the status bar (item count, disk space)
defaults write com.apple.finder ShowStatusBar -bool true
# Show hidden files
defaults write com.apple.finder AppleShowAllFiles -bool true
# New Finder windows open to a specific folder (PfHm = Home)
defaults write com.apple.finder NewWindowTarget -string PfHm
# Path used for new Finder windows (paired with NewWindowTarget above)
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"
# Default search scope: current folder instead of "This Mac"
defaults write com.apple.finder FXDefaultSearchScope -string SCcf
# Keep folders always sorted above files in list view
defaults write com.apple.finder _FXSortFoldersFirst -bool true
# Empty Trash items automatically after 30 days
defaults write com.apple.finder FXRemoveOldTrashItems -bool true
# Disable the "Are you sure you want to open this application?" prompt for downloaded apps
defaults write com.apple.LaunchServices LSQuarantine -bool false
# Don't create .DS_Store files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
# Don't create .DS_Store files on USB volumes
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
# Hide external disks, hard drives, servers, removable media from Desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowMountedServersOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool false
# Hide all icons on the Desktop entirely for a clean look
defaults write com.apple.finder CreateDesktop -bool false

# Unhide the ~/Library folder
chflags nohidden "$HOME/Library"

# Restart affected apps so changes take effect immediately
for app in Dock Finder SystemUIServer; do
  killall "$app" >/dev/null 2>&1 || true
done

echo "Applied macOS defaults."
echo "NOTE: Tap to Click and Three Finger Drag may require a logout/restart"
echo "and one manual toggle in System Settings > Trackpad to fully apply"
echo "(known Apple bug on several macOS versions, including 26 Tahoe)."
