{
  stdenv,
  lib,
  makeWrapper,
  perl,
  epnix,
  buildPackages,
  readline,
  ...
}: {
  pname,
  varname,
  local_config_site ? {},
  local_release ? {},
  isEpicsBase ? false,
  depsBuildBuild ? [],
  nativeBuildInputs ? [],
  buildInputs ? [],
  makeFlags ? [],
  preBuild ? "",
  postInstall ? "",
  postFixup ? "",
  ...
} @ attrs:
with lib; let
  inherit (buildPackages) epnixLib;

  # remove non standard attributes that cannot be coerced to strings
  overridable = builtins.removeAttrs attrs ["local_config_site" "local_release"];
  generateConf = (epnixLib.formats.make {}).generate;

  # "build" as in Nix terminology (the build machine)
  build_arch = epnixLib.toEpicsArch stdenv.buildPlatform;
  # "host" as in Nix terminology (the machine which will run the generated code)
  host_arch = epnixLib.toEpicsArch stdenv.hostPlatform;
in
  stdenv.mkDerivation (overridable
    // {
      strictDeps = true;

      depsBuildBuild = depsBuildBuild ++ [buildPackages.stdenv.cc];

      nativeBuildInputs = nativeBuildInputs ++ [makeWrapper perl readline];

      # Also add perl into the non-native build inputs so that shebangs gets patched
      buildInputs = buildInputs ++ [perl readline] ++ (optional (!isEpicsBase) [epnix.epics-base]);

      makeFlags =
        makeFlags
        ++ [
          "INSTALL_LOCATION=${placeholder "out"}"
        ];

      PERL_HASH_SEED = 0;

      setupHook = ./setup-hook.sh;

      enableParallelBuilding = attrs.enableParallelBuilding or true;

      dontConfigure = true;

      local_config_site = generateConf ({
          # This variable is used as a default version revision if no VCS is found.
          #
          # Since fetchgit and related fetchers remove the .git directory for
          # reproducibility, EPICS fallsback to either the GENVERSIONDEFAULT variable
          # if set (not the default), or the current date/time, which isn't
          # reproducible.
          GENVERSIONDEFAULT = "EPNix";
          CROSS_COMPILER_TARGET_ARCHS =
            if (stdenv.buildPlatform != stdenv.hostPlatform)
            then host_arch
            else null;

          # This prevents EPICS from detecting installed libraries on the host
          # system, for when Nix is compiling without sandbox (e.g.: WSL2)
          GNU_DIR = "/var/empty";
        }
        // local_config_site);

      # Undefine the SUPPORT variable here, since there is no single "support"
      # directory and this variable is a source of conflicts between RELEASE files
      local_release = generateConf (local_release // {SUPPORT = null;});

      preBuild =
        ''
          echo "$local_config_site" > configure/CONFIG_SITE.local
          echo "$local_release" > configure/RELEASE.local

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

        ''
        + preBuild;

      # Automatically create binaries directly in `bin/` that calls the ones that
      # are in `bin/linux-x86_64/`
      # TODO: we should probably do the same for libraries
      postInstall =
        ''
          if [[ -d "$out/bin/${host_arch}" ]]; then
            for file in "$out/bin/${host_arch}/"*; do
              [[ -x "$file" ]] || continue

              makeWrapper "$file" "$out/bin/$(basename "$file")"
            done
          fi
        ''
        + postInstall;

      doCheck = attrs.doCheck or true;
      checkTarget = "runtests";

      stripDebugList = attrs.stripDebugList or ["bin/${host_arch}" "lib/${host_arch}"];
      postFixup =
        optionalString (stdenv.buildPlatform != stdenv.hostPlatform) ''
          stripDirs strip "bin/${build_arch} lib/${build_arch}" "-S"
        ''
        + postFixup;
    })
