{ pkgs, ... }: {
  # Enable Firefox with extensions via policies
  programs.firefox = {
    enable = true;

    # Use policies to install extensions system-wide
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false;
      DisableAccounts = false;
      DisableFirefoxScreenshots = true;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;

      # Install extensions via policies and pin to toolbar
      ExtensionSettings = {
        # uBlock Origin - pinned to navbar
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        # Dark Reader - pinned to navbar
        "addon@darkreader.org" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/darkreader/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
        # Bitwarden - pinned to navbar
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
          default_area = "navbar";
        };
      };

      # Default preferences
      Preferences = {
        "browser.startup.homepage" = "about:home";
        "browser.newtabpage.enabled" = true;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "toolkit.telemetry.enabled" = false;
      };
    };
  };

  # Remove firefox from packages.nix since programs.firefox handles it
  # (will be done via edit to packages.nix)
}
