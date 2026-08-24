{ epnixLib, ... }:
{
  name = "phoebus-save-and-restore-simple-check";
  meta.maintainers = with epnixLib.maintainers; [ minijackson ];

  nodes = {
    server =
      { pkgs, ... }:
      {
        services.phoebus-save-and-restore = {
          enable = true;
          openFirewall = true;

          settings = {
            "auth.impl" = "ldap_embedded";
            "spring.ldap.embedded.ldif" = "file://${./save-and-restore.ldif}";
          };
        };

        services.elasticsearch = {
          enable = true;
          package = pkgs.elasticsearch7;
        };

        # Elasticsearch can be used as an SSPL-licensed software, which is
        # not open-source. But as we're using it run tests, not exposing
        # any service, this should be fine.
        nixpkgs.config.allowUnfreePackages = [ "elasticsearch" ];
        # While waiting for Nixpkgs' packaging of Elasticsearch 8 / 9.
        nixpkgs.config.permittedInsecurePackages = [ pkgs.elasticsearch7.name ];

        # Else OOM
        virtualisation.memorySize = 2047;
      };

    client = { };
  };

  testScript = builtins.readFile ./save-and-restore.py;
}
