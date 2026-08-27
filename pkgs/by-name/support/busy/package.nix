{
  epnixLib,
  mkEpicsPackage,
  fetchFromGitHub,
  fetchpatch2,
  asyn,
  autosave,
  calc,
}:
mkEpicsPackage (finalAttrs: {
  pname = "busy";
  version = "1-7-4";
  varname = "BUSY";

  src = fetchFromGitHub {
    owner = "epics-modules";
    repo = "busy";
    tag = "R${finalAttrs.version}";
    hash = "sha256-mSzFLj42iXkyWGWaxplfLehoQcULLpf745trYMd1XT4=";
  };

  patches = [
    ./fix-release.patch
    (fetchpatch2 {
      name = "used-typed_dset-and-rset.patch";
      url = "https://patch-diff.githubusercontent.com/raw/epics-modules/busy/pull/17.patch?full_index=1";
      hash = "sha256-EbZ6TixBN1Z+Yqu7LpatolPzONPbRDvrGxLabMakpqE=";
    })
  ];

  buildInputs = [
    calc
    asyn
    autosave
  ];

  meta = {
    description = "APS BCDA synApps module: busy";
    homepage = "https://epics-modules.github.io/busy/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ agaget ];
  };
})
