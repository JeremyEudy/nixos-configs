{ config, pkgs, ... }: let
  jovian-nixos = builtins.fetchGit {
    url = "https://github.com/Jovian-Experiments/Jovian-NixOS";
    ref = "development";
  };
in {
  system.activationScripts = {
    print-jovian = {
      text = builtins.trace "building the jovian configuration..." "";
    };
  };
  imports = [ 
    "${jovian-nixos}/modules"
  ];
  boot.kernelParams = [ "amd_pstate=active" ];
  hardware.xone.enable = true;
  jovian.hardware.has.amd.gpu = true;
  jovian.steam.enable = true;
  jovian.devices.steamdeck.enable = false;
  services.orca.enable = false;
  users = {
    groups.tv = {
      name = "tv";
      gid = 10000;
    };
    users.tv = {
      description = "tv";
      extraGroups = [ "users" "gamemode" "networkmanager" "steam" ];
      group = "tv";
      hashedPassword = "<hash your own pass with mkpasswd -s --method=sha512crypt>";
      home = "/home/tv";
      isNormalUser = true;
      uid = 1001;
      linger = true;
    };
  };
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      gpu = {
        # Only for AMD GPUs
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        amd_performance_level = "high";
      };
    };
  };
  # This service is for automating the login process using wakeonlan and SSH
  systemd.services.run_gamescope = {
    description = "Simple service to launch steam in big picture mode for user tv on seat0/tty7";
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
      ExecStartPre = "${pkgs.kbd}/bin/chvt 7";
      ExecStart = "${config.system.path}/bin/start-gamescope-session";
    };

    environment = {
      XDG_SEAT = "seat0";
      XDG_VTNR = "7";
      XDG_SESSION_TYPE = "wayland";
      XDG_CURRENT_DESKTOP = "gamescope";
    };
  };
  # This modification lets the tv user run the above service, but not any other system service
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          action.lookup("unit") == "run_gamescope.service" &&
          subject.user == "tv") {
        return polkit.Result.YES;
      }
    });
  '';
}
