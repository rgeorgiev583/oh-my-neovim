#!/bin/sh
# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
    ncolors=$(tput colors)
fi
if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi

# Only enable exit-on-error after the non-critical colorization stuff,
# which may fail on systems lacking tput or terminfo
set -e

CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
FISH_ENVFILE=~/.config/fish/conf.d/_environment.fish

add_to_shell_profile_if_pattern_not_found () {
  if [ "$CURRENT_SHELL" = "zsh" ]; then
    grep -q "$1" ~/.zshrc || echo "\n$2" >> ~/.zshrc
  elif [ "$CURRENT_SHELL" = "bash" ]; then
    if [ "$(uname)" = Darwin ]; then
      grep -q "$1" ~/.bash_profile || echo "\n$2" >> ~/.bash_profile
    else
      grep -q "$1" ~/.bashrc || echo "\n$2" >> ~/.bashrc
    fi
  elif [ "$CURRENT_SHELL" = "fish" ]; then
    grep -q "$1" "$FISH_ENVFILE" || echo "\n$2" >> "$FISH_ENVFILE"
  else
    grep -q "$1" ~/.profile || echo "\n$2" >> ~/.profile
  fi
}

edit_pattern_in_shell_profile () {
if [ "$(uname)" = Darwin ]; then
  if [ "$CURRENT_SHELL" = "zsh" ]; then
    sed -i "" "s/$1/$2/g" ~/.zshrc
  elif [ "$CURRENT_SHELL" = "bash" ]; then
    sed -i "" "s/$1/$2/g" ~/.bash_profile
  elif [ "$CURRENT_SHELL" = "fish" ]; then
    sed -i "" "s/$1/$2/g" "$FISH_ENVFILE"
  else
    sed -i "" "s/$1/$2/g" ~/.profile
  fi
else
  if [ "$CURRENT_SHELL" = "zsh" ]; then
    sed -i "s/$1/$2/g" ~/.zshrc
  elif [ "$CURRENT_SHELL" = "bash" ]; then
    sed -i "s/$1/$2/g" ~/.bashrc
  elif [ "$CURRENT_SHELL" = "fish" ]; then
    sed -i "s/$1/$2/g" "$FISH_ENVFILE"
  else
    sed -i "s/$1/$2/g" ~/.profile
  fi
fi
}

select_extensions_dialog () {
  if [ "$(uname)" = Darwin ] && hash brew 2>/dev/null && ! hash whiptail 2>/dev/null; then
    brew install newt
  fi

  if hash whiptail 2>/dev/null; then
    dialog_tool=whiptail
  elif hash dialog 2>/dev/null; then
    dialog_tool=dialog
  else
    dialog_tool=
  fi
  if [ ! -n "$dialog_tool" ]; then
    OH_MY_NEOVIM_EXTENSIONS="default"
  else
    AVAILABLE_EXTENSIONS=$( find $OH_MY_NEOVIM/extensions/* -maxdepth 1 -not -path '*default*' -type d -exec basename {} \; -exec echo {} \; -exec sh -c 'ext=$(basename $0);if echo $OH_MY_NEOVIM_EXTENSIONS | grep -q "$ext"; then echo ON; else echo OFF; fi' {} \;)
    CHOOSED_EXTENSIONS=$($dialog_tool --checklist "Choose extensions to install" 28 80 20 ${AVAILABLE_EXTENSIONS} 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
      OH_MY_NEOVIM_EXTENSIONS=$(echo "$CHOOSED_EXTENSIONS"| tr -d '"')
      OH_MY_NEOVIM_EXTENSIONS="default $OH_MY_NEOVIM_EXTENSIONS"
    else
      OH_MY_NEOVIM_EXTENSIONS="default"
    fi
  fi
}

print_logo () {
  printf "${GREEN}"
  echo '   ____  __       __  ___         _   __                _         '
  echo '  / __ \/ /_     /  |/  /_  __   / | / /__  ____ _   __(_)___ ___ '
  echo ' / / / / __ \   / /|_/ / / / /  /  |/ / _ \/ __ \ | / / / __ `__ \'
  echo '/ /_/ / / / /  / /  / / /_/ /  / /|  /  __/ /_/ / |/ / / / / / / /'
  echo '\____/_/ /_/  /_/  /_/\__, /  /_/ |_/\___/\____/|___/_/_/ /_/ /_/ '
  echo '                     /____/                                       '
  echo ''
  printf "${NORMAL}"
}
