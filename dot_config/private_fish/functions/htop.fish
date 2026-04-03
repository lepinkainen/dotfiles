function htop --wraps=btop --description 'btop wrapper'
    if type -q btop
        btop $argv
    else
        command htop $argv
    end
end
