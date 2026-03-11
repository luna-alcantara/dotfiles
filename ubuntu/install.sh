#!/usr/bin/env bash
set -euo pipefail

# WSL Ubuntu bootstrap

DOTNET_SDKS=(
  dotnet-sdk-6.0
  dotnet-sdk-8.0
  dotnet-sdk-10.0
)

DOTNET_TOOLS_DIR="$HOME/.dotnet/tools"

log() { printf "\n==> %s\n" "$*"; }
need_cmd() { command -v "$1" >/dev/null 2>&1; }

if [[ "${EUID:-$(id -u)}" -eq 0 ]]; then
  echo "Run as normal user."
  exit 1
fi

ARCH="$(dpkg --print-architecture)"
CODENAME="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"

# -------------------------------------------------
# Base packages
# -------------------------------------------------

log "Updating apt"

sudo apt-get update -y

sudo apt-get install -y --no-install-recommends \
  ca-certificates \
  curl \
  wget \
  gnupg \
  lsb-release \
  apt-transport-https \
  software-properties-common \
  unzip \
  zip \
  jq \
  tree \
  ripgrep \
  httpie \
  git \
  stow \
  zsh \
  tmux \
  fzf \
  zoxide \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  python-is-python3 \
  nodejs \
  npm \
  luarocks \
  bat \
  build-essential \
  pkg-config

if ! need_cmd bat && need_cmd batcat; then
  sudo ln -sf "$(command -v batcat)" /usr/local/bin/bat
fi

# -------------------------------------------------
# GitHub CLI
# -------------------------------------------------

install_gh() {

  if need_cmd gh; then
    return
  fi

  log "Installing GitHub CLI"

  sudo mkdir -p /etc/apt/keyrings

  wget -nv -O- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg >/dev/null

  sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg

  echo "deb [arch=${ARCH} signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null

  sudo apt-get update -y
  sudo apt-get install gh -y
}

# -------------------------------------------------
# Docker
# -------------------------------------------------

install_docker() {

  if need_cmd docker; then
    return
  fi

  log "Installing Docker"

  sudo install -m 0755 -d /etc/apt/keyrings

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | sudo tee /etc/apt/keyrings/docker.asc >/dev/null

  sudo chmod a+r /etc/apt/keyrings/docker.asc

  sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${CODENAME}
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

  sudo apt-get update -y

  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

  sudo usermod -aG docker "$USER"
}

install_docker_compose_wrapper() {

  if need_cmd docker-compose; then
    return
  fi

  sudo tee /usr/local/bin/docker-compose >/dev/null <<'EOF'
#!/usr/bin/env bash
exec docker compose "$@"
EOF

  sudo chmod +x /usr/local/bin/docker-compose
}

# -------------------------------------------------
# AWS CLI v2
# -------------------------------------------------

install_aws_cli() {

  if need_cmd aws; then
    return
  fi

  log "Installing AWS CLI v2"

  tmp="$(mktemp -d)"

  curl -fsSL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip \
    -o "$tmp/aws.zip"

  unzip -q "$tmp/aws.zip" -d "$tmp"

  sudo "$tmp/aws/install" --update

  rm -rf "$tmp"
}

# -------------------------------------------------
# Starship
# -------------------------------------------------

install_starship() {

  if need_cmd starship; then
    return
  fi

  curl -fsSL https://starship.rs/install.sh | sh -s -- -y
}

# -------------------------------------------------
# Neovim
# -------------------------------------------------

install_neovim() {

  log "Installing Neovim"

  tmp="$(mktemp -d)"

  curl -fsSL \
  https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
  -o "$tmp/nvim.tar.gz"

  tar -xzf "$tmp/nvim.tar.gz" -C "$tmp"

  sudo rm -rf /opt/nvim
  sudo mv "$tmp/nvim-linux-x86_64" /opt/nvim

  sudo ln -sf /opt/nvim/bin/nvim /usr/local/bin/nvim

  rm -rf "$tmp"
}

