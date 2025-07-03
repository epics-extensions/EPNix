{
  makeSetupHook,
  stdenv,
  epnixLib,
}:
makeSetupHook {
  name = "epics-setup-hook";

  substitutions = {
    # Note that since the setup hook is going into 'nativeBuildInputs',
    # the platforms are "shifted",
    # which means from the point of view of the setup hook,
    # the host platform is the end package's build platform,
    # and the target platform is the end package's host platform.

    # "build" as in Nix terminology (the build machine)
    build_arch = epnixLib.toEpicsArch stdenv.hostPlatform;
    # "host" as in Nix terminology (the machine which will run the generated code)
    host_arch = epnixLib.toEpicsArch stdenv.targetPlatform;
  };

  meta = {
    description = "Instructions for building EPICS tops";
    maintainers = with epnixLib.maintainers; [ minijackson ];
    hidden = true;
  };
} ./epics-setup-hook.sh
