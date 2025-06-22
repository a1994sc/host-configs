{
  config,
  pkgs,
  ...
}:
{
  manual.manpages.enable = false;
  news.display = "silent";
  xdg.enable = true;
  services.home-manager.autoUpgrade.enable = true;
  services.home-manager.autoUpgrade.frequency = "weekly";
  programs.home-manager.enable = true;
  programs.atuin = {
    enable = true;
    flags = [
      "--disable-up-arrow"
    ];
    settings = {
      exit_mode = "return-query";
    };
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      whitelist.prefix = [
        "/etc/nixos"
        "${config.xdg.configHome}/home-manager"
      ];
    };
  };
  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
    };
  };
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting # Disable greeting

      set -gx TMPDIR "/run/user/$(${pkgs.uutils-coreutils-noprefix}/bin/id -u)/tmp"

      mkdir -p $TMPDIR
    '';
    functions = {
      prompt_pwd.body = ''
        if test "$PWD" != "$HOME"
          printf "%s" (echo $PWD|sed -e 's|/private||' -e "s|^$HOME|~|")
        else
          echo '~'
        end
      '';
      fish_prompt.body = ''
        set -l normal (set_color normal)

        # Color the prompt differently when we're root
        set -l color_cwd $fish_color_cwd
        set -l suffix '>'
        if functions -q fish_is_root_user; and fish_is_root_user
          if set -q fish_color_cwd_root
            set color_cwd $fish_color_cwd_root
          end
          set suffix '#'
        end

        set -l bold_flag --bold

        echo -n -s (prompt_login)' ' (set_color $color_cwd) (prompt_pwd) $normal (fish_vcs_prompt) $normal " " $suffix " "
      '';
    };
    plugins = [
      {
        name = "grc";
        inherit (pkgs.fishPlugins.grc) src;
      }
      {
        name = "tide";
        inherit (pkgs.fishPlugins.tide) src;
      }
    ];
  };

  home = {
    homeDirectory =
      if (config.home.username == "root") then "/root" else "/home/" + config.home.username;
    stateVersion = "24.05";
    sessionVariables =
      let
        home = config.home.homeDirectory;
      in
      {
        # keep-sorted start
        HISTCONTROL = "ignoredups";
        HISTFILE = "${home}/.bash_eternal_history";
        HISTFILESIZE = "";
        HISTSIZE = "";
        HISTTIMEFORMAT = "[%F %T] ";
        NIX_SHELL_PRESERVE_PROMPT = "1";
        # keep-sorted end
      };
    shellAliases = {
      # keep-sorted start
      cat = "${pkgs.bat}/bin/bat";
      ll = "${pkgs.eza}/bin/eza -lah";
      ls = "${pkgs.eza}/bin/eza";
      # keep-sorted end
    };
    packages = with pkgs; [
      yq-go
      (writeShellScriptBin "ehistory" ''
        ${pkgs.atuin}/bin/atuin search --limit 50 --search-mode full-text --cmd-only $@
      '')
    ];
  };
}
