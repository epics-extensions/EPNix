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
  version = "2.8.24";
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
        PCRE_INCLUDE = "${lib.getDev pcre}/include";
        PCRE_LIB = "${lib.getLib pcre}/lib";

        # Removes warning about unused SUPPORT variable
        STREAM = null;
      };

    nativeBuildInputs = [pcre];
    buildInputs = [pcre] ++ (with epnix.support; [sscan]);
    propagatedBuildInputs = with epnix.support; [asyn calc];

    src = fetchFromGitHub {
      owner = "paulscherrerinstitute";
      repo = "StreamDevice";
      rev = version;
      # Tarball from GitHub is not completely reproducible due to usage of
      # export-subst in .gitattributes for .VERSION
      # See: https://epics.anl.gov/tech-talk/2022/msg01842.php
      forceFetchGit = true;
      hash = "sha256-2MJ6CSNFc5rKijx5TFwwXStzj6zypS4cpMrcSuW4+F0=";
    };

    meta = {
      description = "A generic EPICS device support for devices with a \"byte stream\" based communication interface";
      homepage = "https://paulscherrerinstitute.github.io/StreamDevice/";
      license = lib.licenses.lgpl3Plus;
      maintainers = with epnixLib.maintainers; [minijackson];
    };
  }
