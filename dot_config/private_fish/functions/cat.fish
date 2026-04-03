function cat --wraps=bat --description 'bat wrapper, falls back to cat under Claude Code'
    if set -q CLAUDECODE
        command cat $argv
    else if type -q bat
        bat $argv
    else if type -q batcat
        batcat $argv
    else
        command cat $argv
    end
end
