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
            postgresConnectionString = lib.mkOption {
              type = lib.types.str;
              description = "The connection string for the PostgreSQL connection";
            };
            user = lib.mkOption {
              type = lib.types.str;
              default = "glucose";
              description = "The user for the Glucose service";
            };
          };

          config = lib.mkIf config.services.glucose.enable {
            users.users."${config.services.glucose.user}".isNormalUser = true;
            systemd.services.glucose = {
              wantedBy = [ "multi-user.target" ];
              environment.GLUCOSE_POSTGRES_CONNECTION_STRING = config.services.glucose.postgresConnectionString;
              serviceConfig = {
                User = config.services.glucose.user;
                ExecStart =
                  let
                    inherit (config.services.glucose) port;
                  in
                  "${glucose}/bin/fastapi run --port ${toString port} ${glucose}/lib/python3.12/site-packages/glucose/main.py";
              };
            };
          };
        };
    };
  };
}
