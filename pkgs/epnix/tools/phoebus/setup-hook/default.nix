{
  makeSetupHook,
  epnixLib,
  jdk,
}:
makeSetupHook {
  name = "phoebus-setup-hook";
  substitutions = {
    inherit jdk;
  };

  meta = {
    description = "Common Bash functions for building components of the Phoebus project";
    maintainers = with epnixLib.maintainers; [minijackson];
    hidden = true;
  };
}
./setup-hook.sh
