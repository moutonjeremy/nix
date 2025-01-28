{inputs}: {
  pkgs,
  config,
  ...
}: let
in {
  # https://mipmip.github.io/home-manager-option-search/

  home.stateVersion = "24.05";

  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    fd
    gh
    gnused
    tree
    wget
  ];

  programs.gpg.enable = true;

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userEmail = "moutonjeremy@labbs.fr";
    userName = "Jeremy Mouton";
    signing = {
      signByDefault = true;
      key = "~/.ssh/key.pub";
    };
    lfs = {
      enable = true;
    };
    extraConfig = {
      branch.sort = "-committerdate";
      column.ui = "auto";
      core = {
        editor = "nvim";
        fsmonitor = true;
      };
      fetch = {
        prune = true;
        writeCommitGraph = true;
      };
      gpg.format = "ssh";
      user.signingkey = "~/.ssh/key.pub";
      init.defaultBranch = "main";
      pull.rebase = true;
      rebase.updateRefs = true;
      rerere.enabled = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableFishIntegration = true;
    colors = {
      bg = "#24273a";
      "bg+" = "#363a4f";
      spinner = "#f4dbd6";
      hl = "#ed8796";
      fg = "#cad3f5";
      header = "#ed8796";
      info = "#c6a0f6";
      pointer = "#f4dbd6";
      marker = "#f4dbd6";
      "fg+" = "#cad3f5";
      prompt = "#c6a0f6";
      "hl+" = "#ed8796";
    };
    defaultOptions = [
      "--bind ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down"
      "--preview 'cat {}'"
    ];
  };

  home.file = {
    ".ideavimrc" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/kickstart.nix/config/jetbrains/.ideavimrc";
    };
  };

  xdg.configFile = {
    ghostty = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/kickstart.nix/config/ghostty";
    };
  };

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraPackages = [
      # Included for nil_ls
      pkgs.cargo
      # Included to build telescope-fzf-native.nvim
      pkgs.cmake
      # Included for LuaSnip
      # pkgs.luajitPackages.jsregexp
      pkgs.lua54Packages.jsregexp
      # Included for conform
      pkgs.nodejs
    ];
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    vimdiffAlias = true;
    viAlias = true;
    vimAlias = true;
  };
}