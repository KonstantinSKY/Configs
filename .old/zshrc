# pyenv
# Set the Pyenv root directory
export PYENV_ROOT="$HOME/.pyenv"

# Add Pyenv to PATH only if the Pyenv binary directory exists
if [[ -d "$PYENV_ROOT/bin" ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
fi

# Initialize Pyenv if the Pyenv init script is available
if [[ -x "$(command -v pyenv)" ]]; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi