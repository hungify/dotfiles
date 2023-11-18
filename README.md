# dotfiles

Before doing anything, make sure you know what you are doing! The settings applied by this repository are very personal and definitely not for everyone. I suggest creating your own set of dotfiles based on this repository.

1. Install brew and stuff and follow the post-installection instructions.

```bash
 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2.Clone this repo to the hidden `.dotfile` directory in your home directory (git comes with brew).

```bash
git clone https://github.com/hungify/dotfiles ~/dotfiles
```

3.Install app and stuff.

```bash
cd ~/dotfiles/setup
./app.sh
```

4.SSH setup

```bash
cd ~/dotfiles/setup
./ssh.sh
```

5.Setup macOS.

```bash
./os.sh
```

6.Setup symlinks.

```bash
./symlink.sh
```
