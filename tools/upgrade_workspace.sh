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

printf "${BLUE}Looking for an existing vim config...${NORMAL}\n"
if [ -f ~/.vimrc ] || [ -h ~/.vimrc ]; then
  printf "${YELLOW}Found ~/.vimrc. ${GREEN}Backing up to ~/.vimrc.pre-upgrade${NORMAL}\n"
  mv -f ~/.vimrc ~/.vimrc.pre-upgrade
fi

printf "${BLUE}Looking for plug.vim file...${NORMAL}\n"
if [ ! -f ~/.vim/autoload/plug.vim ]; then
  printf "${YELLOW}plug.vim not found...${NORMAL} ${GREEN}Downloading it from github...${NORMAL}\n"
  curl -sfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

printf "${BLUE}Downloading .vimrc gist file from github...${NORMAL}\n"
curl -sfLo ~/.vimrc https://raw.githubusercontent.com/yacut/workspace/master/.vimrc
printf "${GREEN}Vim config upgraded!${NORMAL}\n"

printf "${BLUE}Checking neovim links${NORMAL}\n"
if [ ! -d ~/.config/nvim ] || [ ! -h ~/.config/nvim ]; then
  printf "${GREEN}Creating ~/.config/nvim link.${NORMAL}\n"
  ln -s ~/.vim ~/.config/nvim
fi
if [ ! -f ~/.config/nvim/init.vim ] || [ ! -h ~/.config/nvim/init.vim ]; then
  printf "${GREEN}Creating ~/.config/nvim/init.vim link.${NORMAL}\n"
  ln -s ~/.vimrc ~/.config/nvim/init.vim
fi

OS_TYPE=$(uname)
if [ "$OS_TYPE" = Darwin ]; then
  if [ ! -f ~/Library/Fonts/Sauce\ Code\ Pro\ Nerd\ Font\ Complete.ttf ]; then
    printf "${BLUE}Downloading Sauce Code Pro Nerd Fonts to ~/Library/Fonts folder...${NORMAL}\n"
    cd ~/Library/Fonts && \
      curl -sfLo "SourceCodePro.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v1.0.0/SourceCodePro.zip && \
      unzip -o SourceCodePro.zip && rm SourceCodePro.zip
  fi

  printf "${BLUE}Installing dependencies with brew...${NORMAL}\n"
  brew install node yarn editorconfig the_silver_searcher libxml2 python python3 ruby zsh
fi

if [ "$OS_TYPE" = Linux ]; then
  if [ ! -f ~/.local/share/fonts/Sauce\ Code\ Pro\ Nerd\ Font\ Complete.ttf ]; then
    printf "${BLUE}Downloading Sauce Code Pro Nerd Fonts to ~/.local/share/fonts folder...${NORMAL}\n"
    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts && \
      curl -sfLo "SourceCodePro.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v1.0.0/SourceCodePro.zip && \
      unzip -o SourceCodePro.zip && rm SourceCodePro.zip
  fi

  if [ -f /etc/debian_version ]; then
      printf "${BLUE}Installing dependencies with apt - ${RED}sudo privileges are required...${NORMAL}\n"
      if [ ! -f /etc/apt/sources.list.d/nodesource.list ]; then
        curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash
      fi
      if [ ! -f /etc/apt/sources.list.d/yarn.list ]; then
        curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
        echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
      fi
      sudo apt-get install -y -q nodejs yarn editorconfig silversearcher-ag libxml2-utils python python3 python-pip xsel ruby ruby-dev build-essential libssl-dev libffi-dev python-dev zsh
  elif [ -f /etc/redhat-release ]; then
      printf "${BLUE}Installing dependencies with yum - ${RED}sudo privileges are required...${NORMAL}\n"
      curl --silent --location https://rpm.nodesource.com/setup_6.x | bash -
      sudo wget https://dl.yarnpkg.com/rpm/yarn.repo -O /etc/yum.repos.d/yarn.repo
      sudo yum -y install nodejs yarn the_silver_searcher python-pip ruby ruby-devel gcc libffi-devel python-devel openssl-devel zsh
  fi
fi

printf "${BLUE}Setting Zsh plugins, theme and PATH...${NORMAL}\n"
if [ "$OS_TYPE" = Darwin ]; then
  sed -i "" "s/ZSH_THEME=\".*/ZSH_THEME=\"agnoster\"/g" ~/.zshrc
  sed -i "" "s/plugins=(.*/plugins=(git node npm yarn gulp docker docker-compose kubectl pip gem brew debian)/g" ~/.zshrc
else
  sed -i "s/ZSH_THEME=\".*/ZSH_THEME=\"agnoster\"/g" ~/.zshrc
  sed -i "s/plugins=(.*/plugins=(git node npm yarn gulp docker docker-compose kubectl pip gem brew debian)/g" ~/.zshrc
fi
grep -q "PATH=\"$(ruby -e 'print Gem.user_dir')/bin:\$PATH\"" ~/.zshrc || echo "PATH=\"$(ruby -e 'print Gem.user_dir')/bin:\$PATH\"" >> ~/.zshrc

printf "${BLUE}Updating global npm packages with yarn...${NORMAL}\n"
mkdir -p ~/.yarn-global
yarn config set prefix ~/.yarn-global
npm config set prefix ~/.yarn-global
grep -q "PATH=\"$HOME/.yarn-global/bin:\$PATH\"" ~/.zshrc || echo "PATH=\"$HOME/.yarn-global/bin:\$PATH\"" >> ~/.zshrc
yarn global upgrade tern eslint jsonlint babel-eslint eslint-plugin-react --global-folder ~/.yarn-global

PATH="$HOME/.yarn-global/bin:$(ruby -e 'print Gem.user_dir')/bin:$PATH"

printf "${BLUE}Upgrading lint tools with pip...${NORMAL}\n"
pip install --quiet --user --upgrade yamllint ansible-lint

printf "${BLUE}Updating neovim providers...${NORMAL}\n"
pip2 install --quiet --user --upgrade neovim
pip3 install --quiet --user --upgrade neovim
gem install --user-install neovim

hash nvim >/dev/null 2>&1 || {
  echo "\n${RED}Error: neovim is not installed${NORMAL}\n"
  echo "${BLUE}https://github.com/neovim/neovim/wiki/Installing-Neovim${NORMAL}"
  exit 1
}
printf "${BLUE}Set nvim as default editor${NORMAL}\n"
grep -q "export EDITOR='nvim'" ~/.zshrc || echo "export EDITOR='nvim'" >> ~/.zshrc
printf "${BLUE}Updating plugins...${NORMAL}\n"
nvim -c ":PlugUpdate" -c ":qa!" --headless
nvim -c ":UpdateRemotePlugins" -c ":qa!" --headless
printf "\n${GREEN}Vim plugins updated!${NORMAL}\n"

hash zsh >/dev/null 2>&1 || {
  echo "\n${RED}Error: zsh is not installed${NORMAL}"
  exit 1
}
env zsh