{
  lib,
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch2,
  asyn,
  calc,
  pcre,
  sscan,
}:
mkEpicsPackage (finalAttrs: {
  pname = "StreamDevice";
  version = "2.8.26";
  varname = "STREAM";

  src = fetchFromGitHub {
    owner = "paulscherrerinstitute";
    repo = "StreamDevice";
    tag = finalAttrs.version;
    # Tarball from GitHub is not completely reproducible due to usage of
    # export-subst in .gitattributes for .VERSION
    # See: https://epics.anl.gov/tech-talk/2022/msg01842.php
    forceFetchGit = true;
    hash = "sha256-/OgjdHvFr6sBRhOLa9F3KJeaxMiKuUuBduHUc4YLYBI=";
  };

  patches = [
    (fetchpatch2 {
      name = "gcc-15-compatibility.patch";
      url = "https://github.com/paulscherrerinstitute/StreamDevice/commit/929204cb13f122e2ff3beb64ab86d8bdb6a21d70.patch?full_index=1";
      hash = "sha256-X9b/EicpzMXGMhSvgMrUjTvB7QW1lXJvc/zzlZPdYho=";
    })
  ];

  nativeBuildInputs = [ pcre ];
  buildInputs = [
    pcre
    sscan
  ];
  propagatedBuildInputs = [
    asyn
    calc
  ];

  local_release = {
    PCRE = null;
    PCRE_INCLUDE = "${lib.getDev pcre}/include";
    PCRE_LIB = "${lib.getLib pcre}/lib";

    # Removes warning about unused SUPPORT variable
    STREAM = null;
  };

  meta = {
    description = "A generic EPICS device support for devices with a \"byte stream\" based communication interface";
    homepage = "https://paulscherrerinstitute.github.io/StreamDevice/";
    license = lib.licenses.lgpl3Plus;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
