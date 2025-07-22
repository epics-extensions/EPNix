{
  stdenvNoCC,
  lib,
  epnix,
  epnixLib,
  writeText,
  python3,
  cacert,
  typst,
  installShellFiles,
  documentedEpnixPkgs ? epnix,
  iocConfig ? { },
}:
let
  inherit (epnixLib) documentation;
  nixdomainLib = epnixLib.inputs.sphinxcontrib-nixdomain.lib;

  iocOptions = documentation.options.iocOptions iocConfig;

  nixosOptionsAttrSet =
    (epnixLib.inputs.nixpkgs.lib.nixosSystem {
      inherit (stdenvNoCC) system;
      modules = [
        epnixLib.inputs.self.nixosModules.nixos
      ];
    }).options;

  isOurs = option: lib.any (lib.hasPrefix "${epnixLib.inputs.self}") option.declarations;
  isVisible = option: !option.internal;

  relativePath =
    path:
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
    (map (x: x // { declarations = map relativePath x.declarations; }))
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

    :::{deprecated} 25.05
    Developing IOC using NixOS-like options.

    These options are staged for removal in EPNix 26.05.

    See {doc}`../user-guides/deprecations/migrating-from-modules-development`
    for how to migrate to the new packaging approach.
    :::

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

    ${epnixLib.documentation.iocPkgsList documentedEpnixPkgs}
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

    ${epnixLib.documentation.pkgsList documentedEpnixPkgs}
  '';

  # Reproducibly download Typst dependencies for PDFs
  typst-packages-vendor = stdenvNoCC.mkDerivation {
    name = "epnix-docs-typst-packages-vendor";

    src = ../../../docs/_templates/typst;

    nativeBuildInputs = [
      cacert
      typst
    ];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      echo "{}" > lang.json

      export TYPST_PACKAGE_PATH="$out"
      export TYPST_PACKAGE_CACHE_PATH="$out"
      typst compile cheatsheet.typ

      runHook postBuild
    '';

    outputHash = "sha256-RrUb+lMMu0whMmkZH2c2ZaQfl/3k36vmtWWYE8UZ9Bg=";
    outputHashMode = "recursive";
  };
in
stdenvNoCC.mkDerivation {
  pname = "epnix-docs";
  version = "24.11";

  src = ../../../docs;

  nativeBuildInputs =
    (with python3.pkgs; [
      furo
      myst-parser
      sphinx
      sphinx-copybutton
      sphinx-tippy
      sphinxcontrib-nixdomain
      sphinxcontrib-typstbuilder
      sphinxext-opengraph
    ])
    ++ [
      typst

      installShellFiles
    ];

  dontConfigure = true;

  postPatch = ''
    mkdir -p ioc/references
    mkdir -p pkgs

    cp -fv "${nixosOptionsSpec}" nixos-options.json
    cp -fv "${writeText "ioc-options.md" iocOptionsPandoc}" ioc/references/options.md
    cp -fv "${writeText "ioc-packages.md" iocPkgsListPandoc}" ioc/references/packages.md
    cp -fv "${writeText "packages.md" pkgsListPandoc}" pkgs/packages.md
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

  env = {
    TYPST_PACKAGE_PATH = "${typst-packages-vendor}";
    TYPST_PACKAGE_CACHE_PATH = "${typst-packages-vendor}";
    SOURCE_DATE_EPOCH = epnixLib.inputs.self.sourceInfo.lastModified;
    EPNIX_VERSION_CURRENT = epnixLib.versions.current;
    EPNIX_VERSION_STABLE = epnixLib.versions.stable;
  };

  meta = {
    description = "The EPNix documentation";
    homepage = "https://epics-extensions.github.io/EPNix/";
    license = lib.licenses.asl20;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    # hidden = true;
  };
}
