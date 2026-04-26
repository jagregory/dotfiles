{ pkgs, lib, username, workmux, ... }:

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
    pkgs.browsh
    pkgs.fzf
    pkgs.gh
    pkgs.granted
    pkgs.jq
    workmux.packages.${pkgs.system}.default
  ] ++ lib.optionals (!isDarwin) [
    pkgs.firefox  # browsh's runtime; Linux-only via Nix
    pkgs.xdg-utils  # provides xdg-open

    # Wrapper: splits a tmux pane for browsh if inside tmux, else runs inline.
    # Also exposed as `www-browser` so xdg-open's headless fallback finds it.
    (pkgs.symlinkJoin {
      name = "browsh-tmux-launcher";
      paths = let
        body = ''
          if [ -n "$TMUX" ]; then
            exec tmux split-window -h "${pkgs.browsh}/bin/browsh --startup-url '$1'"
          else
            exec ${pkgs.browsh}/bin/browsh --startup-url "$1"
          fi
        '';
      in [
        (pkgs.writeShellScriptBin "browsh-open" body)
        (pkgs.writeShellScriptBin "www-browser" body)
      ];
    })
  ];

  xdg.desktopEntries = lib.optionalAttrs (!isDarwin) {
    browsh = {
      name = "Browsh";
      exec = "browsh-open %u";
      mimeType = [ "x-scheme-handler/http" "x-scheme-handler/https" ];
      terminal = false;
    };
  };

  xdg.mimeApps = lib.mkIf (!isDarwin) {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/http" = "browsh.desktop";
      "x-scheme-handler/https" = "browsh.desktop";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  xdg.configFile."nvim".source = ./config/nvim;

  home.sessionPath = [ "$HOME/.nix-profile/bin" ];

  home.file.".config/mise/config.toml".text = ''
    [settings.node]
    compile = false
  '';

  home.file.".claude/CLAUDE.md".source = ./config/claude/CLAUDE.md;
  home.file.".claude/settings.json".source = ./config/claude/settings.json;

  xdg.configFile."fish/functions/fish_prompt.fish".source =
    ./config/fish/functions/fish_prompt.fish;

  xdg.configFile."ghostty/config" = lib.mkIf isDarwin {
    source = ./config/ghostty/config;
  };

  programs.zsh = {
    enable = !isDarwin;
    initContent = ''
      if { [[ -n "$SSH_CONNECTION" ]] || [[ -n "$MOSH_CONNECTION" ]] || [[ -n "$SSH_TTY" ]]; } \
         && [[ -z "$TMUX" ]] \
         && [[ $- == *i* ]] \
         && command -v tmux >/dev/null; then
        exec tmux new -A -s dev
      fi
    '';
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "github.com" = {
        user = "git";
        identityFile = "${homeDir}/.ssh/id_ed25519";
      };
      "*" = {
        addKeysToAgent = "yes";
        extraOptions = lib.optionalAttrs isDarwin {
          UseKeychain = "yes";
        };
      };
    };
  };

  programs.tmux = {
    enable = true;
    prefix = if isDarwin then "C-a" else "C-b";
    mouse = true;
    terminal = "tmux-256color";

    plugins = let
      fzf-links = pkgs.tmuxPlugins.mkTmuxPlugin {
        pluginName = "fzf-links";
        rtpFilePath = "fzf-links.tmux";
        version = "1.4.15";
        src = pkgs.fetchFromGitHub {
          owner = "alberti42";
          repo = "tmux-fzf-links";
          rev = "1.4.15";
          hash = "sha256-ZAZNOBE4n7tXpszNFw6Ri8BlV9s/4x9H2NovqRmOrCY=";
        };
      };
    in [
      {
        plugin = fzf-links;
        # Open URLs in a new tmux pane via browsh (Firefox-based text browser).
        extraConfig = ''
          set -g @fzf-links-browser-open-cmd "tmux split-window -h '${pkgs.browsh}/bin/browsh --startup-url \"%url\"'"
        '';
      }
    ];

    extraConfig = ''
      set -g allow-passthrough on
      set -g set-clipboard on
      set -ag terminal-overrides ",xterm-256color:RGB"
      # mosh strips tmux's default OSC 52 selection format. Override Ms to
      # force the literal "c" (clipboard) selection that mosh accepts.
      set -ag terminal-overrides ",xterm-256color:Ms=\033]52;c%p1%.0s;%p2%s\007"
      set -as terminal-features ",*:hyperlinks"

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
      assume = "source ${pkgs.granted}/share/assume.fish";
    } // lib.optionalAttrs (!isDarwin) {
      bootstrap = "bash /etc/nixos-config/install.sh --home-manager github:jagregory/dotfiles#${username}";
    };

    shellInit = ''
      set -x PATH $PATH ./node_modules/.bin
      set -x PATH $PATH ~/.local/bin
    '' + lib.optionalString isDarwin ''
      set -g fish_user_paths /opt/homebrew/bin $fish_user_paths

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
      signByDefault = true;
      key = "${homeDir}/.ssh/id_ed25519.pub";
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
