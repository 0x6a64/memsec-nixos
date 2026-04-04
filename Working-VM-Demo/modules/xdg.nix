{ ... }: {
  # XDG default applications
  xdg.mime = {
    enable = true;
    defaultApplications = {
      # Web browsing
      "x-scheme-handler/http" = "firefox.desktop";
      "x-scheme-handler/https" = "firefox.desktop";
      "text/html" = "firefox.desktop";
      "application/xhtml+xml" = "firefox.desktop";
      # PDFs
      "application/pdf" = "firefox.desktop";
    };
  };
}
