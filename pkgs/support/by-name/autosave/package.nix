{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage (finalAttrs: {
  pname = "autosave";
  version = "5-11";
  varname = "AUTOSAVE";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "autosave";
    tag = "R${finalAttrs.version}";
    hash = "sha256-T6b2SUxgh2l+F4Vi3oF1aaLIjghlg34tLlwJOgGceLQ=";
  };

  meta = {
    description = "Module that automatically saves values of EPICS PVs to files, and restores those values when the IOC is restarted.";
    inherit (finalAttrs.src.meta) homepage;
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ stephane ];
  };
})
