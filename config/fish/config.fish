set -x GOPATH /Users/jag/dev/go
set -x PATH $PATH ./node_modules/.bin
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH /Users/jag/bin
set -x SHELL (which fish)
set -x EDITOR nvim

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

alias vim nvim

set -g fish_user_paths "/usr/local/opt/gettext/bin" $fish_user_paths
set -g fish_user_paths /opt/homebrew/bin/ $fish_user_paths
