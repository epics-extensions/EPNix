{
  lewis,
  writeShellApplication,
}:
{
  mkSimulator =
    {
      name,
      device ? name,
      package,
      source,
      derivationArgs ? { },
      meta ? { },
      passthru ? { },
    }:
    writeShellApplication {
      inherit
        name
        derivationArgs
        meta
        passthru
        ;
      runtimeInputs = [ lewis ];
      text = ''
        lewis -a "${source}" -k "${package}" "${device}" "$@"
      '';
    };
}
