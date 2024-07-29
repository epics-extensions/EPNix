{
  inputs,
  lib,
  ...
}:
lib.fix (self: let
  rev = inputs.self.sourceInfo.rev or "master";

  # Quote an option if it contains a "." in it
  maybeQuote = el:
    if lib.hasInfix "." el
    then ''"${el}"''
    else el;

  optionName = loc: lib.concatStringsSep "." (map maybeQuote loc);

  isLiteral = value:
    value
    ? _type
    && ((value._type == "literalExpression")
      || (value._type == "literalExample")
      || (value._type == "literalMD"));
in {
  # Get the value of a default value / example, whether it was wrapped in
  # `lib.literalExample` / `lib.literalMD` or not.
  toValue = value:
    if isLiteral value
    then value.text
    else lib.generators.toPretty {} value;

  # Get the text of a description, whether it was wrapped with `lib.mdDoc` or
  # not.
  toText = value:
    if value ? _type
    then value.text
    else value;

  # For text inside Pandoc's Markdown definition lists.
  #
  # Usage:
  #
  # ''
  # Definition
  # : ${inDefList "text spanning multiple lines"}
  # ''
  inDefList = str: let
    lines = lib.splitString "\n" str;
    firstLine = "${lib.head lines}";
    otherLines = map (line: "  ${line}") (lib.drop 1 lines);
  in
    lib.concatStringsSep "\n" ([firstLine] ++ otherLines);

  # Takes an absolute path, returns a source:// markdown link
  sourceLink = path: let
    relativePath = lib.pipe path [
      (lib.splitString "/")
      (lib.sublist 4 255)
      (lib.concatStringsSep "/")
    ];
  in "[${relativePath}](source://${rev}/${relativePath})";

  fromOption = headingLevel: option: let
    header = lib.fixedWidthString headingLevel "#" "";
  in ''
    (opt-${optionName option.loc})=
    ${header} `${optionName option.loc}`

    ${self.toText option.description}

    ${lib.optionalString (option ? default) ''
      Default value
      : ${self.inDefList ''
        ```nix
        ${self.toValue option.default}
        ```
      ''}
    ''}

    Type
    : ${option.type}${lib.optionalString option.readOnly " (read only)"}

    ${lib.optionalString (option ? example) ''
      Example
      : ${self.inDefList ''
        ```nix
        ${self.toValue option.example}
        ```
      ''}
    ''}

    Declared in
    : ${self.inDefList (lib.concatStringsSep "\n" (map self.sourceLink option.declarations))}

  '';
})
