#!/bin/bash

# APT mirror change
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak

CONFIG_FILE="/etc/apt/sources.list"

ARCHITECTURE=$(uname -m)

case "$ARCHITECTURE" in 
  x86_64)
    MIRROR_SITE="https://ftp.udx.icscoe.jp/Linux"
    ;;
  aarch64)
    MIRROR_SITE="https://ftp.lanet.kr"
    ;;
esac

if [ -f "$CONFIG_FILE" ]; then
  sudo sed -i "s|http://archive.ubuntu.com|$MIRROR_SITE|g; s|http://kr.archive.ubuntu.com|$MIRROR_SITE|g; s|http://security.ubuntu.com|$MIRROR_SITE|g; s|http://ports.ubuntu.com|$MIRROR_SITE|g" /etc/apt/sources.list
fi


# Clean snap
snap remove gtk-common-themes
snap remove bare
snap remove gnome-42-2204
snap remove firefox
snap remove snap-store
snap remove snapd-desktop-integration
snap remove core22
snap remove snapd

sudo systemctl stop snapd.socket
sudo systemctl stop snapd.service

sudo apt purge *snapd*
sudo apt autoremove --purge
sudo apt autoclean

sudo rm -rf /run/udev/tags/snap_snap-store_snap-store \
	    /run/udev/tags/snap_firefox_geckodriver \
	    /run/udev/tags/snap_snapd-desktop-integration_snapd-desktop-integration \
	    /run/udev/tags/snap_snap-store_ubuntu-software-local-file \
	    /run/udev/tags/snap_snap-store_ubuntu-software \
	    /run/udev/tags/snap_firefox_firefox \
	    /run/user/1000/systemd/generator.late/xdg-desktop-autostart.target.wants/app-snap\\x2duserd\\x2dautostart@autostart.service \
	    /run/user/1000/systemd/generator.late/app-snap\\x2duserd\\x2dautostart@autostart.service \
	    /run/user/1000/snapd-session-agent.socket \
	    /run/user/1000/doc/by-app/snap.snapd-desktop \
	    /run/snapd.socket \
	    /run/snapd-snap.socket \
	    /run/snapd \
	    /root/snap \
	    /var/cache/apt/archives/snapd_2.66.1+22.04_amd64.deb \
	    /var/lib/gdm3/snap \
	    /var/lib/systemd/deb-systemd-helper-enabled/multi-user.target.wants/snapd.aa-prompt-listener.service \
	    /var/lib/systemd/deb-systemd-helper-enabled/snapd.aa-prompt-listener.service.dsh-also \
	    /var/lib/dpkg/info/gir1.2-snapd-1:amd64.list \
	    /var/lib/dpkg/info/libsnapd-glib1:amd64.triggers \
	    /var/lib/dpkg/info/libsnapd-glib1:amd64.md5sums \
	    /var/lib/dpkg/info/libsnapd-glib1:amd64.shlibs \
	    /var/lib/dpkg/info/libsnapd-glib1:amd64.list \
	    /var/lib/dpkg/info/gir1.2-snapd-1:amd64.md5sums \
	    /var/lib/dpkg/info/libsnapd-glib1:amd64.symbols \
	    /sys/fs/bpf/snap \
	    /tmp/snap-private-tmp \
	    /etc/systemd/system/multi-user.target.wants/snapd.aa-prompt-listener.service \
	    /etc/apparmor.d/abstractions/snap_browsers \
	    $HOME/snap


# Clean junk
sudo apt purge *thunderbird* \
	       *libreoffice* \
	       transmission* \
	       rhythmbox* \
	       aisleriot \
	       shotwell \
	       simple-scan \
	       gnome-calculator \
	       gnome-mahjongg \
	       gnome-mines \
	       gnome-sudoku \
	       gnome-todo
sudo apt autoremove --purge
sudo apt autoclean


# Develop setting
sudo add-apt-repository ppa:longsleep/golang-backports
sudo add-apt-repository ppa:daniel-milde/gdu
sudo apt update
sudo apt install zsh \
		 build-essential \
		 make \
		 cmake \
		 gcc-12 \
		 g++-12 \
		 ccache \
		 libncurses-dev \
		 libssl-dev \
		 flex \
		 libelf-dev \
		 bison \
		 libtool \
		 autoconf \
		 automake \
		 pkg-config \
		 rt-tests \
		 doxygen \
		 gettext \
		 libxcb1-dev \
		 libxcb-render0-dev \
		 libxcb-shape0-dev \
		 libxcb-xfixes0-dev \
		 ninja-build \
		 meson \
		 curl \
		 wget \
		 7zip \
		 jq \
		 poppler-utils \
		 iamgemagick \
		 git \
		 git-lfs \
		 openssh-server \
		 net-tools \
		 btop \
		 duf \
		 gdu \
		 python3 \
		 python3-dev \
		 python3-pip \
		 python3-venv \
		 golang-go \
		 default-jdk \
		 luarocks \
		 gnome-control-center


