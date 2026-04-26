{
  description = "Minimal NixOS aarch64 installer ISO with mainline kernel 7.0 — boot test for ASUS ZenBook A14";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
    in {
      nixosConfigurations.installer = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./iso.nix ];
      };

      packages.${system}.default =
        self.nixosConfigurations.installer.config.system.build.isoImage;
    };
}
