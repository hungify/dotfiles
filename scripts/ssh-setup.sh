#!/usr/bin/env bash

set -euo pipefail

ensure_ssh_dir() {
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
}

write_file_if_missing() {
  local path="$1"
  local content="$2"

  if [[ -e "$path" ]]; then
    echo "Exists, leaving as-is: $path"
    return 0
  fi

  printf '%s\n' "$content" >"$path"
  chmod 600 "$path"
  echo "Created: $path"
}

setup_personal_git() {
  local key_path="$HOME/.ssh/personal"
  local email="nmhungify@gmail.com"
  local name="Hung Nguyen"
  local github_user="hungify"

  read -r -p "Set up personal Git identity? [y/N] " reply
  [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]] || return 0

  if [[ ! -f "$key_path" ]]; then
    ssh-keygen -t ed25519 -C "$email" -f "$key_path"
  fi

  eval "$(ssh-agent -s)"
  ssh-add "$key_path" || true

  cat "$key_path.pub"
  mkdir -p "$HOME/personal"

  write_file_if_missing "$HOME/.gitconfig-personal" "[user]
	email = $email
	name = $name

[github]
	user = $github_user

[core]
	sshCommand = ssh -i $key_path"
}

setup_work_git() {
  local workspace email name key_path host_alias gitconfig_path sshconfig_path

  read -r -p "Set up work Git identity? [y/N] " reply
  [[ "$reply" =~ ^[Yy]([Ee][Ss])?$ ]] || return 0

  read -r -p "Workspace directory name (example: workspaces): " workspace
  read -r -p "SSH host alias (example: github-work): " host_alias
  read -r -p "Work email: " email
  read -r -p "Work name: " name

  mkdir -p "$HOME/$workspace"

  key_path="$HOME/.ssh/$host_alias"
  gitconfig_path="$HOME/$workspace/.gitconfig-$host_alias"
  sshconfig_path="$HOME/.ssh/config-$host_alias"

  if [[ ! -f "$key_path" ]]; then
    ssh-keygen -t ed25519 -C "$email" -f "$key_path"
  fi

  eval "$(ssh-agent -s)"
  ssh-add "$key_path" || true

  cat "$key_path.pub"

  write_file_if_missing "$gitconfig_path" "[user]
	email = $email
	name = $name

[github]
	user = $name

[core]
	sshCommand = ssh -i $key_path"

  write_file_if_missing "$sshconfig_path" "Host $host_alias
    HostName github.com
    User git
    IdentitiesOnly yes
    PreferredAuthentications publickey
    IdentityFile $key_path"
}

ensure_ssh_dir
setup_personal_git
setup_work_git
