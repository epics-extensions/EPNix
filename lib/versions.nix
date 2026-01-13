let
  self = {
    current = "nixos-25.11";
    stable = "nixos-25.11";
    all = [
      "dev"
      "nixos-25.11"
      "nixos-25.05"
      "nixos-24.11"
      "nixos-24.05"
    ];
    all-branches = map (version: if version == "dev" then "master" else version) self.all;
    supported-branches = [
      "master"
      self.stable
    ];
  };
in
self
