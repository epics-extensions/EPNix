{
  stdenvNoCC,
  lib,
  epnixLib,
  epnix,
  quartoMinimal,
  writeText,
  documentedEpnixPkgs ? epnix,
  iocConfig ? {},
  nixosConfig ? {},
}: let
  inherit (epnixLib) documentation;

  iocOptions = documentation.options.iocOptions iocConfig;
  nixosOptions = documentation.options.nixosOptions nixosConfig;

  iocOptionsContent = documentation.options.optionsContent iocOptions 1;
  iocOptionsPandoc = ''
    ---
    title: Options
    format:
      html:
        # Disable the smart extensions so that the quotes in option names are not replaced
        from: markdown-smart
    ---

    ${iocOptionsContent}
  '';

  nixosOptionsContent = documentation.options.optionsContent nixosOptions 1;
  nixosOptionsPandoc = ''
    ---
    title: NixOS Options
    format:
      html:
        # Disable the smart extensions so that the quotes in option names are not replaced
        from: markdown-smart
    ---

    ${nixosOptionsContent}
  '';

  iocPkgsListPandoc = ''
    ---
    title: Packages list
    ---

    ::: callout-note
    This page references all EPNix packages that should be used when packaging an IOC.
    For all other packages, see the [Packages list](../../pkgs/packages.md).
    :::

    ${epnixLib.documentation.iocPkgsList 1 documentedEpnixPkgs}
  '';

  pkgsListPandoc = ''
    ---
    title: Packages list
    ---

    ::: callout-note
    This page references all EPNix packages that may be used outside of an IOC.
    For all IOC-specific packages, see the [IOC packages list](../ioc/references/packages.md).
    :::

    ${epnixLib.documentation.pkgsList 1 documentedEpnixPkgs}
  '';
in
  stdenvNoCC.mkDerivation {
    name = "epnix-book";
    src = ../../doc;

    nativeBuildInputs = [quartoMinimal];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      export HOME=$PWD

      mkdir ioc/references

      cp "${writeText "ioc-options.md" iocOptionsPandoc}" ioc/references/options.md
      cp "${writeText "ioc-packages.md" iocPkgsListPandoc}" ioc/references/packages.md
      cp "${writeText "nixos-options.md" nixosOptionsPandoc}" nixos/options.md
      cp "${writeText "packages.md" pkgsListPandoc}" pkgs/packages.md

      quarto render

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r _site/ "$out"

      runHook postInstall
    '';

    meta = {
      description = "The EPNix documentation book";
      homepage = "https://epics-extensions.github.io/EPNix/";
      license = lib.licenses.asl20;
      maintainers = with epnixLib.maintainers; [minijackson];
      hidden = true;
    };
  }
