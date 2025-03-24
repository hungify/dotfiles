#!/bin/bash

KEYBINDINGS=${HOME}/Library/KeyBindings
CONFIG=${HOME}/.config
SSH=${HOME}/.ssh

function unlink_files {
	echo "Unlinking old files ..."
	rm -rf ${HOME}/.gitconfig
	rm -rf ${SSH}/config
	rm -rf ${HOME}/.zsh
	rm -rf ${HOME}/.zshrc
	rm -rf ${HOME}/.zshenv
	rm -rf ${KEYBINDINGS}/DefaultKeyBinding.dict
	rm -rf ${HOME}/.gitconfig-personal
	rm -rf ${CONFIG}/sketchybar
	rm -rf ${CONFIG}/zed/settings.json
	rm -rf ${CONFIG}/zed/keymap.json
}

function link_files {
	echo "Linking new files ..."
	ln -s $(pwd)/../.gitconfig ${HOME}/
	ln -s $(pwd)/../.zshenv ${HOME}/
	ln -s $(pwd)/../.zshrc ${HOME}/
	ln -s $(pwd)/../.zsh ${HOME}/
	ln -s $(pwd)/../.gitconfig-personal ${HOME}/
	ln -s $(pwd)/../config ${SSH}/

	if [ ! -d ${CONFIG} ]; then
		mkdir ${CONFIG}
	fi
	ln -s $(pwd)/../.config/sketchybar ${CONFIG}/
	ln -s $(pwd)/../.config/zed/settings.json ${CONFIG}/zed/
	ln -s $(pwd)/../.config/zed/keymap.json ${CONFIG}/zed/
	brew services restart sketchybar

	if [ ! -d ${KEYBINDINGS} ]; then
		mkdir ${KEYBINDINGS}
	fi
	ln -s $(pwd)/DefaultKeyBinding.dict ${KEYBINDINGS}/
}

unlink_files

link_files
