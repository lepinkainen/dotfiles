function top --wraps=btop --description 'btop wrapper'
    if type -q btop
        btop $argv
    else
        command top $argv
    end
end
