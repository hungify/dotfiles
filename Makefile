default: remove
	ln -s "$(PWD)/.config/fish/config.fish" ${HOME}/.config/fish
	ln -s "$(PWD)/.fonts" ${HOME}/.fonts
	ln -s "$(PWD)/.gitconfig" ${HOME}/.gitconfig
	ln -s "$(PWD)/.bashrc" ${HOME}/.bashrc
	./scripts/manjaro.sh

remove:
	-rm ~/.config/fish/config.fish
	-rm ~/.fonts
	-rm ~/.gitconfig
	-rm ~/.bashrc