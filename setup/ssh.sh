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
		eval "$(ssh-agent -s)"
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
	email = nmhungify@gmail.com
	name = Hung Nguyen

[github]
	user = hungify

[core]
	sshCommand = "ssh -i ~/.ssh/personal"

EOF
	fi

	if [[ -f ~/.ssh/config-personal ]]; then
		echo "Personal config already exists"
	else
		cat >~/.ssh/config-personal <<EOF
## For personal
Host github.com
    HostName github.com
    User git
    IdentitiesOnly yes
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/personal
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
	local workspace

	if [[ -f ~/.ssh/works ]]; then
		echo "Work SSH key already exists"
		read -p "Do you want to overwrite your SSH key? [y/n]: " is_overwrite
	fi

	if [[ $is_overwrite == "y" ]]; then
		read -p "Enter your workspace: " workspace
		read -p "Enter your work email: " email
		read -p "Enter your work name: " name

		if [[ $(ssh-add -l | grep -w $email) ]]; then
			echo $workspace " with SSH key already added: " $email
		else
			ssh-keygen -t ed25519 -C $email -f ~/.ssh/$workspace
			eval "$(ssh-agent -s)"
			ssh-add ~/.ssh/$workspace
			echo "Work SSH key added: " $email
		fi
	fi

	cat ~/.ssh/$workspace.pub

	if [[ -d ~/$workspace ]]; then
		echo $workspace " directory already exists"
	else
		mkdir ~/$workspace
	fi

	if [[ -f ~/work/.gitconfig-$workspace ]]; then
		echo $workspace " gitconfig already exists"
	else
		cat >~/$workspace/.gitconfig-$workspace <<EOF
[user]
	email = $email
	name = Hung Nguyen

[github]
	user = $name

[core]
	sshCommand = "ssh -i ~/.ssh/$workspace"
EOF
	fi


	if [[ -f ~~/.ssh/config-$workspace ]]; then
		echo "Personal config already exists"
	else
		cat >~/.ssh/config-$workspace <<EOF
## For $workspace
Host github.com
    HostName github.com
    User git
    IdentitiesOnly yes
    PreferredAuthentications publickey
    IdentityFile ~/.ssh/$workspace
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