# gcc version change
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 200

sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 200


# Use ccache
sudo sed -i 's|^PATH="|PATH="/usr/lib/ccache:|' /etc/environment


# zsh check
if command -v zsh &> /dev/null
then
  # oh my zsh
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Fail. script exit"
  exit 1
fi


# PATH
if ! grep -q 'export PATH=$HOME/.go/bin:$HOME/.local/bin:$PATH' "$HOME/.zshrc"; then
  sed -i '11i\export PATH=$HOME/.go/bin:$HOME/.loacl/bin:$PATH\n' $HOME/.zshrc
else
  echo "'export PATH=$HOME/.go/bin/bin:$HOME/.local/bin:$PATH' already exists in $HOME/.zshrc"
fi


# powerlevel10k
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's|robbyrussell|powerlevel10k/powerlevel10k|g' $HOME/.zshrc


# zsh plugins
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone https://github.com/hlissner/zsh-autopair ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autopair
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

if ! grep -q 'fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' "$HOME/.zshrc"; then
  sed -i '13i\fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src\n' $HOME/.zshrc
else
  echo "'fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src' already exists in $HOME/.zshrc"
fi

if ! grep -q 'plugins=(git zsh-autosuggestions zsh-autopair fast-syntax-highlighting zsh-history-substring-search)' "$HOME/.zshrc"; then
  sed -i "s/git/git zsh-autosuggestions zsh-autopair fast-syntax-highlighting zsh-history-substring-search/g" $HOME/.zshrc
else
  echo "'plugins=(git zsh-autosuggestions zsh-autopair fast-syntax-highlighting zsh-history-substring-search)' already exists in $HOME/.zshrc"
fi


