{
  description = "A very basic flake";

  inputs.crane = {
    url = "github:ipetkov/crane";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, crane }:
    let
      craneLib = crane.lib.x86_64-linux;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lib = pkgs.lib;
    in
    {
      packages.x86_64-linux.default = craneLib.buildPackage {
        pname = "niri";
        version = "0.1.0-alpha.1";

        src = with lib; cleanSourceWith {
          src = self;
          filter = path: type:
            hasInfix "/resources/" path ||
            craneLib.filterCargoSources path type;
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
          rustPlatform.bindgenHook
        ];

        buildInputs = with pkgs; wlroots.buildInputs ++ [
          pam
          pipewire
          libGL
        ];

        postInstall = ''
          ${pkgs.patchelf}/bin/patchelf --add-needed ${pkgs.libGL}/lib/libEGL.so.1 $out/bin/niri
          cp resources/niri-session $out/bin/
        '';
      };

      packages.x86_64-linux.niri = self.packages.x86_64-linux.default;

      devShells.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
        name = "niri-shell";

        nativeBuildInputs = [
          pkg-config
          rustPlatform.bindgenHook
        ];

        buildInputs = wlroots.buildInputs ++ [
          rustc
          rustfmt
          cargo
          pam
          pipewire
          libGL
        ];
      };

      nixosModules.niri = import ./nixos/module.nix;

      overlays.default = final: _prev: {
        niri = self.packages.${final.system}.default;
      };
    };
}
