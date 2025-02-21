#!/bin/bash

# Disable quarantine
sudo xattr -rd com.apple.quarantine /Applications/EVKey.app
sudo xattr -rd com.apple.quarantine /Applications/Mos.app
