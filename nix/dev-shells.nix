_: {
  perSystem =
    {
      config,
      pkgs,
      workspace,
      pythonSet,
      ...
    }:
    {
      devShells = {
        default =
          let
            virtualenv = (pythonSet.mkVirtualEnv "glucose-dev-env" workspace.deps.all).overrideAttrs (_: {
              venvIgnoreCollisions = [ "bin/fastapi" ];
            });
          in
          pkgs.mkShellNoCC {
            inputsFrom = [ virtualenv ];

            packages = [
              virtualenv
              pkgs.uv
              pkgs.pyright
              pkgs.ruff
            ];

            env = {
              # Don't create venv using uv
              UV_NO_SYNC = "1";
              # Force uv to use Python interpreter from venv
              UV_PYTHON = "${virtualenv}/bin/python";
              # Prevent uv from downloading managed Python's
              UV_PYTHON_DOWNLOADS = "never";
            };

            shellHook = ''
              # Undo dependency propagation by nixpkgs.
              unset PYTHONPATH

              ${config.pre-commit.installationScript}
            '';
          };
      };
    };
}
