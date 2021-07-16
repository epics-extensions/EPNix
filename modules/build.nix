{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.epnix.buildConfig;
in
{
  options.epnix.buildConfig = {
    flavor = mkOption {
      description = "Name of the flavor of this EPICS distribution";
      type = types.str;
      default = "custom";
    };

    nativeBuildInputs = mkOption {
      description = "Native build inputs needed for the build";
      default = [ ];
      type = types.listOf types.package;
    };

    buildInputs = mkOption {
      description = "Build inputs needed for the build";
      default = [ ];
      type = types.listOf types.package;
    };

    buildSteps = mkOption {
      default = toposort
        (a: b: elem a.relpath b.build.dependsOn)
        (attrValues config.epnix.source.dirs);
      internal = true;
    };
  };

  config.assertions = let
    missingRelpaths = filter (relpath: !config.epnix.source.dirs ? ${relpath}) (flatten (mapAttrsToList (_: v: v.build.dependsOn) config.epnix.source.dirs));
  in [
    {
      assertion = cfg.buildSteps ? result;
      message = "Build dependency loop detected: ${
        concatStringsSep " -> " (map (v: "'${v.relpath}'") cfg.buildSteps.cycle)} loops back to ${
          concatStringsSep ", " (map (v: "'${v.relpath}'") cfg.buildSteps.loops)}";
    }
    {
      assertion = missingRelpaths == [];
      message = "Source directory dependency does not exists: ${concatStringsSep ", " (traceVal missingRelpaths)}";
    }
  ];

  config.epnix.build.build =
    pkgs.stdenv.mkDerivation {
      name = "epics-distribution-${cfg.flavor}";
      src = config.epnix.build.source;

      inherit (cfg) nativeBuildInputs buildInputs;

      dontInstall = true;

      makeFlags = [
        "CC=cc"
        "CCC=g++"
        "CXX=g++"
        "AR=ar"
        "LD=ld"
        "RANLIB=ranlib"
        "ARFLAGS=rc"
      ];

      enableParallelBuilding = true;

      SUPPORT = "${placeholder "out"}/support";

      EPICS_HOST_ARCH =
        let inherit (pkgs) system;
        in
        if system == "x86_64-linux" then "linux-x86_64"
        else if system == "aarch64-linux" then "linux-aarch64"
        else if system == "i686-linux" then "linux-i686"
        else if system == "x86_64-darwin" then "darwin-x86_64"
        else throw "Unsupported system: ${system}";

      buildPhase = ''
        cp -arv . $out
        cd $out

        runHook preBuild

        export PATH="$out/epics-base/bin/$EPICS_HOST_ARCH:$PATH"

        ${concatMapStringsSep "\n" (dir: ''
          pushd "${dir.relpath}"

          echo "Building '${dir.relpath}'..."

          ${dir.build.buildPhase}

          popd
        '') cfg.buildSteps.result}

        runHook postBuild
      '';
    };
}
