{
  treefmt,
  clang-tools,
  nixfmt-rfc-style,
  ruff,
  shfmt,
  taplo,
}:
treefmt.withConfig {
  name = "treefmt-for-epnix";
  settings = {
    tree-root-file = ".git/index";

    excludes = [ "docs/_vale" ];

    formatter = {
      clang-format = {
        command = "clang-format";
        options = [
          "-i"
          "--"
        ];
        includes = [
          "*.c"
          "*.cpp"
          "*.h"
          "*.hpp"
        ];
      };

      nixfmt = {
        command = "nixfmt";
        options = [ "--" ];
        includes = [ "*.nix" ];
      };

      ruff = {
        command = "ruff";
        options = [
          "format"
          "--"
        ];
        includes = [ "*.py" ];
      };

      shfmt = {
        command = "shfmt";
        options = [
          "--write"
          "--simplify"
          "--"
        ];
        includes = [ "*.sh" ];
      };

      taplo = {
        command = "taplo";
        options = [
          "format"
          "--"
        ];
        includes = [ "*.toml" ];
      };
    };
  };
  runtimeInputs = [
    clang-tools
    nixfmt-rfc-style
    ruff
    shfmt
    taplo
  ];
}
