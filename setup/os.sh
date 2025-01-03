#!/bin/bash

################################################################################
# System Preferences > Sound
################################################################################

# Play feedback when volume is changed
defaults write -globalDomain "com.apple.sound.beep.feedback" -int 1

################################################################################
# System Preferences > General > Language & Region
################################################################################

defaults write ".GlobalPreferences_m" AppleLanguages -array en-GB pl-GB
defaults write -globalDomain AppleLanguages -array en-GB pl-GB

################################################################################
# System Preferences > Appearance
################################################################################

# Appearance: Auto
defaults write -globalDomain AppleInterfaceStyleSwitchesAutomatically -bool false

# Click in the scrollbar to: Jump to the spot that's clicked
defaults write -globalDomain AppleScrollerPagingBehavior -bool true

################################################################################
# System Preferences > Accessibility
################################################################################

# Pointer Control >  Trackpad Options > Dragging Style: Three Finger Drag
defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

################################################################################
# System Preferences > Control Centre
################################################################################

# Control Centre Modules > Bluetooth > Show in Menu Bar
defaults write "com.apple.controlcenter" "NSStatusItem Visible Bluetooth" -bool false

# Control Centre Modules > Screen Mirroring > Don't Show in Menu Bar
defaults write "com.apple.airplay" showInMenuBarIfPresent -bool false

# Control Centre Modules > Sound > Always Show in Menu Bar
defaults write "com.apple.controlcenter" "NSStatusItem Visible Sound" -bool false

# Control Centre Modules > Now Playing > Don't Show in Menu Bar
defaults write "com.apple.airplay" "NSStatusItem Visible NowPlaying" -bool false

# Menu Bar Only > Clock Options > Show Date: Always
defaults write "com.apple.menuextra.clock" ShowDate -int 1

# Menu Bar Only > Clock Options > Show the day of a week
defaults write "com.apple.menuextra.clock" ShowDayOfWeek -bool true

# Menu Bar Only > Spotlight > Don't Show in Menu Bar
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

################################################################################
# System Preferences > Siri & Spotlight
################################################################################

#Ask Siri
defaults write com.apple.Siri SiriPrefStashedStatusMenuVisible -bool false
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false

################################################################################
# System Preferences > Desktop & Dock
################################################################################

# Dock > Size:
defaults write com.apple.dock tilesize -int 36

# Dock > Position:
defaults write com.apple.dock pinning -string end

# Dock > Put the Dock on the right of the screen
defaults write com.apple.dock "orientation" -string "right"

# Dock > Magnification
defaults write com.apple.dock largesize -int 54

# Dock > Magnification
defaults write com.apple.dock magnification -bool true

# Dock > Minimize windows using: No Effect
defaults write com.apple.dock mineffect -string suck

# Dock > Minimize windows into application icon
defaults write com.apple.dock minimize-to-application -bool true

# Dock > Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool true

# Dock > Automatically hide and show the Dock (duration)
defaults write com.apple.dock autohide-time-modifier -float 0.4

# Dock > Automatically hide and show the Dock (delay)
defaults write com.apple.dock autohide-delay -float 0

# Show recent applications in Dock
defaults write com.apple.dock "show-recents" -bool false

# Windows & Apps > Prefer tabs when opening documents
defaults write -globalDomain AppleWindowTabbingMode -string "always"

# Mission Controll > Automatically rearrange Spaces based on most recent use
defaults write com.apple.dock mru-spaces -bool false

################################################################################
# System Preferences > Lock Screen
################################################################################

# Start Screen Saver when inactive: Never
defaults -currentHost write com.apple.screensaver idleTime -int 0

################################################################################
# System Preferences > Keyboard
################################################################################

# Keyboard navigation
defaults write -globalDomain AppleKeyboardUIMode -int 2

# Txt Input > Show Input menu in menu bar
defaults write com.apple.TextInputMenu visible -bool false

# Txt Input > Correct spelling automatically
defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Txt Input > Capitalise words automatically
defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false

# Txt Input > Add full stop with double-space
defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

################################################################################
# System Preferences > Trackpad
################################################################################

# Tap to click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Dragging with three finger drag
defaults write com.apple.AppleMultitouchTrackpad "TrackpadThreeFingerDrag" -bool "true"

################################################################################
# Finder > Preferences
################################################################################

# Show all filename extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show warning before changing an extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Show warning before removing from iCloud Drive
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false

# Finder > View > As List
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder > View > Show Path Bar
defaults write com.apple.finder ShowPathbar -bool true

# Finder > View > Show Library folder
chflags nohidden ~/Library

# Finder > View > Show Hidden Files
defaults write com.apple.finder "AppleShowAllFiles" -bool "true"

# Finder > View > Show All Extension
defaults write NSGlobalDomain "AppleShowAllExtensions" -bool "true"

# Finder > View > Show Path Bar
defaults write com.apple.finder "ShowPathbar" -bool "true"

# Finder > General > New Finder windows show
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file:///Users/YOUR_USERNAME/"

# Kill affected apps
for app in "Dock" "Finder"; do
  killall "${app}" >/dev/null 2>&1
done

# Done
echo "Done. Note that some of these changes require a logout/restart to take effect."
