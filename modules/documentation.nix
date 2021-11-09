{ ... }:

{
  config.epnix.doc = {
    manpage = {
      name = "epnix-configuration.nix";
      shortDescription = "EPNix configuration options";
      description = ''
        TODO
      '';
    };
    mdbook.src = ../doc;
  };
}
