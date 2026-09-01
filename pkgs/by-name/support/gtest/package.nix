{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch2,
}:
mkEpicsPackage (finalAttrs: {
  pname = "gtest";
  version = "1.0.1";
  varname = "GTEST";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "gtest";
    rev = "v${finalAttrs.version}";
    hash = "sha256-cDZ4++AkUiOvsw4KkobyqKWLk2GzUSdDdWjLL7dr1ac=";
  };

  patches = [
    (fetchpatch2 {
      name = "fix-compile-error-with-newer-gcc.patch";
      url = "https://github.com/epics-modules/gtest/commit/fb7e1f4053081e9f523ae671a801ce4c5565dc66.patch?full_index=1";
      hash = "sha256-2QO5Oif1TODC1XOpxN4tfza2n8chq9sBlu4jHFs2RD0=";
    })
  ];

  meta = {
    description = "EPICS module to adds the Google Test and Google Mock frameworks to EPICS";
    inherit (finalAttrs.src.meta) homepage;
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
  };
})
