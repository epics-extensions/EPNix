{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  libevent,
  local_config_site ? { },
  local_release ? { },
}:
mkEpicsPackage rec {
  pname = "pvxs";
  version = "1.3.1";
  varname = "PVXS";

  inherit local_config_site local_release;

  src = fetchFromGitHub {
    owner = "mdavidsaver";
    repo = "pvxs";
    rev = version;
    sha256 = "sha256-V/38TdjuBuhZE7bsvtLfQ3QH7bmwNdKHpvVeA81oOXY=";
  };

  # TODO: check pvxs cross-compilation,
  # since it has a somewhat complex logic for finding libevent
  propagatedNativeBuildInputs = [ libevent ];
  propagatedBuildInputs = [ libevent ];

  # Only loopback interface is present
  doCheck = false;

  meta = {
    description = "PVA protocol client/server library and utilities";
    homepage = "https://mdavidsaver.github.io/pvxs/";
    license = lib.licenses.bsd3;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
