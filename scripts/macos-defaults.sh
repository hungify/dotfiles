#!/usr/bin/env bash

set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || {
  echo "This script only works on macOS" >&2
  exit 1
}

defaults write -globalDomain com.apple.sound.beep.feedback -int 1
defaults write -globalDomain AppleLanguages -array en-GB pl-GB
defaults write -globalDomain AppleInterfaceStyleSwitchesAutomatically -bool false
defaults write -globalDomain AppleScrollerPagingBehavior -bool true

defaults write com.apple.AppleMultitouchTrackpad Dragging -bool false
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool false
defaults write com.apple.airplay showInMenuBarIfPresent -bool false
defaults write com.apple.controlcenter "NSStatusItem Visible Sound" -bool false
defaults write com.apple.airplay "NSStatusItem Visible NowPlaying" -bool false
defaults write com.apple.menuextra.clock ShowDate -int 1
defaults write com.apple.menuextra.clock ShowDayOfWeek -bool true
defaults -currentHost write com.apple.Spotlight MenuItemHidden -int 1

defaults write com.apple.Siri SiriPrefStashedStatusMenuVisible -bool false
defaults write com.apple.Siri VoiceTriggerUserEnabled -bool false

defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock pinning -string end
defaults write com.apple.dock orientation -string right
defaults write com.apple.dock largesize -int 54
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock mineffect -string suck
defaults write com.apple.dock minimize-to-application -bool true
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-time-modifier -float 0.4
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock show-recents -bool false
defaults write -globalDomain AppleWindowTabbingMode -string always
defaults write com.apple.dock mru-spaces -bool false

defaults -currentHost write com.apple.screensaver idleTime -int 0

defaults write -globalDomain AppleKeyboardUIMode -int 2
defaults write com.apple.TextInputMenu visible -bool false
defaults write -globalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write -globalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write -globalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
defaults write com.apple.finder FXEnableRemoveFromICloudDriveWarning -bool false
defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder NewWindowTarget -string PfHm
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

chflags nohidden "$HOME/Library"

for app in Dock Finder; do
  killall "$app" >/dev/null 2>&1 || true
done

echo "Applied macOS defaults. Some changes need logout or restart."
