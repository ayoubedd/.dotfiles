#!/bin/zsh

REPO_URL=https://github.com/ayoubedd/.dotfiles
DOTFILES_DIR="$HOME/.dotfiles"
USER=$(whoami)
PACKAGES=(base-devel zsh rustup go stow gdb nasm ncdu lf alacritty vim git python python-pip tree tmux docker docker-compose downgrade zip unzip sway swaybg waybar wofi light zathura swayimg paru greetd grim wtype slurp swappy kanshi curl wget axel)

if [[ "$USER" == "root" ]]
then
    echo "[WARNING] Its not recommended to run this script as root."
    sleep 5
fi

echo '[INFO] Installing system packages.'
sudo pacman --needed -Syuu ${PACKAGES[@]} <<< Y

echo '[INFO] Cloning .dotfiles repo.'
if [ -d "$DOTFILES_DIR" ]
then
    cd "$DOTFILES_DIR"
    if [ ! -d "$DOTFILES_DIR/.git" ]
    then
      echo "[ERROR] existing \"$DOTFILES_DIR\" is not a repositry."
      exit 1
    fi
    git pull
else
    git clone --recurse-submodules "$REPO_URL" "$DOTFILES_DIR"
fi

if [ "$?" != "0" ]
then
    exit 1
fi

cd "$DOTFILES_DIR"

echo '[INFO] Stowing your config files.'
stow -vSt ~/ $(find . -maxdepth 1 -type d -not -path './.git' -not -path . | tr -d './')

echo '[INFO] Symlinking zsh config'
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

echo '[INFO] Insalling AUR packages.'
paru -S greetd-tuigreet <<< Y

echo '[INFO] Done.'
