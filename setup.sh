#!/usr/bin/env bash
# ==============================================================================
#  NamiConfig — First-Time Neovim Setup
#  macOS · Homebrew · lazy.nvim
# ==============================================================================
#  Run from anywhere:
#    bash ~/.config/nvim/setup.sh
#
#  Safe to re-run — every step is idempotent.
# ==============================================================================

set -euo pipefail

# ── Colours ───────────────────────────────────────────────────────────────────
RESET=$'\033[0m'
BOLD=$'\033[1m'
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
CYAN=$'\033[0;36m'
DIM=$'\033[2m'

step()    { echo -e "\n${BOLD}${CYAN}▶ $*${RESET}"; }
ok()      { echo -e "  ${GREEN}✓${RESET}  $*"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET}  $*"; }
fail()    { echo -e "  ${RED}✗${RESET}  $*"; }
info()    { echo -e "  ${DIM}$*${RESET}"; }
skip()    { echo -e "  ${DIM}↩  $* (already installed)${RESET}"; }

# ── Header ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}"
echo "   _   __               _         "
echo "  / | / /___ _____ ___ (_)____    "
echo " /  |/ / \`\` \`/ __ \`\` \\\\ \\/ / __ \\  "
echo "/ /|  / /_/ / / / / / / / / / /  "
echo "/_/ |_/\\__,_/_/ /_/ /_/_/_/ /_/   "
echo ""
echo -e "   ${RESET}${BOLD}NamiConfig — First-Time Setup${RESET}${CYAN}"
echo -e "   Ultimate Neovim Dev Environment${RESET}"
echo ""

# ── Platform check ────────────────────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  fail "This script is for macOS only."
  echo "  For Linux, install the equivalents via your package manager."
  exit 1
fi

# ── Homebrew ─────────────────────────────────────────────────────────────────
step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  warn "Homebrew not found. Installing..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon Macs
  if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  ok "Homebrew installed"
else
  skip "Homebrew"
fi

brew update --quiet

# ── Helper: brew install or skip ─────────────────────────────────────────────
brew_install() {
  local pkg="$1"
  local label="${2:-$pkg}"
  if brew list --formula 2>/dev/null | grep -qx "$pkg"; then
    skip "$label"
  else
    info "Installing $label..."
    brew install "$pkg" --quiet
    ok "$label"
  fi
}

brew_cask() {
  local pkg="$1"
  local label="${2:-$pkg}"
  if brew list --cask 2>/dev/null | grep -qx "$pkg"; then
    skip "$label (cask)"
  else
    info "Installing $label (cask)..."
    brew install --cask "$pkg" --quiet
    ok "$label"
  fi
}

# ── Core: Neovim ─────────────────────────────────────────────────────────────
step "Neovim (>= 0.10 required)"
if command -v nvim &>/dev/null; then
  NVIM_VERSION=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+')
  NVIM_MAJOR=$(echo "$NVIM_VERSION" | cut -d. -f1)
  NVIM_MINOR=$(echo "$NVIM_VERSION" | cut -d. -f2)
  if [[ "$NVIM_MAJOR" -ge 0 && "$NVIM_MINOR" -ge 10 ]] || [[ "$NVIM_MAJOR" -ge 1 ]]; then
    skip "Neovim $NVIM_VERSION"
  else
    warn "Neovim $NVIM_VERSION is too old (need >= 0.10). Upgrading..."
    brew upgrade neovim --quiet
    ok "Neovim upgraded"
  fi
else
  brew_install neovim "Neovim"
fi

# ── Core CLI Tools ────────────────────────────────────────────────────────────
step "Core CLI tools"
brew_install git            "Git"
brew_install curl           "curl"
brew_install wget           "wget"
brew_install fd             "fd (fast file finder)"
brew_install ripgrep        "ripgrep (rg — live grep)"
brew_install fzf            "fzf (fuzzy finder)"
brew_install lazygit        "lazygit (Git TUI)"
brew_install tree           "tree"
brew_install jq             "jq (JSON processor)"
brew_install bat            "bat (better cat)"

# ── Node.js (required for: ts_ls, prettier, eslint_d, leetcode.nvim) ─────────
step "Node.js + npm"
if command -v node &>/dev/null; then
  NODE_VER=$(node --version)
  skip "Node.js $NODE_VER"
else
  brew_install node "Node.js"
fi

# Verify npm is available
if command -v npm &>/dev/null; then
  skip "npm"
else
  warn "npm not found — reinstalling node"
  brew reinstall node --quiet
fi

# ── Python (required for: pyright, black, ruff, debugpy, neotest-python) ─────
step "Python 3"
if command -v python3 &>/dev/null; then
  PY_VER=$(python3 --version)
  skip "$PY_VER"
