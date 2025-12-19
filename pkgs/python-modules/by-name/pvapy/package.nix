{
  lib,
  stdenv,
  toPythonModule,
  mkEpicsPackage,
  fetchFromGitHub,
  replaceVars,
  autoconf,
  automake,
  which,
  python,
  pypaBuildHook,
  pypaInstallHook,
  pythonImportsCheckHook,
  pythonOutputDistHook,
  pythonRecompileBytecodeHook,
  sphinxHook,
  wrapPython,
  sphinx-rtd-theme,
  boost,
  numpy,
  distutils,
  setuptools,
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

  outputs = [
    "out"
    "dist"
  ];

  src = fetchFromGitHub {
    owner = "epics-base";
    repo = "pvaPy";
    tag = version;
    hash = "sha256-YbL3nkqTkzJ2fTfiESXE/NWT1OJeDPrMBNTKFiamAi4=";
  };

  patches = [
    # Upstream's `setup.py` tries to build everything build itself,
    # including downloading dependencies.
    # Here we compile things ourselves using the EPICS build facility,
    # then install the Python parts using the `pypa` hooks.
    ./dont-build-with-setup-py.patch

    (replaceVars ./replace-versions.patch { inherit version; })
  ];

  nativeBuildInputs = [
    autoconf
    automake
    which

    python
    distutils
    setuptools
    sphinx-rtd-theme

    pypaBuildHook
    pypaInstallHook
    pythonImportsCheckHook
    pythonOutputDistHook
    pythonRecompileBytecodeHook
    sphinxHook
    wrapPython
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

  # We still need to use the "standard" EPICS build,
  # so we have to let the default `mkEpicsPackage` build phase run.
  dontUsePypaBuild = true;

  # Some of these instructions are inspired
  # by what's in `tools/pip/pvapy-pip/build.linux.sh`
  postBuild = ''
    # `pvaPy` installs the `pvaccess` library into $out/lib/python/VERSION/ARCH/*
    # instead of the dir read by Python before installing
    cp -a $out/lib/python/*/*/* tools/build/pvaccess

    # Make the Python dirs visible to the `pypa` build phase
    cp -r tools/build/pvaccess pvapy tools/pip/pvapy-pip

    pushd tools/pip/pvapy-pip
    export PVAPY_VERSION=${version}
    # Temporarily unset postBuild to avoid an infinite loop
    postBuild=":" pypaBuildPhase
    popd

    # Copy the dist folder to the source root,
    # so that the `pypa` install hook can find it.
    cp -r tools/pip/pvapy-pip/dist .
  '';

  postInstall = ''
    # Remove the `pvaccess.so` manually installed by the EPICS build system
    # it was already copied to the Python package.
    rm -rf $out/lib/python
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

  postFixup = ''
    wrapPythonPrograms
  '';

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
