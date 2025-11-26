{
  lib,
  stdenv,
  toPythonModule,
  mkEpicsPackage,
  fetchFromGitHub,
  autoconf,
  automake,
  which,
  python,
  pythonImportsCheckHook,
  pythonRecompileBytecodeHook,
  sphinxHook,
  sphinx-rtd-theme,
  boost,
  numpy,
  distutils,
  pillow,
  h5py,
  hdf5plugin,
  pycryptodome,
  rsa,
  blosc,
  lz4,
  bitshuffle,
  epnix,
  epnixLib,
}:

let
  boost' = boost.override {
    enablePython = true;
    inherit python;
    enableNumpy = true;
  };
in
toPythonModule (mkEpicsPackage rec {
  pname = "pvapy";
  version = "5.6.0";
  varname = "PVAPY";

  src = fetchFromGitHub {
    owner = "epics-base";
    repo = "pvaPy";
    rev = version;
    hash = "sha256-YbL3nkqTkzJ2fTfiESXE/NWT1OJeDPrMBNTKFiamAi4=";
  };

  nativeBuildInputs = [
    autoconf
    automake
    which

    python
    distutils
    sphinx-rtd-theme

    pythonImportsCheckHook
    pythonRecompileBytecodeHook
    sphinxHook
  ];

  buildInputs = [
    boost'
    python
  ]
  # Needed for building the Sphinx documentation
  ++ passthru.optional-dependencies.all;

  propagatedBuildInputs = [
    numpy
  ];

  postConfigure = ''
    make configure \
      BOOST_INCLUDE_DIR=${lib.getDev boost'}/include \
      BOOST_DIR=${boost'} \
      BOOST_LIB_DIR=${boost'}/lib \
      BOOST_PYTHON_NUMPY_DIR=${boost'}/lib \
      BOOST_NUMPY_DIR=${boost'}/lib \
      EPICS_BASE=${epnix.epics-base} \
      EPICS_HOST_ARCH=${epnixLib.toEpicsArch stdenv.buildPlatform}
  '';

  postInstall = ''
    # `pvaPy` installs the `pvaccess` library into $out/lib/python/VERSION/ARCH/*
    # instead of the standard location
    mkdir -p $out/${python.sitePackages}
    cp -r tools/build/pvaccess $out/${python.sitePackages}
    mv $out/lib/python/*/*/* $out/${python.sitePackages}/pvaccess

    # manually install the `pvapy` module,
    # because I can't be bothered to figure out how to use
    # upstream's `tools/pip/pvapy-pip/setup.py`
    #
    # TODO: this means that the current EPNix package
    # doesn't have any of the defined `entry_points`.
    cp -r pvapy $out/${python.sitePackages}

    pushd $out/lib
    rmdir -p python/*/*
    popd
  '';

  sphinxRoot = "documentation/sphinx";
  postInstallSphinx = ''
    pushd documentation
    cp -r *.md images presentations $out/share/doc/*/
    popd
    cp LICENSE $out/share/doc/*/
  '';

  pythonImportsCheck = [
    "pvaccess"
    "pvapy"
  ];

  passthru.optional-dependencies = {
    image-processing = [
      pillow
      h5py
      hdf5plugin
    ];
    encryption = [
      pycryptodome
      rsa
    ];
    blosc-compression = [ blosc ];
    lz4-compression = [ lz4 ];
    bslz4-compression = [ bitshuffle ];
    all = [
      pillow
      h5py
      hdf5plugin
      pycryptodome
      rsa
      blosc
      lz4
      bitshuffle
    ];
  };

  meta = {
    description = "PvaPy provides Python bindings for EPICS pvAccess";
    homepage = "https://github.com/epics-base/pvaPy/";
    license = epnixLib.licenses.epics;
    maintainers = with epnixLib.maintainers; [ minijackson ];
    mainProgram = "pvapy";
    platforms = lib.platforms.all;
  };
})
