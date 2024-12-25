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
  sudo sed -i "s|http://archive.ubuntu.com|$MIRROR_SITE|g; s|http://kr.archive.ubuntu.com|$MIRROR_SITE|g; s|http://security.ubuntu.com|$MIRROR_SITE|g" /etc/apt/sources.list
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
		 luarocks

# gcc version change
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 200

sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 200

# Use ccache
sudo sed -i 's|^PATH="|PATH="/usr/lib/ccache:|' /etc/environment

# oh my zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
sed -i '4i\export PATH=$HOME/.go/bin:$HOME/.loacl/bin:$PATH\n' $HOME/.zshrc

git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i 's|robbyrussell|powerlevel10k/powerlevel10k|g' $HOME/.zshrc

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
git clone https://github.com/hlissner/zsh-autopair ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autopair
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search

sed -i '6i\fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src\n' $HOME/.zshrc
sed -i "s/git/git zsh-autosuggestions zsh-autopair fast-syntax-highlighting zsh-history-substring-search/g" $HOME/.zshrc

# rustup 
curl https://sh.rustup.rs -sSf | sh && exec $SHELL

mkdir -p $HOME/.zfunc
sed -i '6i\fpath+=$HOME/.zfunc' $HOME/.zshrc

rustup update stable
rustup completions zsh > $HOME/.zfunc/_rustup
rustup completions zsh cargo > $HOME/.zfunc/_cargo

cargo +stable install --locked cargo-quickinstall
cargo +stable quickinstall cargo-binstall
cargo binstall tealdeer choose du-dust eza fd-find procs ripgrep sd gping
cargo binstall --locked bottom bat broot hyperfine tree-sitter-cli zellij

# fzf
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
$HOME/.fzf/install

file="$HOME/.zshrc"
last_line=$(wc -l < "$file")

if [[ "$last_line" -gt 83 ]]; then
  printf '%s\n' "${last_line}m83" '84a' '' '.' w q | ed -s "$file"
fi

sed -i "88i\export FZF_DEFAULT_COMMAND='fd --type f'" $HOME/.zshrc
sed -i '89i\export FZF_DEFAULT_OPTS="--layout=reverse --inline-info"\n' $HOME/.zshrc

# zoxide
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
sed -i '86i\eval "$(zoxide init zsh)"\n' $HOME/.zshrc

# tealdeer 
tldr -u
curl -L -o $HOME/.zfunc/_tealdeer https://github.com/tealdeer-rs/tealdeer/raw/refs/heads/main/completion/zsh_tealdeer

# bat 
bat --config-file
bat --generate-config-file
sed -i 's|#--theme="TwoDark"|--theme="ansi"|g' $HOME/.config/bat/config

# broot
broot

file="$HOME/.zshrc"
last_line=$(wc -l < "$file")

if [[ "$last_line" -gt 87 ]]; then
  printf '%s\n' "${last_line}m87" '88a' '' '.' w q | ed -s "$file"
fi

# dust 
curl -L -o $HOME/.zfunc/_dust https://github.com/bootandy/dust/raw/refs/heads/master/completions/_dust

# eza
curl -L -o $HOME/.zfunc/_eza https://github.com/eza-community/eza/raw/refs/heads/main/completions/zsh/_eza
sed -i '95i\export EZA_ICONS_AUTO=auto\n' $HOME/.zshrc
echo -e "\nalias e='eza'" >> $HOME/.zshrc

# fd
curl -L -o $HOME/.zfunc/_fd https://github.com/sharkdp/fd/raw/refs/heads/master/contrib/completion/_fd

# procs
sed -i '90i\source <(procs --gen-completion-out zsh)\n' $HOME/.zshrc

# ripgrep
rg --generate complete-zsh > $HOME/.zfunc/_rg

# sd
curl -L -o $HOME/.zfunc/_sd https://github.com/chmln/sd/raw/refs/heads/master/gen/completions/_sd

# zellij
zellij setup --generate-completion zsh > $HOME/.zfunc/_zellij

# go 
go env -w GOPATH="$HOME/.go"
go env -w CGO_CFLAGS='-O3 -g'
go env -w CGO_CXXFLAGS='-O3 -g'
go env -w CGO_FFLAGS='-O3 -g'
go env -w CGO_LDFLAGS='-O3 -g'

go install github.com/cheat/cheat/cmd/cheat@latest
go install github.com/rs/curlie@latest
go install github.com/jesseduffield/lazygit@latest

# httpie
curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list > /dev/null
sudo apt update
sudo apt install httpie

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
