{
  lib,
  epnix,
  writeShellApplication,
}: {
  mkLewisSimulator = {
    name,
    device ? name,
    package,
    source,
  }:
    writeShellApplication {
      inherit name;
      runtimeInputs = [epnix.lewis];
      text = ''
        lewis -a "${source}" -k "${package}" "${device}" "$@"
      '';
    };
}
