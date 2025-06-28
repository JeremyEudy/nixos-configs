# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
# imports {{{
  imports = [
      ./hardware-configuration.nix
      ./zsh.nix
      ./vim.nix
      ./tmux.nix
      ./emulators.nix
      ./music.nix
      ./amdgpu.nix
      ./systemd.nix
      ./sddm-themes.nix
      <home-manager/nixos>
    ];
# }}}
# boot/fs {{{
  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable ntfs support
  boot.supportedFilesystems = [ "ntfs" ];
# }}}
# networking/ssh {{{
  networking.hostName = "full-stampede"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.interfaces.enp39s0.ipv4.addresses = [ {
    address = "192.168.150.20";
    prefixLength = 24;
  } ];
  networking.defaultGateway = "192.168.150.1";
  networking.nameservers = [ "192.168.150.4" "1.1.1.1" "1.1.0.0" ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      X11Forwarding = true;
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ 7777 ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;
# }}}
# locale {{{
  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
# }}}
# display {{{
  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  # serivces.xserver.displayManager.gdm.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Enable budgie desktop environment
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.budgie.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
# }}}
# printing/bluetooth/audio/touchpad {{{
  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
# }}}
# users {{{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jeremy = {
    isNormalUser = true;
    description = "Jeremy Eudy";
    uid = 1000;
    extraGroups = [ "networkmanager" "wheel" "steam" "audio" ];
  };
  users.users.tv = {
    isNormalUser = true;
    description = "TV";
    extraGroups = [ "steam" ];
  };
# }}}
# programs {{{
  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nix.settings.experimental-features=[ "nix-command" "flakes" ];
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Editors
    nano
    kdePackages.kate
    # Terminal
    blackbox-terminal
    # Dev tools
    fortune-kind
    neo-cowsay
    lolcat
    fzf
    silver-searcher
    just
    wget
    git
    expect
    wireguard-tools
    sshfs
    borgbackup
    gparted
    # Hardware/disk utils
    ntfs3g
    lshw
    usbutils
    nvme-cli
    glances
    ncdu
    # Langs
    (python312.withPackages(python-pkgs: with python-pkgs; [
      pip
      setuptools
      pylama
    ]))
    rustc
    # GUI stuff
    vlc
    xorg.xrandr
    xdg-utils
    bitwarden-desktop
    gimp-with-plugins
    krita
    appimage-run
    localsend
    # KDE Stuff
    kdePackages.discover
    kdePackages.kdeconnect-kde
    kdePackages.kaccounts-integration
    kdePackages.kaccounts-providers
    kdePackages.kio-gdrive
    konsave
    # Gaming and graphics
    vulkan-validation-layers
    vulkan-tools
    ffmpeg-full
    alvr
    headsetcontrol
    oversteer
    protontricks
    gamemode
    mangohud
    wineWowPackages.stable
    winetricks
    gamescope
    # Fonts
    powerline-fonts
    nerd-fonts.meslo-lg
    # Android Utilities
    android-tools
  ];

  # AppImage tweaks
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # udev rules
  # services.udev.extraRules = ''
  #   ACTION=="add", ATTRS{idVendor}=="", ATTRS{idProduct}=="", RUN+=""
  # '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Steam
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  # SteamVR fix?
  hardware.steam-hardware.enable = true;

  # KDEConnect
  programs.kdeconnect.enable = true;

  # XDG portal options (fixes alvr)
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
  };

  # List services that you want to enable:
  services.flatpak.enable = true;
# }}}
# system version {{{
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
# }}}
# docker {{{
  # Docker
  virtualisation.docker.enable = true;
  virtualisation.docker.rootless = {
    enable = true;
    setSocketVariable = true;
  };
  virtualisation.docker.autoPrune = {
    enable = true;
    dates = "weekly";
  };
# }}}
# garbage collector {{{
  # Garbage Collector
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";  # Args to pass to nix-collect-garbage
  };
# }}}
}
