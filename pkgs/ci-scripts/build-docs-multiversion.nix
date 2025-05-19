{
  lib,
  writeShellApplication,
  writeText,
  writers,
  epnixLib,
}: let
  stable = "nixos-24.11";
  versions = [
    "dev"
    "nixos-24.11"
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

  # Put the stable version first
  versionsbyPriority = [stable] ++ (lib.remove stable versions);

  versionsPriorities =
    lib.imap0 (i: version: {
      name = version;
      priority = 1 - (i * 0.1);
    })
    versionsbyPriority;

  sitemapUrl = version: ''
    <url>
      <loc>${baseurl}/${version.name}/</loc>
      <priority>${toString version.priority}</priority>
    </url>
  '';

  sitemap = writeText "sitemap.xml" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
      ${lib.concatStringsSep "\n" (map sitemapUrl versionsPriorities)}
    </urlset>
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
      cp ${sitemap} ./book/sitemap.xml
      echo "google-site-verification: googlec2385d4b797d68b3.html" > ./book/googlec2385d4b797d68b3.html
    '';

    meta = {
      description = "Build ";
      maintainers = with epnixLib.maintainers; [minijackson];
      hidden = true;
    };
  }
