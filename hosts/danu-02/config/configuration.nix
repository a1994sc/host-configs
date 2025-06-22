{
  inputs,
  system,
  pkgs,
  ...
}:
{
  # keep-sorted start block=yes case=no
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_12;
  environment.systemPackages = [
    # keep-sorted start block=yes
    inputs.agenix.packages.${system}.agenix
    inputs.agenix.packages.${system}.default
    inputs.disko.packages.${system}.default
    pkgs.duf
    pkgs.fish
    pkgs.fishPlugins.grc
    pkgs.fishPlugins.tide
    pkgs.git
    pkgs.grc
    pkgs.htop
    pkgs.micro
    pkgs.python3
    pkgs.rage
    pkgs.unstable.nh
    pkgs.wget
    # keep-sorted end
  ];
  environment.variables.DIRENV_WARN_TIMEOUT = "100h";
  environment.variables.HISTCONTROL = "ignoredups";
  environment.variables.HISTFILE = "$HOME/.bash_eternal_history";
  environment.variables.HISTFILESIZE = "";
  environment.variables.HISTSIZE = "";
  environment.variables.HISTTIMEFORMAT = "[%F %T] ";
  environment.variables.PROMPT_COMMAND = "history -a; history -c; history -r; $PROMPT_COMMAND";
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  programs.fish.enable = true;
  programs.fish.useBabelfish = true;
  programs.fish.vendor.completions.enable = true;
  system.autoUpgrade.allowReboot = true;
  system.autoUpgrade.dates = "Tue 04:00";
  system.autoUpgrade.enable = true;
  time.timeZone = "America/New_York";
  users.defaultUserShell = pkgs.fish;
  # keep-sorted end
  programs.fish.interactiveShellInit = ''
    set fish_greeting # Disable greeting

    set -gx TMPDIR "/run/user/$(${pkgs.uutils-coreutils-noprefix}/bin/id -u)/tmp"

    mkdir -p $TMPDIR

    function prompt_pwd
      if test "$PWD" != "$HOME"
        printf "%s" (echo $PWD|sed -e 's|/private||' -e "s|^$HOME|~|")
      else
        echo '~'
      end
    end


    function fish_prompt
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
    end
  '';
}
