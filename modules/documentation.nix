{ config, lib, options, pkgs, ... }:

with lib;

let
  visibleOptionDocs = filter (opt: opt.visible && !opt.internal) (optionAttrSetToDocList options);

  toValue = value:
    if value ? _type && value._type == "literalExample" then value.text
    else generators.toPretty { } value;

  toMarkdown = option:
    ''
      ## `${option.name}`

      ${option.description}

      ${optionalString (option ? default) ''
        **Default value**:

        ```nix
        ${toValue option.default}
        ```
      ''}

      **Type**: ${option.type}${optionalString option.readOnly " (read only)"}

      ${optionalString (option ? example) ''
        **Example**:

        ```nix
        ${toValue option.example}
        ```
      ''}

      Declared in:

      ${concatStringsSep "\n" (map (decl: "- ${decl}") option.declarations)}

    '';

  options-md = concatStringsSep "\n" (map toMarkdown visibleOptionDocs);
in
{
  config.epnix.outputs = {
    doc-options-md = pkgs.writeText "options.md" options-md;
    manpage = pkgs.runCommand "epnix-configuration.nix.5"
      {
        src = pkgs.writeText "epnix-configuration.nix.5.md" ''
          % EPNIX-CONFIGURATION.NIX(5)

          # NAME

          epnix-configuration.nix - EPNix configuration options

          # DESCRIPTION

          TODO

          # OPTIONS

          You can use the following options:

          ${options-md}
        '';

        nativeBuildInputs = [ pkgs.pandoc ];
      } ''
      pandoc "$src" --from=markdown --to=man --standalone --output="$out"
    '';
  };
}
