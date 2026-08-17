{
  config,
  epnixLib,
  ports,
  lib,
  pkgs,
  ...
}:
{
  image.modules.virtualbox = {
    image.baseName = "phoebus-ecosystem-epnix-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}";

    virtualisation.diskSize = "auto";

    virtualbox = {
      vmName = "Phoebus ecosystem";
      memorySize = 4096;
      baseImageFreeSpace = 10 * 1024;
      params = {
        cpus = 2;

        nat-pf1 = lib.mapAttrsToList (
          name: cfg:
          lib.concatStringsSep "," [
            name
            cfg.proto or "tcp"
            # host ip, only listen locally
            "127.0.0.1"
            # host port
            (toString cfg.port)
            # guest ip
            ""
            # guest port
            (toString cfg.port)
          ]
        ) ports;
      };

      exportParams = [
        "--vsys=0"
        "--description=VM containing the various services used by the Phoebus client"
        "--vendor=EPNix"
        "--version=${config.system.nixos.label}"
      ];
    };

    # Install the `configuration/` directory into `/etc/nixos`,
    # so that users can rebuild and change the configuration of the VM.
    boot.postBootCommands = ''
      ${lib.getExe (
        pkgs.writeShellApplication {
          name = "install-nixos-config";
          runtimeInputs = [ pkgs.envsubst ];
          runtimeEnv = {
            EPNIX_BRANCH = epnixLib.versions.current-branch;
            # EPNix points Nixpkgs at the same branch than the stable EPNix branch
            EPNIX_STABLE = epnixLib.versions.stable;
            HOSTNAME = config.networking.hostName;
          };

          text = ''
            shopt -s nullglob

            filesInNixOSDir=(/etc/nixos/* /etc/nixos/.*)
            if (( "''${#filesInNixOSDir[@]}" == 0 )); then
              cp -rT --no-preserve=mode ${./..} /etc/nixos
              envsubst -i /etc/nixos/flake.nix -o /etc/nixos/flake.nix
            fi
          '';
        }
      )}
    '';
  };
}
