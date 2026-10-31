# Caps Lock as Hyper on juggernaut

`keychron.conf` maps Caps Lock on the Keychron Q3 (USB ID `3434:0123`)
to Ctrl+Alt+Shift+Meta while held. Tapping Caps Lock does nothing.
The keyboard firmware and other keyboards are unaffected.

Install dependencies with `brew install keyd patchelf`. Homebrew's build reads
configuration from `/home/linuxbrew/.linuxbrew/etc/keyd/`.
These files are source copies; install updates explicitly:

```sh
keyd check ~/.config/keyd/keychron.conf
sudo install -Dm755 /home/linuxbrew/.linuxbrew/opt/keyd/bin/keyd /usr/local/bin/keyd
sudo /home/linuxbrew/.linuxbrew/bin/patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 /usr/local/bin/keyd
sudo restorecon /usr/local/bin/keyd
getent group keyd || sudo groupadd --system keyd
sudo install -d -m755 /home/linuxbrew/.linuxbrew/var/run
sudo install -Dm644 ~/.config/keyd/keychron.conf /home/linuxbrew/.linuxbrew/etc/keyd/keychron.conf
sudo install -Dm644 ~/.config/keyd/keyd.service /etc/systemd/system/keyd.service
sudo systemctl daemon-reload
sudo systemctl enable --now keyd.service
# After subsequent configuration edits:
sudo /usr/local/bin/keyd reload
```

The root-owned executable copy with the host loader avoids SELinux blocking
Homebrew's home-directory executable and interpreter paths. `/usr/local` points
to writable `/var/usrlocal` on Bazzite. Refresh and patch the executable copy
after upgrading keyd in Homebrew. SELinux policy is unchanged.

Keep Plasma's Caps Lock XKB remapping disabled. Assign desktop shortcuts using
Ctrl+Alt+Shift+Meta+letter. Existing Ctrl+Alt Rectangle shortcuts remain separate;
no layout action is assigned here.

Inspect with `sudo journalctl -u keyd.service` or `sudo /usr/local/bin/keyd monitor`.
Disable with `sudo systemctl disable --now keyd.service`.
The emergency stop chord is Backspace+Escape+Enter. The service deliberately has
no automatic restart so that the emergency stop stays effective.
