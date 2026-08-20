let
  toBranch = version: if version == "dev" then "master" else version;

  self = {
    current = "nixos-26.05";
    stable = "nixos-26.05";
    all = [
      "dev"
      "nixos-26.05"
      "nixos-25.11"
      "nixos-25.05"
      "nixos-24.11"
      "nixos-24.05"
    ];
    current-branch = toBranch self.current;
    all-branches = map toBranch self.all;
    supported-branches = [
      "master"
      self.stable
    ];
  };
in
self
