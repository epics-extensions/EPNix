{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.epnix.devShell;

  available = {inputs = config.epnix.inputs;};

  lockFile = importJSON "${available.inputs.self}/flake.lock";
  lockedInputs = mapAttrs (name: node: lockFile.nodes.${node}) lockFile.nodes.${lockFile.root}.inputs;

  inputApps = pipe config.epnix.applications.apps [
    # Get those who are "inputs.something"
    (filter (app: isString app && hasPrefix "inputs." app))

    # Fetch the metadata from the lock file
    (map (inputName: let
      name = last (splitString "." inputName);
    in
      if hasAttr name lockedInputs
      then nameValuePair name lockedInputs.${name}
      else throw "input '${name}' specified in 'epnix.applications.apps' does not exist"))
  ];

  category = mkOption {
    type = types.str;
    default = "general commands";
    description = ''
      Set a free text category under which this command is grouped and
      shown in the help menu.
    '';
    example = "development tools";
  };

  description = mkOption {
    type = types.str;
    description = ''
      Description of this specific command.

      This description will be put in the development shell menu.
    '';
    default = "";
  };

  packageModule = {config, ...}: {
    options = {
      package = mkOption {
        type = types.package;
        description = ''
          The package providing the specified commands.
        '';
      };

      inherit category;

      commands = mkOption {
        type = with types;
          attrsOf (submodule {
            options = {
              inherit description;
              category = mkOption {
                type = types.str;
                description = ''
                  Set a free text category under which this command is grouped
                  and shown in the help menu.

                  If unspecified, defaults to the category of the package.
                '';
                example = "development tools";
              };
            };

            config.category = mkDefault config.category;
          });

        description = ''
          The various commands to document in the menu.
        '';

        default = {};
      };
    };

    config.commands = let
      name = config.package.pname or (parseDrvName config.package.name).name;
      description = config.package.meta.description or "";
    in
      mkDefault {
        ${name}.description = description;
      };
  };

  scriptPackages =
    mapAttrsToList
    (name: scriptCfg:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [pkgs.buildPackages.ncurses];
        text = ''
          # shellcheck disable=SC1091
          source "${pkgs.bash-lib}"

          ${scriptCfg.text}
        '';
      })
    cfg.scripts;

  commandsByCategory = let
    scriptCategories =
      mapAttrsToList
      (name: script: {
        ${script.category} = {
          inherit name;
          inherit (script) description;
        };
      })
      cfg.scripts;

    pkgCommandCategories =
      map
      (pkg:
        mapAttrsToList
        (name: cmd: {
          ${cmd.category} = {
            inherit name;
            inherit (cmd) description;
          };
        })
        pkg.commands)
      cfg.packages;
  in
    zipAttrs (scriptCategories ++ (flatten pkgCommandCategories));

  categoryText = category: commands: ''
    ''${YELLOW}[${category}]''${NORMAL}
    ${concatMapStringsSep
      "\n"
      ({
        name,
        description,
      }: "  \${GREEN}${name}\${NORMAL}\n      ${description}")
      commands}
  '';

  menuText = ''
    ''${BOLD}''${CYAN}EPNix's ${config.epnix.meta.name} devShell''${NORMAL}

    ${concatStringsSep
      "\n"
      (mapAttrsToList categoryText commandsByCategory)}'';
