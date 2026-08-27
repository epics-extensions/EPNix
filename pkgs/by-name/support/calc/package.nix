{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch2,
  sscan,
}:
mkEpicsPackage (finalAttrs: {
  pname = "calc";
  version = "3-7-5";
  varname = "CALC";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "calc";
    tag = "R${finalAttrs.version}";
    sha256 = "sha256-S40HtO7HXDS27u7wmlxuo7oV1abtj1EaXfIz0Kj1IM0=";
  };

  patches = [
    (fetchpatch2 {
      name = "fix-build-errors-with-std-c23.patch";
      url = "https://github.com/epics-modules/calc/commit/2da37a62f2b64e904294c2257874f0a8defa19ca.patch?full_index=1";
      hash = "sha256-ZoWXGqa7GrTYs+nWIU8wyXAxo/X0QwR5o6pxB3+XGTM=";
    })
  ];

  propagatedBuildInputs = [ sscan ];

  meta = {
    description = "Support for run-time expression evaluation";
    homepage = "https://epics-modules.github.io/calc/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
