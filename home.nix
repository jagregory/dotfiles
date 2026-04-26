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

  home.packages = [ pkgs.gh ];

  programs.git = {
    enable = true;

    lfs.enable = true;

    ignores = [
      ".zed/"
      ".vscode/settings.json"
      "**/.claude/settings.local.json"
    ];

    signing = {
      key = "${homeDir}/.ssh/jagregory-github-signing-key.pub";
      signByDefault = true;
      format = "ssh";
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
      gpg.ssh.allowedSignersFile = "${homeDir}/.ssh/allowed_signers";

    } // lib.optionalAttrs isDarwin {
      credential.helper = "osxkeychain";
    } // {
      "credential \"github.com\"".useHttpPath = true;
      "credential \"https://github.com\"".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
      "credential \"https://gist.github.com\"".helper = [ "" "!${pkgs.gh}/bin/gh auth git-credential" ];
    };
  };
}
