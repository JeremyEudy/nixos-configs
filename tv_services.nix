{ pkgs, ... }:
{
  systemd.services.update_tv_steam = {
    description = "Copy all .acf files from /mnt/games steam library to tv user home library, and remove the libraryfolders.vdf file";
    script = ''
      cp -r /mnt/games/SteamLibrary/steamapps/*.acf /home/tv/.local/share/Steam/steamapps && \
      rm -f /home/tv/.local/share/Steam/steamapps/libraryfolders.vdf && \
      chown -R tv:users /home/tv
    '';
    wantedBy = [ "multi-user.target" ];
  };
  systemd.services.tv_graphical = {
    description = "Simple service to launch graphical session for user tv on seat0/tty7";
    after = [  ];
    wantedBy = [  ];

    serviceConfig = {
      Type = "simple";
      User = "tv";
      PAMName = "login";
      TTYPath = "/dev/tty7";
      TTYReset = true;
      TTYVHangup = true;
      TTYVTDisallocate = true;
      StandardInput = "tty";
      StandardOutput = "journal";
      StandardError = "journal";
      ExecStart = 
        "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland";
    };

    environment = {
      XDG_SEAT = "seat0";
      XDG_VTNR = "7";
      XDG_CURRENT_DESKTOP = "KDE";
      KDE_FULL_SESSION = "true";
    };
  };
}