in {
  options.epnix.devShell = {
    packages = mkOption {
      type = with types; listOf (submodule packageModule);
      description = ''
        A list of packages and their command description to add into the
        development environment.
      '';
      example = literalExpression ''
        [
          {
            package = pkg.poetry;
            category = "development tools";
          }
          {
            package = pkg.hello;
            commands.hello = {
              description = "Say hello in the terminal";
              category = "miscellaneous";
            };
          }
        ]
      '';
    };

    scripts = mkOption {
      type = with types;
        attrsOf (submodule {
          options = {
            text = mkOption {
              type = types.str;
              description = ''
                Content of the script.
              '';
            };

            inherit category description;
          };
        });
      description = ''
        A set of shell scripts to add to the development environment.
      '';
      example = {
        "hello-world" = {
          text = ''
            echo 'Hello, World!'
          '';
          category = "miscellaneous";
          description = "Say hello in the terminal";
        };
      };
    };

    environment.variables = mkOption {
      type = with types; attrsOf (nullOr (either str (listOf str)));
      description = ''
        A set of environment variables used in the development environment.

        The value of each variable can be either a string or a list of strings.
        The latter is concatenated, interspersed with colon characters.

        If null is given, the environment variable is explicitely unset,
        preventing said environment variable to "leak" from the host
        environment to the development environment.
      '';
      apply = mapAttrs (n: v:
        if isList v
        then concatStringsSep ":" v
        else v);
      example = {
        EPICS_CA_ADDR_LIST = "localhost";
      };
      default = {};
    };

    attrs = mkOption {
      type = types.submodule {
        freeformType = types.attrs;

        options = {
          inputsFrom = mkOption {
            type = with types; listOf package;
            internal = true;
          };

          nativeBuildInputs = mkOption {
            type = with types; listOf package;
            internal = true;
          };

          shellHook = mkOption {
            type = types.lines;
            internal = true;
          };
        };
      };
      description = ''
        Extra attributes to pass as-is to the `mkShell` function.

        See the nixpkgs [documentation] on `mkShell` for more information.

        [documentation]: <https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-mkShell>
      '';
      default = {};
    };
  };

  config.epnix.devShell = {
    packages = with pkgs.buildPackages; [
      {
        package = bear;
        category = "development tools";
      }
      # Once NixOS 22.05 is released, switch to alejandra
      {
        package = nixpkgs-fmt;
        category = "development tools";
      }
      {
        # Use pkgsBuildBuild so we don't have to build LLVM when
        # cross-compiling. This is necessary for clang because
        # hostPackages != targetPackages
        package = pkgs.pkgsBuildBuild.clang-tools;
        category = "development tools";
        commands."clang-format".description = "Format C/C++ code";
      }
      {package = grc;}
    ];

    scripts = {
      menu = {
        text = ''
          cat <<EPNIX_MENU
          ${menuText}
          EPNIX_MENU
        '';
        description = "Prints this menu";
      };

      epics-components = {
        text = ''
          # set to empty if unset
          : "''${EPICS_COMPONENTS=}"

          IFS=: read -ra components <<<$EPICS_COMPONENTS

          for component in "''${components[@]}"; do
            echo "$component"
          done
        '';
        category = "epnix commands";
        description = "Show the components of the distribution";
      };

      eman = {
        text = ''
          manpage="$(nix build --no-link --json --no-write-lock-file '.#manpage' | ${pkgs.buildPackages.jq}/bin/jq -r '.[].outputs.out')"
          man "$manpage"
        '';
        category = "epnix commands";
        description = "Show the configuration options manpage of the distribution";
      };

      edoc = {
        text = ''
          mdbook="$(nix build --no-link --json --no-write-lock-file '.#mdbook' | ${pkgs.buildPackages.jq}/bin/jq -r '.[].outputs.out')"
          xdg-open "$mdbook/index.html"
        '';
        category = "epnix commands";
        description = "Show the EPNix documentation book for the distribution";
      };

      eregen = {
        text = ''
          eregen-config
          eregen-git
        '';
        category = "epnix commands";
        description = "Regenerate the 'configure/RELEASE.local' file, and subprojects";
      };

      eregen-config = {
        # TODO: generate the CONFIG_SITE.local too
        text = ''
          toplevel="$(realpath -s .)"

          if [[ ! -f "flake.nix" ]]; then
            fatal "Could not find 'flake.nix' file. Are you in an EPNix project?"
          fi

          if [[ ! -d "$toplevel/configure" ]]; then
            fatal "The 'configure/' directory does not exist, you might need to execute 'makeBaseApp.pl' first"
          fi

          # local_release and local_config_site are set in the shell attributes

          info "Adding EPICS components to 'configure/RELEASE.local'"
          # shellcheck disable=SC2154
          echo "$local_release" | tee "$toplevel/configure/RELEASE.local" >&2
          epics-components >> "$toplevel/configure/RELEASE.local"
          epics-components

          info "Adding Make variables to 'configure/CONFIG_SITE.local'"
          # shellcheck disable=SC2154
          echo "$local_config_site" | tee "$toplevel/configure/CONFIG_SITE.local" >&2
        '';
        category = "epnix commands";
        description = "Regenerate EPNix specific 'configure/' files";
      };

      check-config = {
        text = ''
          toplevel="$(realpath -s .)"

          if [[ ! -f "flake.nix" ]]; then
            exit 1
          fi

          if [[ ! -d "configure" ]]; then
            warn "the 'configure/' directory does not exist"
            warn "please run a 'makeBaseApp.pl' command to generate the top build files"
            warn "then run 'eregen-config' to generate EPNix' 'configure/' files"
            warn "finally, add all these files to your Git repository."
            exit 1
          fi

          has_mismatch=0

          # local_release and local_config_site are set in the shell attributes

          release_path="$toplevel/configure/RELEASE.local"
          config_site_path="$toplevel/configure/CONFIG_SITE.local"

          function compare() {
            diff --color=always -au - "$1" | tail -n +3
          }

          if [[ -f "$release_path" ]]; then
            set +e
            # shellcheck disable=SC2154
            release_diff="$( (echo "$local_release"; epics-components) | compare "$release_path")"
            set -e
            if [[ "$release_diff" ]]; then
              warn "the 'configure/RELEASE.local' file differs from the one used by Nix"
              echoe "$release_diff"
              has_mismatch=1
            fi
          else
              warn "the 'configure/RELEASE.local' file does not exist"
              has_mismatch=1
          fi

          if [[ -f "$config_site_path" ]]; then
            set +e
            # shellcheck disable=SC2154
            config_site_diff="$(echo "$local_config_site" | compare "$config_site_path")"
            set -e
            if [[ "$config_site_diff" ]]; then
              warn "the 'configure/CONFIG_SITE.local' file differs from the one used by Nix"
              echoe "$config_site_diff"
              has_mismatch=1
            fi
          else
            warn "the 'configure/CONFIG_SITE.local' file does not exist"
            has_mismatch=1
          fi

          if [[ "$has_mismatch" == 1 ]]; then
            info "run 'eregen-config' to update your 'configure/' directory."
            exit 1
          fi
        '';
        category = "epnix commands";
        description = "Check whether important files in 'configure/' are up to date";
      };

      eregen-git = {
        text = let
          cloneCommands =
            forEach inputApps
            ({
              name,
              value,
            }: let
              inherit (value.locked) type;
            in
              if type == "git"
              then
                if value.locked.dir or "" != ""
                then ''warn "for input '${name}', git repositories with the 'dir' option are not supported"''
                else ''
                  if checkMissing "${name}"; then
                    cloneGit "${name}" "${value.locked.url}" "${value.locked.ref or ""}" "${value.locked.rev}"
                  fi
                ''
              else if type == "github"
              then ''
                if checkMissing "${name}"; then
                  cloneGitHub "${name}" "${value.locked.owner}" "${value.locked.repo}" "${value.original.ref or ""}" "${value.locked.rev}"
                fi
              ''
              else ''warn "not cloning input '${name}', unsupported type '${type}'"'');
        in ''
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
              options+=(--branch "''${wantedRef#refs/heads/}")
            fi

            info "cloning '$name'"

            if ! git clone "''${options[@]}" -- "$url" "$name"; then
              error "clone of input '$name' failed"
              return 1
            fi

            local actualRev
            actualRev="$(git -C "$name" rev-parse HEAD)"

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
        category = "epnix commands";
        description = "Check and clone subprojects";
      };

      enix-local = {
        text = let
          findLocals =
            forEach inputApps
            ({
              name,
              value,
            }: ''
              if [ -e "${name}" ]; then
                info "using local app:" "'${name}'"
                overrides+=(--override-input "${name}" "git+file:./${name}")
              else
                info "app '${name}' is not present locally" "using the one specified in flake inputs"
              fi
            '');
        in ''
          typeset -a overrides=()

          ${concatStringsSep "\n" findLocals}

          nix "$@" "''${overrides[@]}"
        '';
        category = "epnix commands";
        description = "Like 'nix' but uses the locally cloned subprojects";
      };
    };

    environment.variables."GRC_ALIASES" = "true";

    attrs =
      {
        inputsFrom = [config.epnix.outputs.build];

        nativeBuildInputs =
          (map (cmd: cmd.package) cfg.packages)
          ++ scriptPackages
          ++ config.epnix.outputs.build.depsBuildBuild;

        inherit (config.epnix.outputs.build) local_config_site local_release;

        shellHook = ''
          function load_profiles() {
            # Don't return the glob itself, if no matches
            shopt -s nullglob

            for input in $nativeBuildInputs; do
              for file in "$input/etc/profile.d/"*sh; do
                source "$file"
              done
            done
          }

          load_profiles

          ${concatMapStringsSep "\n"
            (var: "unset ${var}")
            (attrNames
              (filterAttrs (_: isNull) cfg.environment.variables))}

          if [[ "$-" == *i* ]]; then
            menu
          fi

          check-config
        '';
      }
      // cfg.environment.variables;
  };

  config.epnix.outputs.devShell = pkgs.mkShell cfg.attrs;
}
