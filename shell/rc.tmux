# Shared tmux helpers and optional autostart.

case $- in
  *i*) ;;
  *) return 0 2>/dev/null || exit 0 ;;
esac

command -v tmux >/dev/null 2>&1 || return 0 2>/dev/null || exit 0

_configs_tmux_apply_status() {
  tmux set-option -g mouse on >/dev/null
  tmux set-option -g status-left-length 40 >/dev/null
  tmux set-option -g status-left " #h:#S " >/dev/null
}

_configs_tmux_connect() {
  session="$1"
  _configs_tmux_apply_status

  if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$session"
  else
    tmux attach-session -t "$session"
  fi
}

_configs_tmux_slot() {
  slot="$1"

  if tmux has-session -t "$slot" 2>/dev/null; then
    _configs_tmux_connect "$slot"
    return
  fi

  tmux new-session -d -s "$slot"
  _configs_tmux_apply_status

  if [ -n "${TMUX:-}" ]; then
    tmux switch-client -t "$slot"
  else
    tmux attach-session -t "$slot"
  fi
}

alias t1='_configs_tmux_slot 1'
alias t2='_configs_tmux_slot 2'
alias t3='_configs_tmux_slot 3'
alias t4='_configs_tmux_slot 4'
alias t5='_configs_tmux_slot 5'
alias tl='tmux list-sessions'

_configs_tmux_autostart() {
  [ -z "${TMUX:-}" ] || return 0

  case "${CONFIGS_TMUX_AUTO:-off}" in
    ssh)
      [ -n "${SSH_CONNECTION:-}" ] || return 0
      ;;
    all)
      ;;
    off|"")
      return 0
      ;;
    *)
      return 0
      ;;
  esac

  tmux new-session -A -s "${CONFIGS_TMUX_SESSION:-main}"
}

_configs_tmux_autostart
