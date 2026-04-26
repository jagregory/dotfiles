# dotfiles

Personal Home Manager flake. Two outputs:

- `jag` — `aarch64-darwin` (Mac)
- `dev` — `x86_64-linux` (Changineers VPS)

## Activation

First time on a new machine (no `home-manager` binary yet):

```bash
nix run home-manager/release-25.11 -- switch --flake github:jagregory/dotfiles#<config>
```

Subsequent updates:

```bash
home-manager switch --flake github:jagregory/dotfiles#<config> --refresh
```

`--refresh` forces nix to re-fetch the flake from GitHub instead of using its 60-second cache.

## What's HM-managed

- `programs.git` — aliases, signing config, gh credential helper, lfs
- `programs.fish` — config + custom prompt function (Mac is on fish)
- `programs.zsh` — Linux only; auto-execs `tmux new -A -s dev` on SSH/mosh login
- `programs.tmux` — `C-a` prefix on Mac, `C-b` on Linux; OSC 8 hyperlinks; workmux bindings
- `programs.ssh` — github.com identity + tailnet match block
- `programs.neovim` — wraps the NvChad config in `config/nvim/`

Plus packages: `gh`, `granted`, `jq`, `workmux`, and a per-machine `setup-github-ssh` helper (the Linux side comes from `Changineers/nix-config`).

## What's not HM-managed

- `Brewfile` — Mac GUIs (Ghostty, Slack, 1Password, etc.) + MAS apps + a couple of CLIs that don't yet have working Nix paths on aarch64-darwin (mise).
- SSH keys — generated per-machine via `setup-github-ssh`.

## First-run on a new VPS

`Changineers/nix-config`'s `install.sh` brings up the box and Tailscale. After that:

```bash
home-manager switch --flake github:jagregory/dotfiles#dev
gh auth login -h github.com --scopes 'admin:public_key,admin:ssh_signing_key'
setup-github-ssh
```

## First-run on a new Mac

1. Install Nix per [Determinate's docs](https://docs.determinate.systems/getting-started/installation).
2. Install Homebrew per [brew.sh](https://brew.sh).
3. Activate this flake:
   ```bash
   nix run home-manager/release-25.11 -- switch --flake github:jagregory/dotfiles#jag
   ```
4. Install Mac-only GUIs/MAS apps:
   ```bash
   brew bundle --file=~/.dotfiles/Brewfile
   ```
