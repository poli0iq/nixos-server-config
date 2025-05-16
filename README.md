Deploy with nixos-anywhere:
```bash
nix run github:nix-community/nixos-anywhere -- --no-disko-deps --copy-host-keys --generate-hardware-config nixos-generate-config system/<host>/hardware-configuration.nix --flake .#<host> --target-host root@<host>
```

Update with nixos-rebuild:
```bash
nixos-rebuild --flake . --target-host poli@<host> --build-host poli@<host> switch --use-remote-sudo
```
