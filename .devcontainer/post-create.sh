#!/usr/bin/env bash
set -euo pipefail

# su resets PATH, so make sure nvm-installed node/npm are found.
export PATH="/usr/local/share/nvm/current/bin:$PATH"

cat << 'EOF' >> /home/vscode/.zshrc
if [ "$TERM" = "xterm-ghostty" ] && ! infocmp xterm-ghostty >/dev/null 2>&1; then
  export TERM=xterm-256color
fi
EOF

# --- Architecture detection (works on x64 and ARM/Apple Silicon) ---
DEB_ARCH="$(dpkg --print-architecture)"            # amd64 | arm64
case "$DEB_ARCH" in
  amd64) NVIM_ARCH="x86_64" ;;
  arm64) NVIM_ARCH="arm64" ;;
  *) echo "Unsupported architecture: $DEB_ARCH" >&2; exit 1 ;;
esac

# --- System packages (treesitter needs a compiler; telescope wants ripgrep/fd) ---
sudo apt-get update
sudo apt-get install -y --no-install-recommends \
  build-essential git curl unzip ripgrep fd-find fzf jq \
  yamllint shellcheck
sudo ln -sf "$(command -v fdfind)" /usr/local/bin/fd

# --- Neovim (stable release; Ubuntu's apt version is too old) ---
curl -fsSL "https://github.com/neovim/neovim/releases/download/stable/nvim-linux-${NVIM_ARCH}.tar.gz" \
  | sudo tar -xz -C /opt
sudo ln -sf "/opt/nvim-linux-${NVIM_ARCH}/bin/nvim" /usr/local/bin/nvim

# --- Helm tooling ---
# kubeconform: validates rendered manifests against k8s schemas
curl -fsSL "https://github.com/yannh/kubeconform/releases/latest/download/kubeconform-linux-${DEB_ARCH}.tar.gz" \
  | sudo tar -xz -C /usr/local/bin kubeconform

# helm-ls: Helm language server
sudo curl -fsSL -o /usr/local/bin/helm-ls \
  "https://github.com/mrjosh/helm-ls/releases/latest/download/helm_ls_linux_${DEB_ARCH}"
sudo chmod +x /usr/local/bin/helm-ls

# helm plugins (--verify=false is needed on Helm 4; falls back for Helm 3)
for plugin in https://github.com/databus23/helm-diff https://github.com/helm-unittest/helm-unittest; do
  helm plugin install "$plugin" --verify=false 2>/dev/null || helm plugin install "$plugin" || true
done

# --- Node-based tools: yaml-language-server (used by helm-ls) and opencode ---
sudo env "PATH=$PATH" npm install -g --allow-scripts=opencode-ai yaml-language-server opencode-ai

# --- Neovim config + plugin bootstrap ---
mkdir -p "$HOME/.config/nvim"
cp -r .devcontainer/nvim/. "$HOME/.config/nvim/"
nvim --headless "+Lazy! sync" "+TSUpdateSync" +qa || true

echo "helm-dev container ready."
