{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.epnix.source;

  fileModule = { name, config, ... }: {
    options = {
      src = mkOption {
        type = types.path;
        description = "Source to use for this source file";
      };

      relpath = mkOption {
        default = name;
        type = types.str;
        description = "Destination of the file, relative to the current source directory. Defaults to the attribute name";
      };
    };
  };

  dirsModule = { name, config, ... }: {
    options = {
      enable = mkOption {
        default = true;
        type = types.bool;
        description = "Whether to include this directory in the EPICS distribution source tree";
      };

      relpath = mkOption {
        default = name;
        type = types.str;
        description = "Relative path under the EPICS distribution source tree to place this directory. Defaults to the attribute name";
      };

      src = mkOption {
        type = types.path;
        description = "Source to use for this source directory";
        apply = src:
          if (config.patches != [ ] || config.postPatch != "")
          then
            (pkgs.runCommand "${builtins.replaceStrings ["/"] ["="] config.relpath}-patched" { } ''
              cp --reflink=auto --no-preserve=ownership --no-dereference --preserve=links -r ${src} $out/
              chmod u+w -R $out
              ${concatMapStringsSep "\n" (p: "patch -p1 --no-backup-if-mismatch -d $out < ${p}") config.patches}
              cd $out
              ${config.postPatch}
            '')
          else src;
      };

      patches = mkOption {
        default = [ ];
        type = types.listOf types.path;
        description = "Patches to apply to source directory";
      };

      postPatch = mkOption {
        default = "";
        type = types.lines;
        description = "Additional commands to run after patching source directory";
      };

      copyFiles = mkOption {
        default = { };
        type = types.attrsOf (types.submodule fileModule);
        description = "Additional files to copy into this directory";
      };

      build = {
        dependsOn = mkOption {
          default = [ ];
          type = types.listOf types.str;
          description = "Specify that building this directory requires building the specified components beforehand";
        };

        preBuild = mkOption {
          default = "";
          type = types.lines;
          description = "Script executed before the build phase";
        };

        buildPhase = mkOption {
          type = types.lines;
          description = "Script for building this component. Defaults to a reasonable build script";
        };

        postBuild = mkOption {
          default = "";
          type = types.lines;
          description = "Script executed before the build phase";
        };

        makeFlags = mkOption {
          default = [ ];
          type = types.listOf types.str;
          description = "Extra flags passed to Make";
        };
      };

      unpackScript = mkOption {
        default = "";
        type = types.lines;
        internal = true;
      };
    };

    config = {
      unpackScript = optionalString config.enable (''
        echo "Copying source directory..."
        mkdir -p "${config.relpath}"
        cp -rfTv --no-preserve=mode "${config.src}" "${config.relpath}"
      '' + (concatMapStringsSep "\n"
        (c: ''
          echo "Copying extra files..."
          mkdir -p "${config.relpath}/$(dirname ${c.relpath})"
          cp -afv "${c.src}" "${config.relpath}/${c.relpath}"
        '')
        (attrValues config.copyFiles)));

      build.dependsOn = [ "epics-base" ];

      build.buildPhase = mkDefault ''
        ${config.build.preBuild}

        if [[ -z "${builtins.toString config.build.makeFlags}" && ! ( -e Makefile || -e makefile || -e GNUmakefile ) ]]; then
            echo "no Makefile, doing nothing"
        else
            # Old bash empty array hack
            # shellcheck disable=SC2086
            local flagsArray=(
                ''${enableParallelBuilding:+-j''${NIX_BUILD_CORES} -l''${NIX_BUILD_CORES}}
                SHELL=$SHELL
                $makeFlags ''${makeFlagsArray+"''${makeFlagsArray[@]}"}
                $buildFlags ''${buildFlagsArray+"''${buildFlagsArray[@]}"}
                ${builtins.toString config.build.makeFlags}
            )

            echoCmd 'build flags' "''${flagsArray[@]}"
            make ''${makefile:+-f $makefile} "''${flagsArray[@]}"
            unset flagsArray
        fi

        ${config.build.postBuild}
      '';
    };
  };
in
{
  options.epnix.source = {
    dirs = mkOption {
      default = { };
      type = types.attrsOf (types.submodule dirsModule);
    };

    unpackScript = mkOption {
      default = "";
      type = types.lines;
      internal = true;
    };
  };

  config.epnix.source = {
    unpackScript = concatMapStringsSep "\n" (c: c.unpackScript) (attrValues cfg.dirs);
  };

  config.epnix.build = {
    source = pkgs.runCommand "epnix-dist-source" { } ''
      mkdir -p $out
      cd $out

      ${cfg.unpackScript}
    '';
  };
}
