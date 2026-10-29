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
    (fetchpatch2 {
      name = "in-recent-asyn-versions-vxi11-is-optional.patch";
      url = "https://github.com/paulscherrerinstitute/StreamDevice/commit/e87e093c846ca19383462036d2f85ca5369b17b3.patch?full_index=1";
      hash = "sha256-kwxIfKfAQtdmV5Y6uYsS+P4OFWf4q4Uez0qvK/7NApA=";
    })
    (fetchpatch2 {
      name = "fix-wrong-non-tab-indent-in-makefile.patch";
      url = "https://github.com/paulscherrerinstitute/StreamDevice/commit/f473f4d6deeb2e956258b3f1b9858f8607c96591.patch?full_index=1";
      hash = "sha256-Wt5MCu6qW3/pfXbffsuzx8/v74pwLzkkcvsVw/sk8lc=";
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
