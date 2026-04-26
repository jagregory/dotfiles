set -x PATH $PATH ./node_modules/.bin
set -x PATH $PATH /Users/jag/.local/bin
set -x EDITOR nvim

alias vim nvim

set -g fish_user_paths /opt/homebrew/bin/ $fish_user_paths

source /Users/jag/.config/fish/completions/granted.fish
alias assume="source /opt/homebrew/bin/assume.fish"

# pnpm
set -gx PNPM_HOME "/Users/jag/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

mise activate fish | source

# ssh agent
if not set -q SSH_AUTH_SOCK
  set -gx SSH_AUTH_SOCK (launchctl getenv SSH_AUTH_SOCK)
end
