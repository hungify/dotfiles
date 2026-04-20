prepare:
	chmod u+x ./bin/dotfiles ./install.sh ./scripts/*.sh

doctor:
	./bin/dotfiles doctor

doctor-verbose:
	./bin/dotfiles doctor --verbose

list:
	./bin/dotfiles list $(if $(OS),--os $(OS),)

link:
	./bin/dotfiles link --force

bootstrap:
	./bin/dotfiles bootstrap --force
