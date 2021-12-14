{ config, devshell, lib, pkgs, epnixLib, ... }:

with lib;
let
  available = { inputs = config.epnix.inputs; };

  lockFile = importJSON "${available.inputs.self}/flake.lock";
  lockedInputs = mapAttrs (name: node: lockFile.nodes.${node}) lockFile.nodes.${lockFile.root}.inputs;

  inputApps = pipe config.epnix.applications.apps [
    # Get those who are "inputs.something"
    (filter (app: isString app && hasPrefix "inputs." app))

    # Fetch the metadata from the lock file
    (map (inputName:
      let name = last (splitString "." inputName);
      in
      if hasAttr name lockedInputs
      then nameValuePair name lockedInputs.${name}
      else throw "input '${name}' specified in 'epnix.applications.apps' does not exist"))
  ];
in
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
      help = "Show the EPNix documentation book for the distribution";
      name = "edoc";
      command = ''
        mdbook="$(nix build --no-link --json --no-write-lock-file '.#mdbook' | ${pkgs.jq}/bin/jq -r '.[].outputs.out')"
        xdg-open "$mdbook/index.html"
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
      command =
        let
          cloneCommands = forEach inputApps
            ({ name, value }:
              let inherit (value.locked) type; in
              if type == "git" then
                if value.locked.dir or "" != ""
                then ''warn "for input '${name}', git repositories with the 'dir' option are not supported"''
                else ''
                  if checkMissing "${name}"; then
                    cloneGit "${name}" "${value.locked.url}" "${value.locked.ref or ""}" "${value.locked.rev}"
                  fi
                ''

              else if type == "github" then ''
                if checkMissing "${name}"; then
                  cloneGitHub "${name}" "${value.locked.owner}" "${value.locked.repo}" "${value.original.ref or ""}" "${value.locked.rev}"
                fi
              ''
              else ''warn "not cloning input '${name}', unsupported type '${type}'"'');
        in
        ''
          source "${pkgs.epnix-commands-lib}/libexec/epnix/commands-lib.sh"

          function checkMissing() {
            local name="$1"

            if [ -e "$name" ]; then
              info "input '$name' already exists, skipping cloning"
              info "" "  if you want to force clone this input,"
              info "" "  simply remove the directory '$name' and re-run 'eregen-git'"
              return 1
            else
              return 0
            fi
          }

          function cloneGit() {
            local name="$1"
            local url="$2"
            # may be empty
            local wantedRef="$3"
            local resolvedRev="$4"

            local -a options=(--recurse-submodules)

            if [ -n "$wantedRef" ]; then
              options+=(--branch "$wantedRef")
            fi

            info "cloning '$name'"

            if ! git clone "''${options[@]}" -- "$url" "$name"; then
              error "clone of input '$name' failed"
              return 1
            fi

            local actualRev="$(git -C "$name" rev-parse HEAD)"

            if [[ "$resolvedRev" == "$actualRev" ]]; then
              return 0
            fi

            if [ -z "$wantedRef" ]; then
              wantedRef="$(git -C "$name" symbolic-ref --short HEAD)"
            fi

            warn "'flake.lock' is out-of-date for input '$name'"
            warn "" "the 'flake.lock' file specifies that input '$name' is at commit:"
            warn "" "   - ''${resolvedRev:1:7}"
            warn "" "  but branch '$wantedRef' from upstream has moved to commit:"
            warn "" "   - ''${actualRev:1:7}"
            info "it is likely that your 'flake.lock' is several commits behind."
            info "if you want to update your inputs, you can use one of the following commands:"
            info "" "  # to updates all inputs"
            info "" "  - nix flake update [--commit-lock-file]" "# updates all inputs"
            info ""
            info "" "  # to updates only this input"
            info "" "  - nix flake lock --update-input '$name' [--commit-lock-file]"
          }

          function cloneGitHub() {
            local name="$1"
            local owner="$2"
            local repo="$3"
            # may be empty
            local wantedRef="$3"
            local resolvedRev="$4"

            cloneGit "$name" "https://github.com/''${owner}/''${repo}.git" "$wantedRef" "$resolvedRev"
          }

          ${concatStringsSep "\n" cloneCommands}
        '';

      category = "EPNix commands";
    }

    {
      help = "Like 'nix' but uses the locally cloned applications";
      name = "enix-local";
      command =
        let
          findLocals = forEach inputApps
            ({ name, value }:
              ''
                if [ -e "${name}" ]; then
                  info "using local app:" "'${name}'"
                  overrides+=(--override-input "${name}" "path:./${name}")
                else
                  info "app '${name}' is not present locally" "using the one specified in flake inputs"
                fi
              '');
        in
        ''
          source "${pkgs.epnix-commands-lib}/libexec/epnix/commands-lib.sh"

          typeset -a overrides=()

          ${concatStringsSep "\n" findLocals}

          nix "$@" "''${overrides[@]}"
        '';

      category = "EPNix commands";
    }
  ];
}