else
  brew_install python "Python 3"
fi

# pip3 — required to install debugpy for DAP
if ! command -v pip3 &>/dev/null; then
  warn "pip3 not found. Trying to install via ensurepip..."
  python3 -m ensurepip --upgrade 2>/dev/null || warn "pip3 install failed — DAP Python may not work"
fi

# ── Go (optional extra — used by gopls + ray-x/go.nvim) ─────────────────────
step "Go (optional — needed if you use plugins.extras.lang.go)"
if command -v go &>/dev/null; then
  GO_VER=$(go version | awk '{print $3}')
  skip "Go $GO_VER"
else
  warn "Go not installed. Skipping (install manually if needed: brew install go)"
fi

# ── Rust / Cargo (optional extra — rustaceanvim + codelldb) ─────────────────
step "Rust (optional — needed if you use plugins.extras.lang.rust)"
if command -v rustc &>/dev/null; then
  RUST_VER=$(rustc --version)
  skip "$RUST_VER"
else
  warn "Rust not installed. Install via: curl https://sh.rustup.rs -sSf | sh"
fi

# ── Deno (required for peek.nvim markdown preview build) ─────────────────────
step "Deno (for peek.nvim markdown preview)"
if command -v deno &>/dev/null; then
  DENO_VER=$(deno --version | head -1)
  skip "$DENO_VER"
else
  brew_install deno "Deno"
fi

# ── Silicon (required for nvim-silicon code screenshots) ─────────────────────
step "Silicon (for :Silicon code screenshot)"
if command -v silicon &>/dev/null; then
  skip "silicon"
else
  # silicon is installed via cargo on macOS
  if command -v cargo &>/dev/null; then
    info "Installing silicon via cargo (this may take a few minutes)..."
    cargo install silicon --quiet 2>/dev/null && ok "silicon" || warn "silicon install failed — try: cargo install silicon"
  else
    warn "silicon not installed (requires Rust/cargo)."
    info "After installing Rust, run: cargo install silicon"
  fi
fi

# ── ImageMagick (for Snacks image rendering) ──────────────────────────────────
step "ImageMagick (for Snacks image display)"
brew_install imagemagick "ImageMagick"

# ── Ghostty terminal (optional, for theme sync feature) ──────────────────────
step "Ghostty (optional — theme sync uses Ghostty config)"
if command -v ghostty &>/dev/null || [[ -d "/Applications/Ghostty.app" ]]; then
  skip "Ghostty"
else
  warn "Ghostty not installed. Theme sync to terminal is disabled."
  info "Install from: https://ghostty.org/download"
fi

# ── Fonts: JetBrainsMono Nerd Font (used by Silicon + UI) ────────────────────
step "JetBrainsMono Nerd Font (used by Silicon plugin)"
if fc-list 2>/dev/null | grep -qi "JetBrainsMono"; then
  skip "JetBrainsMono Nerd Font"
elif ls ~/Library/Fonts/JetBrainsMono* &>/dev/null 2>&1; then
  skip "JetBrainsMono Nerd Font (already in ~/Library/Fonts)"
else
  info "Installing JetBrainsMono Nerd Font..."
  # Tap nerd-fonts and install
  if brew tap | grep -q "homebrew/cask-fonts"; then
    :
  else
    brew tap homebrew/cask-fonts --quiet 2>/dev/null || true
  fi
  brew install --cask font-jetbrains-mono-nerd-font --quiet 2>/dev/null \
    && ok "JetBrainsMono Nerd Font" \
    || warn "Font install failed — install manually from: https://www.nerdfonts.com"
fi

# ── Screenshots directory (used by nvim-silicon output path) ─────────────────
step "Screenshots directory"
mkdir -p ~/Pictures/Screenshots
ok "~/Pictures/Screenshots exists"

# ── Config location check ─────────────────────────────────────────────────────
step "Verifying Neovim config location"
NVIM_CONFIG="$HOME/.config/nvim"
if [[ -f "$NVIM_CONFIG/init.lua" ]]; then
  ok "Config found at $NVIM_CONFIG"
else
  fail "Config not found at $NVIM_CONFIG/init.lua"
  echo ""
  echo "  To clone this config, run:"
  echo "    git clone <your-repo-url> ~/.config/nvim"
  exit 1
fi

# ── Back up existing Neovim state (optional clean slate) ─────────────────────
step "Neovim data directories"
NVIM_DATA="$HOME/.local/share/nvim"
NVIM_CACHE="$HOME/.cache/nvim"
NVIM_STATE="$HOME/.local/state/nvim"

