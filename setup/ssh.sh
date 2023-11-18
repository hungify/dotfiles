#!/bin/bash

function setup_personal_git {

	read -p "Do you want to setup personal git? [y/n]: " is_setup_personal_git

	if [[ ! $is_setup_personal_git == "y" ]]; then
		return
	fi

	if [[ -f ~/.ssh/personal ]]; then
		echo "Personal SSH key already exists"
	else
		ssh-keygen -t ed25519 -C "nmhungify@gmail.com" -f ~/.ssh/personal
	fi

	if [[ $(ssh-add -l | grep -w "hungify@gmail.com") ]]; then
		echo "Personal SSH key already added"
	else
		eval $(ssh-agent -s)
		ssh-add ~/.ssh/personal
		echo "Personal SSH key added: nmhungify@gmail.com"
	fi

	cat ~/.ssh/personal.pub

	if [[ -d ~/personal ]]; then
		echo "Personal directory already exists"
	else
		mkdir ~/personal
	fi

	if [[ -f ~/.gitconfig-personal ]]; then
		echo "Personal gitconfig already exists"
	else
		cat >~/.gitconfig-personal <<EOF
[user]
	email = nmhungify@users.noreply.github.com
	name = Hung Nguyen

[github]
	user = hungify

[core]
	sshCommand = "ssh -i ~/.ssh/personal"

EOF
	fi
}

function setup_work_git {

	read -p "Do you want to setup work git? [y/n]: " is_setup_work_git

	if [[ ! $is_setup_work_git == "y" ]]; then
		return
	fi

	local email
	local name
	local is_overwrite="y"

	if [[ -f ~/.ssh/works ]]; then
		echo "Work SSH key already exists"
		read -p "Do you want to overwrite your SSH key? [y/n]: " is_overwrite
	fi

	if [[ $is_overwrite == "y" ]]; then
		read -p "Enter your work email: " email
		read -p "Enter your work name: " name

		if [[ $(ssh-add -l | grep -w $email) ]]; then
			echo "Work SSH key already added: " $email
		else
			ssh-keygen -t ed25519 -C $email -f ~/.ssh/work
			eval $(ssh-agent -s)
			ssh-add ~/.ssh/work
			echo "Work SSH key added: " $email
		fi
	fi

	cat ~/.ssh/work.pub

	if [[ -d ~/works ]]; then
		echo "Work directory already exists"
	else
		mkdir ~/work
	fi

	if [[ -f ~/work/.gitconfig-works ]]; then
		echo "Work gitconfig already exists"
	else
		cat >~/work/.gitconfig-work <<EOF
[user]
	email = $email
	name = Hung Nguyen

[github]
	user = $name

[core]
	sshCommand = "ssh -i ~/.ssh/work"
EOF
	fi
}

function chmod_files {
	echo "Chmoding files ..."
	chmod 600 ~/.ssh/*
}

chmod_files

setup_personal_git

setup_work_git
