#pyenv
# Set the Pyenv root directory
export PYENV_ROOT="$HOME/.pyenv"

# Check if Pyenv is installed by checking for the existence of the Pyenv binary
if [[ -d "$PYENV_ROOT" && -x "$PYENV_ROOT/bin/pyenv" ]]; then
    # Add Pyenv to PATH only if it's not already there
    if [[ ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
        export PATH="$PYENV_ROOT/bin:$PATH"
    fi

    # Initialize Pyenv
    eval "$(pyenv init -)"
fi