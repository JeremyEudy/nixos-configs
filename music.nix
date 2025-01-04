{ pkgs, ... }:
{
  imports = [
    # musnix might cause possible slowdowns unless it's on a realtime kernel?
    <musnix>
  ];

  environment.systemPackages = with pkgs; [
    reaper
    helm
    # Required for yabdridge
    wine-staging
    # VST management
    yabridge
    yabridgectl
  ];

  # Required to squash realtime complaints from yabridge
  musnix.enable = true;

  security.pam.loginLimits = [
    { domain = "@audio"; item = "memlock"; type = "-"   ; value = "unlimited"; }
    { domain = "@audio"; item = "rtprio" ; type = "-"   ; value = "99"       ; }
    { domain = "@audio"; item = "nofile" ; type = "soft"; value = "99999"    ; }
    { domain = "@audio"; item = "nofile" ; type = "hard"; value = "99999"    ; }
  ];

  services.udev.extraRules = ''
    KERNEL=="rtc0", GROUP="audio"
    KERNEL=="hpet", GROUP="audio"
  '';
}
