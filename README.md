# dotfiles

Before doing anything, make sure you know what you are doing! The settings applied by this repository are very personal and definitely not for everyone. I suggest creating your own set of dotfiles based on this repository.

1.Clone this repo to the hidden `.dotfile` directory in your home directory (git comes with brew).

```bash
git clone https://github.com/hungify/dotfiles ~/dotfiles
```

2.Install app and stuff.

```bash
cd ~/dotfiles/setup
./app.sh
```

3.SSH setup

```bash
cd ~/dotfiles/setup
./ssh.sh
```

4.Setup macOS settings.

```bash
./os.sh
```

5.Setup symlinks for dotfiles.

```bash
./symlink.sh
```
