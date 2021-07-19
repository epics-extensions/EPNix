{ stdenv, lib, runCommand, perl, epics, epnixLib, ... }:

{ pname
, varname
, local_config_site ? { }
, local_release ? { }
, isEpicsBase ? false
, nativeBuildInputs ? [ ]
, buildInputs ? [ ]
, makeFlags ? [ ]
, preBuild ? ""
, ...
} @ attrs:

with lib;
let
  # remove non standard attributes that cannot be coerced to strings
  overridable = builtins.removeAttrs attrs [ "local_config_site" "local_release" ];
  generateConf = (epnixLib.formats.make { }).generate;
in
stdenv.mkDerivation (overridable // {
  nativeBuildInputs = nativeBuildInputs ++ [ perl ];
  buildInputs = buildInputs ++ (optional (!isEpicsBase) [ epics.base ]);

  makeFlags = makeFlags ++ [
    "CC=cc"
    "CCC=g++"
    "CXX=g++"
    "AR=ar"
    "LD=ld"
    "RANLIB=ranlib"
    "ARFLAGS=rc"
    "INSTALL_LOCATION=${placeholder "out"}"
  ];

  setupHook = ./setup-hook.sh;

  enableParallelBuilding = true;

  dontConfigure = true;

  preBuild = ''
    cp -fv --no-preserve=mode "${generateConf "${pname}-CONFIG_SITE.local" local_config_site}" configure/CONFIG_SITE.local
    cp -fv --no-preserve=mode "${generateConf "${pname}-RELEASE.local" local_release}" configure/RELEASE.local

    # set to empty if unset
    : ''${EPICS_COMPONENTS=}

    IFS=: read -a components <<<$EPICS_COMPONENTS

    for component in "''${components[@]}"; do
      echo "$component"
      echo "$component" >> configure/RELEASE.local
    done

  '' + preBuild;
})
