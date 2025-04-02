{
  stdenvNoCC,
  lib,
  epnix,
  epnixLib,
  writeText,
  python3,
  installShellFiles,
  nixdomainLib,
  documentedEpnixPkgs ? epnix,
  iocConfig ? {},
  nixosConfig ? {},
}: let
  inherit (epnixLib) documentation;

  iocOptions = documentation.options.iocOptions iocConfig;
  nixosOptions = documentation.options.nixosOptions nixosConfig;

  nixosOptionsAttrSet =
    (epnixLib.inputs.nixpkgs.lib.nixosSystem {
      inherit (stdenvNoCC) system;
      modules = [
        epnixLib.inputs.self.nixosModules.nixos
      ];
    })
    .options;

  isOurs = option: lib.any (lib.hasPrefix "${epnixLib.inputs.self}") option.declarations;
  isVisible = option: !option.internal;

  relativePath = path:
    lib.pipe path [
      (lib.splitString "/")
      (lib.sublist 4 255)
      (lib.concatStringsSep "/")
    ];

  # rev = epnixLib.inputs.self.sourceInfo.rev or "master";

  nixosOptionsSpec = lib.pipe nixosOptionsAttrSet [
    nixdomainLib.optionAttrSetToDocList
    (lib.filter isOurs)
    (lib.filter isVisible)
    (map (x: x // {declarations = map relativePath x.declarations;}))
    (map (x: lib.nameValuePair x.name x))
    lib.listToAttrs
    builtins.toJSON
    (writeText "nixos-options.json")
  ];

  iocOptionsContent = documentation.options.optionsContent iocOptions 3;
  # Have a separate "Options" header for the Sphinx manpage output
  iocOptionsPandoc = ''
    IOC options reference
    =====================

    Options
    -------

    ${iocOptionsContent}
  '';

  iocPkgsListPandoc = ''
    IOC packages list
    =================

    ::: note
    This page references all EPNix packages that should be used when packaging an IOC.
    For all other packages, see the [Packages list](../../pkgs/packages.md).
    :::

    Packages
    --------

    ${epnixLib.documentation.iocPkgsList 3 documentedEpnixPkgs}
  '';

  pkgsListPandoc = ''
    Packages list
    =============

    ::: note
    This page references all EPNix packages that may be used outside of an IOC.
    For all IOC-specific packages, see the [IOC packages list](../ioc/references/packages.md).
    :::

    Packages
    --------

    ${epnixLib.documentation.pkgsList 3 documentedEpnixPkgs}
  '';
in
  stdenvNoCC.mkDerivation {
    pname = "epnix-docs";
    version = "24.11";

    src = ../../docs;

    nativeBuildInputs =
      (with python3.pkgs; [
        furo
        myst-parser
        sphinx
        sphinx-copybutton
        sphinxcontrib-nixdomain
        sphinxext-opengraph
      ])
      ++ [
        installShellFiles
      ];

    dontConfigure = true;

    postPatch = ''
      mkdir ioc/references
      mkdir pkgs

      cp -v "${nixosOptionsSpec}" nixos-options.json
      cp -v "${writeText "ioc-options.md" iocOptionsPandoc}" ioc/references/options.md
      cp -v "${writeText "ioc-packages.md" iocPkgsListPandoc}" ioc/references/packages.md
      cp -v "${writeText "packages.md" pkgsListPandoc}" pkgs/packages.md
    '';

    shellHook = ''
      if [[ -f docs/conf.py ]]; then
        install -v "${nixosOptionsSpec}" docs/nixos-options.json
      elif [[ -f conf.py ]]; then
        install -v "${nixosOptionsSpec}" nixos-options.json
      else
        echo "Couldn't find root of docs directory, not copying options.json files"
      fi
    '';

    buildPhase = ''
      runHook preBuild

      make html man

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/doc/epnix/

      cp -r _build/html $out/share/doc/epnix/
      installManPage _build/man/*.?

      runHook postInstall
    '';

    meta = {
      description = "The EPNix documentation";
      homepage = "https://epics-extensions.github.io/EPNix/";
      license = lib.licenses.asl20;
      maintainers = with epnixLib.maintainers; [minijackson];
      # hidden = true;
    };
  }