# rustup 
if ! command -v rustup &> /dev/null; then
  echo "Installation rustup"
  curl https://sh.rustup.rs -sSf | sh
  echo "Installation is complete"

  if ! command -v rustup &> /dev/null; then
    . "$HOME/.cargo/env"

    echo "rustup version check"
    rustup --version

    echo "cargo version check"
    cargo --version
  
    echo "rustup update"
    rustup update stable
  
    zfunc_dir="$HOME/.zfunc"

    if [ ! -d "$zfunc_dir" ]; then
      mkdir -p "$zfunc_dir"
    else
      echo "Directory already exists: $HOME/.zfunc"
    fi

    if ! grep -q 'fpath+=$HOME/.zfunc' "$HOME/.zshrc"; then
      sed -i '13i\fpath+=$HOME/.zfunc' $HOME/.zshrc
    else
      echo "'fpath+=$HOME/.zfunc' already exists in $HOME/.zshrc"
    fi

    if [ ! -f "$zfunc_dir/_rustup" ]; then
      rustup completions zsh > "$zfunc_dir/_rustup"
      if [ $? -ne 0 ]; then
        echo "Error: Failed to generate zsh completions for rustup"
        exit 1
      else
        echo "Created $zfunc_dir/_rustup"
      fi
    fi

    if [ ! -f "$zfunc_dir/_cargo" ]; then
      rustup completions zsh cargo > "$zfunc_dir/_cargo"
      if [ $? -ne 0 ]; then
        echo "Error: Failed to generate zsh completions for cargo"
        exit 1
      else
        echo "Created $zfunc_dir/_cargo"
      fi
    fi

    packages_to_install=(
      cargo-quickinstall
      cargo-binstall
      tealdeer
      choose
      du-dust
      eza
      fd-find
      procs
      ripgrep
      sd
      gping
      bottom
      bat
      broot
      hyperfine
      tree-sitter-cli
      zellij
    )

    installed_packages=$(cargo install --list)

    if ! echo "$installed_packages" | grep -q "cargo-quickinstall"; then
      echo "Installing cargo-quickinstall"
      cargo +stable install --locked cargo-quickinstall
    fi

    if ! echo "$installed_packages" | grep -q "cargo-binstall"; then
      echo "Installing cargo-binstall"
      cargo +stable install --locked cargo-binstall
    fi

    basic_packages=(
      tealdeer
      choose
      du-dust
      eza
      fd-find
      procs
      ripgrep
      sd
      gping
    )

    locked_packages=(
      bottom
      bat
      broot
      hyperfine
      tree-sitter-cli
      zellij
    )

    for pkg in "${basic_packages[@]}"; do
      if ! echo "$installed_packages" | grep -q "$pkg"; then
        echo "Installing $pkg with cargo binstall"
        cargo binstall -y "$pkg"
        if [ $? -eq 0 ]; then
          echo "Successfully installed $pkg"
        else
          echo "Error installing $pkg"
        fi
      else
        echo "$pkg is already installed"
      fi
    done

    for pkg in "${locked_packages[@]}"; do
      if ! echo "$installed_packages" | grep -q "pkg"; then
        echo "Installing $pkg with cargo binstall --locked"
        cargo binstall --locked -y "$pkg"
        if [ $? -eq 0 ]; then
          echo "Successfully installed $pkg"
        else
          echo "Error installing $pkg"
        fi
      else
        echo "$pkg is already installed"
      fi
    done

    # tealdeer
    if command -v tldr > /dev/null 2>&1; then
      tldr -u
      if [ ! -f "$zfunc_dir/_tealdeer" ]; then
        curl -L -o $HOME/.zfunc/_tealdeer https://github.com/tealdeer-rs/tealdeer/raw/refs/heads/main/completion/zsh_tealdeer
        if [ $? -ne 0 ]; then
          echo "Failed to download tealdeer shell completion"
          exit 1
        else
          echo "Successfully $zfunc_dir/_tealdeer"
        fi
      fi
    else
      echo "Error: tealdeer is not installed"
      exit 1
    fi

    # bat
    if command -v bat > /dev/null 2>&1; then
      bat --config-file
      bat --generate-config-file
      sed -i 's|#--theme="TwoDark"|--theme="ansi"|g' $HOME/.config/bat/config
    else
      echo "Error: bat is not installed"
      exit 1
    fi

    # broot
    if command -v broot > /dev/null 2>&1; then
      echo "y" | broot

      file="$HOME/.zshrc"
      search_string="source $HOME/.config/broot/launch/bash/br"

      if [ ! -f "$file" ]; then
        echo "Error: $file not found"
        exit 1
      fi

      line_number=$(grep -n "$search_string" "$file" | cut -d: -f1)

      if [ -n "$line_number" ]; then
        echo "Found the line at: $line_number"

        extracted_line=$(sed "${line_number}q;d" "$file")

        sed -i "${line_number}d" "$file"

        sed -i '95i\'"$extracted_line\n" "$file"

        sed -i '$d' "$file"
      else
        echo "The line '$search_string' was not found in $file"
      fi
    else
      echo "Error: broot is not installed"
      exit 1
    fi
  
    # dust 
    if command -v dust > /dev/null 2>&1; then
      if [ ! -f "$zfunc_dir/_dust" ]; then
        curl -L -o $HOME/.zfunc/_dust https://github.com/bootandy/dust/raw/refs/heads/master/completions/_dust
        if [ $? -ne 0 ]; then
          echo "Failed to download du-dust shell completion"
          exit 1
        else
          echo "Successfully $zfunc_dir/_dust"
        fi
      fi
    else
      echo "Error: du-dust is not installed"
      exit 1
    fi

    # eza
    if command -v eza > /dev/null 2>&1; then
      if [ ! -f "$zfunc_dir/_eza" ]; then
        curl -L -o $HOME/.zfunc/_eza https://github.com/eza-community/eza/raw/refs/heads/main/completions/zsh/_eza
        if [ $? -ne 0 ]; then
          echo "Failed to download eza shell completion"
          exit 1
        else
          echo "Successfully $zfunc_dir/_dust"
        fi
      fi

      if ! grep -q "export EZA_ICONS_AUTO=auto" "$HOME/.zshrc"; then
        sed -i "102i\export EZA_ICONS_AUTO=auto\n" $HOME/.zshrc
      else
        echo "export EZA_ICONS_AUTO=auto already exists in $HOME/.zshrc"
      fi

      if ! grep -q "alias e='eza'" "$HOME/.zshrc"; then
        sed -i "129i\alias e='eza'\n" $HOME/.zshrc
      else
        echo "alias e='eza' already exists in $HOME/.zshrc"
      fi
    else
      echo "Error: eza is not installed"
      exit 1
    fi

    # fd
    if command -v fd > /dev/null 2>&1; then
      if [ ! -f "$zfunc_dir/_fd" ]; then
        curl -L -o $HOME/.zfunc/_fd https://github.com/sharkdp/fd/raw/refs/heads/master/contrib/completion/_fd
        if [ $? -ne 0 ]; then
          echo "Failed to download fd-find shell completion"
          exit 1
        else
          echo "Successfully $zfunc_dir/_fd"
        fi
      fi
    else
      echo "Error: fd-find is not installed"
      exit 1
    fi

    # procs
    if command -v procs > /dev/null 2>&1; then
      if ! grep -q "source <(procs --gen-completion-out zsh)" "$HOME/.zshrc"; then
        sed -i "97i\source <(procs --gen-completion-out zsh)\n" $HOME/.zshrc
      else
        echo "source <(procs --gen-completion-out zsh) already exists in $HOME/.zshrc"
      fi
    else
      echo "Error: procs is not installed"
      exit 1
    fi

    # ripgrep
    if command -v rg > /dev/null 2>&1; then
      if [ ! -f "$zfunc_dir/_rg" ]; then
        rg --generate complete-zsh > $HOME/.zfunc/_rg
        if [ $? -ne 0 ]; then
          echo "Error: Failed to generate zsh completions for ripgrep"
          exit 1
        else
          echo "Created $zfunc_dir/_rg"
        fi
      fi
    else
      echo "Error: ripgrep is not installed"
      exit 1
    fi

    # sd
    if command -v sd > /dev/null 2>&1; then
      if [ ! -f "$zfunc_dir/_sd" ]; then
        curl -L -o $HOME/.zfunc/_sd https://github.com/chmln/sd/raw/refs/heads/master/gen/completions/_sd
        if [ $? -ne 0 ]; then
          echo "Failed to download sd shell completion"
          exit 1
        else
          echo "Successfully $zfunc_dir/_sd"
        fi
      fi
    else
      echo "Error: sd is not installed"
      exit 1
    fi

    # zellij
    if command -v zellij > /dev/null 2>&1; then
      if [ ! -f "$zfunc_dir/_zellij" ]; then
        zellij setup --generate-completion zsh > $HOME/.zfunc/_zellij
        if [ $? -ne 0 ]; then
          echo "Error: Failed to generate zsh completion for zellij"
          exit 1
        else
          echo "Created $zfunc_dir/_zellij"
        fi
      fi
    else
      echo "Error: zellij is not installed"
      exit 1
    fi

  else
    echo "The command cannot be executed because rustup is not installed"
    exit 1
  fi

