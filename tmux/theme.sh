# ----------------------------------------------------------------------------
# Tmux Color and Style setup
# ----------------------------------------------------------------------------

# Colors
tm_color_active=colour32
tm_color_inactive=colour241
tm_color_feature=colour206
tm_color_music=colour215
tm_active_border_color=colour240

# Separators
tm_separator_left_bold="◀"
tm_separator_left_thin="❮"
tm_separator_right_bold="▶"
tm_separator_right_thin="❯"
tm_person_icon="👤"

set -g status-left-length 32
set -g status-right-length 150
set -g status-interval 10

# Default Statusbar colors
set-option -g status-style fg=$tm_color_active,bg=default,default

# Default window title colors
set -g window-status-style fg=$tm_color_inactive,bg=default
set -g window-status-format "#I #W"

# active window title colors
set -g window-status-current-style fg=$tm_color_active,bg=default
set -g  window-status-current-format "$tm_separator_left_thin #I #W $tm_separator_right_thin"

# pane border
set -g pane-border-style fg=$tm_color_inactive
set -g pane-active-border-style fg=$tm_active_border_color

# message text
set -g message-style bg=default,fg=$tm_color_active

# pane number display
set-option -g display-panes-active-colour $tm_color_active
set-option -g display-panes-colour $tm_color_inactive

# clock
set-window-option -g clock-mode-colour $tm_color_active

tm_tunes="#[fg=$tm_color_music]#(~/.dotfiles/tmux/music.sh)"

tm_date="#[fg=$tm_color_inactive] %R %d %b"
tm_host="#[fg=$tm_color_feature,bold]#h"
tm_session_name="#[fg=$tm_color_feature,bold]#S"

set -g status-left $tm_person_icon'     '
set -g status-right $tm_tunes' '$tm_date' '$tm_host
