{
  stdenv,
  kernel,
  epnix,
  fetchpatch,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mrf-driver";

  inherit (epnix.support.mrfioc2) version src;

  patches = [
    (fetchpatch {
      name = "use-vm_flags_set-on-kernels-6-3.patch";
      url = "https://github.com/epics-modules/mrfioc2/commit/64634a23a035d336de5d720b2e1ecafcc918d737.patch";
      hash = "sha256-6/obmLfLKfhcwn12O0KKpogWCzg7Evs1kIoNm0x7Puw=";
      stripLen = 2;
    })
  ];

  # Needed for kernel modules
  hardeningDisable = ["format" "pic"];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  enableParallelBuilding = true;

  setSourceRoot = ''
    export sourceRoot="$(pwd)/${finalAttrs.src.name}/mrmShared/linux";
  '';

  makeFlags =
    kernel.makeFlags
    ++ [
      "-C"
      "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "KERNELRELEASE=${kernel.modDirVersion}"
      "INSTALL_MOD_PATH=$(out)"
      "VERSION=${finalAttrs.version}"
      "M=$(sourceRoot)"
      # Uncomment this line to enable debugging
      # "KCFLAGS=-DDBG"
    ];

  buildFlags = ["modules"];
  installTargets = ["modules_install"];

  meta = {
    description = "MRF kernel driver";
    inherit (epnix.support.mrfioc2.meta) homepage license maintainers;
  };
})
