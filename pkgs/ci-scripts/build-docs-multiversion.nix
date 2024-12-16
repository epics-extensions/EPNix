{
  writeShellApplication,
  writeText,
  writers,
  epnixLib,
}: let
  stable = "nixos-24.05";
  versions = [
    "dev"
    "nixos-24.05"
  ];
  baseurl = "https://epics-extensions.github.io/EPNix";
  # Make a redirection using the <meta> tag,
  # with a delay of 1 second, because Google considers them not permanent
  #
  # We need non-permanent redirections, because the redirection will change
  # when a new stable version is released
  redirect = writeText "stable-redirect.html" ''
    <meta http-equiv=refresh content="1;url=${stable}/">
  '';

  versionInfo = ver: {
    name = ver;
    url = "${baseurl}/${ver}/";
  };
  versions_json = writers.writeJSON "versions.json" (map versionInfo versions);
in
  writeShellApplication {
    name = "build-docs-multiversion";

    text = ''
      for version in ${toString versions}; do
        mkdir -p "./book/$version"
        cp ${versions_json} "./$version/docs/versions.json"
        git -C "$version" add docs/versions.json
        nix build "./$version#docs" --print-build-logs
        cp -LrT --no-preserve=mode,ownership ./result/share/doc/epnix/html "./book/$version"
      done
      cp ${redirect} ./book/index.html
    '';

    meta = {
      description = "Build ";
      maintainers = with epnixLib.maintainers; [minijackson];
      hidden = true;
    };
  }
