{lib, ...}:
with lib; {
  options.epnix.meta = {
    name = mkOption {
      description = "Name of this EPICS distribution";
      type = types.str;
    };

    version = mkOption {
      description = "Version of this EPICS distribution";
      type = types.str;
      default = "0.0.1";
    };
  };
}
