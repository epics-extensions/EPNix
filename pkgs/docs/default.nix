{
  stdenvNoCC,
  lib,
  epnix,
  epnixLib,
  writeText,
  python3,
  installShellFiles,
  documentedEpnixPkgs ? epnix,
  iocConfig ? {},
  nixosConfig ? {},
}: let
  inherit (epnixLib) documentation;

  iocOptions = documentation.options.iocOptions iocConfig;
  nixosOptions = documentation.options.nixosOptions nixosConfig;

  iocOptionsContent = documentation.options.optionsContent iocOptions 3;
  # Have a separate "Options" header for the Sphinx manpage output
  iocOptionsPandoc = ''
    IOC options reference
    =====================

    Options
    -------

    ${iocOptionsContent}
  '';

  nixosOptionsContent = documentation.options.optionsContent nixosOptions 3;
  nixosOptionsPandoc = ''
    NixOS options reference
    =======================

    Options
    -------

    ${nixosOptionsContent}
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
    version = "23.11";

    src = ../../docs;

    nativeBuildInputs =
      (with python3.pkgs; [
        furo
        myst-parser
        sphinx
        sphinx-copybutton
      ])
      ++ [
        installShellFiles
      ];

    dontConfigure = true;

    postPatch = ''
      mkdir ioc/references
      mkdir pkgs

      cp "${writeText "ioc-options.md" iocOptionsPandoc}" ioc/references/options.md
      cp "${writeText "ioc-packages.md" iocPkgsListPandoc}" ioc/references/packages.md
      cp "${writeText "nixos-options.md" nixosOptionsPandoc}" nixos-services/options.md
      cp "${writeText "packages.md" pkgsListPandoc}" pkgs/packages.md
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
