{
  stdenvNoCC,
  lib,
  epnix,
  epnixLib,
  python3,
  cacert,
  typst,
  installShellFiles,
  epnixOutsideDefaultScopes,
  documentedEpnixPkgs ? epnix,
}:
let
  nixdomainLib = epnixLib.inputs.sphinxcontrib-nixdomain.lib;

  nixosOptions =
    (epnixLib.inputs.nixpkgs.lib.nixosSystem {
      inherit (stdenvNoCC) system;
      modules = [
        epnixLib.inputs.self.nixosModules.nixos
      ];
    }).options;

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
  version = epnixLib.versions.current;

  src = ../../../docs;

  nativeBuildInputs =
    (with python3.pkgs; [
      furo
      myst-parser
      sphinx
      sphinx-copybutton
      sphinxcontrib-nixdomain
      sphinxcontrib-plantuml
      sphinxcontrib-typstbuilder
      sphinxext-opengraph
      sphinxext-rediraffe
    ])
    ++ [
      typst

      installShellFiles
    ];

  dontConfigure = true;

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
    NIXDOMAIN_OBJECTS = nixdomainLib.documentObjects {
      sources = {
        self = epnixLib.inputs.self.outPath;
        nixpkgs = epnixLib.inputs.nixpkgs.outPath;
      };
      options.options = nixosOptions;
      packages = {
        packages = {
          epnix = documentedEpnixPkgs;
        }
        // epnixOutsideDefaultScopes;
        extraFilters = [
          (p: !(p.meta.hidden or false))
        ];
      };
    };
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
  };
}
