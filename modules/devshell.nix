{ config, devshell, lib, pkgs, ... }:

with lib;
{
  options.devShell = mkOption {
    description = ''
      Devshell related options

      See https://github.com/numtide/devshell/ for more information.
    '';
    type = types.submodule {
      imports = (import "${devshell}/modules/modules.nix" { inherit pkgs lib; }) ++ [
        "${devshell}/extra/language/c.nix"
      ];
    };
    default = { };
  };

  config.epnix.outputs.devShell = config.devShell.devshell.shell;
  config.nixpkgs.overlays = [ devshell.overlay ];

  config.devShell.devshell.motd = ''
    [38;5;202m🔨 Welcome to EPNix-${config.epnix.buildConfig.flavor}'s devShell[0m
    $(type -p menu &>/dev/null && menu)
  '';

  config.devShell.commands = [
    {
      package = pkgs.bear;
      category = "development tools";
    }
    { package = pkgs.grc; }

    {
      help = "Format nix code";
      package = pkgs.nixpkgs-fmt;
      category = "development tools";
    }

    {
      help = "Format C/C++ code";
      name = "clang-format";
      package = pkgs.clang-tools;
      category = "development tools";
    }

    {
      help = "Show the components of the distribution";
      name = "epics-components";
      command = ''
        # set to empty if unset
        : ''${EPICS_COMPONENTS=}

        IFS=: read -a components <<<$EPICS_COMPONENTS

        for component in "''${components[@]}"; do
          echo "$component"
        done
      '';
      category = "EPNix commands";
    }

    {
      help = "Show the configuration options manpage of the distribution";
      name = "eman";
      command = ''
        manpage="$(nix build --no-link --json --no-write-lock-file '.#manpage' | ${pkgs.jq}/bin/jq -r '.[].outputs.out')"
        man "$manpage"
      '';
      category = "EPNix commands";
    }
  ];
}
