{
  inputs,
  lib,
  ...
}@args:
let
  self = {
    markdown = import ./documentation/markdown.nix args;
    options = import ./documentation/options.nix args;

    isVisible = pkg: !(pkg.value.meta.hidden or false);

    isNotIocSpecific = base: pkg: (self.isVisible pkg) && base != "support.";
    isIocSpecific = base: pkg: (self.isVisible pkg) && base == "support.";

    filteredPkgsList =
      filt: pkgs: lib.concatStringsSep "\n" (self.mapRecursiveDrvsToList self.package2markdown filt pkgs);

    pkgsList = self.filteredPkgsList self.isNotIocSpecific;
    iocPkgsList = self.filteredPkgsList self.isIocSpecific;

    # Apply a function to a derivation and its path, contained recursively in a
    # attrset, while supporting the `recurseForDerivations` attribute.
    #
    # It will also filter-out hidden derivation using the meta.hidden attribute.
    #
    # Type: (String -> Derivation -> a) -> (Derivation -> bool) -> a -> AttrSet -> [a]
    mapRecursiveDrvsToList =
      f: filt: attrset:
      let
        mapRecursiveDrvsToList' =
          base: f: attrset:
          let
            attrset' = lib.filterAttrs (s: _: s != "recurseForDerivations") attrset;
            attrsList = lib.mapAttrsToList lib.nameValuePair attrset';
            partitioning = lib.partition (x: lib.isDerivation x.value) attrsList;

            filteredDerivations = lib.filter (filt base) partitioning.right;
            drvApplication = map (x: f "${base}${x.name}" x.value) filteredDerivations;

            subAttrs = lib.filter (x: x.value.recurseForDerivations or false) partitioning.wrong;

            subApplications = lib.flatten (
              map (x: mapRecursiveDrvsToList' "${base}${x.name}." f x.value) subAttrs
            );
          in
          if partitioning.wrong == [ ] then drvApplication else drvApplication ++ subApplications;
      in
      mapRecursiveDrvsToList' "" f attrset;

    maybeUrl = text: destination: if destination == null then text else "[${text}](${destination})";

    licenseLink = license: self.maybeUrl license.fullName (license.url or null);

    licenseList =
      pkg:
      lib.pipe pkg.meta.license [
        lib.toList
        (map self.licenseLink)
        self.markdown.optionalBulletList
        self.markdown.indented
        (lib.concatStringsSep "\n")
      ];

    maintainerInfo =
      maintainer:
      if maintainer ? github then
        "[${maintainer.name}](https://github.com/${maintainer.github}) [(mail)](mailto:${maintainer.email})"
      else
        "[${maintainer.name}](mailto:${maintainer.email})";

    maintainerList =
      pkg:
      let
        mailToAll =
          lib.optional ((lib.length pkg.meta.maintainers) > 1)
            "[Mail to all maintainers](mailto:${
              lib.concatStringsSep "," (map (m: m.email) pkg.meta.maintainers)
            })";
      in
      lib.pipe pkg.meta.maintainers [
        lib.toList
        (map self.maintainerInfo)
        (l: l ++ mailToAll)
        self.markdown.optionalBulletList
        self.markdown.indented
        (lib.concatStringsSep "\n")
      ];

    declarationParam =
      pkg:
      lib.optionalString (pkg.meta ? position) (
        let
          fullPath = lib.head (lib.splitString ":" pkg.meta.position);
          isEpnix = lib.hasPrefix "${inputs.self}" fullPath;
          relativePath = lib.removePrefix "${inputs.self}/" fullPath;
        in
        lib.optionalString isEpnix ''
          :declaration: ${relativePath}
        ''
      );

    # TODO: support a category for splitting packages
    # TODO: specify available platforms, and fill out the meta.platforms field in
    # all packages
    package2markdown = path: pkg: ''
      :::{nix:package} epnix.${path}
      ${self.declarationParam pkg}

      ${pkg.meta.description}

      ${pkg.meta.longDescription or ""}

      :name: `${pkg.pname or pkg.name}`
      :version: `${pkg.version}`
      :homepage: <${pkg.meta.homepage}>
      :licenses:
      ${self.licenseList pkg}
      :maintainers:
      ${self.maintainerList pkg}
      :::
    '';
  };
in
self
