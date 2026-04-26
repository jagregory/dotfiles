set -x GOPATH /Users/jag/dev/go
set -x PATH $PATH ./node_modules/.bin
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH /Users/jag/bin
set -x PATH $PATH /Users/jag/.local/bin
set -x SHELL /opt/homebrew/bin/fish
set -x EDITOR nvim

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

alias vim nvim
alias tf terraform
alias tailscale "/Applications/Tailscale.app/Contents/MacOS/Tailscale"

set -g fish_user_paths "/usr/local/opt/gettext/bin" $fish_user_paths
set -g fish_user_paths /opt/homebrew/bin/ $fish_user_paths

source /Users/jag/.config/fish/completions/granted.fish
alias assume="source /opt/homebrew/bin/assume.fish"

# pnpm
set -gx PNPM_HOME "/Users/jag/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# bun
set --export BUN_INSTALL "$HOME/.bun"
set --export PATH $BUN_INSTALL/bin $PATH
~/.local/bin/mise activate fish | source

# ssh agent
if not set -q SSH_AUTH_SOCK
  set -gx SSH_AUTH_SOCK (launchctl getenv SSH_AUTH_SOCK)
end

