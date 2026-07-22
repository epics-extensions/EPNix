{
  config,
  epnixLib,
  lib,
  pkgs,
  ports,
  ...
}:
{
  imports = [
    ./archiver-appliance.nix
    ./phoebus-alarm.nix
    ./phoebus-services.nix
    ./ioc.nix

    # Configuration used only when building images
    ./images/virtualbox.nix
    ./images/qemu-vm.nix
  ];

  # When modifying this list,
  # make sure to also modify `docs/pkgs/user-guides/phoebus-ecosystem-vm.md`.
  _module.args.ports = {
    archiver-appliance.port = 8080;
    alarm-logger.port = 8081;
    save-restore.port = 8082;
    olog.port = 8083;
    channel-finder.port = 8084;

    apache-kafka.port = 9092;

    ioc = {
      port = 5064;
      proto = "tcp";
    };
    ioc-udp = {
      port = 5064;
      proto = "udp";
    };

    ssh.port = 2222;
  };

  networking.hostName = "phoebus-ecosystem";

  users.users.root.initialHashedPassword = "";

  environment.epics = {
    ca_addr_list = [ "127.0.0.1" ];
    ca_auto_addr_list = false;
  };

  environment.systemPackages = with pkgs; [
    htop
    tmux
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withPython3 = false;
    withRuby = false;
  };

  services.openssh = {
    enable = true;
    ports = [ ports.ssh.port ];
    settings = {
      PermitRootLogin = "yes";
      PermitEmptyPasswords = "yes";
    };
  };
  security.pam.services.sshd.allowNullPassword = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  swapDevices = lib.mkVMOverride [
    {
      device = "/var/swapfile";
      size = 2048; # MiB
    }
  ];

  boot.initrd.systemd.enable = true;
  boot.kernel.sysfs.module.zswap.parameters.enabled = true;

  services.getty = {
    greetingLine = ''<< Phoebus ecosystem VM, on NixOS with EPNix ${config.system.nixos.label} (\m) - \l >>'';
    helpLine = ''

      See the EPNix documentation for more information:

        https://epics-extensions.github.io/EPNix/${epnixLib.versions.current}/pkgs/user-guides/phoebus-ecosystem-vm.html'';
  };

  system.nixos.label =
    let
      inherit (epnixLib.inputs) self;
      rev = self.dirtyShortRev or self.shortRev or "unknown";
    in
    "${config.system.nixos.release}-${rev}";

  system.stateVersion = lib.trivial.release;
}
