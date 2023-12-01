{
  description = "A scrollable-tiling Wayland compositor";

  inputs.crane.url = "github:ipetkov/crane";

  outputs = { self, nixpkgs, crane }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      craneLib = crane.mkLib pkgs;
      lib = pkgs.lib;
    in
    {
      packages.x86_64-linux.default = craneLib.buildPackage {
        pname = "niri";
        version = "25.02";

        src = with lib; cleanSourceWith {
          src = self;
          filter = path: type:
            hasInfix "/resources/" path ||
            hasInfix "/shaders/" path ||
            hasInfix "/snapshots/" path ||
            hasSuffix ".frag" path ||
            hasSuffix ".vert" path ||
            craneLib.filterCargoSources path type;
        };

        nativeBuildInputs = with pkgs; [
          pkg-config
          rustPlatform.bindgenHook
        ];

        buildInputs = with pkgs; wlroots.buildInputs ++ [
          pam
          pango
          pipewire
          libGL
        ];

        preCheck = ''
          export XDG_RUNTIME_DIR=$TMPDIR
        '';

        postInstall = ''
          cp resources/niri-session $out/bin/
        '';

        env.CARGO_BUILD_RUSTFLAGS = lib.concatStringsSep " " [
          "-C link-arg=-Wl,--push-state,--no-as-needed"
          "-C link-arg=-lEGL"
          "-C link-arg=-lwayland-client"
          "-C link-arg=-Wl,--pop-state"
        ];
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
          pango
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
