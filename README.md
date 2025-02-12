# nix
Nix configuration for my computers

Configuration from [text](https://github.com/dmmulroy/kickstart.nix/tree/main)

## Install

### Install nix

Go to [nix website](https://nixos.org/download/) for install nix

```
sh <(curl -L https://nixos.org/nix/install)
```

### Install nix configuration

This command is used for use flake.nix and configure the system with the configuration defined in this folder

```
nix run nix-darwin --extra-experimental-features "nix-command flakes" -- switch --flake ~/nix#simple
```

### Reconfigure the system

If you change a configuration, you need to execute a command. This one will reuse the flake.nix and update your system configuration

```
darwin-rebuild switch --flake ~/nix#simple
```