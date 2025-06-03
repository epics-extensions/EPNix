{
  makeSetupHook,
  epnixLib,
  jdk21_headless,
}:
makeSetupHook {
  name = "phoebus-setup-hook";
  substitutions = {
    jdk = jdk21_headless;
  };

  meta = {
    description = "Common Bash functions for building components of the Phoebus project";
    maintainers = with epnixLib.maintainers; [minijackson];
    hidden = true;
    inherit (jdk21_headless.meta) platforms;
  };
}
./setup-hook.sh
