{ stdenv
, lib
, runCommand
, makeWrapper
, perl
, epnix
, buildPackages
, pkgsBuildBuild
, writeText
, ...
}:

{ pname
, varname
, local_config_site ? { }
, local_release ? { }
, isEpicsBase ? false
, nativeBuildInputs ? [ ]
, buildInputs ? [ ]
, makeFlags ? [ ]
, preBuild ? ""
, postInstall ? ""
, ...
} @ attrs:

with lib;
let
  inherit (buildPackages) epnixLib;

  # remove non standard attributes that cannot be coerced to strings
  overridable = builtins.removeAttrs attrs [ "local_config_site" "local_release" ];
  generateConf = (epnixLib.formats.make { }).generate;

  # "build" as in Nix terminology (the build machine)
  build_arch = epnixLib.toEpicsArch stdenv.buildPlatform;
  # "host" as in Nix terminology (the machine which will run the generated code)
  host_arch = epnixLib.toEpicsArch stdenv.hostPlatform;
in
stdenv.mkDerivation (overridable // {
  strictDeps = true;

  depsBuildBuild = [ buildPackages.stdenv.cc ];

  nativeBuildInputs = nativeBuildInputs ++ [ makeWrapper perl ];
  buildInputs = buildInputs ++ (optional (!isEpicsBase) [ epnix.epics-base ]);

  makeFlags = makeFlags ++ [
    "INSTALL_LOCATION=${placeholder "out"}"

    # This prevents EPICS from detecting installed libraries on the host
    # system, for when Nix is compiling without sandbox (e.g.: WSL2)
    "GNU_DIR=/var/empty"
  ] ++ optional
    (stdenv.buildPlatform != stdenv.hostPlatform)
    "CROSS_COMPILER_TARGET_ARCHS=${host_arch}";

  setupHook = ./setup-hook.sh;

  enableParallelBuilding = attrs.enableParallelBuilding or true;

  dontConfigure = true;

  # "build" as in Nix terminology (the build machine)
  build_config_site = generateConf
    (with buildPackages.stdenv; {
      CC = "${cc.targetPrefix}cc";
      CCC = "${cc.targetPrefix}c++";
      CXX = "${cc.targetPrefix}c++";

      AR = "${cc.bintools.targetPrefix}ar";
      LD = "${cc.bintools.targetPrefix}ld";
      RANLIB = "${cc.bintools.targetPrefix}ranlib";

      ARFLAGS = "rc";
    } // optionalAttrs cc.isClang {
      GNU = "NO";
      CMPLR_CLASS = "clang";
    });

  # "host" as in Nix terminology (the machine which will run the generated code)
  host_config_site = generateConf
    (with stdenv; {
      CC = "${cc.targetPrefix}cc";

      CCC = if stdenv.cc.isClang then "${cc.targetPrefix}clang++" else "${cc.targetPrefix}c++";
      CXX = if stdenv.cc.isClang then "${cc.targetPrefix}clang++" else "${cc.targetPrefix}c++";

      AR = "${cc.bintools.targetPrefix}ar";
      LD = "${cc.bintools.targetPrefix}ld";
      RANLIB = "${cc.bintools.targetPrefix}ranlib";

      ARFLAGS = "rc";
    } // optionalAttrs cc.isClang {
      GNU = "NO";
      CMPLR_CLASS = "clang";
    });

  local_config_site = generateConf local_config_site;

  # Undefine the SUPPORT variable here, since there is no single "support"
  # directory and this variable is a source of conflicts between RELEASE files
  local_release = generateConf (local_release // { SUPPORT = null; });

  passAsFile = [
    "build_config_site"
    "host_config_site"
    "local_config_site"
    "local_release"
  ];

  preBuild = (optionalString isEpicsBase ''
    cp -fv --no-preserve=mode "$build_config_sitePath" configure/os/CONFIG_SITE.${build_arch}.${build_arch}
    cp -fv --no-preserve=mode "$host_config_sitePath" configure/os/CONFIG_SITE.${build_arch}.${host_arch}

    echo "=============================="
    echo "CONFIG_SITE.${build_arch}.${build_arch}"
    echo "------------------------------"
    cat "configure/os/CONFIG_SITE.${build_arch}.${build_arch}"
    echo "=============================="
    echo "CONFIG_SITE.${build_arch}.${host_arch}"
    echo "------------------------------"
    cat "configure/os/CONFIG_SITE.${build_arch}.${host_arch}"

  '') + ''
    cp -fv --no-preserve=mode "$local_config_sitePath" configure/CONFIG_SITE.local
    cp -fv --no-preserve=mode "$local_releasePath" configure/RELEASE.local

    # set to empty if unset
    : "''${EPICS_COMPONENTS=}"

    IFS=: read -ra components <<<$EPICS_COMPONENTS

    for component in "''${components[@]}"; do
      echo "$component"
      echo "$component" >> configure/RELEASE.local
    done

    echo "=============================="
    echo "CONFIG_SITE.local"
    echo "------------------------------"
    cat "configure/CONFIG_SITE.local"
    echo "=============================="
    echo "RELEASE.local"
    echo "------------------------------"
    cat "configure/RELEASE.local"
    echo "------------------------------"

  '' + preBuild;

  # Automatically create binaries directly in `bin/` that calls the ones that
  # are in `bin/linux-x86_64/`
  # TODO: we should probably do the same for libraries
  postInstall = ''
    if [[ -d "$out/bin/${host_arch}" ]]; then
      for file in "$out/bin/${host_arch}/"*; do
        [[ -x "$file" ]] || continue

        makeWrapper "$file" "$out/bin/$(basename "$file")"
      done
    fi
  '' + postInstall;

  doCheck = attrs.doCheck or true;
  checkTarget = "runtests";
})
