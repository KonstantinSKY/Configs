# Skip if not interactive
case $- in
  *i*) ;;
  *) return ;;
esac

[[ -d "$HOME/Work" ]] && WORK="$HOME/Work" || WORK="$HOME"

export CONFIGS_PATH="$WORK/Configs"
export PROJECTS_PATH="$WORK/Projects"
export BACKUPS_PATH="$WORK/BackUps"
export PATH="$HOME/.cargo/bin:$PATH"

alias Configs='cd $CONFIGS_PATH; ls -ls'
alias Projects='cd $PROJECTS_PATH; ls -ls'

# fnm
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
fi
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

if command -v bat > /dev/null 2>&1; then
    alias cat='bat --paging=never'
    alias lcat='/usr/bin/cat'
fi

la() { command ls "$@" -la --color=auto; }
chx() { command chmod u+x "$@"; }

cdl() {
  cd "$@" && ls -la --color=auto
}

z() {
  if [ -n "$1" ]; then
    zeditor "$1"
  else
    zeditor .
  fi
}

# Send deletes to trash when the helper is available.
if command -v trash >/dev/null 2>&1; then
  alias rm='trash'
  alias trashbox='trash --help'
fi

alias rsss="remote_start_sudo_script.sh"
alias server="ssh server"

choose_editor() {
  if command -v nvim >/dev/null 2>&1; then
    nvim "$@"
  else
    command vi "$@"
  fi
}
alias vi=choose_editor
alias ge=gemini

# GNU Make Global Configuration
export MAKEFILES="$CONFIGS_PATH/make/all.mk"
export MAKEFLAGS="-I $CONFIGS_PATH/make"
