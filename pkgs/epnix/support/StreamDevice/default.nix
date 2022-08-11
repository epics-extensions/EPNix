{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  epnix,
  pcre,
  local_config_site ? {},
  local_release ? {},
}: let
  version = "2.8.22";
in
  mkEpicsPackage {
    pname = "StreamDevice";
    inherit version;
    varname = "STREAM";

    inherit local_config_site;
    local_release =
      local_release
      // {
        PCRE = null;
        PCRE_INCLUDE = "${pcre.dev}/include";
        PCRE_LIB = "${pcre}/lib";

        # Removes warning about unused SUPPORT variable
        STREAM = null;
      };

    buildInputs = [pcre] ++ (with epnix.support; [sscan]);
    propagatedBuildInputs = with epnix.support; [asyn calc];

    patches = [./printf-only-string-literal.patch];

    src = fetchFromGitHub {
      owner = "paulscherrerinstitute";
      repo = "StreamDevice";
      rev = version;
      hash = "sha256-guGzwcf/wZdX7lKLXaQvQpVt3GUtdi193qUnc5v8vz8=";
    };

    meta = {
      description = "A generic EPICS device support for devices with a \"byte stream\" based communication interface";
      homepage = "https://paulscherrerinstitute.github.io/StreamDevice/";
      license = lib.licenses.lgpl3Plus;
      maintainers = with epnixLib.maintainers; [minijackson];
    };
  }
