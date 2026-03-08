## Updating

```bash
nixos-rebuild --flake .#<host> switch --target-host poli@<host>.host.0iq.dev --use-remote-sudo
```

## Dedicated server

### Deployment

1. ```bash
   mkdir -p /tmp/<host>-extra-files/etc/ssh
   ssh-keygen -ted25519 -N"" -f /tmp/<host>-extra-files/etc/ssh/ssh_host_ed25519_key
   ssh-to-age </tmp/<host>-extra-files/etc/ssh/ssh_host_ed25519_key.pub
   ```
   Update `.sops.yaml` and `sops updatekeys secrets/*`.

2. For sshd in initrd (in the absence of TPM2):
   ```bash
   mkdir -p /tmp/<host>-extra-files/etc/secrets/initrd
   ssh-keygen -ted25519 -N"" -f /tmp/<host>-extra-files/etc/secrets/initrd/ssh_host_ed25519_key
   ```

3. ```bash
   nix run github:nix-community/nixos-anywhere -- --flake .#<host> \
       --disk-encryption-keys /tmp/secret.key /tmp/<host>-luks-pass \
       --extra-files /tmp/<host>-extra-files \
       root@<host>.host.0iq.dev
   ```

### LUKS unlock via SSH

```bash
rbw get <host>.host.0iq.dev --field LUKS | ssh -p2222 root@<host>.host.0iq.dev
```

## VPS deployment (moeka)

(Needs updating)

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#<host> \
    --no-disko-deps --copy-host-keys \
    --generate-hardware-config nixos-generate-config system/<host>/hardware-configuration.nix \
    --target-host root@<host>
```
