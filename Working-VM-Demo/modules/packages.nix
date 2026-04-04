{ pkgs, inputs, ... }: {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = (with pkgs; [
    # System Monitoring
    bat
    btop
    nvtopPackages.amd
    dysk
    fastfetch

    # File Management
    lsd
    ripgrep
    fzf

    # Archives
    p7zip
    unzip
    xz
    zip

    # Security
    age
    sops

    # Networking
    nmap
    wget
    curl

    # Development Tools
    alejandra
    git
    github-cli
    ghostty
    jq
    nil
    nixd
    vscode

    # Shell
    tealdeer
    zsh-powerlevel10k
    meslo-lgs-nf

    # GNOME Applications
    gnome-tweaks
    gnome-extension-manager
    dconf-editor

    # Fonts & Cursors
    bibata-cursors
    nerd-fonts.ubuntu
    nerd-fonts.noto
    noto-fonts
    noto-fonts-color-emoji

    # Utilities
    discord
  ])
  ++
  # Claude Code from llm-agents flake
  (with inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}; [
    claude-code
  ]);
}
