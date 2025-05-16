{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  pkg-config,
  systemdMinimal,
}:
mkEpicsPackage {
  pname = "epics-systemd";
  version = "2022-02-09";
  varname = "EPICS_SYSTEMD";

  nativeBuildInputs = [pkg-config];
  buildInputs = [systemdMinimal];

  src = fetchFromGitHub {
    owner = "minijackson";
    repo = "epics-systemd";
    rev = "31619a1a3e620c3d2ff11b6bb2092be752b31026";
    hash = "sha256-uDtbrKWwd38IIBBEYXUCDuarAfeqh4QCu6JJ6z4qrqc=";
  };

  meta = {
    description = "Systemd-related facilities for EPICS IOCs";
    homepage = "https://github.com/minijackson/epics-systemd";
    license = lib.licenses.mit;
    maintainers = with epnixLib.maintainers; [minijackson];
  };
}
