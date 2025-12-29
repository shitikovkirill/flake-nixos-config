# flake-nixos-config


```bash
mkdir -p ~/.config/nix/
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
```

```bash
sudo nixos-rebuild build  --flake .#asus-n56vj --impure
sudo nixos-rebuild switch --flake .#asus-n56vj --impure
```
