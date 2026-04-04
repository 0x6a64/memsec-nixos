{ pkgs, ... }: {
  # Create live user
  users.users.nixos = {
    isNormalUser = true;
    description = "Live User";
    extraGroups = [ "wheel" "networkmanager" "video" ];
    shell = pkgs.zsh;
    initialPassword = "";
  };

  # Passwordless sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Auto-login for live user
  services.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Workaround for auto-login (disable getty)
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # ZSH configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Shell aliases
    shellAliases = {
      # Git shortcuts
      gita = "git add -A && git commit -m";

      # NixOS management
      update = "sudo nix flake update && sudo nixos-rebuild boot --flake --upgrade --option warn-dirty false";
      rebuild = "sudo nixos-rebuild switch --flake --option warn-dirty false";
      rebuildst = "sudo nixos-rebuild switch --flake --show-trace --option warn-dirty false";

      # Navigation
      cdn = "cd ~/Nixos";

      su = "sudo -s";
      sudo = "sudo ";  # Allow aliases to work with sudo
    };

    # Shell initialization
    promptInit = ''
      # Enable Powerlevel10k instant prompt (must be at the very top)
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Load Powerlevel10k theme
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Load p10k configuration
      [[ -f /etc/nixos/assets/p10k.zsh ]] && source /etc/nixos/assets/p10k.zsh
    '';

    interactiveShellInit = ''
      # Skip zsh-newuser-install wizard
      zsh-newuser-install() { :; }

      # Disable autocorrect
      unsetopt correct

      # History settings
      setopt hist_ignore_all_dups  # Remove older duplicate entries from history
      setopt hist_reduce_blanks    # Remove superfluous blanks from history items
      setopt inc_append_history    # Save history entries as soon as they are entered

      # Auto complete options
      setopt auto_list             # Automatically list choices on ambiguous completion
      setopt auto_menu             # Automatically use menu completion

      # Completion styling
      zstyle ':completion:*' menu select                     # Select completions with arrow keys
      zstyle ':completion:*' group-name ""                   # Group results by category
      zstyle ':completion:::::' completer _expand _complete _ignored _approximate  # Enable approximate matches
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'  # Case insensitive completion

      # Fix common typo
      alias cd..='cd ..'
    '';

    # History configuration
    histSize = 10000;
    histFile = "$HOME/.zsh_history";
  };

  # Copy p10k config to system location
  environment.etc."nixos/assets/p10k.zsh".source = ../assets/p10k.zsh;

  # Create .zshrc to prevent zsh-newuser-install wizard
  environment.etc."skel/.zshrc".text = ''
    # Managed by NixOS - prevents zsh-newuser-install wizard
  '';
}
