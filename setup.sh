#!/bin/zsh

set -e

REPO_URL=https://github.com/ayoubedd/.dotfiles
DOTFILES_DIR="$HOME/.dotfiles"
USER=$(whoami)

# Some directories to created
DIRS=(
  Pictures/{Screenshots,Personal} \
  Videos/{Recordings,Movies} \
  Code/{ayoub})

# A list of packges to be installed
PACKAGES=(base-devel zsh rustup go bat \
  stow gdb nasm lf alacritty vim exa \
  git python python-pip tree tmux docker btop \
  docker-compose downgrade zip unzip sway playerctl \
  paru greetd greetd-tuigreet grim wtype slurp glow \
  kanshi curl wget axel wl-clipboard swayidle git-delta \
  mako papirus-icon-theme blueman spotifyd \
  swaybg waybar wofi brightnessctl zathura zathura-pdf-mupdf \
  swayimg noto-fonts noto-fonts-emoji otf-font-awesome \
  papirus-icon-theme ttf-roboto cliphist xdg-user-dirs \
  xdg-desktop-portal xdg-desktop-portal-wlr procps-ng)

AUR_PACKAGES=(catppuccin-cursors-mocha wl-color-picker \
  catppuccin-gtk-theme-mocha neovim-git swaylock-effects-git \
  wofi-emoji-git battop spotify-tui)

if [[ "$USER" == "root" ]]
then
    echo "[WARNING] Its not recommended to run this script as root."
    sleep 5
fi

echo '[INFO] Performing system update.'
sudo pacman --needed -Syyu

echo '[INFO] Installing system packages.'
sudo pacman --needed -S ${PACKAGES[@]}

echo '[INFO] Installing rust toolchain'
rustup default stable

echo '[INFO] Insalling AUR packages.'
paru --needed -S ${AUR_PACKAGES[@]}

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

cd "$DOTFILES_DIR"

echo '[INFO] Stowing your config files.'
stow -vSt ~/ $(find . -maxdepth 1 -type d -not -path './.git' -not -path . | tr -d './')

echo '[INFO] Creating Home directories.'
xdg-user-dirs-update
for dir in ${DIRS[@]}
do
  echo "[INFO] Creating => \"~/$dir/\""
  mkdir -p "$HOME/$dir/"
done

echo '[INFO] Installing volta and nodejs.'
curl https://get.volta.sh | bash
volta install node

echo '[INFO] Installing tmux plugin manager'
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo '[INFO] Done.'
