#!/usr/bin/env bash

# helpers
function echo_ok() { echo -e '\033[1;32m'"$1"'\033[0m'; }
function echo_warn() { echo -e '\033[1;33m'"$1"'\033[0m'; }
function echo_error() { echo -e '\033[1;31mERROR: '"$1"'\033[0m'; }

echo_ok "Install starting. You may be asked for your password (for sudo)."

# requires xcode and tools!
xcode-select -p || exit "XCode must be installed! (use the app store)"

# homebrew
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
if hash brew &>/dev/null; then
  echo_ok "Homebrew already installed. Getting updates..."
  brew update
  brew doctor
else
  echo_warn "Installing homebrew..."
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update homebrew recipes
brew update

# Install Mac Application Store CLI
brew install mas

# make sure we're using Bash 4 first
brew install bash

# Install from Brewfile
echo_ok "Installing brews and casks..."
brew bundle

echo_ok "Cleaning up..."
brew cleanup

echo_ok "Installing Python packages..."

PIP="pip3 install --user --no-cache-dir --default-timeout=6000"

setup_python() {
  if [ -f "$HOME/.setup_python" ]; then
    printf '\n'
    printf "########################################################\n"
    printf ".setup_python found, skipping\n"
  else
    printf '\n'
    printf "########################################################\n"
    printf ".setup_python not found, setting up python\n"
    # install one giant cacert for python3
    wget https://curl.se/ca/cacert.pem -O /tmp/cacert.pem
    openssl x509 -outform der -in /tmp/cacert.pem -out /tmp/cacert.crt
    sudo cp -R /tmp/cacert.crt /usr/local/share/ca-certificates/
    sudo update-ca-certificates
    # Remove python 2.7 and related links and replace with python 3.x
    sudo rm -f /usr/bin/python2* /usr/bin/python
    sudo ln -s /usr/bin/python3 /usr/bin/python
    # Use pip3 as well
    sudo rm -f /usr/bin/pip
    sudo ln -s /usr/bin/pip3 /usr/bin/pip
    # Install base python packages that will be used later in this script
    $PIP wheel
    $PIP --upgrade requests
    $PIP setuptools
    $PIP pipenv
    $PIP wheel
    touch $HOME/.setup_python
  fi
}
setup_python

PYTHON_PACKAGES=(
  ipython
  virtualenv
  virtualenvwrapper
  wheel
)

sudo $PIP "${PYTHON_PACKAGES[@]}"

echo_ok "Installing oh my zsh..."

if [[ ! -f ~/.zshrc ]]; then
  echo ''
  echo '##### Installing oh-my-zsh...'
  curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
  cp ~/.zshrc ~/.zshrc.orig
  cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
  chsh -s /bin/zsh
fi

echo_ok "Configuring ssh and git"

if [[ ! -f ~/.ssh/id_rsa ]]; then
  echo ''
  echo '##### Please enter your git username: '
  read git_username
  echo '##### Please enter your git email address: '
  read git_email
  echo '##### Please enter your favorite editor(vim, atom, or vscode(type code)): '
  read editor

  # setup git
  if [[ $git_username && $git_email && $editor ]]; then
    # setup config
    git config --global user.name "$git_username"
    git config --global user.email "$git_email"
    git config --global github.user "$github_user"
    #git config --global github.token your_token_here
    git config --global color.ui true
    git config --global push.default current
    # VS Code support
    git config --global core.editor "$editor --wait"

    # specify a global exclusion list
    git config --global core.excludesfile $HOME/.gitignore
    # add .DS_Store to that list
    echo .DS_Store >> $HOME/.gitignore

    # Not using github
    # set rsa key
    # git osxkeychain helper should be installed with brewfile using command above 'brew bundle' runs a brew install git
    # https://docs.github.com/en/github/getting-started-with-github/getting-started-with-git/caching-your-github-credentials-in-git
    git config --global credential.helper osxkeychain

    # generate ssh key
    cd $HOME/.ssh || exit
    ssh-keygen -o -a 100 -t ed25519 -f $HOME/.ssh/id_ed25519 -C "$git_email"
    pbcopy <$HOME/.ssh/id_ed25519.pub
    echo ''
    echo '##### The following ed25519 key has been copied to your clipboard: '
    cat $HOME/.ssh/id_ed25519.pub
    ssh -T git@github.com
  fi
