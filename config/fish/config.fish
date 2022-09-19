set -x GOPATH /Users/jag/dev/go
set -x PATH $PATH ./node_modules/.bin
set -x PATH $PATH $GOPATH/bin
set -x SHELL (which fish)
set -x EDITOR nvim

function envchain-sh
  set -lx ENVCHAIN $argv
  if not [ "$ENVCHAIN" ]
    echo Env not specified
    false
  else
    envchain $ENVCHAIN env $SHELL
  end
end

[ -f /usr/local/share/autojump/autojump.fish ]; and source /usr/local/share/autojump/autojump.fish

alias vim nvim

set -g fish_user_paths "/usr/local/opt/gettext/bin" $fish_user_paths

