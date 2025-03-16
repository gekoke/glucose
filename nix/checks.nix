{ inputs, ... }:
{
  imports = [ inputs.pre-commit-hooks.flakeModule ];

  perSystem =
    {
      pkgs,
      ...
    }:
    {
      pre-commit = {
        settings = {
          hooks = {
            deadnix = {
              enable = true;
              settings = {
                edit = true;
              };
            };
            nixfmt-rfc-style = {
              enable = true;
            };
            statix.enable = true;
            gitleaks = {
              enable = true;
              name = "gitleaks";
              entry = "${pkgs.gitleaks}/bin/gitleaks protect --verbose --redact --staged";
              pass_filenames = false;
            };
            ruff = {
              enable = true;
              pass_filenames = false;
            };
            ruff-formatting = {
              enable = true;
              name = "ruff-formatting";
              entry = "${pkgs.ruff}/bin/ruff format";
              pass_filenames = false;
            };
          };
        };
      };
    };
}
