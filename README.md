# Dotfiles

My personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

## Installation

```
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lepinkainen
```

## Fresh machine

1. Put this machine's age private key at `~/.config/chezmoi/key.txt`
   (copy from another machine / 1Password, or generate one and add its
   public key to `key/recipients.txt`, see CLAUDE.md). Until it exists,
   encrypted files (`~/.ssh/config`, `~/.config/cal/config.yaml`) are
   skipped and `chezmoi apply` prints a warning.
2. Run the install command above.
3. `mise bootstrap` to install CLI tools, then `chezmoi init` once more so
   the generated config picks up `delta` as the diff pager.
