{
  lewis,
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
      runtimeInputs = [lewis];
      text = ''
        lewis -a "${source}" -k "${package}" "${device}" "$@"
      '';
    };
}
