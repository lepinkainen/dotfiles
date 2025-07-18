# # Base16 Shell: https://github.com/chriskempson/base16-shell
# if status --is-interactive
#     set BASE16_SHELL "$HOME/.config/base16-shell/"
#     source "$BASE16_SHELL/profile_helper.fish"
# end

# base16-materia

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
    # Initialize atuin, disable up-arrow search
    if type -q atuin
        atuin init fish --disable-up-arrow | source
    end
    # init kubectl completions
    if type -q kubectl
        kubectl completion fish | source
    end
    
    # Initialize zoxide (better cd command) if available
    if type -q zoxide
        zoxide init fish | source
    end
end

# Automatically install fisher
if not functions -q fisher
    set -q XDG_CONFIG_HOME; or set XDG_CONFIG_HOME ~/.config
    curl https://git.io/fisher --create-dirs -sLo $XDG_CONFIG_HOME/fish/functions/fisher.fish
    fish -c fisher
end

# Greeting, runs on every shell
function fish_greeting
    #if test -e "/usr/local/bin/task"
    #    task next
    #end
end

# iTerm 2 integration
#test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

# GPG setup, it needs GPG_TTY set to do anything useful
set -gx GPG_TTY (tty)

### Replace builtins with external software if available

# Eza is an ls replacement. Exa is deprecated
if type -q eza
  alias ls "eza --time-style long-iso --icons --no-quotes --git --header"
end

# Bat is a fancier cat
if type -q bat
  alias cat bat
end

# Bat is named batcat on ubuntu/debian, because of reasons
if type -q batcat
  alias cat batcat
end

# fd is a better find
if type -q fd
  alias find fd
end

# ripgrep is a better grep
if type -q rg
  alias grep rg
end

# btop is a better top
if type -q btop
  alias top btop
  alias htop btop
end

# automatic env variables when entering directories
# plus other stuff
if type -q mise
    mise activate fish | source
end

# direnv things
if type -q direnv
    direnv hook fish | source
end

# Use starship prompt if installed
if type -q starship
  starship init fish | source
end

# connect to a single named tmux session at all times
if type -q tmux
    alias tmux "tmux new-session -A -s main"
end

# Kubernetes shortcuts if kubectl is available
if type -q kubectl
  alias k kubectl
end

# Function to extract various archive formats
function extract
    switch $argv[1]
        case '*.tar.bz2'
            tar xjf $argv[1]
        case '*.tar.gz'
            tar xzf $argv[1]
        case '*.bz2'
            bunzip2 $argv[1]
        case '*.rar'
            unrar x $argv[1]
        case '*.gz'
            gunzip $argv[1]
        case '*.tar'
            tar xf $argv[1]
        case '*.tbz2'
            tar xjf $argv[1]
        case '*.tgz'
            tar xzf $argv[1]
        case '*.zip'
            unzip $argv[1]
        case '*.Z'
            uncompress $argv[1]
        case '*.7z'
            7z x $argv[1]
        case '*'
            echo "'$argv[1]' cannot be extracted via extract"
    end
end

# Source local.fish if it exists
if test -f (dirname (status -f))/local.fish
    source (dirname (status -f))/local.fish
end
# Added by LM Studio CLI (lms)
set -gx PATH $PATH /Users/riku.lindblad/.cache/lm-studio/bin
# End of LM Studio CLI section

