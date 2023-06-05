{
  stdenvNoCC,
  lib,
  epnix,
  epnixLib,
  emptyDirectory,
  writeText,
  pandoc,
  documentedEpnixPkgs ? epnix,
  iocConfig ? {},
  nixosConfig ? {},
}: let
  inherit (epnixLib) documentation;

  iocOptions = documentation.options.iocOptions iocConfig;
  nixosOptions = documentation.options.nixosOptions nixosConfig;

  iocOptionsContent = documentation.options.optionsContent iocOptions 2;
  iocPandoc = ''
    ---
    title: epnix-ioc
    section: 5
    header: EPNix IOC options and packages
    ---

    # PACKAGES

    This section references all EPNix packages that should be used when packaging an IOC.
    For all other packages, see `epnix-packages(5)`.

    ${epnixLib.documentation.iocPkgsList 2 documentedEpnixPkgs}

    ---

    # OPTIONS

    ${iocOptionsContent}

    # SEE ALSO

    `epnix-nixos(5)`, `epnix-packages(5)`
  '';

  nixosOptionsContent = documentation.options.optionsContent nixosOptions 2;
  nixosOptionsPandoc = ''
    ---
    title: epnix-nixos
    section: 5
    header: EPNix NixOS options
    ---

    # OPTIONS

    ${nixosOptionsContent}

    # SEE ALSO

    `epnix-ioc(5)`, `epnix-packages(5)`
  '';

  pkgsListPandoc = ''
    ---
    title: epnix-packages
    section: 5
    header: EPNix packages
    ---

    # DESCRIPTION

    This page references all EPNix packages that may be used outside of an IOC.
    For all IOC-specific packages, see `epnix-ioc(5)`.

    # PACKAGES

    ${epnixLib.documentation.pkgsList 2 documentedEpnixPkgs}

    # SEE ALSO

    `epnix-ioc(5)`, `epnix-nixos(5)`
  '';
in
  stdenvNoCC.mkDerivation {
    name = "epnix-manpages";
    src = emptyDirectory;

    nativeBuildInputs = [pandoc];

    dontConfigure = true;

    buildPhase = ''
      runHook preBuild

      pandoc "${writeText "ioc-options.md" iocPandoc}" -t man -so epnix-ioc.5
      pandoc "${writeText "nixos-options.md" nixosOptionsPandoc}" -t man -so epnix-nixos.5
      pandoc "${writeText "epnix-packages.md" pkgsListPandoc}" -t man -so epnix-packages.5

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      install -Dt $out/share/man/man5/ epnix-ioc.5 epnix-nixos.5 epnix-packages.5
      # Add the bin folder so that the man path gets added to `manpath`
      mkdir -p $out/bin

      runHook postInstall
    '';

    meta = {
      description = "The EPNix documentation man page";
      homepage = "https://epics-extensions.github.io/EPNix/";
      license = lib.licenses.asl20;
      maintainers = with epnixLib.maintainers; [minijackson];
      hidden = true;
    };
  }
