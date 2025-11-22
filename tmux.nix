{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    tmux
  ];
  programs.tmux = {
    enable = true;
    clock24 = true;
    plugins = [ pkgs.tmuxPlugins.catppuccin ];
    extraConfig = ''
      # *FUNCTIONAL CHANGES* {{{
      #remap prefix from 'C-b' to 'M-w'
      unbind C-b
      set-option -g prefix M-w
      bind-key M-w send-prefix

      # fix escape delay
      set -s escape-time 0

      # vi-copy and copy/paste fix for different tmux versions
      run-shell "tmux setenv -g TMUX_VERSION $(tmux -V | cut -d' ' -f2)"
      set -g mode-keys vi
      if-shell '[ $(echo "$TMUX_VERSION >= 2.4" | bc) == 1]' \
      "\
          bind-key -T copy-mode-vi v send -X begin-selection; \
          bind-key -T copy-mode-vi y send -X copy-selection; \
          bind-key -T copy-mode-vi V send -X rectangle-toggle; \
      "
      if-shell '[ $(echo "$TMUX_VERSION < 2.4" | bc) == 1]' \
      "\
          bind -t vi-copy v begin-selection; \
          bind -t vi-copy y copy-selection; \
          bind -t vi-copy V rectangle-toggle; \
      "
      if-shell '[ $TMUX_VERSION == "3.0a" ]' \
      "\
          bind-key -T copy-mode-vi v send -X begin-selection; \
          bind-key -T copy-mode-vi y send -X copy-selection; \
          bind-key -T copy-mode-vi V send -X rectangle-toggle; \
      "
      bind -n M-y copy-mode
      bind -n M-p paste-buffer
      bind C-p run-shell "tmux set-buffer \"$(xclip -o)\"; tmux paste-buffer"
      bind C-y run-shell "tmux show-buffer | xclip -sel clip -i"

      # split panes using | and -
      unbind '"'
      unbind %
      bind c new-window -c "#{pane_current_path}"
      bind -n M-\\ split-window -h -c "#{pane_current_path}"
      bind -n M-| split-window -h -c "#{pane_current_path}"
      bind -n M-- split-window -v -c "#{pane_current_path}"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # reload config file (change file location to your the tmux.conf you want to use)
      bind -n M-r source-file ~/.tmux.conf \; display "Reloaded ~/.tmux.conf"

      # switch panes using Vim keybinds
      bind -n M-h select-pane -L
      bind -n M-l select-pane -R
      bind -n M-k select-pane -U
      bind -n M-j select-pane -D

      # Enable mouse mode (tmux 2.1 and above)
      set -g mouse on

      # Window Controls
      bind k kill-pane
      bind l kill-session
      bind < resize-pane -L 1
      bind > resize-pane -R 1
      bind - resize-pane -D 1
      bind = resize-pane -U 1
      bind -n C-Left resize-pane -L 10
      bind -n C-Right resize-pane -R 10
      bind -n C-Down resize-pane -D 10
      bind -n C-Up resize-pane -U 10
      bind -n C-M-h resize-pane -L 5
      bind -n C-M-l resize-pane -R 5
      bind -n C-M-j resize-pane -D 5
      bind -n C-M-k resize-pane -U 5
      bind . command-prompt
      bind a last-window
      bind space command-prompt -p index "select-window"
      bind -n M-c new-window
      bind -n C-M-c clear-history

      # don't rename windows automatically
      # set-option -g allow-rename off
      # set-window-option -g allow-rename off
      # }}}
      # *DESIGN CHANGES* {{{
      # Colors
      set -g default-terminal "screen-256color"
      set -g @catppuccin_flavour 'mocha'
      set -g @catppuccin_window_tabs_enabled on
      set -g @catppuccin_date_time "%H:%M"
      # }}}
    '';
  };
}
