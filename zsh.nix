{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    zsh-powerlevel10k
  ];
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableLsColors = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    histSize = 10000;
    promptInit = ''
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
      export POWERLEVEL10K_MODE=nerdfont-complete
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      fortune | cowsay | lolcat
    '';
    ohMyZsh = {
      enable = true;
      plugins = [
        "aliases" "docker" "docker-compose"
        "git" "man" "pip" "python" "sudo"
        "web-search" "zsh-interactive-cd"
      ];
    };
    shellAliases = {
      open = "xdg-open";
      extip = "curl -s 4.ipquail.com/ip";
      fixaudio = "sudo headsetcontrol -s 100";
      fa = "fixaudio";
      stop = "bash /home/jeremy/Utilities/Helper/kill_shortcut.sh";
      master = "gco master && gl";
      docker-compose = "docker compose";
      dl = "docker-compose logs -f";
      drl = "docker-compose down && docker-compose up -d && docker-compose logs -f";
      drb = "docker-compose down && docker-compose up --build -d && docker-compose logs -f";
      dr = "docker-compose down && docker-compose up -d";
      dn = "docker-compose down";
      de = "docker-compose exec";
      dps = "docker-compose ps";
      greatfox = "ssh -X jeremy@greatfox.net";
      sl = "source .local.rc";
    };
  };
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];
}
