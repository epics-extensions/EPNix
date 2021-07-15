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
              ${lib.concatMapStringsSep "\n" (p: "patch -p1 --no-backup-if-mismatch -d $out < ${p}") config.patches}
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

      unpackScript = mkOption {
        default = "";
        type = types.lines;
        internal = true;
      };
    };

    config = {
      unpackScript = lib.optionalString config.enable (''
        echo "Copying source directory..."
        mkdir -p "${config.relpath}"
        cp -rfTv --no-preserve=mode "${config.src}" "${config.relpath}"
      '' + (lib.concatMapStringsSep "\n"
        (c: ''
          echo "Copying extra files..."
          mkdir -p "${config.relpath}/$(dirname ${c.relpath})"
          cp -afv "${c.src}" "${config.relpath}/${c.relpath}"
        '')
        (lib.attrValues config.copyFiles)));
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
    unpackScript = lib.concatMapStringsSep "\n" (c: c.unpackScript) (lib.attrValues cfg.dirs);
  };

  config.epnix.build = {
    source = pkgs.runCommand "epnix-dist-source" { } ''
      mkdir -p $out
      cd $out

      ${cfg.unpackScript}
    '';
  };
}
