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

printf "${GREEN}Downloading .editorconfig gist file from github...${NORMAL}\n"
curl -s -O -L https://raw.githubusercontent.com/oh-my-neovim/workspace/master/.editorconfig

printf "${GREEN}Downloading .eslintrc gist file from github...${NORMAL}\n"
curl -s -O -L https://raw.githubusercontent.com/oh-my-neovim/workspace/master/plugins/react/.eslintrc.json

printf "${GREEN}Downloading .tern-project gist file from github...${NORMAL}\n"
curl -s -O -L https://raw.githubusercontent.com/oh-my-neovim/workspace/master/plugins/javascript/.tern-project

printf "${GREEN}Downloading .jsbeautifyrc gist file from github...${NORMAL}\n"
curl -s -O -L https://raw.githubusercontent.com/oh-my-neovim/workspace/master/plugins/javascript/.jsbeautifyrc

printf "${GREEN}Config files for react project created!${NORMAL}\n"