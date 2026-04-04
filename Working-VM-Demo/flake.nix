{
  description = "NixOS VM with GNOME and Development Tools";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, llm-agents }: {
    nixosConfigurations.vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inputs = { inherit nixpkgs llm-agents; }; };
      modules = [
        ({ modulesPath, ... }: {
          imports = [
            (modulesPath + "/profiles/qemu-guest.nix")
            ./iso-configuration.nix
          ];

          # VM needs a root filesystem and bootloader
          fileSystems."/" = {
            device = "/dev/disk/by-label/nixos";
            fsType = "ext4";
          };
          boot.loader.grub.device = "/dev/vda";

          # VM display and resource settings
          virtualisation.vmVariant = {
            virtualisation = {
              memorySize = 4096;
              cores = 2;
              qemu.options = [
                "-vga virtio"
              ];
            };
          };
        })
      ];
    };

    # Development shell for working on this flake
    devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
      name = "nixiso-vm-dev";
      packages = with nixpkgs.legacyPackages.x86_64-linux; [
        alejandra  # Nix formatter
        nil        # Nix language server
      ];
      shellHook = ''
        echo "Nixiso-VM development environment"
        echo ""
        echo "Commands:"
        echo "  nixos-rebuild build-vm --flake .#vm  - Build VM"
        echo "  ./result/bin/run-nixos-live-vm       - Run VM"
      '';
    };
  };
}
