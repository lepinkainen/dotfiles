function grep --wraps=rg --description 'rg wrapper, falls back to grep under Claude Code'
    if set -q CLAUDECODE
        command grep $argv
    else if type -q rg
        rg $argv
    else
        command grep $argv
    end
end
