#!/bin/sh
OS_TYPE=$(uname)
if [ "$OS_TYPE" = Darwin ]; then
  # uninstall font
  rm ~/Library/Fonts/Sauce\ Code\ Pro*.ttf
elif [ "$OS_TYPE" = Linux ]; then
  # uninstall font
  rm ~/.local/share/fonts/Sauce\ Code\ Pro*.ttf
fi
. $OH_MY_NEOVIM/tools/custom.sh
if [ "$CURRENT_SHELL" = "fish" ]; then
  edit_pattern_in_shell_profile "set PATH $(ruby -e 'print Gem.user_dir')/bin \$PATH" ""
else
  edit_pattern_in_shell_profile "PATH=\"$(ruby -e 'print Gem.user_dir')/bin:\$PATH\"" ""
fi