else
  echo "Already have rustup installed."
fi


# fzf
if ! command -v fzf &> /dev/null; then
  echo "Installation fzf"
  git clone --depth 1 https://github.com/junegunn/fzf.git $HOME/.fzf

  (
    echo "y"
    echo "y"
    echo "y"
  ) | $HOME/.fzf/install --all
  echo "Installation is complete"

  file="$HOME/.zshrc"
  search_string='[ -f $HOME/.fzf.zsh ] && source ~/.fzf.zsh'

  if [ ! -f "$file" ]; then
    echo "Error: $file not found"
    exit 1
  fi

  line_number=$(grep -n "$search_string" "$file" | cut -d: -f1)

  if [ -n "$line_number" ]; then
    echo "Found the line at: $line_number"

    extracted_line=$(sed "${line_number}q;d" "$file")

    sed -i "${line_number}d" "$file"

    sed -i '91i\'"$extracted_line\n" "$file"

    sed -i '$d' "$file"
  else
    echo "The line '$search_string' was not found in $file"
  fi

  if ! grep -q 'export FZF_DEFAULT_COMMAND="fd --type f"' "$HOME/.zshrc"; then
    sed -i "95i\export FZF_DEFAULT_COMMAND='fd --type f'\n" $HOME/.zshrc
  else
    echo "export FZF_DEFAULT_COMMAND='fd --type f' already exists in $HOME/.zshrc"
  fi

  if ! grep -q 'export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"' "$HOME/.zshrc"; then
    sed -i '96i\export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"' $HOME/.zshrc
  else
    echo "export FZF_DEFAULT_OPTS='--layout=reverse --inline-info' already exists in $HOME/.zshrc"
  fi

else
  echo "Already have rustup installed."
fi