for dir in "$NVIM_DATA" "$NVIM_CACHE" "$NVIM_STATE"; do
  if [[ ! -d "$dir" ]]; then
    mkdir -p "$dir"
    ok "Created $dir"
  else
    info "$dir already exists"
  fi
done

# ── Mason pre-check: warn if build tools missing ─────────────────────────────
step "Build toolchain (for Mason binary compilation)"

# Check for make/cmake (needed by some Mason-installed LSPs)
if ! command -v make &>/dev/null; then
  warn "make not found — some Mason tools may fail to compile"
  info "Install Xcode Command Line Tools: xcode-select --install"
fi

# Check for clang/cc (needed for tree-sitter parsers)
if ! command -v cc &>/dev/null && ! command -v clang &>/dev/null; then
  warn "C compiler not found — Treesitter parsers may fail to compile"
  info "Install Xcode Command Line Tools: xcode-select --install"
else
  ok "C compiler available"
fi

# ── LuaJIT (used by lazy.nvim, some plugins) ─────────────────────────────────
step "LuaJIT (used internally by Neovim)"
# Neovim bundles LuaJIT, no install needed; just inform
ok "Bundled with Neovim — no separate install needed"

# ── Mason-installed binaries (LSPs, formatters, linters) ─────────────────────
step "Mason-managed tools (auto-installed on first nvim start)"
info "The following will be auto-installed by Mason on first Neovim launch:"
info "  LSP servers : lua_ls, ts_ls, pyright, clangd, html, cssls, jsonls,"
info "                yamlls, bashls, marksman, dockerls, taplo, jdtls, rust_analyzer"
info "  Formatters  : prettier, stylua, black, shfmt, clang-format,"
info "                gofumpt, goimports-reviser, golines, google-java-format, rubocop"
info "  Linters     : eslint_d, ruff, shellcheck, markdownlint-cli2, hadolint"
info "  DAP         : debugpy (Python)"
info ""
info "All tools install automatically — no manual step required."

# ── First-run: bootstrap lazy.nvim ───────────────────────────────────────────
step "Bootstrapping lazy.nvim plugin manager"
LAZY_PATH="$HOME/.local/share/nvim/lazy/lazy.nvim"
if [[ -d "$LAZY_PATH" ]]; then
  skip "lazy.nvim already bootstrapped"
else
  info "lazy.nvim will be cloned automatically on first nvim launch"
  ok "Will bootstrap on first launch"
fi

# ── First-run: install all plugins ────────────────────────────────────────────
step "Installing plugins (headless first run)"
echo ""
warn "This will open Neovim headlessly to install all plugins."
warn "It may take 1–3 minutes on first run. Please wait..."
echo ""

# Run Neovim headlessly to trigger lazy.nvim sync
nvim --headless \
  "+lua require('lazy').sync({ wait = true, show = false })" \
  "+qa" \
  2>/dev/null && ok "All plugins installed" \
  || warn "Plugin install may have partially failed — open nvim and run :Lazy sync"

# ── Final summary ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}${GREEN}  ✓  NamiConfig setup complete!${RESET}"
echo -e "${BOLD}${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
echo -e "${BOLD}  Next steps:${RESET}"
echo ""
echo "  1. ${BOLD}Open Neovim${RESET}"
echo "       nvim"
echo ""
echo "  2. ${BOLD}Wait for Mason to finish tool installation${RESET}"
echo "       (watch the status bar — Mason installs LSPs/linters on first open)"
echo ""
echo "  3. ${BOLD}Check health${RESET}"
echo "       :checkhealth"
echo ""
echo "  4. ${BOLD}Switch theme${RESET}"
echo "       <Space>th  — live theme picker with Ghostty sync"
echo ""
echo "  5. ${BOLD}Explore keymaps${RESET}"
echo "       <Space>     — opens which-key popup"
echo "       <Space>ch   — cheat sheet"
echo ""
echo -e "${BOLD}  Optional extras to enable in ${CYAN}lua/settings.lua${RESET}:"
echo "    • plugins.extras.lang.go     — Go development (gopls, delve DAP)"
echo "    • plugins.extras.lang.rust   — Rust (rust-analyzer, codelldb DAP)"
echo "    • plugins.extras.lang.sql    — SQL + vim-dadbod UI"
echo "    • plugins.extras.testing.neotest — Unified test runner"
echo ""
echo -e "${DIM}  Config: ~/.config/nvim${RESET}"
echo -e "${DIM}  Data:   ~/.local/share/nvim${RESET}"
echo -e "${DIM}  Cache:  ~/.cache/nvim${RESET}"
echo ""
