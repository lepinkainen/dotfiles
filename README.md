# Dotfiles

My personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Installation

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lepinkainen
```

## Fresh machine

1. Put this machine's age private key at `~/.config/chezmoi/key.txt`
   (copy from 1Password or another machine; a brand-new key also needs its
   public key added to `key/recipients.txt` and the secrets re-encrypted,
   see CLAUDE.md). Nothing else needs installing first.
2. Run the install command above. The apply installs Homebrew, the casks
   from the Brewfile, mise and everything in its config (`mise bootstrap`),
   and only then the scripts that need those tools. Expect a sudo prompt
   or two.

If the key was missing in step 1, the encrypted files (`~/.ssh/config`,
`~/.config/cal/config.yaml`) are skipped with a warning. Place the key and
run `chezmoi apply` again.
