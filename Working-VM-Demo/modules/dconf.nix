{ pkgs, ... }: {
  # Enable dconf for GNOME settings
  programs.dconf.enable = true;

  # Systemd service to apply dconf settings after graphical interface is ready
  systemd.services.apply-dconf-settings = {
    description = "Apply GNOME dconf settings for live user";
    wantedBy = [ "graphical.target" ];
    after = [ "graphical.target" "display-manager.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "nixos";
      Environment = "DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus";
    };

    script = ''
      # Wait for user session to be fully ready
      # Increased to 10s for slower VMs/hardware
      sleep 10

      # Apply GNOME settings via dconf
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/gtk-theme "'Adwaita-dark'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/icon-theme "'Adwaita'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-theme "'Bibata-Modern-Ice'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/cursor-size "24"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/font-antialiasing "'grayscale'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/font-hinting "'slight'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/clock-show-weekday "true"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/clock-format "'24h'"

      # Background settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/picture-options "'none'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/primary-color "'#1a1a1a'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/background/secondary-color "'#1a1a1a'"

      # Screensaver settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/screensaver/picture-options "'none'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/screensaver/primary-color "'#1a1a1a'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/screensaver/secondary-color "'#1a1a1a'"

      # Window manager settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/wm/preferences/button-layout "'appmenu:minimize,close'"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/wm/keybindings/close "['<Alt>q']"

      # Touchpad settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/peripherals/touchpad/natural-scroll "false"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/peripherals/touchpad/two-finger-scrolling-enabled "true"

      # Shell settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/disable-extension-version-validation "true"
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/favorite-apps "['firefox.desktop', 'code.desktop', 'org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop']"
      ${pkgs.dconf}/bin/dconf write /org/gnome/shell/keybindings/show-screenshot-ui "['<Shift><Super>s']"

      # Mutter settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/mutter/experimental-features "['scale-monitor-framebuffer', 'variable-refresh-rate']"
      ${pkgs.dconf}/bin/dconf write /org/gnome/mutter/edge-tiling "true"

      # Privacy settings
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/privacy/remove-old-temp-files "true"
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/privacy/remove-old-trash-files "true"
    '';
  };
}
