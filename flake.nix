{
  description = "Converter for the OPB format to be used by pbcount";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    crane.url = "github:ipetkov/crane/v0.23.4";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      fenix,
      crane,
      treefmt-nix,
      ...
    }:
    let
      lib = nixpkgs.lib;

      # All supported build systems.
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      treefmt =
        system:
        (treefmt-nix.lib.evalModule nixpkgs.legacyPackages.${system} ./nix/treefmt.nix).config.build;

      defaultAttrs = {
        inherit crane;
        inherit fenix;
      };
    in
    {
      formatter = lib.genAttrs systems (system: (treefmt system).wrapper);

      overlays.default = final: prev: {
        opb2pbcount = final.callPackage ./nix/default.nix defaultAttrs;
      };

      packages = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;
        in
        {
          default = pkgs.opb2pbcount;

          container = pkgs.dockerTools.buildImage {
            name = "opb2pbcount";
            copyToRoot = pkgs.buildEnv {
              name = "opb2pbcount";
              paths = [
                pkgs.opb2pbcount
                pkgs.time
              ];
              pathsToLink = [ "/bin" ];
            };
            config = {
              Entrypoint = [ "opb2pbcount" ];
              Labels = {
                "org.opencontainers.image.source" = "https://github.com/practical-kc/opb2pbcount";
                "org.opencontainers.image.description" = "Converter for the OPB format to be used by pbcount";
                "org.opencontainers.image.licenses" = "LGPL-3.0-or-later";
              };
            };
          };
        }
      );

      checks = lib.genAttrs systems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          format = (treefmt system).check self;
          lint = pkgs.callPackage ./nix/default.nix (defaultAttrs // { lint = true; });
        }
      );
    };
}
