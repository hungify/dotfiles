manjaro: remove
	ln -s "$(PWD)/.config/fish/config.fish" ${HOME}/.config/fish
	ln -s "$(PWD)/.config/fish/nvm.fish" ${HOME}/.config/fish/functions
	ln -s "$(PWD)/.fonts" ${HOME}/.fonts
	ln -s "$(PWD)/.gitconfig" ${HOME}/.gitconfig
	ln -s "$(PWD)/.bashrc" ${HOME}/.bashrc
	./scripts/manjaro.sh

feroda: remove
	ln -s "$(PWD)/.config/fish/config.fish" ${HOME}/.config/fish
	ln -s "$(PWD)/.config/fish/nvm.fish" ${HOME}/.config/fish/functions
	sudo sh -c 'ln -s "$(PWD)/.fonts/FiraCode" /usr/share/fonts/FiraCode'
	sudo sh -c 'ln -s "$(PWD)/.fonts/MonoLisa" /usr/share/fonts/MonoLisa'
	ln -s "$(PWD)/.gitconfig" ${HOME}/.gitconfig
	ln -s "$(PWD)/.bashrc" ${HOME}/.bashrc
	./scripts/feroda.sh

remove:
	-rm -rf ~/.config/fish/config.fish
	-rm -rf ~/.config/fish//functions/nvm.fish
	-rm -rf ~/.fonts
	-rm -rf ~/.gitconfig
	-rm -rf ~/.bashrc
	-sudo sh -c 'rm -rf /usr/share/fonts/MonoLisa'
	-sudo sh -c 'rm -rf /usr/share/fonts/FiraCode'
