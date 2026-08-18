function fish_user_key_bindings
    if functions -q _fifc; and set -q fifc_keybinding
        bind $fifc_keybinding _fifc
        bind -M insert $fifc_keybinding _fifc
    end
end
