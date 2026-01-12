args:
let
  self = {
    markdown = import ./documentation/markdown.nix args;
    options = import ./documentation/options.nix args;
  };
in
self
