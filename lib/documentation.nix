{
  inputs,
  lib,
  ...
} @ args: let
  self = {
    markdown = import ./documentation/markdown.nix args;
    options = import ./documentation/options.nix args;

    isVisible = pkg: !(pkg.value.meta.hidden or false);

    isNotIocSpecific = base: pkg: (self.isVisible pkg) && base != "support.";
    isIocSpecific = base: pkg: (self.isVisible pkg) && base == "support.";

    filteredPkgsList = filt: headingLevel: pkgs:
      lib.concatStringsSep
      "\n"
      (self.mapRecursiveDrvsToList
        (self.package2pandoc headingLevel)
        filt
        pkgs);

    pkgsList = self.filteredPkgsList self.isNotIocSpecific;
    iocPkgsList = self.filteredPkgsList self.isIocSpecific;

    # Apply a function to a derivation and its path, contained recursively in a
    # attrset, while supporting the `recurseForDerivations` attribute.
    #
    # It will also filter-out hidden derivation using the meta.hidden attribute.
    #
    # Type: (String -> Derivation -> a) -> (Derivation -> bool) -> a -> AttrSet -> [a]
    mapRecursiveDrvsToList = f: filt: attrset: let
      mapRecursiveDrvsToList' = base: f: attrset: let
        attrset' = lib.filterAttrs (s: _: s != "recurseForDerivations") attrset;
        attrsList = lib.mapAttrsToList lib.nameValuePair attrset';
        partitioning = lib.partition (x: lib.isDerivation x.value) attrsList;

        filteredDerivations = lib.filter (filt base) partitioning.right;
        drvApplication = map (x: f "${base}${x.name}" x.value) filteredDerivations;

        subAttrs = lib.filter (x: x.value.recurseForDerivations or false) partitioning.wrong;

        subApplications = lib.flatten (map
          (x: mapRecursiveDrvsToList' "${base}${x.name}." f x.value)
          subAttrs);
      in
        if partitioning.wrong == []
        then drvApplication
        else drvApplication ++ subApplications;
    in
      mapRecursiveDrvsToList' "" f attrset;

    maybeUrl = text: destination:
      if destination == null
      then text
      else "[${text}](${destination})";

    licenseLink = license: self.maybeUrl license.fullName (license.url or null);

    licenseList = pkg:
      if lib.isList pkg.meta.license
      then
        lib.concatMapStringsSep
        "\n"
        (license: "  - ${self.licenseLink license}")
        pkg.meta.license
      else "  - ${self.licenseLink pkg.meta.license}";

    maintainerInfo = maintainer:
      if maintainer ? github
      then "[${maintainer.name}](https://github.com/${maintainer.github}) [(mail)](mailto:${maintainer.email})"
      else "[${maintainer.name}](mailto:${maintainer.email})";

    maintainerList = pkg:
      lib.concatMapStringsSep
      "\n"
      (maintainer: "  - ${self.maintainerInfo maintainer}")
      pkg.meta.maintainers;

    # TODO: support a category for splitting packages
    # TODO: specify available platforms, and fill out the meta.platforms field in
    # all packages
    package2pandoc = headingLevel: path: pkg: let
      header = lib.fixedWidthString headingLevel "#" "";
    in ''
      (pkg-${path})=
      ${header} ${pkg.pname or pkg.name}

      Path
      : `epnix.${path}`

      Version
      : `${pkg.version}`

      Description
      : _${pkg.meta.description}_

      Homepage
      : <${pkg.meta.homepage}>

      ${lib.optionalString (pkg.meta ? position) (let
        filePath = lib.head (lib.splitString ":" pkg.meta.position);
        isEpnix = lib.hasPrefix "${inputs.self}" filePath;
        declarationLink = self.markdown.sourceLink filePath;
      in
        lib.optionalString isEpnix ''
          Declared in
          : ${self.markdown.inDefList declarationLink}
        '')}

      License(s)
      : ${self.markdown.inDefList (self.licenseList pkg)}

      Package maintainer(s)
      : ${self.markdown.inDefList (self.maintainerList pkg)}
      ${lib.optionalString
        ((lib.length pkg.meta.maintainers) > 1)
        "    - [Mail to all maintainers](mailto:${lib.concatStringsSep "," (map (m: m.email) pkg.meta.maintainers)})"}
    '';
  };
in
  self
