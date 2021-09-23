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
  config.nixpkgs.overlays = [
    devshell.overlay
    (self: super: {
      epnix-commands-lib = super.writeTextDir "/libexec/epnix/commands-lib.sh" ''
        set -euo pipefail
        IFS=$'\n\t'

        tput() {
          # If tput fails, it just means less colors
          ${pkgs.ncurses}/bin/tput "$@" 2> /dev/null || true
        }

        NORMAL="$(tput sgr0)"
        BOLD="$(tput bold)"

        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        PURPLE="$(tput setaf 5)"
        CYAN="$(tput setaf 6)"
        WHITE="$(tput setaf 7)"

        echoe() {
          echo "$@" >&2
        }

        info() {
          echoe "$BOLD''${CYAN}Info: $WHITE$@$NORMAL"
        }

        warn() {
          echoe "$BOLD''${YELLOW}Warning: $WHITE$@$NORMAL"
        }

        error() {
          echoe "$BOLD''${RED}Error: $WHITE$@$NORMAL"
        }

        fatal() {
          error "$@"
          exit 1
        }
      '';
    })
  ];

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
