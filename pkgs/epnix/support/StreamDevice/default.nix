{ lib
, epnixLib
, mkEpicsPackage
, fetchFromGitHub
, epnix
, pcre
, local_config_site ? { }
, local_release ? { }
}:

let
  version = "2.8.20";
in
mkEpicsPackage {
  pname = "StreamDevice";
  inherit version;
  # TODO: is this correct?
  varname = "STREAM";

  inherit local_config_site;
  local_release = local_release // {
    PCRE = null;
    PCRE_INCLUDE = "${pcre.dev}/include";
    PCRE_LIB = "${pcre}/lib";

    # Removes warning about unused SUPPORT variable
    STREAM = null;
  };

  buildInputs = [ pcre ] ++ (with epnix.support; [ sscan ]);
  propagatedBuildInputs = with epnix.support; [ asyn calc ];

  patches = [ ./printf-only-string-literal.patch ];

  src = fetchFromGitHub {
    owner = "paulscherrerinstitute";
    repo = "StreamDevice";
    rev = version;
    sha256 = "sha256-D4/jTn+LI12nRNV3Sun3Y/UP79nbERzEAp80D2/eUNQ=";
  };

  meta = {
    description = "A generic EPICS device support for devices with a \"byte stream\" based communication interface";
    homepage = "https://paulscherrerinstitute.github.io/StreamDevice/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
}
