{
  stdenvNoCC,
  lib,
  epnixLib,
  fetchFromGitHub,
  jdk21_headless,
  gradle,
  sphinx,
  tomcat9,
  python3Packages,
  python3,
  archiver-appliance,
  sitespecific ? ./sitespecific/epnix,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "archiver-appliance";
  version = "2.4.1";

  src = fetchFromGitHub {
    owner = "archiver-appliance";
    repo = "epicsarchiverap";
    rev = finalAttrs.version;
    hash = "sha256-9PvwS6T4WmY+pSBu4IzR65kLnsY4BCMeDW/i8i8Vdlg=";
  };

  patches = [
    # Tries to use 'git log'
    ./skip-release-notes.patch

    # Messes up the shebang auto-patching
    ./fix-policies-shebang.patch

    # https://github.com/archiver-appliance/epicsarchiverap/pull/531
    ./dont-install-docs-dependencies.patch

    ./offline-javadoc.patch
  ];

  nativeBuildInputs = [
    jdk21_headless
    gradle
    sphinx
    python3Packages.myst-parser
    python3Packages.sphinx-copybutton
    python3Packages.sphinx-rtd-theme
    python3Packages.sphinxcontrib-mermaid
    python3Packages.sphinxcontrib-openapi
    python3Packages.sphinxext-opengraph
    python3Packages.sphinxext-rediraffe
  ];
  buildInputs = [ python3 ];

  gradleBuildTask = "buildRelease";
  gradleFlags = [
    "-PprojVersion=${finalAttrs.version}"
    "-PinstallDocsDependencies=false"
    "-Dorg.gradle.java.home=${jdk21_headless}"
  ];

  # Update by running `nix build .#archiver-appliance.mitmCache.updateScript && ./result`
  mitmCache = gradle.fetchDeps {
    pkg = archiver-appliance;
    data = ./deps.json;
  };

  # Some PV tests fail
  #doCheck = true;

  env = {
    ARCHAPPL_SITEID = "epnix";
    TOMCAT_HOME = "${tomcat9}";
  };

  postPatch = ''
    echo "Copying sitespecific directory"
    cp -rT ${sitespecific} src/sitespecific/epnix
  '';

  installPhase = ''
    runHook preInstall

    install -Dt $out/webapps build/libs/{retrieval,engine,etl,mgmt}.war
    mkdir -p $out/share/doc/archappl
    cp -r LICENSE LICENCES $out/share/doc/archappl

    install --mode=644 -Dt $out/share/archappl/sql src/main/org/epics/archiverappliance/config/persistence/*.sql
    install -Dt $out/share/archappl/ src/sitespecific/tests/classpathfiles/policies.py

    runHook postInstall
  '';

  meta = {
    description = "Implementation of an archiver for EPICS control systems that aims to archive millions of PVs";
    homepage = "https://epicsarchiver.readthedocs.io/en/stable/";
    license =
      with lib.licenses;
      with epnixLib.licenses;
      [
        epics
        # Embedded components
        asl20
        bsd2
        bsd3
        gpl2Only
        mit
        psfl
      ];
    maintainers = with epnixLib.maintainers; [ minijackson ];
    inherit (jdk21_headless.meta) platforms;
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # gradle dependencies
      binaryBytecode
    ];
  };
})
