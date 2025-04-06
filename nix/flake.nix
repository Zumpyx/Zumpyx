{
  description = "Zumpyx Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, lib, config, ... }: {

      nixpkgs.config.allowUnfree = true;
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
          # 必需品
          pkgs.tig pkgs.neovim pkgs.tmux pkgs.ranger pkgs.kitty 
          pkgs.yabai pkgs.skhd  # 平铺式窗口与快捷键

          # 生锈了
          pkgs.helix pkgs.zellij pkgs.yazi pkgs.alacritty pkgs.bat pkgs.starship pkgs.fd pkgs.lsd pkgs.sniffnet pkgs.atuin pkgs.czkawka pkgs.gitui pkgs.zola pkgs.asciinema

          # 配置相关包
          pkgs.mkalias

          # 常用应用
          pkgs.obsidian 
          

          # 网络安全
          pkgs.nmap pkgs.seclists pkgs.feroxbuster pkgs.gobuster pkgs.rustscan
          pkgs.alterx pkgs.chaos pkgs.cloudlist pkgs.cvemap pkgs.dnsx pkgs.httpx pkgs.interactsh pkgs.katana pkgs.naabu pkgs.notify pkgs.nuclei pkgs.subfinder pkgs.uncover # ProjectDiscovery

          # 暂不支持
          # pkgs.obs-studio
        ];

      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        noto-fonts-color-emoji
        liberation_ttf
        fira-code
        fira-code-symbols
        mplus-outline-fonts.githubRelease
        dina-font
        proggyfonts
      ] ++ (builtins.filter lib.attrsets.isDerivation (builtins.attrValues nerd-fonts));

      # Macos 索引
      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
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



      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";


      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."Zumpyx" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
      ];
    };
  };
}
