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

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[ -f /Users/jag/dev/changineers/whitelabel/node_modules/tabtab/.completions/serverless.fish ]; and . /Users/jag/dev/changineers/whitelabel/node_modules/tabtab/.completions/serverless.fish
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[ -f /Users/jag/dev/changineers/whitelabel/node_modules/tabtab/.completions/sls.fish ]; and . /Users/jag/dev/changineers/whitelabel/node_modules/tabtab/.completions/sls.fish