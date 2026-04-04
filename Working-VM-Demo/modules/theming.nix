{pkgs, ...}: {
  # GTK and GNOME theming without Stylix or home-manager

  # Install GTK themes and icon themes
  environment.systemPackages = with pkgs; [
    # GTK themes
    adwaita-icon-theme
    gnome-themes-extra

    # Cursor theme
    bibata-cursors

    # Fonts
    noto-fonts
    noto-fonts-color-emoji
    nerd-fonts.noto
    nerd-fonts.ubuntu
    meslo-lgs-nf
  ];

  # Set environment variables for dark mode
  environment.sessionVariables = {
    # Force GTK dark theme
    GTK_THEME = "Adwaita:dark";

    # Qt applications respect GTK theme
    QT_STYLE_OVERRIDE = "Adwaita-Dark";
  };

  # Configure fonts
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      noto-fonts
      noto-fonts-color-emoji
      nerd-fonts.noto
      nerd-fonts.ubuntu
      meslo-lgs-nf
      liberation_ttf
      dejavu_fonts
    ];

    fontconfig = {
      enable = true;
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel.rgba = "rgb";

      defaultFonts = {
        serif = ["Noto Serif" "DejaVu Serif"];
        sansSerif = ["Noto Sans" "DejaVu Sans"];
        monospace = ["NotoMono Nerd Font" "Noto Sans Mono" "DejaVu Sans Mono"];
        emoji = ["Noto Color Emoji"];
      };
    };
  };

  # Set cursor theme system-wide
  environment.variables = {
    XCURSOR_THEME = "Bibata-Modern-Ice";
    XCURSOR_SIZE = "24";
  };
}
