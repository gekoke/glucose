_: {
  perSystem =
    {
      workspace,
      pythonSet,
      ...
    }:
    {
      packages = rec {
        default = glucose;
        glucose = (pythonSet.mkVirtualEnv "glucose-env" workspace.deps.default).overrideAttrs (_: {
          venvIgnoreCollisions = [ "bin/fastapi" ];
        });
      };
    };
}
