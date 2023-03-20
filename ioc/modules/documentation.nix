{
  lib,
  pkgs,
  ...
}:
with lib; let
  licenseList = pkg:
    if isList pkg.meta.license
    then
      concatMapStringsSep
      "\n"
      (license: "  - [${license.fullName}](${license.url})")
      pkg.meta.license
    else "  - [${pkg.meta.license.fullName}](${pkg.meta.license.url})";

  maintainerInfo = maintainer:
    if maintainer ? github
    then "[${maintainer.name}](https://github.com/${maintainer.github}) [(mail)](mailto:${maintainer.email})"
    else "[${maintainer.name}](mailto:${maintainer.email})";

  maintainerList = pkg:
    concatMapStringsSep
    "\n"
    (maintainer: "  - ${maintainerInfo maintainer}")
    pkg.meta.maintainers;

  # Apply a function to a derivation and its path, contained recursively in a
  # attrset, while supporting the `recurseForDerivations` attribute.
  #
  # Type: (String -> Derivation -> a) -> a -> AttrSet -> [a]
  mapRecursiveDrvsToList = f: sep: attrset: let
    mapRecursiveDrvsToList' = base: f: attrset: let
      attrset' = filterAttrs (s: _: s != "recurseForDerivations") attrset;
      attrsList = mapAttrsToList nameValuePair attrset';
      partitioning = partition (x: isDerivation x.value) attrsList;

      drvApplication = map (x: f "${base}${x.name}" x.value) partitioning.right;

      subAttrs = filter (x: x.value.recurseForDerivations or false == true) partitioning.wrong;

      subApplications = flatten (map
        (x: mapRecursiveDrvsToList' "${base}${x.name}." f x.value)
        subAttrs);
    in
      if partitioning.wrong == []
      then drvApplication
      else drvApplication ++ [sep] ++ subApplications;
  in
    mapRecursiveDrvsToList' "" f attrset;

  # TODO: specify available platforms, and fill out the meta.platforms field in
  # all packages
  package2md = path: pkg: ''
    ### ${pkg.pname}

    - Path: `epnix.${path}`
    - Version: `${pkg.version}`
    - Description: _${pkg.meta.description}_
    - Homepage: <${pkg.meta.homepage}>
    - Declared in: ${let
      filePath = head (splitString ":" pkg.meta.position);
      relativePath = pipe filePath [
        (splitString "/")
        (sublist 4 255)
        (concatStringsSep "/")
      ];
    in "[${relativePath}](file://${filePath})"}
    - License(s):
    ${licenseList pkg}
    - Package maintainer(s):
    ${maintainerList pkg}
    ${optionalString
      ((length pkg.meta.maintainers) > 1)
      "  - [Mail to all maintainers](mailto:${concatStringsSep "," (map (m: m.email) pkg.meta.maintainers)})"}
  '';

  packages-md = concatStringsSep "\n" (mapRecursiveDrvsToList package2md "\n---\n" pkgs.epnix);

  packages-man-md = ''
    # AVAILABLE PACKAGES

    ${packages-md}
  '';

  packages-doc-md =
    pkgs.writeText "packages-doc-md" ''
    '';
in {
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
      pages."packages.md".text = ''
        # Available packages

        ${packages-md}
      '';
    };
  };
}
