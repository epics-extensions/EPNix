let
  self = {
    current = "dev";
    stable = "nixos-25.05";
    all = [
      "dev"
      "nixos-25.05"
      "nixos-24.11"
      "nixos-24.05"
      "nixos-23.11"
      "nixos-23.05"
    ];
    all-branches = map (version: if version == "dev" then "master" else version) self.all;
    supported-branches = [
      "master"
      self.stable
    ];
  };
in
self
