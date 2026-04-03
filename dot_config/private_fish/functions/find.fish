function find --wraps=fd --description 'fd wrapper, falls back to find under Claude Code'
    if set -q CLAUDECODE
        command find $argv
    else if type -q fd
        fd $argv
    else
        command find $argv
    end
end
