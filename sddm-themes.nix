{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [(
    pkgs.catppuccin-sddm.override {
      flavor = "mocha";
      font  = "Noto Sans";
      fontSize = "9";
      background = "${./assets/cozy.jpg}";
      loginBackground = true;
    }
  )];

  services.displayManager.sddm.theme = "catppuccin-mocha";
}
