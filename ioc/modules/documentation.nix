{
  lib,
  pkgs,
  ...
}: {
  config.epnix.outputs = {
    mdbook =
      lib.warn
      "the mdbook output is deprecated, please use `pkgs.epnix.book` instead"
      pkgs.epnix.book;
    manpage =
      lib.warn
      "the manpage output is deprecated, please use `pkgs.epnix.manpages` instead"
      pkgs.epnix.manpages;
  };
}
