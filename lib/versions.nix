let
  self = {
    current = "dev";
    stable = "nixos-24.11";
    all = [
      "dev"
      "nixos-24.11"
      "nixos-24.05"
      "nixos-23.11"
      "nixos-23.05"
    ];
    all-branches = map (version:
      if version == "dev"
      then "master"
      else version)
    self.all;
  };
in
  self
