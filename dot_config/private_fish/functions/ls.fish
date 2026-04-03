function ls --wraps=eza --description 'eza with icons, falls back to ls under Claude Code'
    if set -q CLAUDECODE
        command ls $argv
    else if type -q eza
        eza --time-style long-iso --icons --no-quotes --git --header $argv
    else
        command ls $argv
    end
end
