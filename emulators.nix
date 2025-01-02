{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    retroarchFull
  ];
}
