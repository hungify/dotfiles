#!/bin/bash

# Disable quarantine
sudo xattr -rd com.apple.quarantine /Applications/CleanShot\ X.app
sudo xattr -rd com.apple.quarantine /Applications/Paste.app
sudo xattr -rd com.apple.quarantine /Applications/EVKey.app
sudo xattr -rd com.apple.quarantine /Applications/Mos.app
