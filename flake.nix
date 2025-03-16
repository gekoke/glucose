{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    systems.url = "github:nix-systems/x86_64-linux";

    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs = {
        pyproject-nix.follows = "pyproject-nix";
        nixpkgs.follows = "nixpkgs";
      };
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs = {
        pyproject-nix.follows = "pyproject-nix";
        uv2nix.follows = "uv2nix";
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports =
        let
          initializeUvWorkspace = {
            perSystem =
              { lib, pkgs, ... }:
              {
                _module.args = rec {
                  workspace = inputs.uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };
                  python = pkgs.python312;
                  pythonSet =
                    (pkgs.callPackage inputs.pyproject-nix.build.packages {
                      inherit python;
                    }).overrideScope
                      (
                        lib.composeManyExtensions [
                          (workspace.mkPyprojectOverlay { sourcePreference = "wheel"; })
                          inputs.pyproject-build-systems.overlays.default
                        ]
                      );
                };
              };
          };
        in
        [
          initializeUvWorkspace
          ./nix/checks.nix
          ./nix/dev-shells.nix
          ./nix/formatter.nix
          ./nix/nixos-module.nix
          ./nix/packages.nix
        ];
    };
}
