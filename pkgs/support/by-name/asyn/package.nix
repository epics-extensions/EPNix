{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch2,
  pkg-config,
  rpcsvc-proto,
  libtirpc,
  ipac,
  seq,
}:
mkEpicsPackage (finalAttrs: {
  pname = "asyn";
  version = "4-45";
  varname = "ASYN";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "asyn";
    tag = "R${finalAttrs.version}";
    hash = "sha256-VOHgDuRSj3dUmCWX+nyCf/i+VNGpC0ZsyIP0qBUG0vw=";
  };

  patches = [
    ./use-pkg-config.patch
    (fetchpatch2 {
      name = "fix-number-of-devsupfun-entries.patch";
      url = "https://github.com/epics-modules/asyn/commit/b0340d83a903095f3a89163f90b2a48690d5021d.patch?full_index=1";
      hash = "sha256-jRBj+7mWkhV8ma2p+FvwTvM+zmdSUuJ7sTgfGGiBJhI=";
    })
    (fetchpatch2 {
      name = "explicitly-cast-function-pointers.patch";
      url = "https://github.com/epics-modules/asyn/commit/8f3c8f651d12651908c845370431943ec4ef6d5c.patch?full_index=1";
      hash = "sha256-34tyVhvvmmMhZ9UP9K/aexWla5Ni4bB7ozDINQUrKv8=";
    })
  ];

  local_config_site = {
    TIRPC = "YES";
  };

  depsBuildBuild = [ pkg-config ];
  nativeBuildInputs = [
    pkg-config
    rpcsvc-proto
    libtirpc
  ];
  buildInputs = [
    libtirpc
  ];

  propagatedBuildInputs = [
    ipac
    seq
  ];

  meta = {
    description = "EPICS module for driver and device support";
    homepage = "https://epics-modules.github.io/asyn/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
