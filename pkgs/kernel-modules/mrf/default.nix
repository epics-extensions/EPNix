{
  stdenv,
  kernel,
  kernelModuleMakeFlags,
  epnix,
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

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=$(out)"
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
