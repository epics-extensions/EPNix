{ lib, pkgs, ... }:

with lib;

let
  licenseList = pkg:
    if isList pkg.meta.license then
      concatMapStringsSep
        "\n"
        (license: "  - [${license.fullName}](${license.url})")
        pkg.meta.license
    else
      "  - [${pkg.meta.license.fullName}](${pkg.meta.license.url})";

  maintainerInfo = maintainer:
    if maintainer ? github
    then "[${maintainer.name}](https://github.com/${maintainer.github}) [(mail)](mailto:${maintainer.email})"
    else "[${maintainer.name}](mailto:${maintainer.email})";

  maintainerList = pkg:
    concatMapStringsSep
      "\n"
      (maintainer: "  - ${maintainerInfo maintainer}")
      pkg.meta.maintainers;

  # TODO: specify available platforms, and fill out the meta.platforms field in
  # all packages
  package2md = path: pkg: ''
    ### ${pkg.pname}

    - Path: `${path}`
    - Version: `${pkg.version}`
    - Description: _${pkg.meta.description}_
    - Homepage: <${pkg.meta.homepage}>
    - License(s):
    ${licenseList pkg}
    - Package maintainer(s):
    ${maintainerList pkg}
    ${optionalString
      ((length pkg.meta.maintainers) > 1)
      "  - [Mail to all maintainers](mailto:${concatStringsSep "," (map (m: m.email) pkg.meta.maintainers)})"}
  '';

  packages-md = ''
    ${package2md "epnix.epics-base" pkgs.epnix.epics-base}

    ---

    ${concatStringsSep
      "\n"
      (mapAttrsToList
        (path: pkg: package2md "epnix.support.${path}" pkg)
        pkgs.epnix.support)}
  '';

  packages-man-md = ''
    # AVAILABLE PACKAGES

    ${packages-md}
  '';

  packages-doc-md = pkgs.writeText "packages-doc-md" ''
    # Available packages

    ${packages-md}
  '';
in
{
  config.epnix.doc = {
    manpage = {
      name = "epnix-configuration.nix";
      shortDescription = "EPNix configuration options";
      description = ''
        TODO
      '';
      textBefore = packages-man-md;
    };
    mdbook = {
      src = ../doc;
      preBuild = ''
        ls
        cp "${packages-doc-md}" src/packages.md
      '';
    };
  };
}
