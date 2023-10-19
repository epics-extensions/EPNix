{
  lib,
  epnixLib,
  ...
}: {
  name = "phoebus-save-and-restore-simple-check";
  meta.maintainers = with epnixLib.maintainers; [minijackson];

  nodes = {
    server = {
      services.phoebus-save-and-restore = {
        enable = true;
        openFirewall = true;
      };

      nixpkgs.config.allowUnfreePredicate = pkg:
        builtins.elem (lib.getName pkg) [
          # Elasticsearch can be used as an SSPL-licensed software, which is
          # not open-source. But as we're using it run tests, not exposing
          # any service, this should be fine.
          "elasticsearch"
        ];

      # Else OOM
      virtualisation.memorySize = 2047;
    };

    client = {};
  };

  testScript = builtins.readFile ./save-and-restore.py;
}
