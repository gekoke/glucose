{ self, ... }:
{

  flake = {
    nixosModules = rec {
      default = glucose;

      glucose =
        {
          config,
          options,
          lib,
          pkgs,
          ...
        }:
        let
          inherit (self.packages.${pkgs.system}) glucose;
        in
        {
          options.services.glucose = {
            enable = lib.mkEnableOption "the Glucose service";
            port = lib.mkOption {
              type = lib.types.port;
              default = 18133;
              description = "The port to run Glucose on";
            };
            user = lib.mkOption {
              type = lib.types.str;
              default = "glucose";
              description = "The user for the Glucose service";
            };
            environmentFile = lib.mkOption {
              type = lib.types.path;
              description = "Path to the systemd environment file for the service";
            };
          };

          config =
            let
              cfg = config.services.glucose;
            in
            lib.mkIf cfg.enable {
              users.users."${cfg.user}".isNormalUser = true;
              systemd.services.glucose = {
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  EnvironmentFile = cfg.environmentFile;
                  User = cfg.user;
                  ExecStart = "${glucose}/bin/fastapi run --port ${toString cfg.port} ${glucose}/lib/python3.12/site-packages/glucose/main.py";
                };
              };
            };
        };
    };
  };
}
