{ pkgs, lib, username, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  homeDir = if isDarwin then "/Users/${username}" else "/home/${username}";
in
{
  home.username = username;
  home.homeDirectory = homeDir;
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = [
    pkgs.gh

    (pkgs.writeShellScriptBin "setup-github-ssh" ''
      set -euo pipefail

      KEY="$HOME/.ssh/id_ed25519"
      REQUIRED_SCOPES="admin:public_key,admin:ssh_signing_key"

      if ! gh auth status -h github.com >/dev/null 2>&1; then
        echo "Not authenticated. Run:" >&2
        echo "  gh auth login -h github.com --scopes '$REQUIRED_SCOPES'" >&2
        exit 1
      fi

      status=$(gh auth status -h github.com 2>&1)
      if ! echo "$status" | grep -q admin:public_key \
         || ! echo "$status" | grep -q admin:ssh_signing_key; then
        echo "Refreshing gh auth with required scopes..."
        gh auth refresh -h github.com -s "$REQUIRED_SCOPES"
      fi

      if [ ! -f "$KEY" ]; then
        echo "Generating ed25519 key at $KEY"
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
        ssh-keygen -t ed25519 -f "$KEY" -C "$(whoami)@$(hostname)" -N ""
      else
        echo "Using existing key at $KEY"
      fi

      title="$(hostname)-$(date +%Y%m%d)"
      gh ssh-key add "$KEY.pub" --title "$title" || true
      gh ssh-key add "$KEY.pub" --title "$title-sign" --type signing || true

      if ! ssh-keygen -F github.com >/dev/null 2>&1; then
        echo "Pre-trusting github.com host key..."
        ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
      fi

      echo
      echo "Done. Test with: ssh -T git@github.com"
    '')
  ];

  home.sessionVariables.EDITOR = "nvim";
  home.sessionPath = [ "$HOME/.nix-profile/bin" ];

  xdg.configFile."fish/functions/fish_prompt.fish".source =
    ./config/fish/functions/fish_prompt.fish;

  programs.zsh = {
    enable = !isDarwin;
    initContent = ''
      if [[ -n "$SSH_CONNECTION" ]] && [[ -z "$TMUX" ]] && command -v tmux >/dev/null; then
        exec tmux new -A -s dev
      fi
    '';
  };

  programs.tmux = {
    enable = true;
    prefix = if isDarwin then "C-a" else "C-b";
    mouse = true;
    terminal = "tmux-256color";

    extraConfig = ''
      set -g allow-passthrough on
      set -ag terminal-overrides ",xterm-256color:RGB"

      bind '"' split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind -n C-l send-keys -R \; clear-history \; send-keys Enter

      # workmux
      bind C-t run-shell "workmux sidebar"
      bind C-s display-popup -h 30 -w 100 -d "#{pane_current_path}" -E "workmux dashboard"

      set-option -g default-shell ${pkgs.fish}/bin/fish
    '';
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      vim = "nvim";
    } // lib.optionalAttrs isDarwin {
      assume = "source /opt/homebrew/bin/assume.fish";
    };

    shellInit = ''
      set -x PATH $PATH ./node_modules/.bin
      set -x PATH $PATH ~/.local/bin
    '' + lib.optionalString isDarwin ''
      set -g fish_user_paths /opt/homebrew/bin $fish_user_paths

      if test -f ~/.config/fish/completions/granted.fish
        source ~/.config/fish/completions/granted.fish
      end

      if not set -q SSH_AUTH_SOCK
        set -gx SSH_AUTH_SOCK (launchctl getenv SSH_AUTH_SOCK)
      end
    '';

    interactiveShellInit = ''
      set -gx PNPM_HOME ~/Library/pnpm
      if not string match -q -- $PNPM_HOME $PATH
        set -gx PATH $PNPM_HOME $PATH
      end

      mise activate fish | source
    '';
  };

  programs.git = {
    enable = true;

    lfs.enable = true;

    ignores = [
      ".zed/"
      ".vscode/settings.json"
      "**/.claude/settings.local.json"
    ];

    signing = {
      format = "ssh";
      signByDefault = isDarwin;
    } // lib.optionalAttrs isDarwin {
      key = "${homeDir}/.ssh/jagregory-github-signing-key.pub";
    };

    settings = {
      user = {
        name = "James Gregory";
        email = "james@jagregory.com";
      };

      alias = {
        st = "status";
        aa = "!git add -A";
        ci = "commit";
        cia = "!git aa && git ci";
        co = "checkout";
        lb = "!git branch -vv";
        rb = "rebase";
        fixup = "!git log -n 50 --pretty=format:'%h %s' --no-merges | fzf | cut -c -7 | xargs -o git commit --fixup";
        branchd = "!git branch --no-color | fzf -m | xargs -I {} git branch -D '{}'";
        cb = ''!git switch ''${1:-$(git branch -vv | fzf | cut -c3- | awk '{print $1;}')} #'';
        ci-dd = ''!f() { set -e; d=$1; (echo "$d" | grep -q '^[+-]\d*[ymwdHMS]$') || (echo 'Usage: git ci-dd <datediff> <args...>' && return 1); shift; GIT_COMMITTER_DATE="$(date -v$d)" git commit --date "$(date -v$d)" "$@"; }; f'';
        ci-dd-abs = ''!f() { set -e; d=$1; (echo "$d") || (echo 'Usage: git ci-dd-abs <date> <args...>' && return 1); shift; GIT_COMMITTER_DATE="$d" git commit --date "$d" "$@"; }; f'';
        tag-dd = ''!f() { set -e; d=$1; (echo "$d" | grep -q '^[+-]\d*[ymwdHMS]$') || (echo 'Usage: git tag-dd <datediff> <args...>' && return 1); shift; GIT_COMMITTER_DATE="$(date -v$d)" git tag "$@"; }; f'';
        branch-prune = ''!git fetch --prune && git branch --format '%(refname:short) %(upstream:track)' | awk '$2 == "[gone]" { print $1 }' | xargs git branch -D'';
      };

      init.defaultBranch = "main";
      rebase.autosquash = true;
      pull.rebase = "merges";
      branch = {
        autoSetupRebase = "always";
        sort = "-committerdate";
      };
      log.follow = true;
      push.autoSetupRemote = true;

    } // lib.optionalAttrs isDarwin {
      credential.helper = "osxkeychain";
      gpg.ssh.allowedSignersFile = "${homeDir}/.ssh/allowed_signers";
    } // {
      "credential \"github.com\"".useHttpPath = true;
      "credential \"https://github.com\"".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      "credential \"https://gist.github.com\"".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
    };
  };
}