# zoxide
if ! command -v zoxide &> /dev/null; then
  echo "Installation zoxide"

  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
  if [ $? -ne 0 ]; then
    echo "Failed to download zoxide install script"
    exit 1
  fi

  echo "Installation is complete"

  if ! grep -q 'eval "$(zoxide init zsh)"' "$HOME/.zshrc"; then
    sed -i '93i\eval "$(zoxide init zsh)"\n' $HOME/.zshrc
  else
    echo 'eval "$(zoxide init zsh)" already exists in $HOME/.zshrc'
  fi

else
  echo "Already have zoxide installed."
fi


# go 
go env -w GOPATH="$HOME/.go"
go env -w CGO_CFLAGS='-O3 -g'
go env -w CGO_CXXFLAGS='-O3 -g'
go env -w CGO_FFLAGS='-O3 -g'
go env -w CGO_LDFLAGS='-O3 -g'

# cheat 
if ! command -v cheat &> /dev/null; then
  echo "Installation cheat"
  go install github.com/cheat/cheat/cmd/cheat@latest
  if [ $? -eq 0 ]; then
    echo "Installation is Complete"
  else
    echo "Failed to download cheat"
  fi

  if command -v cheat &> /dev/null; then
    if [ ! -f "$HOME/.zfunc/_cheat" ]; then
      https://github.com/cheat/cheat/raw/refs/heads/master/scripts/cheat.zsh
      if [ $? -ne 0 ]; then
        echo "Failed to download sd shell completion"
        exit 1
      else
        echo "Successfully $zfunc_dir/_sd"
      fi
    fi
  else
    echo "Error: cheat is not installed"
    exit 1
  fi
else
  echo "Already have cheat installed"
fi

if ! command -v curlie &> /dev/null; then
  echo "Installation curlie"
  go install github.com/rs/curlie@latest
  if [ $? -eq 0 ]; then
    echo "Installation is Complete"
  else
    echo "Failed to download curlie"
  fi
else
  echo "Already have curlie installed"
fi

if ! command -v lazygit &> /dev/null; then
  echo "Installation lazygit"
  go install github.com/jesseduffield/lazygit@latest
  if [ $? -eq 0 ]; then
    echo "Installation is Complete"
  else
    echo "Failed to download lazygit"
  fi
else
  echo "Already have lazygit installed"
fi


# httpie
# curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
# echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list > /dev/null
# sudo apt update
# sudo apt install httpie


# node
git clone -b v5.3.22 --recursive --depth=1 https://github.com/nodenv/node-build.git $HOME/.node-build
PREFIX=/usr/local sudo $HOME/.node-build/install.sh
node-build 22.12.0 $HOME/.nodes/node-22.12.0

sudo mkdir -p /usr/local/share/chnode
sudo curl -L -o /usr/local/share/chnode/chnode.sh https://github.com/tkareine/chnode/raw/refs/heads/master/chnode.sh
source /usr/local/share/chnode/chnode.sh
chnode node-22.12.0

npm install -g npm@latest
npm install -g neovim

sed -i '92i\source /usr/local/share/chnode/chnode.sh' $HOME/.zshrc
sed -i '93i\chnode node-22.12.0\n' $HOME/.zshrc


# ruby
git clone -b v0.9.4 --recursive --depth=1 https://github.com/postmodern/ruby-install.git $HOME/.ruby-install
cd $HOME/.ruby-install 
sudo make install

mkdir -p $HOME/.rubies

ruby-install --update
ruby-install --rubies-dir $HOME/.rubies/ ruby 3.3.6

rm -rf $HOME/src

git clone -b v0.3.9 --recursive --depth=1 https://github.com/postmodern/chruby.git $HOME/.chruby
cd $HOME/.chruby
sudo make install
sudo $HOME/.chruby/scripts/setup.sh
source /usr/local/share/chruby/chruby.sh
chruby ruby-3.3.6
echo "ruby-3.3.6" > $HOME/.ruby-version

sed -i '95i\source /usr/local/share/chruby/chruby.sh' $HOME/.zshrc
sed -i '96i\source /usr/local/share/chruby/auto.sh\n' $HOME/.zshrc

gem install neovim


# neovim
git clone -b v0.10.1 --recursive --depth=1 https://github.com/neovim/neovim.git $HOME/.neovim
cd $HOME/.neovim
make CMAKE_BUILD_TYPE=Release
sudo make install

mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
rm -rf ~/.config/nvim/.git
nvim

echo -e "\nalias nz='nvim $HOME/.zshrc'" >> $HOME/.zshrc
echo -e "alias sz='source $HOME/.zshrc'" >> $HOME/.zshrc