fi

echo_ok "Installing VS Code Extensions..."

VSCODE_EXTENSIONS=(
  AlanWalk.markdown-toc
  CoenraadS.bracket-pair-colorizer
  DavidAnson.vscode-markdownlint
  DotJoshJohnson.xml
  EditorConfig.EditorConfig
  Equinusocio.vsc-material-theme
  HookyQR.beautify
  James-Yu.latex-workshop
  PKief.material-icon-theme
  PeterJausovec.vscode-docker
  Shan.code-settings-sync
  Zignd.html-css-class-completion
  akamud.vscode-theme-onedark
  akmittal.hugofy
  anseki.vscode-color
  arcticicestudio.nord-visual-studio-code
  aws-scripting-guy.cform
  bungcip.better-toml
  christian-kohler.npm-intellisense
  christian-kohler.path-intellisense
  codezombiech.gitignore
  dansilver.typewriter
  dbaeumer.jshint
  donjayamanne.githistory
  dracula-theme.theme-dracula
  eamodio.gitlens
  eg2.vscode-npm-script
  ipedrazas.kubernetes-snippets
  loganarnett.lambda-snippets
  lukehoban.Go
  mohsen1.prettify-json
  monokai.theme-monokai-pro-vscode
  ms-python.python
  ms-vscode.azure-account
  msjsdiag.debugger-for-chrome
  robertohuertasm.vscode-icons
  robinbentley.sass-indented
  waderyan.gitblame
  whizkydee.material-palenight-theme
  whtsky.agila-theme
  zhuangtongfa.Material-theme
  foxundermoon.shell-format
  timonwong.shellcheck
)

if hash code &>/dev/null; then
  echo_ok "Installing VS Code extensions..."
  for i in "${VSCODE_EXTENSIONS[@]}"; do
    code --install-extension "$i"
  done
fi

# Install flutter (still need to test)
# git clone https://github.com/flutter/flutter.git ~/Downloads/flutter
# sudo mv ~/Downloads/flutter /usr/local/Cellar/
# sudo ln -s /usr/local/bin/Cellar/flutter/bin/flutter /usr/local/bin/flutter
# flutter precache
# flutter doctor
# export PATH="$PATH:/usr/local/bin/flutter"

# install sdkman
curl -s "https://get.sdkman.io" | bash

echo_ok "Configuring OSX..."

# Set fast key repeat rate
# The step values that correspond to the sliders on the GUI are as follow (lower equals faster):
# KeyRepeat: 120, 90, 60, 30, 12, 6, 2
# InitialKeyRepeat: 120, 94, 68, 35, 25, 15
defaults write NSGlobalDomain KeyRepeat -int 6
defaults write NSGlobalDomain InitialKeyRepeat -int 25

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Require password as soon as screensaver or sleep mode starts
# defaults write com.apple.screensaver askForPassword -int 1
# defaults write com.apple.screensaver askForPasswordDelay -int 0

# Show filename extensions by default
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Expanded Save menu
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

# Expanded Print menu
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# Enable tap-to-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Disable "natural" scroll
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo_ok 'Running OSX Software Updates...'
sudo softwareupdate -i -a

echo_ok "Creating folder structure..."
[[ ! -d $HOME/docs ]] && mkdir $HOME/docs
[[ ! -d $HOME/code ]] && mkdir $HOME/code

echo_ok "Bootstrapping complete"

# LINKS
# https://medium.com/@yutafujii_59175/a-complete-one-by-one-guide-to-install-docker-on-your-mac-os-using-homebrew-e818eb4cfc3
# https://www.atlassian.com/git/tutorials/setting-up-a-repository/git-config
