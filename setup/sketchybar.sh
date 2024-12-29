#!/bin/bash
CONFIG=${HOME}/.config

echo "Installing Dependencies"

# Check and install Lua if not already installed
if ! command -v lua &>/dev/null; then
	brew install lua
else
	echo "Lua is already installed"
fi

# Check and install switchaudio-osx if not already installed
if ! command -v switchaudio-osx &>/dev/null; then
	brew install switchaudio-osx
else
	echo "switchaudio-osx is already installed"
fi

# Check and install nowplaying-cli if not already installed
if ! command -v nowplaying &>/dev/null; then
	brew install nowplaying-cli
else
	echo "nowplaying-cli is already installed"
fi

# Check and install sketchybar if not already installed
if ! command -v sketchybar &>/dev/null; then
	brew tap FelixKratz/formulae
	brew install sketchybar
else
	echo "sketchybar is already installed"
fi

# Check and install fonts if not already installed
if ! brew list --cask | grep -q 'sf-symbols'; then
	brew install --cask sf-symbols
else
	echo "sf-symbols font is already installed"
fi

if ! brew list --cask | grep -q 'font-sf-mono'; then
	brew install --cask font-sf-mono
else
	echo "font-sf-mono is already installed"
fi

if ! brew list --cask | grep -q 'font-sf-pro'; then
	brew install --cask font-sf-pro
else
	echo "font-sf-pro is already installed"
fi

curl -L https://github.com/kvndrsslr/sketchybar-app-font/releases/download/v2.0.28/sketchybar-app-font.ttf -o $HOME/Library/Fonts/sketchybar-app-font.ttf

# SbarLua
(git clone https://github.com/FelixKratz/SbarLua.git /tmp/SbarLua && cd /tmp/SbarLua/ && make install && rm -rf /tmp/SbarLua/)

brew services restart sketchybar