# -------------------------------------------------
# Yazi
# -------------------------------------------------

install_yazi() {

  if need_cmd yazi; then
    return
  fi

  tmp="$(mktemp -d)"

  curl -fsSL \
  https://github.com/sxyazi/yazi/releases/latest/download/yazi-x86_64-unknown-linux-gnu.zip \
  -o "$tmp/yazi.zip"

  unzip -q "$tmp/yazi.zip" -d "$tmp/yazi"

  sudo install -m 0755 "$tmp"/yazi/*/yazi /usr/local/bin/yazi
  sudo install -m 0755 "$tmp"/yazi/*/ya   /usr/local/bin/ya

  rm -rf "$tmp"
}

# -------------------------------------------------
# Lazygit
# -------------------------------------------------

install_lazygit() {

  if need_cmd lazygit; then
    return
  fi

  version=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazygit/releases/latest \
    | awk -F'"' '/tag_name/ {print $4}' | sed 's/^v//')

  tmp="$(mktemp -d)"

  curl -fsSL \
  "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz" \
  -o "$tmp/lazygit.tar.gz"

  tar -xzf "$tmp/lazygit.tar.gz" -C "$tmp"

  sudo install -m 0755 "$tmp/lazygit" /usr/local/bin/lazygit

  rm -rf "$tmp"
}

# -------------------------------------------------
# Lazydocker
# -------------------------------------------------

install_lazydocker() {

  if need_cmd lazydocker; then
    return
  fi

  version=$(curl -fsSL https://api.github.com/repos/jesseduffield/lazydocker/releases/latest \
    | awk -F'"' '/tag_name/ {print $4}' | sed 's/^v//')

  tmp="$(mktemp -d)"

  curl -fsSL \
  "https://github.com/jesseduffield/lazydocker/releases/download/v${version}/lazydocker_${version}_Linux_x86_64.tar.gz" \
  -o "$tmp/lazydocker.tar.gz"

  tar -xzf "$tmp/lazydocker.tar.gz" -C "$tmp"

  sudo install -m 0755 "$tmp/lazydocker" /usr/local/bin/lazydocker

  rm -rf "$tmp"
}

# -------------------------------------------------
# NVM
# -------------------------------------------------

install_nvm() {

  if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
    return
  fi

  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

  export NVM_DIR="$HOME/.nvm"
  . "$NVM_DIR/nvm.sh"

  nvm install --lts
  nvm alias default 'lts/*'
}

# -------------------------------------------------
# Dotnet SDKs + Tools
# -------------------------------------------------

install_dotnet() {

  log "Installing Microsoft package repo"

  wget https://packages.microsoft.com/config/ubuntu/${CODENAME}/packages-microsoft-prod.deb \
    -O packages-microsoft-prod.deb

  sudo dpkg -i packages-microsoft-prod.deb

  rm packages-microsoft-prod.deb

  sudo apt-get update -y

  for sdk in "${DOTNET_SDKS[@]}"; do
    log "Installing $sdk"
    sudo apt-get install -y "$sdk"
  done

  mkdir -p "$DOTNET_TOOLS_DIR"

  log "Installing dotnet global tools"

  dotnet tool install --global dotnet-outdated-tool || \
  dotnet tool update --global dotnet-outdated-tool

  dotnet tool install --global dotnet-search || \
  dotnet tool update --global dotnet-search

  dotnet tool install --global Amazon.Lambda.TestTool-6.0 || \
  dotnet tool update --global Amazon.Lambda.TestTool-6.0

  dotnet tool install --global Amazon.Lambda.TestTool-8.0 || \
  dotnet tool update --global Amazon.Lambda.TestTool-8.0

  dotnet tool install --global Amazon.Lambda.TestTool-10.0 || \
  dotnet tool update --global Amazon.Lambda.TestTool-10.0

  dotnet new install Amazon.Lambda.Templates || \
  dotnet new update Amazon.Lambda.Templates
}

