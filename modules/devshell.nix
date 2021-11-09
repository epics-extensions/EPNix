{ config, devshell, lib, pkgs, epnixLib, ... }:

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
      epnix-commands-lib =
        super.writeTextDir "/libexec/epnix/commands-lib.sh" ''
          PATH="${makeBinPath (with pkgs; [ ncurses ])}''${PATH:+:$PATH}"

          source "${pkgs.bash-lib}"
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

    {
      help = "Regenerate the 'configure/' directory, top-level Makefile, and subprojects";
      name = "eregen";
      command = ''
        eregen-config
        eregen-git
      '';
      category = "EPNix commands";
    }

    {
      help = "Regenerate the 'configure/' directory, top-level Makefile";
      name = "eregen-config";
      command = ''
        source "${pkgs.epnix-commands-lib}/libexec/epnix/commands-lib.sh"

        toplevel="$(realpath -s .)"

        if [[ ! -f "epnix.toml" ]]; then
          fatal "Could not find 'epnix.toml' file. Are you in an EPNix project?"
        fi

        typeset -a old_files=()

        if [ -f "$toplevel/Makefile" ]; then
          old_files+=("$toplevel/Makefile")
        fi

        if [ -d "$toplevel/configure" ]; then
          old_files+=("$toplevel/configure")
        fi

        if [ "''${#old_files[@]}" -ne 0 ]; then
          info "Removing old toplevel files:" "''${old_files[@]}"
          rm --recursive --force --interactive=once --one-file-system "''${old_files[@]}"
        fi

        info "Regenerating toplevel files"
        cp -rfv --no-preserve=mode "${pkgs.epnix.epics-base}/templates/makeBaseApp/top/configure" "$toplevel"
        cp -rfv --no-preserve=mode "${pkgs.epnix.epics-base}/templates/makeBaseApp/top/Makefile" "$toplevel"

        info "Adding EPICS components to 'configure/RELEASE.local'"
        epics-components | tee "$toplevel/configure/RELEASE.local" >&2
      '';

      category = "EPNix commands";
    }

    {
      help = "Check and clone subprojects";
      name = "eregen-git";
      command = builtins.readFile (pkgs.substituteAll {
        src = ./devshell/eregen-git.sh;

        inherit (pkgs) git jq zsh;

        epnix_commands_lib = pkgs.epnix-commands-lib;
        epics_base = pkgs.epnix.epics-base;

        app_names = map (app: epnixLib.getAppName app) config.epnix.applications.apps;
      });

      category = "EPNix commands";
    }
  ];

  config.devShell.devshell.startup."eregen-git" = stringAfter [ "motd" ] "eregen-git";
}
