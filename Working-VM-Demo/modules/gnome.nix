{ pkgs, ... }: {
  # Enable GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable GNOME browser connector for extension installation
  services.gnome.gnome-browser-connector.enable = true;

  # Minimal GNOME extensions for live environment
  environment.systemPackages = with pkgs.gnomeExtensions; [
    appindicator      # System tray support
    caffeine          # Prevent screen lock
    user-themes       # Custom theme support
  ];

  # Configure VSCode to use basic password store (no keyring prompts)
  environment.sessionVariables = {
    VSCODE_KEYRING_PASS = "nixos-live";
  };

  # Exclude unnecessary GNOME applications to reduce ISO size
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour          # First-run tour
    gnome-music         # Music player
    gnome-contacts      # Contacts manager
    gnome-maps          # Maps application
    simple-scan         # Scanner
    geary               # Email client
    epiphany            # GNOME Web browser
    totem               # Video player
    gnome-calendar      # Calendar
    gnome-software      # Software center
    gnome-terminal      # Old terminal (we use ghostty/console)
  ];
}