# -------------------------------------------------
# TPM
# -------------------------------------------------

install_tpm() {

  TPM_DIR="$HOME/.tmux/plugins/tpm"

  if [[ -d "$TPM_DIR/.git" ]]; then
    return
  fi

  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
}

# -------------------------------------------------
# Zsh default shell
# -------------------------------------------------

set_default_shell_zsh() {

  ZSH_PATH="$(command -v zsh)"

  if [[ "${SHELL:-}" != "$ZSH_PATH" ]]; then
    chsh -s "$ZSH_PATH" || true
  fi
}

# -------------------------------------------------
# Opencode
# -------------------------------------------------

install_opencode() {

  if command -v opencode >/dev/null 2>&1; then
    return
  fi

  log "Installing opencode"

  version=$(curl -fsSL https://api.github.com/repos/sst/opencode/releases/latest \
    | awk -F'"' '/tag_name/ {print $4}' | sed 's/^v//')

  tmp=$(mktemp -d)

  curl -fsSL \
  "https://github.com/sst/opencode/releases/download/v${version}/opencode_linux_amd64.tar.gz" \
  -o "$tmp/opencode.tar.gz"

  tar -xzf "$tmp/opencode.tar.gz" -C "$tmp"

  sudo install -m 0755 "$tmp/opencode" /usr/local/bin/opencode

  rm -rf "$tmp"
}

# -------------------------------------------------
# gh-dash
# -------------------------------------------------

install_gh_dash() {

  if command -v gh-dash >/dev/null 2>&1; then
    return
  fi

  log "Installing gh-dash"

  version=$(curl -fsSL https://api.github.com/repos/dlvhdr/gh-dash/releases/latest \
    | awk -F'"' '/tag_name/ {print $4}' | sed 's/^v//')

  tmp=$(mktemp -d)

  curl -fsSL \
  "https://github.com/dlvhdr/gh-dash/releases/download/${version}/gh-dash_${version}_linux_amd64.tar.gz" \
  -o "$tmp/ghdash.tar.gz"

  tar -xzf "$tmp/ghdash.tar.gz" -C "$tmp"

  sudo install -m 0755 "$tmp/gh-dash" /usr/local/bin/gh-dash

  rm -rf "$tmp"
}

# -------------------------------------------------
# Run installs
# -------------------------------------------------

install_gh
install_docker
install_docker_compose_wrapper
install_aws_cli
install_starship
install_neovim
install_yazi
install_lazygit
install_lazydocker
install_nvm
install_dotnet
install_tpm
install_gh_dash
install_opencode
set_default_shell_zsh

# -------------------------------------------------
# Summary
# -------------------------------------------------
log "Done"

echo "git:        $(git --version)"
echo "stow:       $(stow --version | head -n1)"
echo "zsh:        $(zsh --version)"
echo "tmux:       $(tmux -V)"
echo "starship:   $(starship --version)"
echo "zoxide:     $(zoxide --version)"
echo "fzf:        $(fzf --version | head -n1)"
echo "nvim:       $(nvim --version | head -n1)"
echo "yazi:       $(yazi --version || true)"
echo "lazygit:    $(lazygit --version || true)"
echo "lazydocker: $(lazydocker --version || true)"
echo "gh:         $(gh --version | head -n1)"
echo "docker:     $(docker --version || true)"
echo "compose:    $(docker compose version || true)"
echo "aws:        $(aws --version || true)"
echo "python:     $(python --version)"
echo "dotnet:     $(dotnet --list-sdks || true)"
echo "node:       $(node --version || true)"
echo "npm:        $(npm --version || true)"
echo "luarocks:   $(luarocks --version | head -n1)"
echo "bat:        $(bat --version || true)"
echo "jq:         $(jq --version)"
echo "rg:         $(rg --version | head -n1)"
echo "Inside tmux, press prefix + I to install plugins."

