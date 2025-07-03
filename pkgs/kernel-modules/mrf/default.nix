{
  stdenv,
  kernel,
  epnix,
  fetchpatch,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mrf-driver";

  inherit (epnix.support.mrfioc2) version src;

  # Needed for kernel modules
  hardeningDisable = [
    "format"
    "pic"
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  enableParallelBuilding = true;

  setSourceRoot = ''
    export sourceRoot="$(pwd)/${finalAttrs.src.name}/mrmShared/linux";
  '';

  makeFlags = kernel.makeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "KERNELRELEASE=${kernel.modDirVersion}"
    "INSTALL_MOD_PATH=$(out)"
    "VERSION=${finalAttrs.version}"
    "M=$(sourceRoot)"
    # Uncomment this line to enable debugging
    # "KCFLAGS=-DDBG"
  ];

  buildFlags = [ "modules" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "MRF kernel driver";
    inherit (epnix.support.mrfioc2.meta) homepage license maintainers;
  };
})
