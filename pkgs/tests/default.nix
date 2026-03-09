# Non-NixOS tests
{ pkgs, self, ... }:
{
  docs-linkcheck = pkgs.testers.lycheeLinkCheck {
    site = "${pkgs.epnix.docs}/share/doc/epnix/html";
    remap = let
      current-version = pkgs.epnixLib.versions.current;
      current-branch = if current-version == "dev" then "master" else current-version;
    in {
      "^https://epics-extensions.github.io/EPNix/${current-version}/" =
        "file://${pkgs.epnix.docs}/share/doc/epnix/html/";

      "^https://github.com/epics-extensions/(epn|EPN)ix/blob/${current-branch}/([^?]+)(\\?.+)?$" = "file://${self}/\\$2";
      "^https://github.com/epics-extensions/(epn|EPN)ix/tree/${current-branch}/([^?]+)(\\?.+)?$" = "file://${self}/\\$2";
      "^https://github.com/epics-extensions/(epn|EPN)ix/edit/${current-branch}/([^?]+)(\\?.+)?$" = "file://${self}/\\$2";
    };
    extraConfig = {
      max_concurrency = 5;
      max_retries = 5;
      retry_wait_time = 3;

      exclude_all_private = true;
      extensions = [ "html" ];
      require_https = true;
      hosts."matrix.to".include_fragments = false;
    };
  };
}
