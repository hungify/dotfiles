#!/bin/bash

# Function to setup personal git
function setup_personal_git {
    read -p "Do you want to set up personal git? [y/n]: " is_setup_personal_git

    if [[ $is_setup_personal_git != "y" ]]; then
        return
    fi

    local personal_key_path="$HOME/.ssh/personal"
    local ssh_config_path="$HOME/.ssh/config-personal"
    local git_config_path="$HOME/.gitconfig-personal"
    local email="nmhungify@gmail.com"
    local name="Hung Nguyen"
    local github_user="hungify"

    if [[ ! -f $personal_key_path ]]; then
        ssh-keygen -t ed25519 -C "$email" -f $personal_key_path || { echo "Failed to generate personal SSH key"; return 1; }
    fi

    if ! ssh-add -l | grep -q "$email"; then
        eval "$(ssh-agent -s)"
        ssh-add $personal_key_path || { echo "Failed to add personal SSH key"; return 1; }
        echo "Personal SSH key added: $email"
    else
        echo "Personal SSH key already added"
    fi

    cat "$personal_key_path.pub"

    mkdir -p "$HOME/personal"

    if [[ ! -f $git_config_path ]]; then
        cat > "$git_config_path" <<EOF
[user]
    email = $email
    name = $name

[github]
    user = $github_user

[core]
    sshCommand = "ssh -i $personal_key_path"
EOF
        echo "Personal gitconfig created"
    else
        echo "Personal gitconfig already exists"
    fi

    if [[ ! -f $ssh_config_path ]]; then
        cat > "$ssh_config_path" <<EOF
## For personal
Host github.com
    HostName github.com
    User git
    IdentitiesOnly yes
    PreferredAuthentications publickey
    IdentityFile $personal_key_path
EOF
        echo "Personal SSH config created"
    else
        echo "Personal SSH config already exists"
    fi
}

# Function to setup work git
function setup_work_git {
    read -p "Do you want to setup work git? [y/n]: " is_setup_work_git

    if [[ $is_setup_work_git != "y" ]]; then
        return
    fi

    local workspace
    local email
    local name

    read -p "Enter your workspace: " workspace

    local work_key_path="$HOME/.ssh/$workspace"
    local ssh_config_path="$HOME/.ssh/config-$workspace"
    local git_config_path="$HOME/$workspace/.gitconfig-$workspace"

    if [[ -f $work_key_path ]]; then
        read -p "Work SSH key already exists. Do you want to overwrite it? [y/n]: " is_overwrite
        [[ $is_overwrite != "y" ]] && return
    fi

    read -p "Enter your work email: " email
    read -p "Enter your work name: " name

    if ! ssh-add -l | grep -q "$email"; then
        ssh-keygen -t ed25519 -C "$email" -f $work_key_path || { echo "Failed to generate work SSH key"; return 1; }
        eval "$(ssh-agent -s)"
        ssh-add $work_key_path || { echo "Failed to add work SSH key"; return 1; }
        echo "Work SSH key added: $email"
    else
        echo "$workspace with SSH key already added: $email"
    fi

    cat "$work_key_path.pub"

    mkdir -p "$HOME/$workspace"

    if [[ ! -f $git_config_path ]]; then
        cat > "$git_config_path" <<EOF
[user]
    email = $email
    name = $name

[github]
    user = $name

[core]
    sshCommand = "ssh -i $work_key_path"
EOF
        echo "$workspace gitconfig created"
    else
        echo "$workspace gitconfig already exists"
    fi

    if [[ ! -f $ssh_config_path ]]; then
        cat > "$ssh_config_path" <<EOF
## For $workspace
Host $workspace
    HostName github.com
    User git
    IdentitiesOnly yes
    PreferredAuthentications publickey
    IdentityFile $work_key_path
EOF
        echo "SSH config for $workspace created"
    else
        echo "SSH config for $workspace already exists"
    fi
}

function chmod_files {
    echo "Changing file permissions ..."
    chmod 600 "$HOME/.ssh"/* || { echo "Failed to change file permissions"; return 1; }
}

function check_if_shh_exists {
    if [[ ! -d "$HOME/.ssh" ]]; then
        echo "SSH directory does not exist. Creating ..."
        mkdir "$HOME/.ssh" || { echo "Failed to create SSH directory"; return 1; }
    fi
}

function ping_github {
    ssh -T git@github.com
}

check_if_shh_exists || exit 1
chmod_files || exit 1
setup_personal_git || exit 1
setup_work_git || exit 1
ping_github
