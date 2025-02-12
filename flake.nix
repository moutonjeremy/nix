{
  description = "Personnal nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    xcode-installer = import ./xcode-installer.nix;
    configuration = { pkgs, config, ... }: {
      nixpkgs.config.allowUnfree = true;
      nixpkgs.config.allowBroken = true;

      environment.systemPackages = [
        (xcode-installer { inherit pkgs; })
        pkgs.mkalias
        pkgs.neovim
        pkgs.vscode
        pkgs.go
        pkgs.golangci-lint
        pkgs.terraform
        pkgs.terraform-docs
        pkgs.git
        pkgs.eza
        pkgs.awscli
        pkgs.podman-desktop
        pkgs.discord
        pkgs.ollama
        pkgs.aerospace
      ];

      system.activationScripts = {
        pre.text = ''
          echo "Installation de Xcode Command Line Tools..."
          ${xcode-installer { inherit pkgs; }}/bin/install-xcode
        '';

        applications.text = let
          env = pkgs.buildEnv {
            name = "system-applications";
            paths = config.environment.systemPackages;
            pathsToLink = "/Applications";
          };
        in
          pkgs.lib.mkForce ''
            echo "setting up /Applications..." >&2
            rm -rf /Applications/Nix\ Apps
            mkdir -p /Applications/Nix\ Apps
            find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
            while read -r src; do
              app_name=$(basename "$src")
              echo "copying $src" >&2
              ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
            done
          '';
      };

      homebrew = {
        enable = true;
        casks = [
          "vlc"
          "ghostty"
          "spotify"
          "proton-drive"
          "bambu-studio"
          "parsec"
          "slack"
        ];
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          upgrade = true;
        };
      };

      nix.settings.experimental-features = "nix-command flakes";
      programs.zsh.enable = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Nix daemon
      services.nix-daemon.enable = true;

      # Aerospace
      services.aerospace.enable = true;
      services.aerospace.settings = {
        gaps = {
          outer.left = 8;
          outer.bottom = 8;
          outer.top = 8;
          outer.right = 8;
        };
      };

      # System configuration
      system.defaults = {
        dock.persistent-apps = [
          "/Applications/Ghostty.app"
          "/Applications/Spotify.app"
        ];
        finder.FXPreferredViewStyle = "Nlsv";
        loginwindow.GuestEnabled  = false;
        NSGlobalDomain.AppleICUForce24HourTime = true;
        NSGlobalDomain.AppleShowAllExtensions = true;
        finder.ShowPathbar = true;
        dock.tilesize = 32;
        dock.show-recents = false;
      };

      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "jerem";
            autoMigrate = true;
          };
        }
      ];
    };
  };
}