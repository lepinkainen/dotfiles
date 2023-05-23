# Generic binaries
if test -d "$HOME/bin/"
    set -gx fish_user_paths $HOME/bin/ $fish_user_paths
end

# More generic local binaries
if test -d "$HOME/.local/bin/"
    set -gx fish_user_paths $HOME/.local/bin/ $fish_user_paths
end

# homebrew
if test -d "/opt/homebrew/bin/"
    set -gx fish_user_paths /opt/homebrew/bin/ $fish_user_paths
end

# Default go binary path
if test -d "$HOME/go/bin/"
    set -gx fish_user_paths $HOME/go/bin/ $fish_user_paths
end

# Rustup
if test -d "$HOME/.cargo/bin/"
    set -gx fish_user_paths $HOME/.cargo/bin/ $fish_user_paths
end

# Doom-emacs
if test -d "$HOME/.emacs.d/bin/"
    set -gx fish_user_paths $HOME/.emacs.d/bin/ $fish_user_paths
end

# Sqlite
if test -d "/usr/local/opt/sqlite/bin"
    set -gx fish_user_paths "/usr/local/opt/sqlite/bin" $fish_user_paths
end

if test -d "/usr/local/opt/node@12/bin"
    set -gx fish_user_paths "/usr/local/opt/node@12/bin" $fish_user_paths
end

# Open vscode editor in a new window and wait for the file to be saved
if test -e "/usr/local/bin/code"
    set -U EDITOR code -nw
else
    set -U EDITOR nano
end

set -Ux LANG en_US.UTF-8
set -Ux LC_ALL en_US.UTF-8

# Google cloud sdk stuff
if test -f "$HOME/google-cloud-sdk/path.fish.inc"
    source "$HOME/google-cloud-sdk/path.fish.inc"
end

# Run on exit
function on_exit --on-process %self
    echo fish is now exiting
end

# Run for login shells
if status --is-login
    uptime
end

if status --is-interactive
    atuin init fish --disable-up-arrow | source
end


# Automatically install fisher
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Greeting, runs on every shell
function fish_greeting
    if test -e "/usr/local/bin/task"
        task next
    end
end

# iTerm 2 integration
test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# Homeshick integration and completions
source "$HOME/.homesick/repos/homeshick/homeshick.fish"
source "$HOME/.homesick/repos/homeshick/completions/homeshick.fish"
# Check if a homeshick refresh is needed
#homeshick --quiet refresh

### Replace builtins with external software if available

# Exa is an ls replacement
if type -q exa
  alias ls "exa --time-style long-iso"
end

# Bat is a fancier cat
if type -q bat
  alias cat bat
end

# Bat is named batcat on ubuntu/debian, because of reasons
if type -q batcat
  alias cat batcat
end

# Swap git pager depending on what's installed
if type -q diff-so-fancy
  git config --global core.pager "diff-so-fancy | less --tabs=4 -RFX"
else
  git config --global core.pager "less"
end

# Use starship prompt if installed
if type -q starship
  starship init fish | source
end
