{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    reaper
    helm
  ];
}
